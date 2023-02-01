//
//  DictionaryHomeView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/08.
//

import SwiftUI
import RealmSwift
import UIKit

struct DictionaryView: View {
    
    //辞書モデルの情報を所持
    @ObservedResults(DictionaryModel.self) var results
    //表示順の選択リストを作成
    let sortPicker: [String] = ["ASC", "DESC", "NEW", "PENCIL✏️"]
    @State var sortAndfiltered = "ASC" //表示順の初期値
    @State var searchText = "" //検索テキストの初期値
    
    var body: some View {
        NavigationStack{
            ZStack {
                //背景色を設定
                Color("BackgroundColorBlue")
                //Listを表示(DictionaryListViewファイル)
                DictionaryListView(searchText: searchText, sortAndfiltered: sortAndfiltered)
                //Listの影を設定
                    .shadow(radius: 9)
                //Listの背景色を設定
                    .background(Color("BackgroundColorBlue"))
                    .scrollContentBackground(.hidden)
                //タイトルとレイアウトを指定
                    .navigationTitle("Dictionary")
                    .navigationBarTitleDisplayMode(.inline)
                //タイトルの左右に Pencil, 表示順Picker, 編集ボタン を配置
                    .toolbar {
                        //左側 Pencil(下記を参照)
                        ToolbarItem(placement: .navigationBarLeading) { Pencil() }
                        //右側 表示順Picker
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Picker(selection: $sortAndfiltered, label: Text("")) {
                                ForEach(sortPicker.indices, id: \.self) { index in
                                    Text("\(sortPicker[index])").tag("\(sortPicker[index])")
                                }
                            }
                        }//右側 編集ボタン
                        ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                    }
            }
        }//検索テキスト(変数searchTextに代入)
        .searchable(text: $searchText)
    }
}

struct Pencil: View {
    //PencilMarkの数
    @State var countPencil: Int = funcCountPencil()
    var body: some View {
        ZStack(alignment: .center) {
            //丸い長方形の図形を作成
            Rectangle()
                .fill(Color.white)
                .frame(width: 90, height: 40)
                .cornerRadius(10)
                .shadow(radius: 9)
            HStack {
                //Image(pencil.circle)とcountPencil(数)を表示
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(Color.green)
                    .font(.system(size: 20))
                Text("× \(countPencil)")
                    .font(.system(size: 20))
                    .foregroundColor(Color.black)
            }//数が変更する度に変数countPencilに代入
            .onChange(of: funcCountPencil()) { newValue in
                countPencil = newValue
            }
        }
    }
}


struct DictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        DictionaryView()
    }
}

