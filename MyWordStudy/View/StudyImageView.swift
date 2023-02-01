//
//  StudyImageView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/22.
//

import SwiftUI

struct StudyImageView: View {
    
    //screenサイズを取得
    let screenSizeWidth = UIScreen.main.bounds.width
    let screenSizeHeight = UIScreen.main.bounds.height
    
    //列挙型のどれかのiPhoneType
    let iPhoneType: screenType
    
    //列挙型でiPhoneTypeを定義
    enum screenType {
        case iPhoneType01 //SE2nd, SE3nd
        case iPhoneType02 //11Pro, 12mini, 13mini
        case iPhoneType03 //12, 12Pro 13, 13Pro, 14
        case iPhoneType04 //14Pro
        case iPhoneType05 //11, 11ProMax
        case iPhoneType06 //12ProMax, 13ProMax, 14Plus
        case iPhoneType07 //14ProMax
    }
    
    //イニシャライザでプロパティiPhoneTypeを設定
    init() {
        switch (screenSizeWidth, screenSizeHeight) {
            case (375.0, 667.0): iPhoneType = .iPhoneType01
            case (375.0, 812.0): iPhoneType = .iPhoneType02
            case (390.0, 844.0): iPhoneType = .iPhoneType03
            case (393.0, 852.0): iPhoneType = .iPhoneType04
            case (414.0, 896.0): iPhoneType = .iPhoneType05
            case (428.0, 926.0): iPhoneType = .iPhoneType06
            default: iPhoneType = .iPhoneType07
        }
    }
    
    var body: some View {
        
        //格iPhoneTypeによってImageサイズを調整表示
        
        if iPhoneType == .iPhoneType01 {
            Image("studyImage")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
        }
        
        if iPhoneType == .iPhoneType02 || iPhoneType == .iPhoneType03 || iPhoneType == .iPhoneType04 {
            Image("studyImage")
                .resizable()
                .scaledToFill()
                .frame(width: screenSizeWidth, height: 200)
                .clipped()
        }
        
        if iPhoneType == .iPhoneType05 || iPhoneType == .iPhoneType06 || iPhoneType == .iPhoneType07 {
            Image("studyImage")
                .resizable()
                .scaledToFill()
                .frame(width: screenSizeWidth, height: 250)
                .clipped()
        }
    }
}

struct StudyImageView_Previews: PreviewProvider {
    static var previews: some View {
        StudyImageView()
    }
}
