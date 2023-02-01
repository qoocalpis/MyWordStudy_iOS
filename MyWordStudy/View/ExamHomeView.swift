//
//  ExamHomeView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/08.
//

import SwiftUI
import RealmSwift

struct ExamHomeView: View {
    
    @StateObject var storeKit = StoreKitManager()
    @State var isPurchased = false
    @State var isAlert = false
    @State var count: Int = funcCountPencil()
    @State var isStartSheet: Bool = false
    @State var isWrongSheet: Bool = false
    @State var today = Date()
    @ObservedResults(ResultExamModel.self,filter: NSPredicate(format: "resultBool = false")) var wrongs
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                StudyImageView()
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 50)
                    .opacity(0.4)
                HStack {
                    Spacer()
                    Text("\(today,style: .date)").padding(.trailing).padding(.bottom).font(.title3).foregroundColor(Color.black)
                }
            }
            HStack {
                Text("Spelling Exam")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle)
                    .padding(.leading)
                Spacer()
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 30))
                    .padding(-15)
                Text("× \(count) ")
                    .font(.system(size: 30))
                    .padding()
            }
            .onAppear() {
                count = funcCountPencil()
            }
            DetailExamListView()
            HStack {
                Button {
                    if isPurchased && wrongs.count > 0 {
                        isWrongSheet.toggle()
                    }
                    if !isPurchased {
                        isAlert.toggle()
                    }
                } label: {
                    ZStack {
                        if isPurchased && wrongs.count > 0 {
                            Rectangle()
                                .fill(Color.orange)
                                .cornerRadius(10)
                                .frame(width: 95, height: 70)
                                .shadow(radius: 2)
                        }else {
                            Rectangle()
                                .fill(Color.gray)
                                .cornerRadius(10)
                                .frame(width: 95, height: 70)
                                .shadow(radius: 2)
                        }
                        VStack {
                            Text("WRONG")
                                .foregroundColor(.white)
                            Text("TRY AGAIN")
                                .foregroundColor(.white)
                        }
                        if !isPurchased {
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundColor(Color("lockColor"))
                                .padding(EdgeInsets(
                                    top: 0,        // 上辺の余白幅
                                    leading: 90,    // 左辺の余白幅
                                    bottom: 50,     // 下辺の余白幅
                                    trailing: 0    // 右辺の余白幅
                                ))
                        }
                    }
                    .onAppear {
                        Task {
                            isPurchased = (try? await storeKit.isPurchased()) ?? false
                        }
                    }
                }
                .padding()
                Button {
                    if(0<count){ isStartSheet.toggle() }
                } label: {
                    ZStack {
                        if(0<count) {
                            Rectangle()
                                .fill(Color.cyan)
                                .cornerRadius(10)
                                .frame(width: 95, height: 70)
                                .shadow(radius: 2)
                        }else {
                            Rectangle()
                                .fill(Color.gray)
                                .cornerRadius(10)
                                .frame(width: 95, height: 70)
                                .shadow(radius: 2)
                        }
                        Text("START")
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .padding(.bottom)
            .alert("Warning", isPresented: $isAlert) {
                Button("OK") {
                }
            } message: {
                Text("You need to purchase for product (Settings -> All function)")
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $isStartSheet) {
            StartExamView(exams: intoArrayAllExam(), countExam: intoArrayCount(), isPresented: $isStartSheet)
        }
        .fullScreenCover(isPresented: $isWrongSheet) {
            WrongExamView(exams: intoArrayWrongExam(), countExam: intoArrayWrongCount(), isPresented_01: $isWrongSheet)
        }
    }
    
    var backgroundColorBody: some View {
        LinearGradient (
            gradient: Gradient(colors: [Color("BackgroundColorBlue"), Color.purple, Color("BackgroundColorBlue")]),
            startPoint: .topLeading,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}



struct ExamHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ExamHomeView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
    }
}
