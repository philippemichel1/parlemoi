//
//  ControleurSafari.swift
//  parleMoi
//
//  Created by Philippe MICHEL on 30/01/2022.
//

import SafariServices
import SwiftUI

struct ControleurSafari: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<ControleurSafari>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<ControleurSafari>) {

    }
}
