//
//  DictionaryListView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/27.
//

import SwiftUI
import RealmSwift

struct DictionaryListView: View {
    //辞書モデルの情報を保持
    @ObservedResults(DictionaryModel.self) var items
    
    //イニシャライザで　items の参照方法を指定する
    init(searchText: String = "", sortAndfiltered: String) {
        //参照定義に必要な引数を変数に置き換える
        var sortBool: Bool  //true = 昇順, false = 降順
        var keyPath: String //sortする項目
        
        //表示順Pickerの値によって変数を設定
        switch sortAndfiltered {
            case "DESC":
                sortBool = false
                keyPath = "word"
            case "NEW":
                sortBool = false
                keyPath = "set_date"
            default :
                sortBool = true
                keyPath = "word"
        }
        //Pickerが”FAVORITE”の場合
        if  sortAndfiltered == "PENCIL✏️" {
            //検索テキストが空の場合
            if searchText.isEmpty {
                self._items = ObservedResults(DictionaryModel.self,
                                              filter: NSPredicate(format: "checkMark = true"),
                                              sortDescriptor: SortDescriptor.init(keyPath: keyPath, ascending: sortBool))
                //検索テキストに値がある場合
            } else {
                self._items = ObservedResults(DictionaryModel.self,
                                              filter: NSPredicate(format: "checkMark = true AND word CONTAINS[c] %@", searchText),
                                              sortDescriptor: SortDescriptor.init(keyPath: keyPath, ascending: sortBool))
            }
            //Pickerが”FAVORITE”以外の場合
        }else {
            //検索テキストが空の場合
            if  searchText.isEmpty {
                self._items = ObservedResults(DictionaryModel.self,
                                              sortDescriptor: SortDescriptor.init(keyPath: keyPath, ascending: sortBool))
                //検索テキストに値がある場合
            } else {
                self._items = ObservedResults(DictionaryModel.self,
                                              filter: NSPredicate(format: "word CONTAINS[c] %@", searchText),
                                              sortDescriptor: SortDescriptor.init(keyPath: keyPath, ascending: sortBool))
            }
        }
    }
    
    var body: some View {
        //Listに重ねてPlusButtonを右下に表示する
        ZStack(alignment: .bottomTrailing){
            //List形式のViewでitemsを表示
            List {
                ForEach(items) { item in
                    //ItemRow子Viewの呼び出し(下記参照)
                    ItemRow(item: item)
                }
                .onDelete(perform: $items.remove)
            }//PlusButtonの呼び出し(下記参照)
            PlusButton().padding(.trailing).padding(.bottom)
        }
    }
}

struct ItemRow: View {
    //親View(ObservedResults)から子Viewの呼び出し
    @ObservedRealmObject var item: DictionaryModel
    @State var size: Int = fechDefaultSize()
    
    var body: some View {
        
        HStack{
            //word definition PencilMarkを表示
            if size == 1 {
                Text(item.word)
                Spacer()
                Text(item.definition)
            }
            if size == 0 {
                Text(item.word).font(.callout)
                Spacer()
                Text(item.definition).font(.callout)
            }
            if size == 2 {
                Text(item.word).font(.title3)
                Spacer()
                Text(item.definition).font(.title3)
            }
            //PencilMarkをタップ毎に表示,非表示を切り替える
            Button {
                //タップ毎に辞書モデルをupdateする
                update_model(word: item.word, definition: item.definition, checkMark: item.checkMark, set_date: item.set_date)
            } label: {
                //表示の場合と非表示の場合でImageを切り替える
                Image(systemName: item.checkMark ? "pencil.circle.fill":"circle")
                    .foregroundColor(item.checkMark ? Color.green:Color.gray)
                    .opacity(item.checkMark ? 1:0.2)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .onAppear {
            size = fechDefaultSize()
        }
        //行の幅と行の線の色を指定
        .frame(maxWidth: .infinity, minHeight: 50)
        .listRowSeparatorTint(.orange)
    }
}

struct PlusButton: View {
    @State var showingSheet: Bool = false
    var body: some View {
        ZStack {
            Button {
                showingSheet.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill()
                        .foregroundColor(Color.white)
                        .frame(width: 50)
                        .shadow(radius: 7)
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(Color.mint)
                }
            }
            .sheet(isPresented: $showingSheet) {
                RegisterView()
            }
            .onAppear {
                showingSheet = false
            }
        }
    }
}

