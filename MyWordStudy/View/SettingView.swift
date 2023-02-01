//
//  SettingView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/19.
//

import SwiftUI

struct SettingView: View {
    
    @State var sound: Bool = fechDefaultSound()
    @State var size: Int = fechDefaultSize()
    @State var screen: Int = fechDefaultScreen()
    @State var removeAlert:Bool = false
    @State var isDeleteShow:Bool = false
    
    var body: some View {
        NavigationStack {
            
            ProductView()
            
            List {
                Section("Default") {
                    HStack {
                        Picker("Character size", selection: $size) {
                            Text("small").tag(0)
                            Text("medium").tag(1)
                            Text("large").tag(2)
                        }
                    }
                    HStack {
                        Text("Default screen")
                        Spacer()
                        HStack {
                            Picker("Character size", selection: $screen) {
                                Image(systemName: "books.vertical").tag(0)
                                Image(systemName: "pencil.circle.fill").foregroundColor(Color.green).tag(3)
                            }
                            .pickerStyle(.segmented)
                            .background(Color.red.opacity(0.3))
                        }
                    }
                    HStack {
                        Text("Sound")
                        Spacer()
                        Text(sound ? "ON" : "OFF")
                            .foregroundColor(sound ? Color.blue : Color.red)
                        Toggle(isOn: $sound) {}
                    }
                }
                .onChange(of: size){ newValue in updateDefault(size: newValue, screen: screen, sound: sound) }
                .onChange(of: screen){ newValue in updateDefault(size: size, screen: newValue, sound: sound) }
                .onChange(of: sound){ newValue in updateDefault(size: size, screen: screen, sound: newValue) }
                
                Section("delete") {
                    HStack {
                        Text("Remove to 0")
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(Color.green)
                        Spacer()
                        Button {
                            removeAlert.toggle()
                        } label: {
                            ZStack {
                                Rectangle()
                                    .fill(Color.pink)
                                    .frame(width: 100, height: 40)
                                    .cornerRadius(10)
                                Text("REMOVE").foregroundColor(Color.white)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .alert(isPresented: $removeAlert) {
                            Alert(title: Text("Warning"),
                                  message: Text("Do you allow to remove ?"),
                                  primaryButton: .cancel(Text("cancel"), action: { }),
                                  secondaryButton: .destructive(Text("Allow"), action: { removeCheckMark() }))
                        }
                    }
                    HStack {
                        Text("Delete all local data")
                        Spacer()
                        Button {
                            isDeleteShow.toggle()
                        } label: {
                            ZStack {
                                Rectangle()
                                    .fill(Color.yellow)
                                    .frame(width: 100, height: 40)
                                    .cornerRadius(10)
                                Text("DELETE").foregroundColor(Color.blue)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .sheet(isPresented: $isDeleteShow) {
                        DeleteDataView(sound: $sound, size: $size, screen: $screen)
                            .presentationDetents([.height(300)])
                    }
                }
            }
            .environment(\.defaultMinListRowHeight, 75)
            .navigationTitle("Settings")
        }
    }
}

struct ContentVi_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
