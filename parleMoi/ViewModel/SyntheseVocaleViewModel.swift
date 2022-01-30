//
//  SyntheseVocaleViewModel.swift
//  parleMoi
//
//  Created by Philippe MICHEL on 30/01/2022.
//

import AVFAudio
import AVFoundation

class SyntheseVocaleViewModel:NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    var speechSynthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
    // variable de partage du canal audio
    var audioSession = AVAudioSession.sharedInstance()
    
    
    // vitesse de lecture
    var rate:Float = AVSpeechUtteranceDefaultSpeechRate
    
    var volume:Float = 0.5
    
    // configuration type de langue
    var voice = AVSpeechSynthesisVoice(identifier: Locale.current.identifier)
    
    // variable etat de la lecture
    @Published var lectureEnCours:Bool = false
    
    override init() {
        super.init()
        self.speechSynthesizer.delegate = self
        
    }
    // volume Audio
    func volumeAudio(niveauVolume:CGFloat) {
        volume = Float(niveauVolume)
    }
    
    // definir la vitesse de lecture
    func rythmeLecture(vitesseLecture:CGFloat) {
        rate = Float(vitesseLecture)
    }

    // lecture du texte
    func demarrerLecture(texte:String) {
        // gestion du mode lecture
        // gestion de partage du canal de son entre plusieurs application.
        do {
            // configuration du type de flux audio
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .defaultToSpeaker)
            // demande l'utilisattion  du canal audio
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            // utterance (contient le texte à lire.
            let utterance = AVSpeechUtterance(string: texte)
            utterance.voice = voice
            //utterance.volume = volume
            utterance.rate = rate
            speechSynthesizer.speak(utterance)
            
            
        } catch let error as NSError {
            print("type erreur \(error.localizedDescription)")
        }
    }
    
    // arrete la lecture
    func arretLecture() {
        // arret de la lecture après le dernier mot en cours
        speechSynthesizer.stopSpeaking(at: .word)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("Début de lecture")
        self.lectureEnCours = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // non utilisé pour l'exemple
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        // non utilisé pour l'exemple
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // non utilisé pour l'exemple
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        // non utilisé pour l'exemple
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        do {
            // rend le flux audio disponible pour les autre application
            try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("Terminer fin de lecture.")
            self.lectureEnCours = false
            
        } catch let error as NSError {
            print("type erreur \(error.localizedDescription)")
        }
    }
}

