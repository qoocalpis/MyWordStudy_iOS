//
//  HomeTabView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/01.
//

import SwiftUI
import RealmSwift

struct HomeTabView: View {
    
    //辞書モデル,翻訳言語モデルの情報を保持
    @ObservedResults(DictionaryModel.self) var results
    @ObservedResults(RecentlySourceModel.self) var resultsRecentSource
    @ObservedResults(RecentlyTargetModel.self) var resultsRecentTarget
    
    //screenのサイズを取得
    let screenSizeWidth = UIScreen.main.bounds.width
    let screenSizeHeight = UIScreen.main.bounds.height
    
    //TabViewのtag(selectTabIndex)の初期値を指定
    @State var selectTabIndex = fechDefaultScreen()
    
    //イニシャライザ(Tabのカラー設定)
    init(){
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 0/255, green: 111/255, blue: 98/255, alpha: 1)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        
        TabView(selection: $selectTabIndex) {
            //辞書が登録されていない場合
            if results.count == 0 {
                EmptyInfoView()
                    .tabItem {
                        Image(systemName: "books.vertical")
                        Text("Dictionary")
                    }.tag(0)
                //辞書が登録されている場合
            }else {
                DictionaryView()
                    .tabItem {
                        Image(systemName: "books.vertical")
                        Text("Dictionary")
                    }.tag(0)
            }
            //翻訳
            TranslateView(selectTabIndex: $selectTabIndex, countRecentSource: resultsRecentSource.count, countRecentTarget: resultsRecentTarget.count)
                .tabItem {
                    HStack{
                        Image(systemName: "character.book.closed.fill")
                        Text("Translation")
                    }
                }.tag(1)
            
            //テキストスキャナー(※一時的に未実装にしている....)
//            CameraScannerView()
//                .tabItem {
//                    HStack {
//                        Image(systemName: "camera.viewfinder")
//                        Text("Scanner")
//                    }
//                }.tag(2)
            
            //単語スペルテスト
            ExamHomeView()
                .tabItem {
                    Image(systemName: "pencil.circle.fill")
                    Text("Spelling")
                }.tag(3)
            //設定
            SettingView()
                .tabItem {
                    Image(systemName: "gear.badge.questionmark")
                    Text("Setting")
                }.tag(4)
        }
        //選択中のImage(sysName)の色を設定
        .accentColor(Color.yellow)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeTabView()
//           // .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
//    }
//}
