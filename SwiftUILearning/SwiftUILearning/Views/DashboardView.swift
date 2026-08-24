//
//  DashboardView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/04/25.
//

import SwiftUI

struct ControllerItem: Identifiable {
    let id = UUID()
    let title: String
    let destination: AnyView
}

struct DashboardView: View {
    let arrOfControllers: [ControllerItem] = [
        ControllerItem(title: "Video Player", destination: AnyView(VideoPlayerView())),
        ControllerItem(title: "List View", destination: AnyView(ListView())),
        ControllerItem(title: "Form View", destination: AnyView(FormView())),
        ControllerItem(title: "UI Controls", destination: AnyView(UIControlsView())),
        ControllerItem(title: "Tabbar", destination: AnyView(MainTabView())),
        ControllerItem(title: "API Calling", destination: AnyView(APICallingView())),
        ControllerItem(title: "DocSignViewNew", destination: AnyView(DocSignViewNew())),
        /*ControllerItem(title: "Image Compressor", destination: AnyView(ImageCompressorView())),
        ControllerItem(title: "PDF Compressor", destination: AnyView(PDFCompressorView())),
        ControllerItem(title: "Plant Identifier", destination: AnyView(PlantDetectionView())),
        ControllerItem(title: "Bird Identifier", destination: AnyView(BirdDetectionView())),
        ControllerItem(title: "Animal Identifier", destination: AnyView(AnimalDetectionView())),
        ControllerItem(title: "QRCode Generator ", destination: AnyView(QRCodeGeneratorView())),
        ControllerItem(title: "QRCode Scanner", destination: AnyView(QRCodeScannerView())),
        ControllerItem(title: "BarCode Generator ", destination: AnyView(BarcodeGeneratorView())),
        ControllerItem(title: "BarCode Scanner", destination: AnyView(BarCodeScannerView())),
        ControllerItem(title: "Create Zip", destination: AnyView(ZipView())),
        ControllerItem(title: "UnZip", destination: AnyView(UnZipView())),
        ControllerItem(title: "UnRar", destination: AnyView(UnRarView())),
        ControllerItem(title: "Voice Changer", destination: AnyView(VoiceChangerView())),
        ControllerItem(title: "DocSign", destination: AnyView(SelectDocView())),
        ControllerItem(title: "Pill Reminder", destination: AnyView(SplashView())),
        ControllerItem(title: "HeartRate Monitor", destination: AnyView(HeartRateMonitorView())),*/
    ]
    @State var title : String = "Dashboard"
    
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: false)
            List (arrOfControllers) { item in
                NavigationLink(destination: item.destination) {
                    Text(item.title)
                }
            }.padding(.top, -10) // Shift form upward to remove 10pt gap
        }.navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    DashboardView()
}
