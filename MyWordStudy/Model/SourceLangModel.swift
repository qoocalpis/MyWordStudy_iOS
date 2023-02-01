//
//  SourceLangModel.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/30.
//

import SwiftUI
import RealmSwift

//翻訳元になる言語モデルクラス
class SourceLangArray: ObservableObject {
    
    //構造体
    struct SourceLang {
        var parLanguage: String    //パラメーター言語
        var language: String       //言語
        var selected: Bool = false //選択or未選択
        
        //イニシャライザで定義できるようにする
        init(_ parLanguage: String, _ language: String, _ selected: Bool = false) {
            self.parLanguage = parLanguage
            self.language = language
            self.selected = selected
        }
        
    }
    
    //構造体SourceLangを言語毎に定義し配列に格納
    @Published var sourceLangArray: [SourceLang] = [
    SourceLang("BG", "Bulgarian"),
    SourceLang("CS","Czech"),
    SourceLang("DA", "Danish"),
    SourceLang("DE", "German"),
    SourceLang("EL", "Greek"),
    SourceLang("EN", "English", true),//初期値は英語を選択
    SourceLang("ES", "Spanish"),
    SourceLang("ET", "Estonian"),
    SourceLang("FI", "Finnish"),
    SourceLang("FR", "French"),
    SourceLang("HU", "Hungarian"),
    SourceLang("ID", "Indonesian"),
    SourceLang("IT", "Italian"),
    SourceLang("JA", "Japanese"),
    SourceLang("LT", "Lithuanian"),
    SourceLang("LV", "Latvian"),
    SourceLang("NL", "Dutch"),
    SourceLang("PL", "Polish"),
    SourceLang("PT", "Portuguese"),
    SourceLang("RO", "Romanian"),
    SourceLang("RU", "Russian"),
    SourceLang("SK", "Slovak"),
    SourceLang("SL", "Slovenian"),
    SourceLang("SV", "Swedish"),
    SourceLang("TR", "Turkish"),
    SourceLang("UK", "Ukrainian"),
    SourceLang("ZH", "Chinese")
    ]
}



//Realmのsource言語モデルを定義
final class RecentlySourceModel: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var language: String = "" //言語
    @Persisted var selected: Bool = true                   //選択
    @Persisted var date: Date = Date()                     //選択時の日時
}

//Realmのsource言語モデルに保存
func addSourceModel(language: String) -> Void {
    
    let realm = try! Realm()
    
    //Realmのsource言語モデルのレコード数
    let count = realm.objects(RecentlySourceModel.self).count

    //3レコードまで保存
    if count < 3 {
        try! realm.write {
            let insertData = RecentlySourceModel(value: ["language": language])
            realm.add(insertData, update: .modified)
        }
        //それ以上は古いレコードから削除しレコードを入れ直す
    }else {
        try! realm.write {
            realm.delete(realm.objects(RecentlySourceModel.self)[0])
            let insertData = RecentlySourceModel(value: ["language": language])
            realm.add(insertData, update: .modified)
        }
    }
    return
}

