//
//  ExamViewModel.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/14.
//

import SwiftUI
import RealmSwift
import Foundation

//構造体ResultExamの定義
struct ResultExam: Identifiable{
    let id = UUID()         //一意コード
    let number: Int         //テスト順No
    let word: String        //単語
    let definition: String  //意味
    let resultBool: Bool    //テスト結果
}

//Penマーク有りのRealm辞書モデルの情報を構造体ResultExamに当てはめて順次配列に格納する
func intoArrayAllExam() -> [ResultExam] {
    
    var allExam: [ResultExam] = []
    
    let realm = try! Realm()
    
    let results = realm.objects(DictionaryModel.self).filter("checkMark = true")
    
    var index = 0
    
    for result in results {
        allExam.append(ResultExam(number: index, word: result.word, definition: result.definition, resultBool: false))
        index += 1
    }
    return allExam
}

//Penマーク有りのRealm辞書モデルの情報の数
func intoArrayCount() -> Int {
    
    let realm = try! Realm()
    
    let results = realm.objects(DictionaryModel.self).filter("checkMark = true")
    
    let count = results.count
    
    return count
}

//Realmテスト結果モデルの定義(保存用)
class ResultExamModel:  Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var number: Int //テストNo
    @Persisted var word: String                  //単語
    @Persisted var definition: String            //意味
    @Persisted var resultBool: Bool              //テスト結果
}

//Realmテスト結果モデルに保存
func addResultModel(results: [ResultExam]) -> Void {
    
    let realm = try! Realm()
    
    //前回に保存したレコードを削除
    try! realm.write{
        let userTable = realm.objects(ResultExamModel.self)
        realm.delete(userTable)
    }
    //新しく保存
    for result in results {
        let insertData = ResultExamModel(value: ["number": result.number, "word": result.word, "definition": result.definition, "resultBool": result.resultBool])
        try! realm.write{
            realm.add(insertData, update: .modified)
        }
    }
}

//Realmテスト結果モデルに保存した結果を更新
func updateDate(results: [ResultExam]) -> Void {
    
    let realm = try! Realm()
    
    for result in results {
        let insertData = ResultExamModel(value: ["number": result.number, "word": result.word, "definition": result.definition, "resultBool": result.resultBool])
        try! realm.write{
            realm.add(insertData, update: .modified)
        }
        
    }
}

//前回Spellingテストを間違えた問題を配列に格納
func intoArrayWrongExam() -> [ResultExam] {
    
    var allExam: [ResultExam] = []
    
    let realm = try! Realm()
    
    let results = realm.objects(ResultExamModel.self).filter("resultBool = false")
    
    for result in results {
        allExam.append(ResultExam(number: result.number, word: result.word, definition: result.definition, resultBool: false))
    }
    
    return allExam
}

//前回Spellingテストを間違えた問題の数
func intoArrayWrongCount() -> Int {
    
    let realm = try! Realm()
    
    let results = realm.objects(ResultExamModel.self).filter("resultBool = false")
    
    let count = results.count
    
    return count
}


//正答率%のクラスの定義
class Percentage: ObservableObject {
    
    @Published var percentage: Int = calculatePercentage()//保存されたRealm結果モデルから算出する関数
    
}

//保存されたRealm結果モデルから正答率%を算出する関数
func calculatePercentage() -> Int {
    
    let realm = try! Realm()
    
    let all = realm.objects(ResultExamModel.self)
    let allCount = all.count
    let corrects = realm.objects(ResultExamModel.self).filter("resultBool = true")
    let correctsCount = corrects.count
    
    if allCount == 0 {
        return 0
    }
    else {
        let percentage: Double = Double(correctsCount)/Double(allCount)*100
        return Int(percentage)
    }
}
