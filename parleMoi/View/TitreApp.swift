//
//  TitreApp.swift
//  parleMoi
//
//  Created by Philippe MICHEL on 30/01/2022.
//

import SwiftUI

struct TitreApp: View {
    var body: some View {
        Text("titleApp")
            .padding(10)
            .frame(width: 250, height: 30)
            .font(.largeTitle)
            .foregroundColor(Color.white)
            .background(Color("CouleurPremierPlan"))
            .cornerRadius(10)
    }
}

struct TitreApp_Previews: PreviewProvider {
    static var previews: some View {
        TitreApp()
    }
}

