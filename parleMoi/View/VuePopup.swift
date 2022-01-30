//
//  VuePopup.swift
//  parleMoi
//
//  Created by Philippe MICHEL on 30/01/2022.
//

import SwiftUI

struct VuePopup: View {
    @State var montrerSafari:Bool = false
    @State var deplacementFenetre:CGSize = CGSize.zero
    
    var urlString = "https://www.titastus.com"
    var body: some View {
        VStack {
            HStack {
                Image(Ressources.images.logotitastus.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                    .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Button(action: {
                    self.montrerSafari.toggle()
                }, label: {
                    Text("Titastus.com")
                        .foregroundColor(Color("CouleurPremierPlan"))
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                })
                    .padding()
                    .sheet(isPresented: $montrerSafari) {
                        ControleurSafari(url: URL(string: self.urlString)!)
                    }
            }
        }.background(Color.gray.opacity(0.8)
                        .cornerRadius(10)
                        .shadow(color: /*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/.opacity(0.15), radius: 10, x: 3, y: -1))
        
        //déplacement de la popup à propos de
            .offset(deplacementFenetre)
            .gesture(
                DragGesture()
                    .onChanged {self.deplacementFenetre = $0.translation})
        
        
    }
}

struct VuePopup_Previews: PreviewProvider {
    static var previews: some View {
        VuePopup()
    }
}

