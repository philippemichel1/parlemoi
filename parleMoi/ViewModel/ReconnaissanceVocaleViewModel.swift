//
//  ReconnaissanceVocaleViewModel.swift
//  parleMoi
//
//  Created by Philippe MICHEL on 30/01/2022.
//

import Speech
import AVFoundation

extension Notification.Name {
    static let tacheDeRetrabscription = Notification.Name("ajoutTacheNotification")
}

class ReconnaissanceVocaleViewModel:NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    // création du manageur + configuration de la langue
    //var speechRecognizer:SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    // création du manageur + configuration de la langue
    var speechRecognizer:SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: Locale.current.identifier))
    // Gestion du partage voix
    let audioSession = AVAudioSession.sharedInstance()
    // moteur
    let engine = AVAudioEngine()
    // requete
    var request: SFSpeechAudioBufferRecognitionRequest?
    // tache de transcription de la voix en texte
    var task: SFSpeechRecognitionTask?
    
    
    @Published var enregistrementEnCours:Bool = false
    var transformerVoixText:String?
    @Published var boutonUtilisationMicro:Bool = false
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        
        // autorisation utilisation micro
        SFSpeechRecognizer.requestAuthorization { (autorisationMicro) in
            OperationQueue.main.addOperation { [self] in
                switch autorisationMicro {
                case .authorized:
                    print("permission accordé")
                    boutonUtilisationMicro = true
                case .notDetermined:
                    print("aucune réponse")
                case .denied:
                    print("aucune permission accordé")
                    boutonUtilisationMicro = false
                case .restricted:
                    print("seulement si l'application est active")
                    boutonUtilisationMicro = true
                default:
                    print("réponse par défault")
                }
            }
        }
    }
    // demarre la transcription de la voix en texte
    func demarrerTranscriptionVoix() {
        //supprime les transcription precédentes
        enregistrementEnCours = true
        if task != nil {
            task?.cancel()
            task = nil
        }
        
        //Préparer l'enregistrement
        // Le nœud audio pour l'entrée singleton du moteur audio. (doc apple)
        let node = engine.inputNode
        
        //configuration de la session
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .mixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            request = SFSpeechAudioBufferRecognitionRequest()
            guard request != nil else { return }
            task = speechRecognizer?.recognitionTask(with: request!, resultHandler: { (resultat, erreur) in
                //Erreur ou resultat final
                if erreur != nil || (resultat != nil && resultat!.isFinal) {
                    //Arrête
                    print(erreur?.localizedDescription ?? "")
                    // arret du moteur, arret du processus
                    self.engine.stop()
                    
                    // suppression bus enregistrement
                    node.removeTap(onBus: 0)
                    self.request = nil
                    self.task = nil
                }
                
                if resultat != nil {
                    self.transformerVoixText = resultat!.bestTranscription.formattedString
                    NotificationCenter.default.post(name: NSNotification.Name.tacheDeRetrabscription, object: self.transformerVoixText)
                    //print(self.transformerVoixText) // affiche texte dans la console
                    
                }
            })
            let format = node.outputFormat(forBus: 0)
            node.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
                self.request?.append(buffer)
            }
            engine.prepare()
            do {
                try engine.start()
            } catch {
                print("Erreur au lancement => \(error.localizedDescription)")
            }
        } catch {
            print("Erreur du set de catégory => \(error.localizedDescription)")
        }
    }
    // arret de la retranscrpition de la voix
    func arretTranscription() {
        do {
            engine.stop()
            request?.endAudio()
           try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            enregistrementEnCours = false
        } catch {
            print(error.localizedDescription)
            
        }
       
    }
    
    //arret ou demarrer le processus de transcription de la voix
    func etatProcessus() {
        //demarre la transcription si la variable est Vrai et inverssement
        engine.isRunning ? arretTranscription() : demarrerTranscriptionVoix()
    }
}

