//
//  UIControlsView.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 26/04/25.
//

import SwiftUI

enum Platform : String, CaseIterable {
    case iOS
    case android
    case web
    case other
}

struct UIControlsView: View {
    @State var title : String = "UI Controls"
    @State var isEnable : Bool = true
    @State var progress: Double = 0.1
    @State var selectedPlatform : Platform = .other
    
    var body: some View {
        NavigationStack {
            HeaderView(title: title, isBack: true)
            ZStack {
                List {
                    VStack (alignment: .leading){
                        UIToggleView()
                        Text ("Toggle View").padding(.bottom).bold()
                        Toggle("Toggle Static", isOn: .constant(true)).tint(.blue)
                        Toggle("Toggle Dynamic", isOn: $isEnable).tint(.red)
                        Toggle("Custom Toggle", isOn: .constant(true))
                            .toggleStyle(CustomThumbToggleStyle(
                                thumbColor: .red,
                                onColor: Color.red.opacity(0.2),
                                offColor: .gray.opacity(0.4)
                            ))
                    }
                    
                    VStack (alignment: .leading) {
                        Text ("Progress View").padding(.bottom).bold()
                        ZStack {
                            
                            // Background Circle
                            // Represents full progress
                            Circle().stroke(lineWidth: 15).fill(Color.red.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            // Foreground Circle
                            // Represent Dynamic progress
                            Circle()
                                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                            //                                     .foregroundColor(.pink)
                                .fill(Color.red)
                                .rotationEffect(Angle(degrees: 270.0))
                                .animation(.linear, value: progress)
                            
                            // Display the progress in percentage
                            Text(String(format: "%.0f%%", min(self.progress, 1.0) * 100.0))
                                .font(.title)
                                .bold()
                            
                        }.frame(height: 100)
                        Spacer()
                        Slider(value: $progress, in: 0...1).tint(Color.red)
                    }
                    
                    VStack (alignment: .leading) {
                        Text ("Checkbox").padding(.bottom).bold()
                        Text ("Choose any favorite language").padding(.bottom).italic()
                        
                        HStack {
                            Image(systemName: selectedPlatform == .iOS ? "checkmark.square" : "square")
                                .resizable()
                                .frame(width:26, height:26)
                                .onTapGesture {
                                    if selectedPlatform == .iOS {
                                        selectedPlatform = .other
                                    } else {
                                        selectedPlatform = .iOS
                                    }
                                }
                            Text ("IOS").italic()
                        }
                        
                        HStack {
                            Image(systemName: selectedPlatform == .android ? "checkmark.square" : "square")
                                .resizable()
                                .frame(width:26, height:26)
                                .onTapGesture {
                                    if selectedPlatform == .android {
                                        selectedPlatform = .other
                                    } else {
                                        selectedPlatform = .android
                                    }
                                }
                            Text ("Android").italic()
                        }
                        
                        HStack {
                            Image(systemName: selectedPlatform == .web ? "checkmark.square" : "square")
                                .resizable()
                                .frame(width:26, height:26)
                                .onTapGesture {
                                    if selectedPlatform == .web {
                                        selectedPlatform = .other
                                    } else {
                                        selectedPlatform = .web
                                    }
                                }
                            Text ("Web").italic()
                        }
                    }
                    
                    VStack (alignment: .leading) {
                        Text ("Menubar").padding(.bottom).bold()
                        
                        
                    }
                    
                }.padding(.top, -10) // Shift form upward to remove 10pt gap
            }
            
            Spacer()
        }.navigationBarHidden(true) // Hide on this screen
    }
}

#Preview {
    UIControlsView()
}

struct UIToggleView: View {
    @State var value: Bool = false
    var body: some View {
        Toggle("Toggle", isOn: $value)
            .toggleStyle(CustomThumbToggleStyle(thumbColor: .white, onColor: .red.opacity(1.0), offColor: .red.opacity(0.2)))
    }
}

struct CustomThumbToggleStyle: ToggleStyle {
    var thumbColor: Color
    var onColor: Color
    var offColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? onColor : offColor)
                    .frame(width: 51, height: 31)
               
                Circle()
                    .fill(thumbColor)
                    .frame(width: 27, height: 27)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

