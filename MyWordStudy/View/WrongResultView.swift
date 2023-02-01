//
//  WrongResultView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/14.
//

import SwiftUI
import RealmSwift

struct WrongResultView: View {
    
    @Binding var isPresented_01: Bool
    @Binding var exams: [ResultExam]
    
    var body: some View {
        NavigationStack {
            if exams.count == 0 {
                Text("NONE").font(.largeTitle)
            }else {
                ScrollView {
                    ForEach(0..<exams.count, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .stroke(exams[index].resultBool ? Color.green : Color.red, lineWidth: 10)
                                .frame(height: 100)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            VStack {
                                HStack {
                                    Image(systemName: exams[index].resultBool ? "checkmark.circle" : "xmark")
                                        .foregroundColor(exams[index].resultBool ? Color.green : Color.red)
                                    Text(exams[index].resultBool ? "correct!!" : "wrong…")
                                        .foregroundColor(exams[index].resultBool ? Color.green : Color.red)
                                    Spacer()
                                    Text("\(index+1)/\(exams.count)")
                                }
                                .frame(maxWidth: 300)
                                ScrollView(.horizontal) {
                                    VStack {
                                        Text(exams[index].word).font(.title3)
                                        Spacer()
                                        Text(exams[index].definition).font(.caption)
                                    }
                                }
                                .frame(maxWidth: 300)
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .navigationBarHidden(true)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            isPresented_01.toggle()
                        } label: {
                            HStack {
                                Text("Back")
                                Image(systemName: "circle")
                            }
                        }
                    }
                }
            }
        }
    }
}
