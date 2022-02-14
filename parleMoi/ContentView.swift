//
//  ContentView.swift
//  parleMoi
//
//  Created by Philippe MICHEL on 30/01/2022.
//

import SwiftUI
struct ContentView: View {
    //@State var texteDictee:String = ""
    
    @StateObject var utiliserMicro:ReconnaissanceVocaleViewModel = ReconnaissanceVocaleViewModel()
    @StateObject var voixSynthese:SyntheseVocaleViewModel = SyntheseVocaleViewModel()
    
    @State var TexteRetranscrit:String = ""
    
    @State var montrerPopup:Bool = false
    @State var montrerAlerte = false
    @State var clavierAfficher:Bool = false
    var largeurTextEditor:CGFloat = 285
    var hauteurTextEditor:CGFloat = 350
    var pictogramme:[String] = ["person.wave.2.fill", "speaker.wave.2.fill"]
    @State  var selection:Int = 0
    
    //parametre pour les vues animées
    let milieu = UIScreen.main.bounds.height / 2
    let largeurEcran = UIScreen.main.bounds.width
    let popupHauteur:CGFloat = 200
    
    // variable pour le slider
    @State var value: CGFloat = 0.5
    var min: CGFloat = 0.0
    var max: CGFloat = 1.0
    var step: CGFloat = 0.1
    var minTrackColor: UIColor?
    var maxTrackColor: UIColor?
    
    var body: some View {
        NavigationView {
            VStack {
                TitreApp()
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            HStack (spacing:10) {
                                //type animation pour la fenetre popupup
                                Button("about") {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))
                                    {
                                        self.montrerPopup.toggle()
                                    }
                                }
                                .foregroundColor(Color("CouleurPremierPlan"))
                                .font(.system(size: 15))
                                Spacer()
                            }
                        }
                    }// toolbar
                // bouton fermeture du clavier
                if clavierAfficher {
                    Button {
                        // Action
                        rentrerClavier()
                        self.clavierAfficher = false
                        
                    } label: {
                        Image(systemName: Ressources.images.clavier.rawValue)
                    }
                    .imageScale(.large)
                    .foregroundColor(Color("CouleurPremierPlan"))
                    .disabled(clavierAfficher  ? false : true)
                    
                }
                // zstack pour la gestion du popup
                ZStack {
                    TextEditor(text:  $TexteRetranscrit)
                        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.tacheDeRetrabscription), perform: {
                            TexteRetranscrit = $0.object as? String ?? ""
                        })
                    // clavier affiché
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                            self.clavierAfficher = true
                            
                            
                            //clavier non afficher
                        }.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                            self.clavierAfficher = false
                            
                        }
                        .frame(width: largeurTextEditor, height: demensionTextEditor())
                        .background(Color("monVert"))
                        .cornerRadius(10)
                        .disabled(utiliserMicro.engine.isRunning || (voixSynthese.speechSynthesizer.isSpeaking) ? true : false)
                    
                    // création du popup
                    VuePopup()
                        .padding()
                        .offset(x: 0, y:  montrerPopup ? -popupHauteur + popupHauteur : -UIScreen.main.bounds.height)
                }
                // creation picker
                Picker("", selection: $selection) {
                    ForEach(0..<pictogramme.count) {choix in
                        Image(systemName: pictogramme[choix])
                    }
                }
                .frame(width: largeurEcran - 100)
                .pickerStyle(SegmentedPickerStyle())
                .disabled(utiliserMicro.engine.isRunning || (voixSynthese.speechSynthesizer.isSpeaking) ? true : false)
                .opacity(utiliserMicro.engine.isRunning || (voixSynthese.speechSynthesizer.isSpeaking) ? 0.4 : 1)
                
                // message alerte
                .alert(isPresented: $montrerAlerte, content: {
                    Alert(title: Text("listenAlert"))
                })
                //Selecteur
                if selection == 0 {
                    //transcription
                    Button {
                        // Action
                        voixSynthese.arretLecture()
                        utiliserMicro.etatProcessus()
                        
                    } label: {
                        if utiliserMicro.enregistrementEnCours {
                            Image(systemName: Ressources.images.stop.rawValue)
                        } else {
                            Image(systemName: Ressources.images.micro.rawValue)
                        }
                    }
                    .imageScale(.large)
                    .frame(width: 100, height: 100)
                    .background(Color("CouleurPremierPlan"))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .disabled(utiliserMicro.boutonUtilisationMicro ? false : true)
                    .opacity(utiliserMicro.boutonUtilisationMicro ? 1 : 0.4)
                    
                } else {
                    // selecteur sur lecture
                    // affichage du slider de la vitesse de lecture.
                    VStack {
                        Slider(
                            value: $value,
                            in: min...max,
                            step: step,
                            onEditingChanged: { (success) in
                                voixSynthese.rythmeLecture(vitesseLecture: value)
                            },
                            minimumValueLabel:
                                Text("min")
                                .foregroundColor(Color("CouleurPremierPlan"))
                                .font(.system(size: 15))
                            ,
                            maximumValueLabel: Text("max")
                                .foregroundColor(Color("CouleurPremierPlan"))
                                .font(.system(size: 15))) {
                                }
                        // change la couleur du slider
                                .accentColor(Color("CouleurPremierPlan"))
                        // change la couleur du slider
                                .frame(width: largeurEcran - 100)
                        
                    }
                    .disabled(voixSynthese.speechSynthesizer.isSpeaking ? true : false)
                    .opacity(voixSynthese.speechSynthesizer.isSpeaking ? 0.4 : 1)
                    
                    // affichage texte
                    HStack {
                        Text("speechSpeed")
                        Text((String(format: "%.1f",value)))
                    }
                    .foregroundColor(Color("CouleurPremierPlan"))
                    .font(.system(size: 15))
                    .opacity(voixSynthese.speechSynthesizer.isSpeaking ? 0.4 : 1)
                    
                    Button {
                        // Action lecture
                        if utiliserMicro.transformerVoixText != nil {
                            self.montrerAlerte = false
                            self.etatProcessusLecture()
                        } else {
                            self.montrerAlerte = true
                        }
                        
                        
                    } label: {
                        if voixSynthese.lectureEnCours {
                            Image(systemName: Ressources.images.stop.rawValue)
                        } else {
                            Image(systemName: Ressources.images.lecture.rawValue)
                        }
                        
                    }
                    .imageScale(.large)
                    .frame(width: 100, height: 100)
                    .background(Color("CouleurPremierPlan"))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .disabled(utiliserMicro.boutonUtilisationMicro ? false : true)
                    .opacity(utiliserMicro.boutonUtilisationMicro ? 1 : 0.4)
                    
                } // Hstack
                
                
                // gestion des messages de texte en fonction du bouton
                VStack {
                    if selection == 0 {
                        if utiliserMicro.enregistrementEnCours {
                            Text("registrationStop")
                            
                        } else {
                            Text("registrationStart")
                        }
                    } else {
                        if voixSynthese.lectureEnCours {
                            Text("listenStop")
                        } else {
                            Text("listenStart")
                        }
                    } // fin if gestion message en fonction
                }
                .foregroundColor(Color("CouleurPremierPlan"))
                .font(.system(size: 15))
                
            } // vstack final
            .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .edgesIgnoringSafeArea(.all)
            .background(Color("CouleurTrameFond"))
            
        } // fin navigationView
        
    } //someView
    // modification de la hauteur en fonction de la detectiuon du clavier
    func demensionTextEditor() -> CGFloat {
        return clavierAfficher ? hauteurTextEditor - 130 : hauteurTextEditor
    }
    
    //determine si le bouton lecture doit lancer ou arreter la lecture
    func etatProcessusLecture() {
        voixSynthese.speechSynthesizer.isSpeaking ? voixSynthese.arretLecture() : voixSynthese.demarrerLecture(texte: TexteRetranscrit)
    }
    
    // rentre le clavier
    func rentrerClavier() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} // contentView

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



