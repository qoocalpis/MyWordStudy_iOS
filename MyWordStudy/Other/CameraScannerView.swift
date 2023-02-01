//
//  CameraScannerView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/18.
//

import SwiftUI
import VisionKit

struct CameraScannerView: View {
    
    @State private var showCameraScannerView = true
    @State private var isDeviceCapacity = false
    @State private var showDeviceNotCapacityAlert = false
    @State private var scanWord: String = ""
    @State private var scanDefinition: String = ""
    @State var tips: String = ""
    @State var selected: Int = 0
    @State var isAnimation = false
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    ProgressView()
                    Text(tips).font(.title2).padding()
                }
                CameraScannerViewController(startScanning: $showCameraScannerView, scanWord: $scanWord, scanDefinition: $scanDefinition, selected: $selected)
            }
            HStack {
                Picker("", selection: $selected) {
                    Text("word").tag(0)
                    Text("definition").tag(1)
                }
                .pickerStyle(.segmented)
                .background(Color.red.opacity(0.3))
            }
            HStack {
                Image(systemName: "info.circle")
                Text("Tap the words in the frame")
            }
            .padding(.bottom)
            Text("word").foregroundColor(Color.green)
            
            if scanWord == "" {
                TextField("", text: $scanWord)
                    .disabled(true)
                    .overlay(
                        RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                            .stroke(Color.orange, lineWidth: 1.0)
                            .padding(-8.0)
                    )
            }
            if scanWord != "" {
                TextField("", text: $scanWord)
                    .overlay(
                        RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                            .stroke(Color.orange, lineWidth: 1.0)
                            .padding(-8.0)
                    )
            }
            
            Text("definition").foregroundColor(Color.purple).padding(.top)
            
            if scanDefinition == "" {
                TextField("", text: $scanDefinition)
                    .disabled(true)
                    .overlay(
                        RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                            .stroke(Color.orange, lineWidth: 1.0)
                            .padding(-8.0)
                    )
            }
            if scanDefinition != "" {
                TextField("", text: $scanDefinition)
                    .overlay(
                        RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                            .stroke(Color.orange, lineWidth: 1.0)
                            .padding(-8.0)
                    )
            }
            if scanWord != "" && scanDefinition != "" {
                Button {
                    isAnimation.toggle()
                    add_model(word: scanWord, definition: scanDefinition)
                    
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(isAnimation ? Color.orange : Color.mint)
                            .frame(width: isAnimation ? 140: 100, height: 50)
                            .cornerRadius(10)
                            .animation(.easeIn, value: isAnimation)
                        isAnimation ? Text("Completed") : Text("SAVE")
                            .foregroundColor(Color.black)
                    }
                }
                .padding()
            }else {
                ZStack {
                    Rectangle()
                        .fill( Color.gray)
                        .frame(width: 100, height: 50)
                        .cornerRadius(10)
                        .animation(.easeIn, value: isAnimation)
                    Text("SAVE")
                        .foregroundColor(Color.black)
                }
                .padding()
            }
            
        }
        .alert("Scanner Unavailable", isPresented: $showDeviceNotCapacityAlert, actions: {})
        .onAppear {
            isDeviceCapacity = (DataScannerViewController.isSupported &&
                                DataScannerViewController.isAvailable)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                tips = "Check your camera settings"
                if selected == 0 {
                    selected = 1
                    selected = 0
                }
                if selected == 1 {
                    selected = 0
                    selected = 1
                }
            }
        }
        .onChange(of: isAnimation) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    isAnimation = false
                }
            }
        }
    }
}

struct CameraScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScannerView()
    }
}
