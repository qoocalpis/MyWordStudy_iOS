//
//  SettingView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/19.
//

import SwiftUI

struct SettingView: View {
    
    //SettingModelに保存されているレコード情報の取得
    @State var sound: Bool = fechDefaultSound()
    @State var size: Int = fechDefaultSize()
    @State var screen: Int = fechDefaultScreen()
    //DictionaryModelのcheckMark数を0にするAlertの呼び出しトリガー
    @State var removeAlert:Bool = false
    //全テーブルのレコードを削除するsheetの呼び出しトリガー
    @State var isDeleteShow:Bool = false
    
    var body: some View {
        NavigationStack {
            
            //製品情報の表示
            ProductView()
            
            List {
                Section("Default") {
                    HStack {
                        //プロパティsize(Int)によって切り替える
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
                            //プロパティscreen(Int)によって切り替える
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
                        //プロパティsound(Bool)によって切り替える
                        Text(sound ? "ON" : "OFF")
                            .foregroundColor(sound ? Color.blue : Color.red)
                        Toggle(isOn: $sound) {}
                    }
                }
                //格設定の値が変更される度にSettingModelを更新
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
                            //DictionaryModelのcheckMark数を0にするAlertの呼び出し
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
                        //Alertの表示
                        .alert(isPresented: $removeAlert) {
                            Alert(title: Text("Warning"),
                                  message: Text("Do you allow to remove ?"),
                                  //cancel と allow ボタン
                                  primaryButton: .cancel(Text("cancel"), action: { }),
                                  secondaryButton: .destructive(Text("Allow"), action: { removeCheckMark() }))
                        }
                    }
                    HStack {
                        Text("Delete all local data")
                        Spacer()
                        Button {
                            //全テーブルのレコードを削除するsheetの呼び出し
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
                    //isDeleteShowがtrue時にsheetを表示(DeleteDataView)
                    .sheet(isPresented: $isDeleteShow) {
                        DeleteDataView(sound: $sound, size: $size, screen: $screen)
                            .presentationDetents([.height(300)])
                    }
                }
            }
            //行の高さ
            .environment(\.defaultMinListRowHeight, 75)
            //タイトル
            .navigationTitle("Settings")
        }
    }
}

struct ContentVi_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
