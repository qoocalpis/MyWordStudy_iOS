//
//  SourceLanguageView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/29.
//

import SwiftUI
import RealmSwift

struct SourceLanguageView: View {
    
    //SourceLangModelに定義
    @ObservedObject var vm: SourceLangArray
    @ObservedResults(RecentlySourceModel.self,sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var recent
    
    //親View(TranslateView)へ戻る際のdismiss処理
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        List {
            //RecentlySourceModelにレコードが存在する場合
            if(recent.count>0){
                Section("Recent") {
                    ForEach(recent) { item in
                        RecentSourceRow(item: item, vm: vm)
                    }
                }
            }
            Section("Source Language") {
                ForEach(0..<vm.sourceLangArray.count, id: \.self) { i in
                    HStack {
                        Text(vm.sourceLangArray[i].language)
                            .font(.title3)
                        Spacer()
                        //選択状態の言語にcheckmarkを設定
                        if vm.sourceLangArray[i].selected {
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
                        if vm.sourceLangArray[i].selected { dismiss() }
                        //新しく言語選択した場合
                        else {
                            //現在選択状態の言語から新しくtapした言語を選択状態に切り替える
                            if let firstIndex = vm.sourceLangArray.firstIndex(where: { $0.selected == true }) {
                                vm.sourceLangArray[firstIndex].selected = false
                                vm.sourceLangArray[i].selected = true
                                //RecentlySourceModelに保存
                                addSourceModel(language: vm.sourceLangArray[i].language)
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

struct RecentSourceRow: View {
    //親View(SourceLanguageView)からの引き継ぎ
    @ObservedRealmObject var item: RecentlySourceModel
    @ObservedObject var vm: SourceLangArray
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
            if let selectedIndex = vm.sourceLangArray.firstIndex(where: { $0.language == item.language && $0.selected == false }) {
                //現在選択状態の言語から新しくtapした言語を選択状態に切り替える
                if let firstIndex = vm.sourceLangArray.firstIndex(where: { $0.selected == true }) {
                    vm.sourceLangArray[firstIndex].selected = false
                    vm.sourceLangArray[selectedIndex].selected = true
                    //RecentlySourceModelに保存
                    addSourceModel(language: item.language)
                    //TranslateViewに戻る
                    dismiss()
                }
            }
        }
    }
}


//struct SourceLanguageView_Previews: PreviewProvider {
//    static var previews: some View {
//        SourceLanguageView(sourceLangArray: $sourceLangArray)
//    }
//}
