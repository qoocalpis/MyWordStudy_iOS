//
//  DeeplAPI.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2022/12/21.
//

import SwiftUI
import Alamofire



extension TranslateView {
    
    // DeepL APIのレスポンス用構造体
    struct DeepLResult: Codable {
        let translations: [Translation]
        struct Translation: Codable {
            var detected_source_language: String
            var text: String
        }
    }
    
    //  翻訳実行
    func translation(text: String, sourcePara: String, targetPara: String) {
        
        // DeepL API認証キー
        let authKey: String = "************************************"
        // APIリクエストするパラメータを作成
        let parameters: [String: String] = [
            "text": text,
            "target_lang": targetPara,
            "auth_key": authKey,
            "source_lang": sourcePara
        ]
        // ヘッダーを作成
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        // JSONデコード用
        let decoder: JSONDecoder = JSONDecoder()
        // DeepL APIを実行
        AF.request("https://api-free.deepl.com/v2/translate", method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default, headers: headers).responseDecodable(of: DeepLResult.self) { response in
            // リクエスト成功か判定
            if case .success = response.result {
                do {
                    // 結果をデコード
                    let result = try decoder.decode(DeepLResult.self, from: response.data!)
                    // 結果のテキストを取得&画面に反映
                    for tex in result.translations {
                        print("\(tex.text)")
                    }
                    translatedText =  result.translations[0].text
                    
                } catch {
                    debugPrint("デコード失敗")
                }
            } else {
                debugPrint("APIリクエストエラー")
            }
        }
    }
}
