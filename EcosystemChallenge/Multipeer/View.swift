//
//  View.swift
//  EcosystemChallenge
//
//  Created by Layza Maria Rodrigues Carneiro on 18/06/25.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @State private var localNetwork = LocalNetworkSessionCoordinator()

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Connected")) {
                    ForEach(Array(localNetwork.connectedDevices), id: \.self) { peerID in
                        NavigationLink(destination: ImageShareView(peerID: peerID, network: localNetwork)) {
                            HStack {
                                Text(peerID.displayName)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                Section(header: Text("Nearby")) {
                    ForEach(Array(localNetwork.otherDevices), id: \.self) { peerID in
                        HStack {
                            Text(peerID.displayName)
                            Spacer()
                            Button {
                                localNetwork.invitePeer(peerID: peerID)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                    }
                }
            }
            .navigationTitle("P2P")
        }
        .onAppear {
            localNetwork.startBrowsing()
            localNetwork.startAdvertising()
        }
        .onDisappear {
            localNetwork.stopBrowing()
            localNetwork.stopAdvertising()
        }
    }
}

struct ImageShareView: View {
    @State private var imageToSend: UIImage?
    @State private var showImagePicker = false
    @State private var receivedImage: UIImage?
    
    var peerID: MCPeerID
    var network: LocalNetworkSessionCoordinator

    var body: some View {
        VStack {
            if let received = network.receivedImage {
                Image(uiImage: received)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            if let image = imageToSend {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                Button("Enviar Imagem") {
                    try? network.sendImage(peerID: peerID, image: image)
                }
                .padding()
            }

            Button("Selecionar Imagem") {
                showImagePicker = true
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $imageToSend)
        }
    }
}
