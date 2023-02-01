//
//  SettingViewModel.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/19.
//

import SwiftUI
import RealmSwift

//Realm設定モデルの定義
class SettingViewModel: Object, ObjectKeyIdentifiable  {
    
    @Persisted(primaryKey: true) var pk: Int = 0 //一件しか保存しないのでpkは0で固定
    @Persisted var size: Int = 1                 //文字サイズ
    @Persisted var screen: Int = 0               //HomeTabViewのselectTabIndex
    @Persisted var sound: Bool = true            //Examの効果音
    
}

//文字サイズの取得
func fechDefaultSize() -> Int {
    
    let realm = try! Realm()
    
    //変更済の場合
    if let result = realm.objects(SettingViewModel.self).first {
        return result.size
    }
    //未変更ならデフォルトで1
    return 1
}

//起動後直後の立ち上げ画面の取得
func fechDefaultScreen() -> Int {
    
    let realm = try! Realm()
    
    //変更済の場合
    if let result = realm.objects(SettingViewModel.self).first {
        return result.screen
    }
    //未変更ならデフォルトで0
    return 0
}

//Soundの有無
func fechDefaultSound() -> Bool {
    
    let realm = try! Realm()
    
    //変更済の場合
    if let result = realm.objects(SettingViewModel.self).first {
        return result.sound
    }
    //未変更ならデフォルトでfalse
    return false
}

//Realm設定モデルへの更新
func updateDefault(size: Int, screen: Int, sound: Bool) -> Void {
    
    let realm = try! Realm()
    
    let insertData = SettingViewModel(value: ["pk": 0, "size": size, "screen": screen, "sound": sound])
    
    try! realm.write {
        
        realm.add(insertData, update: .modified)
        
    }
    return
}
