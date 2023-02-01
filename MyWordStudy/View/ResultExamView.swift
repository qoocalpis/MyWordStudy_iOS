//
//  ResultExamView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/04.
//

import SwiftUI
import RealmSwift

struct ResultExamView: View {
    
    @Binding var isPresented: Bool
    @ObservedResults(ResultExamModel.self,sortDescriptor: SortDescriptor(keyPath: "number", ascending: true)) var results
    
    var body: some View {
        NavigationStack {
            if results.count == 0 {
                Text("None").font(.largeTitle)
            }else {
                ScrollView {
                    ForEach(results) { result in
                        ZStack {
                            Rectangle()
                                .stroke(result.resultBool ? Color.green : Color.red, lineWidth: 10)
                                .frame(height: 100)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            VStack {
                                HStack {
                                    Image(systemName: result.resultBool ? "checkmark.circle" : "xmark")
                                        .foregroundColor(result.resultBool ? Color.green : Color.red)
                                    Text(result.resultBool ? "correct!!" : "wrong…")
                                        .foregroundColor(result.resultBool ? Color.green : Color.red)
                                    Spacer()
                                    Text("\(result.number+1)/\(results.count)")
                                }
                                .frame(maxWidth: 300)
                                ScrollView(.horizontal) {
                                    VStack {
                                        Text(result.word).font(.title3)
                                        Spacer()
                                        Text(result.definition).font(.caption)
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
                            isPresented.toggle()
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

//struct ResultExamView_Previews: PreviewProvider {
//    static var previews: some View {
//        ResultExamView(isPresented: $isPresented, results: $results)
//    }
//}
