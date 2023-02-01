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
    
    @State var word = ["", "", "", "", ""]
    @State var definition = ["", "", "", "", ""]
    @State var isAlert: Bool = false
    @State var isSaveButton: Bool = false
    @State var addedIndexToString: String = ""
    @State var isPurchased: Bool = false
    @StateObject var storeKit = StoreKitManager()
    @FocusState private var nameFieldIsFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color("BackgroundColorBlue")
                    .ignoresSafeArea()
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
                    inputTextField()
                        .padding(1)
                    HStack{
                        Button {
                            word = ["", "", "", "", ""]
                            definition = ["", "", "", "", ""]
                        } label: {
                            resetBody
                        }
                        .padding(15)
                        Button {
                            addDictionary(word: word, definition: definition)
                            word = ["", "", "", "", ""]
                            definition = ["", "", "", "", ""]
                            read_model()
                        } label: {
                            saveBody
                        }
                        .padding(15)
                    }
                    .onAppear {
                        /// 0.3秒の遅延発生後TextFieldに初期フォーカスをあてる
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                            nameFieldIsFocused = true
                        }
                        Task {
                            isPurchased = (try? await storeKit.isPurchased()) ?? false
                        }
                    }
                    .onChange(of: word) { newValue in
                        isSaveButton = checkTextField(word: newValue, definition: definition)
                    }
                    .onChange(of: definition) { newValue in
                        isSaveButton = checkTextField(word: word, definition: newValue)
                    }
                    .alert("Result", isPresented: $isAlert) {
                        Button("OK") {
                            addedIndexToString = ""
                        }
                    } message: {
                        Text("\(addedIndexToString) successed!")
                    }
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
        ForEach(0..<word.count, id: \.self){ i in
            HStack {
                Text("#\(i+1)")
                if(i==0){
                    TextField("word", text: $word[i])
                        .focused($nameFieldIsFocused)
                        .frame(width: 130, height: 40)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("....")
                    TextField("definition", text: $definition[i])
                        .frame(width: 170, height: 40)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }else{
                    if isPurchased {
                        TextField("word", text: $word[i])
                            .frame(width: 130, height: 40)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("....")
                        TextField("definition", text: $definition[i])
                            .frame(width: 170, height: 40)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }else {
                            TextField("word", text: $word[i])
                                .disabled(true)
                                .frame(width: 130, height: 40)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(5)
                            Text("....")
                            TextField("definition", text: $definition[i])
                                .disabled(true)
                                .frame(width: 170, height: 40)
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(5)
                    }
                }
            }
        }
    }
    func addDictionary(word: [String], definition: [String]) -> Void {
        
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
        if !isPurchased {
            Button {
                isAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                    Text("If you want to use all input functions")
                }
            }
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
