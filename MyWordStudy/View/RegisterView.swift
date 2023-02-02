//
//  RegisterView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/03.
//

import SwiftUI
import RealmSwift
import StoreKit


struct RegisterView: View {
    
    //格TextField分の配列
    @State var wordsArray = ["", "", "", "", ""]
    @State var definitionsArray = ["", "", "", "", ""]
    //Saveボタン時のAlert呼び出し状態
    @State var isAlert: Bool = false
    //Saveボタンの有効可否
    @State var isSaveButton: Bool = false
    @State var addedIndexToString: String = ""
    //課金製品情報
    @State var isPurchased: Bool = false
    @StateObject var storeKit = StoreKitManager()
    //View表示時のキーボード自動表示
    @FocusState private var nameFieldIsFocused: Bool
    //親ViewのDictionaryView or EmptyInfoViewへ戻る
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack{
                //背景色の設定
                Color("BackgroundColorBlue")
                    .ignoresSafeArea()
                //左上に親Viewへ戻るボタン設定
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading){
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.app").font(.largeTitle)
                            }
                            .padding(.top)
                        }
                    }
                VStack{
                    Text("Please register new dictionary")
                        .font(.title2)
                    //5行ずつword,definitionのTextField
                    inputTextField()
                        .padding(1)
                    HStack{
                        Button {
                            //Tap時に格TextFieldをリセット
                            wordsArray = ["", "", "", "", ""]
                            definitionsArray = ["", "", "", "", ""]
                        } label: {
                            //リセットボタンのレイアウト
                            resetBody
                        }
                        .padding(15)
                        Button {
                            //Tap時に辞書を保存&格TextFieldをリセット
                            addDictionary(word: wordsArray, definition: definitionsArray)
                            wordsArray = ["", "", "", "", ""]
                            definitionsArray = ["", "", "", "", ""]
                        } label: {
                            //SAVEボタンのレイアウト
                            saveBody
                        }
                        .padding(15)
                    }
                    //View立ち上げ時の処理
                    .onAppear {
                        /// 0.3秒の遅延発生後TextFieldに初期フォーカスをあてる
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            nameFieldIsFocused = true
                        }
                        //製品が購入済か調べる
                        Task {
                            isPurchased = (try? await storeKit.isPurchased()) ?? false
                        }
                    }
                    //Saveボタンの有効可否を入力時にcheck
                    .onChange(of: wordsArray) { newValue in
                        isSaveButton = checkTextField(word: newValue, definition: definitionsArray)
                    }
                    .onChange(of: definitionsArray) { newValue in
                        isSaveButton = checkTextField(word: wordsArray, definition: newValue)
                    }
                    //Saveボタンが成功時のAlert
                    .alert("Result", isPresented: $isAlert) {
                        Button("OK") {
                            addedIndexToString = ""
                        }
                    } message: {
                        Text("\(addedIndexToString) successed!")
                    }
                    //未購入時のみ表示
                    infomaition(isPurchased: $isPurchased)
                }
            }
        }
    }
    var resetBody: some View {
        Text("RESET")
            .fontWeight(.semibold)
            .frame(width: 160, height: 48)
            .foregroundColor(Color(red: 1.0, green: 0.18, blue: 0.33, opacity: 1.0))
            .background(Color(.yellow))
            .cornerRadius(24)
            .shadow(color: .black, radius: 1)
    }
    var saveBody: some View {
        Text("SAVE")
            .fontWeight(.semibold)
            .frame(width: 160, height: 48)
            .foregroundColor(Color(.blue))
            .background(isSaveButton ? Color(.cyan) : Color.gray)
            .cornerRadius(24)
            .shadow(color: .black, radius: 1)
    }
    
    func checkTextField(word: [String], definition: [String]) -> Bool {
        
        for i in 0..<word.count {
            if(word[i] != "" && definition[i] != "") {
                return true
            }
        }
        return false
    }
    
    func inputTextField() -> some View {
        ForEach(0..<wordsArray.count, id: \.self){ i in
            HStack {
                Text("#\(i+1)")
                if(i==0){
                    TextField("word", text: $wordsArray[i])
                        .focused($nameFieldIsFocused)
                        .frame(width: 130, height: 40)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("....")
                    TextField("definition", text: $definitionsArray[i])
                        .frame(width: 170, height: 40)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }else{
                    //購入済みの場合
                    if isPurchased {
                        TextField("word", text: $wordsArray[i])
                            .frame(width: 130, height: 40)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("....")
                        TextField("definition", text: $definitionsArray[i])
                            .frame(width: 170, height: 40)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    //未購入の場合,2~5行のTextFieldは無効
                    }else {
                            TextField("word", text: $wordsArray[i])
                                .disabled(true) //無効
                                .frame(width: 130, height: 40)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(5)
                            Text("....")
                            TextField("definition", text: $definitionsArray[i])
                                .disabled(true) //無効
                                .frame(width: 170, height: 40)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(5)
                    }
                }
            }
        }
    }
    //Realm辞書モデルに保存
    func addDictionary(word: [String], definition: [String]) -> Void {
        
        //配列の数分を保存
        for i in 0..<word.count {
            
            if(word[i] == "" || definition[i] == ""){
                continue
            }
            
            if word[i] != "" && definition[i] != "" {
                
                var changeToWord = Array(word[i])
                var changeToDefinition = Array(definition[i])
                
                for _ in 0 ..< changeToWord.count {
                    if (changeToWord.first == " " || changeToWord.first == "　"){
                        changeToWord.remove(at: 0)
                    }
                    if(changeToWord.last == " " || changeToWord.last == "　") {
                        changeToWord.remove(at: changeToWord.count-1)
                    }
                }
                
                for _ in 0 ..< changeToDefinition.count {
                    if (changeToDefinition.first == " " || changeToDefinition.first == "　"){
                        changeToDefinition.remove(at: 0)
                    }
                    if(changeToDefinition.last == " " || changeToDefinition.last == "　") {
                        changeToDefinition.remove(at: changeToDefinition.count-1)
                    }
                }
                
                let changeToStringWord = changeToWord.map{String($0)}
                let changeToStringDefinition = changeToDefinition.map{String($0)}
                
                var resultWord = changeToStringWord.joined()
                var resultDefinition = changeToStringDefinition.joined()
                
                resultWord = resultWord.replacingOccurrences(of: "\n", with: "")
                resultDefinition = resultDefinition.replacingOccurrences(of: "\n", with: "")
                
                
                if resultWord == "" || resultDefinition == "" {
                    continue
                }else {
                    
                    let realm = try! Realm()
                    
                    let insertData = DictionaryModel(value: ["word": resultWord, "definition": resultDefinition])
                    
                    try! realm.write{
                        realm.add(insertData, update: .modified)
                    }
                    addedIndexToString += "#\(i+1),"
                }
            }
        }
        //
        if addedIndexToString != "" {
            addedIndexToString = String(addedIndexToString.dropLast())
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                isAlert = true
            }
        }
    }
}

struct infomaition : View {
    
    @State var isAlert = false
    @Binding var isPurchased: Bool
    
    var body: some View {
        //未購入の場合
        if !isPurchased {
            Button {
                //Alertの呼び出し
                isAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                    Text("If you want to use all input functions")
                }
            }
            //Alert表示
            .alert("Warning", isPresented: $isAlert) {
                Button("OK") {
                    isAlert.toggle()
                }
            } message: {
                    Text("You need to purchase for product (Settings -> All function)")
            }
        }
    }
}



struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
