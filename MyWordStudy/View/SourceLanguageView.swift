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
                        if vm.sourceLangArray[i].selected {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Color.green)
                                .font(.title3)
                        }
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if vm.sourceLangArray[i].selected { dismiss() }
                        else {
                            if let firstIndex = vm.sourceLangArray.firstIndex(where: { $0.selected == true }) {
                                vm.sourceLangArray[firstIndex].selected = false
                                vm.sourceLangArray[i].selected = true
                                addSourceModel(language: vm.sourceLangArray[i].language)
                            }
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct RecentSourceRow: View {
    @ObservedRealmObject var item: RecentlySourceModel
    @ObservedObject var vm: SourceLangArray
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack {
            Text(item.language)
                .font(.title3)
            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            if let selectedIndex = vm.sourceLangArray.firstIndex(where: { $0.language == item.language && $0.selected == false }) {
                if let firstIndex = vm.sourceLangArray.firstIndex(where: { $0.selected == true }) {
                    vm.sourceLangArray[firstIndex].selected = false
                    vm.sourceLangArray[selectedIndex].selected = true
                    addSourceModel(language: item.language)
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
