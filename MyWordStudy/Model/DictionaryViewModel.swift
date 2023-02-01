//
//  DictionaryModel.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/02.
//

import SwiftUI
import RealmSwift

//Realm辞書モデルの定義
final class DictionaryModel: Object, ObjectKeyIdentifiable{
    
    @Persisted(primaryKey: true) var word: String = ""  //単語or熟語
    @Persisted var definition: String = ""              //定義
    @Persisted var set_date: Date = Date()              //現在日付時刻
    @Persisted var checkMark: Bool = false              //PencilMarkの有無
    
}

//Realm辞書モデルに保存
func add_model(word: String, definition: String) -> Void {
    
    //単語と意味に値がある場合
    if word != "" && definition != "" {
        
        var changeToWord = Array(word)
        var changeToDefinition = Array(definition)
        
        //word,前後に空白があれば削除する(全角半角スペース両方)
        for _ in 0 ..< changeToWord.count {
            if (changeToWord.first == " " || changeToWord.first == "　"){
                changeToWord.remove(at: 0)
            }
            if(changeToWord.last == " " || changeToWord.last == "　") {
                changeToWord.remove(at: changeToWord.count-1)
            }
        }
        //definition,前後に空白があれば削除する(全角半角スペース両方)
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
        
        //改行された値を一行にする処理
        resultWord = resultWord.replacingOccurrences(of: "\n", with: "")
        resultDefinition = resultDefinition.replacingOccurrences(of: "\n", with: "")

        //単語または意味に値がない場合
        if resultWord == "" || resultDefinition == "" {
            return
        //値ありの場合保存
        }else {
            
            let realm = try! Realm()
            
            let insertData = DictionaryModel(value: ["word": resultWord, "definition": resultDefinition])
            
            try! realm.write{
                realm.add(insertData, update: .modified)
            }
            return
        }
    }
    return
}



//Realm辞書モデルの更新(Penマークの有無によって処理)
func update_model(word: String, definition: String, checkMark: Bool, set_date: Date) -> Void {
    
    func changeMark(checkMark: Bool) -> Bool {
        if checkMark {
            return false
        }else {
            return true
        }
    }
    
    let realm = try! Realm()
    
    try! realm.write{
        let record = DictionaryModel(value: ["word": word, "definition": definition, "checkMark": changeMark(checkMark: checkMark), "set_date": set_date])
        realm.add(record, update: .modified)
    }
}


//Penマークがある(True)のレコード数を取得
func funcCountPencil() -> Int {
    
    let realm = try! Realm()
    
    let results = realm.objects(DictionaryModel.self).filter("checkMark = true")
    
    let count = results.count
    
    return count
}


//以下のremoveCheckMark()とdeleteLocalData()はSettingViewで使われる
//Penマークの数を0にする
func removeCheckMark() -> Void {
    
    let realm = try! Realm()
    
    let results = realm.objects(DictionaryModel.self)

    try! realm.write{
        
        results.setValue(false, forKey: "checkMark")
    }
}

//Realmを使用している全てのモデルの情報を削除
//(DictionaryModelやRecentlySourceModelやRecentlyTargetModelなど全て)
func deleteLocalData() -> Void {
    
    let realm = try! Realm()
    
    try! realm.write {
        // Delete all objects from the realm.
        realm.deleteAll()
    }
}



//以下はApp内で使用していない
//Realm辞書モデルの情報をPrint
func read_model() -> Void {
    
    let realm = try! Realm()
    
    try! realm.write{
        let userTable = realm.objects(DictionaryModel.self).sorted(byKeyPath: "word")
        print(userTable)
    }
    
}

//Realm辞書モデル情報を削除
func delete_model() -> Void {
    
    let realm = try! Realm()
    
    try! realm.write{
        let userTable = realm.objects(DictionaryModel.self)
        realm.delete(userTable)
    }
}
