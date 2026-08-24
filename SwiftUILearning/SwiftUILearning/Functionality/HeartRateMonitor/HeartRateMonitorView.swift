//
//  HeartRateMonitorView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 12/11/25.
//

import SwiftUI
import AVFoundation

struct HeartRateMonitorView: View {
    @StateObject private var viewModel = HeartRateMonitorViewModel()
    @State private var pulseScale: CGFloat = 1.0
    private let pulseAnimation = Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Heart Rate Monitor")
                .font(.largeTitle)
                .bold()
            
            if viewModel.isMonitoring {
                if viewModel.fingerDetected {
                    ZStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.red)
                            .scaleEffect(pulseScale)
                            .onAppear {
                                withAnimation(pulseAnimation) {
                                    pulseScale = 1.3
                                }
                            }
                            .onDisappear { pulseScale = 1.0 }
                        
                        if viewModel.bpm > 0 {
                            Text("\(viewModel.bpm) BPM")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                                .shadow(radius: 10)
                                .offset(y: 160)
                        }
                    }
                    .frame(height: 250)
                    
                    Text("Monitoring... Keep your finger on the camera.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    VStack {
                        Image(systemName: "hand.point.up.left.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)
                        Text("Place your finger on the back camera and flashlight.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            } else {
                if viewModel.bpm > 0 {
                    VStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                        Text("Your Heart Rate: \(viewModel.bpm) BPM")
                            .font(.title2)
                            .bold()
                    }
                } else {
                    Image(systemName: "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                    Text("Tap Start to Measure")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            
            Button(action: {
                if viewModel.isMonitoring {
                    viewModel.stopMonitoring()
                } else {
                    viewModel.startMonitoring()
                }
            }) {
                Text(viewModel.isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isMonitoring ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    HeartRateMonitorView()
}
