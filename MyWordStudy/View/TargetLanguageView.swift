//
//  TargetLanguageView.swift
//  MyWordsApp
//
//  Created by 川人悠生 on 2022/12/30.
//

import SwiftUI
import RealmSwift

struct TargetLanguageView: View {
     
    @ObservedObject var vm: TargetLangArray
    @ObservedResults(RecentlyTargetModel.self,sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var recent
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        
        List {
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
                        if(vm.targetLangArray[i].selected) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(Color.green)
                                .font(.title3)
                        }
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if vm.targetLangArray[i].selected { dismiss() }
                        else {
                            if let firstIndex = vm.targetLangArray.firstIndex(where: { $0.selected == true }) {
                                vm.targetLangArray[firstIndex].selected = false
                                vm.targetLangArray[i].selected = true
                                addTargetModel(language: vm.targetLangArray[i].language)
                            }
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
struct RecentTargetRow: View {
    @ObservedRealmObject var item: RecentlyTargetModel
    @ObservedObject var vm: TargetLangArray
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
            if let selectedIndex = vm.targetLangArray.firstIndex(where: { $0.language == item.language && $0.selected == false }) {
                if let firstIndex = vm.targetLangArray.firstIndex(where: { $0.selected == true }) {
                    vm.targetLangArray[firstIndex].selected = false
                    vm.targetLangArray[selectedIndex].selected = true
                    addTargetModel(language: item.language)
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
