//
//  TargetLanguageView.swift
//  MyWordsApp
//
//  Created by 川人悠生 on 2022/12/30.
//

import SwiftUI
import RealmSwift

struct TargetLanguageView: View {
     
    //TargetLangModelに定義
    @ObservedObject var vm: TargetLangArray
    @ObservedResults(RecentlyTargetModel.self,sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var recent
    
    //親View(TranslateView)へ戻る際のdismiss処理
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        
        List {
            //RecentlyTargetModelにレコードが存在する場合
            if(recent.count>0){
                Section("Recent") {
                    ForEach(recent) { item in
                        RecentTargetRow(item: item, vm: vm)
                    }
                }
            }
            Section("Target Language") {
                ForEach(0..<vm.targetLangArray.count, id: \.self) { i in
                    HStack {
                        Text(vm.targetLangArray[i].language)
                            .font(.title3)
                        Spacer()
                        //選択状態の言語にcheckmarkを設定
                        if(vm.targetLangArray[i].selected) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Color.green)
                                .font(.title3)
                        }
                    }
                    .padding()
                    .contentShape(Rectangle())
                    //tap時の処理
                    .onTapGesture {
                        //元々選択済の言語をtapした場合TranslateViewに戻る
                        if vm.targetLangArray[i].selected { dismiss() }
                        //新しく言語選択した場合
                        else {
                            //現在選択状態の言語から新しくtapした言語を選択状態に切り替える
                            if let firstIndex = vm.targetLangArray.firstIndex(where: { $0.selected == true }) {
                                vm.targetLangArray[firstIndex].selected = false
                                vm.targetLangArray[i].selected = true
                                //RecentlyTargetModelに保存
                                addTargetModel(language: vm.targetLangArray[i].language)
                            }
                            //TranslateViewに戻る
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
struct RecentTargetRow: View {
    //親View(TargetLanguageView)からの引き継ぎ
    @ObservedRealmObject var item: RecentlyTargetModel
    @ObservedObject var vm: TargetLangArray
    //親View(TranslateView)へ戻る際のdismiss処理
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack {
            Text(item.language)
                .font(.title3)
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        //tap時の処理
        .onTapGesture {
            //新しく言語選択した場合
            if let selectedIndex = vm.targetLangArray.firstIndex(where: { $0.language == item.language && $0.selected == false }) {
                //現在選択状態の言語から新しくtapした言語を選択状態に切り替える
                if let firstIndex = vm.targetLangArray.firstIndex(where: { $0.selected == true }) {
                    vm.targetLangArray[firstIndex].selected = false
                    vm.targetLangArray[selectedIndex].selected = true
                    //RecentlyTargetModelに保存
                    addTargetModel(language: item.language)
                    //TranslateViewに戻る
                    dismiss()
                }
            }
        }
    }
}


//struct TargetLanguageView_Previews: PreviewProvider {
//    static var previews: some View {
//        TargetLanguageView()
//    }
//}
