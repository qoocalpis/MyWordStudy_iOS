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
        //HomeTabViewのtag(index)
        self._selectTabIndex = selectTabIndex
        
        //RecentlySourceModelにレコードがある場合
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
        //ない場合はデフォルト
        }else {
            sourceObject = SourceLangArray()
        }
        //RecentlyTargetModelにレコードがある場合
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
        //ない場合はデフォルト
        }else {
            targetObject = TargetLangArray()
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                //OriginalColor(Assets.xcassetsファイルに定義)
                Color("TranslateViewBackgroundColor")
                VStack {
                    HStack {
                        Button {
                            //翻訳元言語指定Viewの呼び出し状態
                            isSheetSource.toggle()
                        } label: {
                            ZStack {
                                //選択されている言語
                                Text(selectedSource().language).font(.headline).padding().foregroundColor(Color("TranslateLanguageColor"))//OriginalColor(Assets.xcassetsファイルに定義)
                            }
                        }.padding()
                        Spacer()
                        Button {
                            //翻訳元と翻訳先の言語の入れ替え
                            reverseLang(source: selectedSource(), target: selectedTarget())
                        } label: {
                            Image(systemName: "arrow.left.arrow.right").foregroundColor(.pink)
                        }.padding()
                        
                        Spacer()
                        Button {
                            //翻訳先言語指定Viewの呼び出し状態
                            isSheetTarget.toggle()
                        } label: {
                            //選択されている言語
                            Text(selectedTarget().language).font(.headline).padding().foregroundColor(Color("TranslateLanguageColor"))//OriginalColor(Assets.xcassetsファイルに定義)
                        }.padding()
                    }
                    //タイトルとそのレイアウト
                    .navigationTitle("Translate")
                    .navigationBarTitleDisplayMode(.large)
                    //左右上部にScreen切り替えボタンの設定
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                //HomeTabViewのtag(index)を指定
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
                                //HomeTabViewのtag(index)を指定
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
                    //翻訳元言語指定Viewの呼び出し
                    .sheet(isPresented: $isSheetSource, content: {
                        SourceLanguageView(vm: sourceObject)
                    })
                    //翻訳先言語指定Viewの呼び出し
                    .sheet(isPresented: $isSheetTarget, content: {
                        TargetLanguageView(vm: targetObject)
                    })
                    .padding()
                    //翻訳するテキスト
                    TextField("input", text: $text)
                        //キーボード自動表示
                        .focused($fieldIsFocused)
                        //レイアウト設定
                        .overlay(
                            RoundedRectangle(cornerSize: CGSize(width: 8.0, height: 8.0))
                                .stroke(Color.orange, lineWidth: 1.0)
                                .padding(-8.0)
                        )
                        .padding(16.0)
                        //入力文字数制限
                        .onReceive(Just(text)) { _ in
                            if text.count > maxTextLength {
                                text = String(text.prefix(maxTextLength))
                            }
                        }
                    //network未接続時
                    if !isNetwork { Text("※ internet doesn’t work").foregroundColor(Color.red) }
                    //翻訳後のTextに値が存在する場合
                    if translatedText != "" {
                        Text(translatedText).padding()
                        Button {
                            //購入済の場合SAVEボタン有効
                            if isPurchased {
                                isAnimation.toggle()
                                add_model(word: text, definition: translatedText)
                            //未購入の場合Alertの呼び出し
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
                                //未購入の場合,鍵表示
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
                        //未購入の場合のAlert表示
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
            //製品が購入済か調べる
            Task {
                isPurchased = (try? await storeKit.isPurchased()) ?? false
            }
        }
        //キーボードのreturnキーtap時,翻訳実行
        .onSubmit({
            translation(text: text, sourcePara: selectedSource().parLanguage, targetPara: selectedTarget().parLanguage)
        })
        //入力時,常に翻訳実行
        .onChange(of: text) { newValue in
            translation(text: text, sourcePara: selectedSource().parLanguage, targetPara: selectedTarget().parLanguage)
        }
        //Saveボタンtap時のアニメーションの動作
        .onChange(of: isAnimation) { newValue in
            //1.5秒後にfalseに戻す
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    isAnimation = false
                }
            }
        }
        //network接続確認
        .onChange(of: network.isConnected) { newValue in
            //2秒後に接続状況を取得
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
