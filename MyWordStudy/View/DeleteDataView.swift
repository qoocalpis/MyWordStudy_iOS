//
//  DeleteDataView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/21.
//

import SwiftUI

struct DeleteDataView: View {
    
    //親View(SettingView)からプロパティの引き継ぎ
    @Binding var sound: Bool
    @Binding var size: Int
    @Binding var screen: Int
    
    //親View(SettingView)へ戻る際のdismiss処理
    @Environment(\.dismiss) private var dismiss
    //タイマー
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    //長押し状態
    @GestureState var isDetectingLongPress = false
    //秒の初期値
    @State var sec: Int = 5
    //Alertの呼び出し状態
    @State var isAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                //背景色の設定
                Color("BackgroundColorRedBlack")
                    .opacity(0.4)
                    .ignoresSafeArea(edges: [.bottom])
                VStack {
                    //説明を表示
                    Text("Dictionary get disappeared,")
                        .padding(.top)
                    Text("if you push under the button.")
                    HStack {
                        //必要LongTap時間の表示
                        Text("Press and hold for ")
                        ZStack {
                            Circle()
                                .frame(width: 50)
                            Text("\(sec)")
                                .foregroundColor(Color.orange)
                                .font(.title)
                        }
                        Text(" seconds to clear")
                    }
                    .font(.headline)
                    
                    ZStack {
                        Rectangle()
                            .fill(isDetectingLongPress ? Color.red : Color.yellow)
                            .frame(width: 300, height: 75)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .gesture(longPress)
                        Text("Please hold this button down")
                            .font(.headline)
                            .foregroundColor(Color.purple)
                    }
                    .padding().padding(.bottom)
                    
                }
                //タイトル
                .navigationTitle("Warning")
                .navigationBarTitleDisplayMode(.inline)
                //左上に戻るボタン表示
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            //親View(SettingView)へ戻る
                            dismiss()
                        } label: {
                            Image(systemName: "xmark").font(.title3)
                        }
                    }
                }
                .onReceive(timer) { _ in
                    //長押し時にタイマー毎に1マイナス
                    if isDetectingLongPress {
                        sec -= 1
                    //tap状態ではない場合初期値に戻す
                    }else {
                        sec = 5
                    }
                }
                //isAlertがtrue時にAlertの表示
                .alert("Completed!", isPresented: $isAlert) {
                    Button("OK") {
                        //親View(SettingView)へ戻る
                        dismiss()
                    }
                } message: {
                    Text("Deleted all dicionary and data in App")
                }
            }
        }
    }
    
    var longPress: some Gesture {
        //5秒間の監視と検知
        LongPressGesture(minimumDuration: 5)
            //監視しながら4秒間でAnimationの動作を指定
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 4.0)
            }
            //5秒終了時
            .onEnded {_finished in
                //全テーブルのレコードを削除
                deleteLocalData()
                //格設定も初期値に戻す
                sound = true
                size = 1
                screen = 0
                //Alertの呼び出し
                isAlert.toggle()
            }
    }
}




//struct DeleteDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteDataView()
//    }
//}
