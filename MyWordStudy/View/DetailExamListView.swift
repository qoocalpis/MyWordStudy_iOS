//
//  DetailExamListView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/10.
//


import SwiftUI
import RealmSwift

struct DetailExamListView: View {
    
    @State var isPresented = false
    @State var examArray = intoArrayAllExam()
    @ObservedResults(ResultExamModel.self,sortDescriptor: SortDescriptor(keyPath: "number", ascending: true)) var results
    @ObservedResults(ResultExamModel.self,filter: NSPredicate(format: "resultBool = true")) var correctResults
    
    var body: some View {
        VStack {
            Text("Percentage of correct answers on your last exam")
                .font(.callout)
                .padding(10)
            HStack {
                Spacer()
                Button {
                    isPresented.toggle()
                } label: {
                    Text("detail >").foregroundColor(Color.pink)
                }
                Text("\(calculatePercentage()) %")
                    .font(.system(size: 20))
                    .padding(.trailing)
            }
            .sheet(isPresented: $isPresented, content: {
                ResultExamView(isPresented: $isPresented)
            })
            .padding(.leading)
            ZStack {
                Rectangle()
                    .fill(Color("BackgroundColorBlue"))
                    .opacity(0.5)
                    .frame(height: 165)
                if (examArray.count == 0) {
                    Text("Nothing your list of exams")
                }
                if (examArray.count<4) {
                    HStack(spacing: 10) {
                        ForEach(0..<examArray.count, id: \.self){index in
                            ZStack {
                                Rectangle()
                                    .fill(Color.yellow)
                                    .cornerRadius(10)
                                    .frame(width: 110, height: 150)
                                    .shadow(radius: 1)
                                VStack {
                                    Text(" \(examArray[index].definition)")
                                        .foregroundColor(Color.black)
                                        .font(.caption2)
                                        .padding()
                                    HStack {
                                        Text("\(examArray[index].word.count)")
                                            .font(.caption2)
                                            .foregroundColor(Color.blue)
                                        Text(" characters")
                                            .font(.caption2)
                                            .foregroundColor(Color.black)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: 100, maxHeight: 140)
                }else {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(0..<examArray.count, id: \.self){index in
                                ZStack {
                                    Rectangle()
                                        .fill(Color.yellow)
                                        .cornerRadius(10)
                                        .frame(width: 110, height: 150)
                                        .shadow(radius: 1)
                                    VStack {
                                        Text(" \(examArray[index].definition)")
                                            .foregroundColor(Color.black)
                                            .font(.caption2)
                                            .padding()
                                        HStack {
                                            Text("\(examArray[index].word.count)")
                                                .font(.caption2)
                                                .foregroundColor(Color.blue)
                                            Text(" characters")
                                                .font(.caption2)
                                                .foregroundColor(Color.black)
                                        }
                                    }
                                    .frame(maxWidth: 100, maxHeight: 140)
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                examArray = intoArrayAllExam()
            }
        }
    }
    func calculatePercentage() -> Int {
        if results.count == 0 {
            return 0
        }
        else {
            let percentage: Double = Double(correctResults.count)/Double(results.count)*100
            return Int(percentage)
        }
    }
}

struct DetailExamListView_Previews: PreviewProvider {
    static var previews: some View {
        DetailExamListView()
    }
}

