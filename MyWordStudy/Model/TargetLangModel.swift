//
//  TargetLangModel.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/31.
//

import SwiftUI
import RealmSwift

//翻訳先になる言語モデルクラス
class TargetLangArray: ObservableObject {
    
    //構造体
    struct TargetLang {
        var parLanguage: String       //パラメーター言語
        var language: String          //言語
        var selected: Bool = false    //選択or未選択
        
        //イニシャライザで定義できるようにする
        init(_ parLanguage: String, _ language: String, _ selected: Bool = false) {
            self.parLanguage = parLanguage
            self.language = language
            self.selected = selected
        }
    }
    
    //構造体TargetLangを言語毎に定義し配列に格納
    @Published var targetLangArray: [TargetLang] = [
        TargetLang("BG", "Bulgarian"),
        TargetLang("CS","Czech"),
        TargetLang("DA", "Danish"),
        TargetLang("DE", "German"),
        TargetLang("EL", "Greek"),
        TargetLang("EN", "English"),
        TargetLang("ES", "Spanish"),
        TargetLang("ET", "Estonian"),
        TargetLang("FI", "Finnish"),
        TargetLang("FR", "French"),
        TargetLang("HU", "Hungarian"),
        TargetLang("ID", "Indonesian"),
        TargetLang("IT", "Italian"),
        TargetLang("JA", "Japanese", true),//初期値は日本語を選択
        TargetLang("LT", "Lithuanian"),
        TargetLang("LV", "Latvian"),
        TargetLang("NL", "Dutch"),
        TargetLang("PL", "Polish"),
        TargetLang("PT", "Portuguese"),
        TargetLang("RO", "Romanian"),
        TargetLang("RU", "Russian"),
        TargetLang("SK", "Slovak"),
        TargetLang("SL", "Slovenian"),
        TargetLang("SV", "Swedish"),
        TargetLang("TR", "Turkish"),
        TargetLang("UK", "Ukrainian"),
        TargetLang("ZH", "Chinese")
    ]
}

//RealmのTarget言語モデルを定義
final class RecentlyTargetModel: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var language: String = ""  //言語
    @Persisted var selected: Bool = true                    //選択
    @Persisted var date: Date = Date()                      //選択時の日時
}

//RealmのTarget言語モデルに保存
func addTargetModel(language: String) -> Void {
    
    let realm = try! Realm()
    
    //RealmのTarget言語モデルのレコード数
    let count = realm.objects(RecentlyTargetModel.self).count

    //3レコードまで保存
    if count < 3 {
        try! realm.write {
            let insertData = RecentlyTargetModel(value: ["language": language])
            realm.add(insertData, update: .modified)
        }
    //それ以上は古いレコードから削除しレコードを入れ直す
    }else {
        try! realm.write {
            realm.delete(realm.objects(RecentlyTargetModel.self)[0])
            let insertData = RecentlyTargetModel(value: ["language": language])
            realm.add(insertData, update: .modified)
        }
    }
    return
}
