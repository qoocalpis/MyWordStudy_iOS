//
//  EmptyView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/04.
//

import SwiftUI

struct EmptyInfoView: View {
    
    @State var showingSheet: Bool = false
    
    var body: some View {
        ZStack{
            //背景色を設定
            LinearGradient(
                gradient: Gradient(colors: [Color("BackgroundColorBlue"), Color.purple, Color("BackgroundColorBlue")]),
                startPoint: .topLeading,
                endPoint: .bottom
            )
            //screen幅一杯まで広げる
            .ignoresSafeArea()
            
            VStack{
                Text("Please register new dictionary")
                    .font(.system(size: 27))
                Button {
                    //タップ時の処理
                    showingSheet.toggle()
                } label: {
                    ZStack {
                        //丸円
                        Circle()
                            .foregroundColor(Color.white)
                            .frame(width: 80)
                            .shadow(radius: 10)
                        Image(systemName: "plus")
                            .font(.title)
                    }
                }
                //showingSheetがtrue時にfullScreen(RegisterView())の呼び出し
                .fullScreenCover(isPresented: $showingSheet) {
                    RegisterView()
                }
            }
        }
    }
}




struct EmptyInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyInfoView()
    }
}
