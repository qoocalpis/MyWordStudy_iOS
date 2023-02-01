//
//  DeleteDataView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/21.
//

import SwiftUI

struct DeleteDataView: View {
    
    @State var sec: Int = 5
    @Environment(\.dismiss) private var dismiss
    @GestureState var isDetectingLongPress = false
    @State var isAlert: Bool = false
    
    @Binding var sound: Bool
    @Binding var size: Int
    @Binding var screen: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColorRedBlack")
                    .opacity(0.4)
                    .ignoresSafeArea(edges: [.bottom])
                VStack {
                    Text("Dictionary get disappeared,")
                        .padding(.top)
                    Text("if you push under the button.")
                    HStack {
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
                .navigationTitle("Warning")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark").font(.title3)
                        }
                    }
                }
                .onReceive(timer) { _ in
                    if isDetectingLongPress {
                        sec -= 1
                    }else {
                        sec = 5
                    }
                }
                .alert("Completed!", isPresented: $isAlert) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Deleted all dicionary and data in App")
                }
            }
        }
    }
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 5)
        
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
                transaction.animation = Animation.easeIn(duration: 4.0)
            }
            .onEnded {_finished in
                deleteLocalData()
                sound = true
                size = 1
                screen = 0
                isAlert.toggle()
            }
    }
}




//struct DeleteDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeleteDataView()
//    }
//}
