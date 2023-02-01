//
//  TranslateView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/21.
//

import SwiftUI
import RealmSwift
import StoreKit
import Combine



struct TranslateView: View {
    
    //課金製品情報
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased = false
    //翻訳元,翻訳先の言語モデル(※init)
    @ObservedObject var sourceObject: SourceLangArray
    @ObservedObject var targetObject: TargetLangArray
    //networkモデルと接続状態
    @ObservedObject var network = MonitoringNetworkState()
    @State var isNetwork = MonitoringNetworkState().isConnected
    //翻訳用のテキスト(Max40文字入力可)と翻訳後のテキスト
    @FocusState private var fieldIsFocused: Bool //翻訳用のテキストのキーボード表示状態
    let maxTextLength = 40
    @State var text = ""
    @State var translatedText = ""
    //言語指定Viewの呼び出し状態
    @State var isSheetSource = false
    @State var isSheetTarget = false
    //Realm辞書モデルへの保存時のアクション状態
    @State var isAnimation = false
    @State var isAlert = false
    //HomeTabViewのScreen状態(selectTabIndex)(※init)
    @Binding var selectTabIndex: Int
    //親ViewのHomeTabViewから引数を引き継いでイニシャライザ処理
    init(selectTabIndex: Binding<Int>, countRecentSource: Int, countRecentTarget: Int) {
        self._selectTabIndex = selectTabIndex
        if countRecentSource > 0 {
            let realm = try! Realm()
            let resultLang = realm.objects(RecentlySourceModel.self).sorted(byKeyPath: "date", ascending: false)[0].language
            let tempObject = SourceLangArray()
            if resultLang == tempObject.sourceLangArray.first(where: { $0.selected == true })?.language {
                sourceObject = tempObject
            }else {
                if let firstIndex = tempObject.sourceLangArray.firstIndex(where: { $0.selected == true }) {
                    tempObject.sourceLangArray[firstIndex].selected = false
                }
                if let selectedIndex = tempObject.sourceLangArray.firstIndex(where: { $0.language == resultLang }) {
                    tempObject.sourceLangArray[selectedIndex].selected = true
                }
                sourceObject = tempObject
            }
        }else {
            sourceObject = SourceLangArray()
        }
        if countRecentTarget > 0 {
            let realm = try! Realm()
            let resultLang = realm.objects(RecentlyTargetModel.self).sorted(byKeyPath: "date", ascending: false)[0].language
            let tempObject = TargetLangArray()
            if resultLang == tempObject.targetLangArray.first(where: { $0.selected == true })?.language {
                targetObject = tempObject
            }else {
                if let firstIndex = tempObject.targetLangArray.firstIndex(where: { $0.selected == true }) {
                    tempObject.targetLangArray[firstIndex].selected = false
                }
                if let selectedIndex = tempObject.targetLangArray.firstIndex(where: { $0.language == resultLang }) {
                    tempObject.targetLangArray[selectedIndex].selected = true
                }
                targetObject = tempObject
            }
        }else {
            targetObject = TargetLangArray()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("TranslateViewBackgroundColor")
                VStack {
                    HStack {
                        Button {
                            isSheetSource.toggle()
                        } label: {
                            ZStack {
                                Text(selectedSource().language).font(.headline).padding().foregroundColor(Color("TranslateLanguageColor"))
                            }
                        }.padding()
                        Spacer()
                        Button {
                            reverseLang(source: selectedSource(), target: selectedTarget())
                        } label: {
                            Image(systemName: "arrow.left.arrow.right").foregroundColor(.pink)
                        }.padding()
                        
                        Spacer()
                        Button {
                            isSheetTarget.toggle()
                        } label: {
                            Text(selectedTarget().language).font(.headline).padding().foregroundColor(Color("TranslateLanguageColor"))
                        }.padding()
                    }
                    .navigationTitle("Translate")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                selectTabIndex = 0
                            } label: {
                                VStack {
                                    Text("Dictionary")
                                    HStack {
                                        Image(systemName: "arrowshape.turn.up.left")
                                        Image(systemName: "books.vertical")
                                    }
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                selectTabIndex = 3
                            } label: {
                                VStack {
                                    Text("Spelling")
                                    HStack {
                                        Image(systemName: "pencil.circle.fill")
                                        Image(systemName: "arrowshape.turn.up.right")
                                    }
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $isSheetSource, content: {
                        SourceLanguageView(vm: sourceObject)
                    })
                    .sheet(isPresented: $isSheetTarget, content: {
                        TargetLanguageView(vm: targetObject)
                    })
                    .padding()
                    TextField("input", text: $text)
                        .onTapGesture {
                            print("Tap")
                        }
                        .focused($fieldIsFocused)
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                                .stroke(Color.orange, lineWidth: 1.0)
                                .padding(-8.0)
                        )
                        .padding(16.0)
                        .onReceive(Just(text)) { _ in
                            if text.count > maxTextLength {
                                text = String(text.prefix(maxTextLength))
                            }
                        }
                    if !isNetwork { Text("※ internet doesn’t work").foregroundColor(Color.red) }
                    if translatedText != "" {
                        Text(translatedText).padding()
                        
                        Button {
                            if isPurchased {
                                isAnimation.toggle()
                                add_model(word: text, definition: translatedText)
                            }else {
                                isAlert.toggle()
                            }
                        } label: {
                            ZStack {
                                Rectangle()
                                    .fill(isAnimation ? Color.orange : Color.mint)
                                    .frame(width: isAnimation ? 140: 100, height: 50)
                                    .cornerRadius(10)
                                    .animation(.easeIn, value: isAnimation)
                                isAnimation ? Text("Completed") : Text("SAVE")
                                    .foregroundColor(Color.black)
                                if !isPurchased {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(Color.gray)
                                        .padding(EdgeInsets(
                                            top: 0,     // 上辺の余白幅
                                            leading: 90,// 左辺の余白幅
                                            bottom: 50, // 下辺の余白幅
                                            trailing: 0 // 右辺の余白幅
                                        ))
                                }
                            }
                        }
                        .padding()
                        .alert("Warning", isPresented: $isAlert) {
                            Button("OK") {
                            }
                        } message: {
                            Text("You need to purchase for product (Settings -> All function)")
                        }
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            /// 0.3秒の遅延発生後TextFieldに初期フォーカスをあてる
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                fieldIsFocused = true
            }
            Task {
                isPurchased = (try? await storeKit.isPurchased()) ?? false
            }
        }
        .onSubmit({
            translation(text: text, sourcePara: selectedSource().parLanguage, targetPara: selectedTarget().parLanguage)
        })
        .onChange(of: text) { newValue in
            translation(text: text, sourcePara: selectedSource().parLanguage, targetPara: selectedTarget().parLanguage)
        }
        .onChange(of: isAnimation) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    isAnimation = false
                }
            }
        }
        .onChange(of: network.isConnected) { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                isNetwork = newValue
            }
        }
    }
    
    func selectedSource() -> SourceLangArray.SourceLang {
        let seachIndex = sourceObject.sourceLangArray.firstIndex(where: { $0.selected == true })!
        return sourceObject.sourceLangArray[seachIndex]
    }
    func selectedTarget() -> TargetLangArray.TargetLang {
        let seachIndex = targetObject.targetLangArray.firstIndex(where: { $0.selected == true })!
        return targetObject.targetLangArray[seachIndex]
    }
    func reverseLang(source: SourceLangArray.SourceLang, target: TargetLangArray.TargetLang) {
        if let firstIndex = sourceObject.sourceLangArray.firstIndex(where: { $0.selected == true }) {
            sourceObject.sourceLangArray[firstIndex].selected = false
            if let changedIndex = sourceObject.sourceLangArray.firstIndex(where: { $0.language == target.language }) {
                sourceObject.sourceLangArray[changedIndex].selected = true
            }
        }
        if let firstIndex = targetObject.targetLangArray.firstIndex(where: { $0.selected == true }) {
            targetObject.targetLangArray[firstIndex].selected = false
            if let changedIndex = targetObject.targetLangArray.firstIndex(where: { $0.language == source.language }) {
                targetObject.targetLangArray[changedIndex].selected = true
            }
        }
    }
}


struct TranslateView_Previews: PreviewProvider {
    @State static var selectTabIndex = 0
    static var previews: some View {
        TranslateView(selectTabIndex: $selectTabIndex, countRecentSource: 0, countRecentTarget: 0)
    }
}
