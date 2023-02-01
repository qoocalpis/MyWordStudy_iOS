//
//  WrongExamView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/13.
//

import SwiftUI
import Combine
import AVFoundation

struct WrongExamView: View {
    @State var exams: [ResultExam]
    let countExam: Int
    @Binding var isPresented_01:Bool
    
    @State private var isLinkResultExamView = false
    @State private var isAnswer = false
    @State var enable: Bool = true
    @State var text = ""
    @State var index = 0
    @FocusState private var fieldIsFocused: Bool
    @State var sound: Bool = fechDefaultSound()
    
    private let correctSound = try!  AVAudioPlayer(data: NSDataAsset(name: "correctSound")!.data)
        
        private func correctPlaySound(){
            if sound {
                correctSound.stop()
                correctSound.currentTime = 0.0
                correctSound.play()
            }
        }
    
    private let wrongSound = try!  AVAudioPlayer(data: NSDataAsset(name: "wrongSound")!.data)

        private func wrongPlaySound(){
            if sound {
                wrongSound.stop()
                wrongSound.currentTime = 0.0
                wrongSound.play()
            }
        }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if isAnswer {
                        Text("correct").foregroundColor(Color.mint)
                        Text(exams[index].word)
                            .font(.title)
                    }
                    Text(exams[index].definition)
                        .font(.largeTitle)
                        .padding()
                    TextField("Input word", text: $text)
                        .keyboardType(.alphabet)
                        .disableAutocorrection(true)
                        .focused($fieldIsFocused)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .textFieldStyle(.roundedBorder)
                        .shadow(radius: 2)
                        .onReceive(Just(text)) { _ in
                            if text.count > exams[index].word.count {
                                text = String(text.prefix(exams[index].word.count))
                            }
                        }
                        .padding()
                    
                    Text("Characters \(text.count) / \(exams[index].word.count)")
                    buttonBody
                }
                .onAppear {
                    /// 0.3秒の遅延発生後TextFieldに初期フォーカスをあてる
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        fieldIsFocused = true
                    }
                }
                .onAppear {
                    sound = fechDefaultSound()
                }
                .onChange(of: text) { newValue in
                    if newValue == exams[index].word {
                        correctPlaySound()
                        exams[index] = ResultExam(number: exams[index].number, word: exams[index].word, definition: exams[index].definition, resultBool: true)
                        toNextExam()
                    }
                    if newValue == exams[countExam-1].word {
                        correctPlaySound()
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            //addResultModel(results: exams)
                            updateDate(results: exams)
                            isLinkResultExamView.toggle()
                        }
                    }
                }
                .navigationDestination(isPresented: $isLinkResultExamView) {
                    WrongResultView(isPresented_01: $isPresented_01, exams: $exams)
                }
                if text == exams[index].word {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.green)
                        .opacity(0.5)
                        .font(.system(size: 200))
                }
                if isAnswer {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.red)
                        .opacity(0.5)
                        .font(.system(size: 200))
                }
            }
            .toolbar {
                ToolbarItem {
                    Text("\(index+1) / \(countExam)")
                        .font(.title)
                        .padding()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented_01.toggle()
                    }
                }
            }
        }
    }
    var buttonBody: some View {
        VStack {
            if (index<countExam-1) {
                Button {
                    wrongPlaySound()
                    enable.toggle()
                    isAnswer = true
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        isAnswer = false
                        index+=1
                        text = ""
                        enable.toggle()
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 60, height: 40)
                            .cornerRadius(10)
                        Text("skip")
                    }
                }
                .disabled(!enable)
            }
            if(index == countExam-1){
                Button {
                    wrongPlaySound()
                    enable.toggle()
                    isAnswer = true
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        //addResultModel(results: exams)
                        updateDate(results: exams)
                        isAnswer = false
                        text = ""
                        isLinkResultExamView.toggle()
                        enable.toggle()
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 60, height: 40)
                            .cornerRadius(10)
                        Text("end")
                    }
                }
                .disabled(!enable)
            }
        }
    }
    func toNextExam() -> Void {
        /// 0.3秒の遅延発生後TextFieldに初期フォーカスをあてる
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            if(index<countExam-1){
                index+=1
            }
            text = ""
        }
    }
}


//struct WrongExamView_Previews: PreviewProvider {
//    static var previews: some View {
//        WrongExamView()
//    }
//}
