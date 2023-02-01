//
//  StoreKitManager.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/26.
//

import Foundation
import StoreKit

//Errorタイプを列挙型で定義
public enum StoreError: Error {
    case failedVerification
}

//課金用StoreKitManagerクラスの定義
class StoreKitManager: ObservableObject {
    
    //非消耗型のProductの情報
    @Published var storeProducts: [Product] = []
    @Published var purchasedCourses : [Product] = []
    
    //トランザクションプロパティ
    var updateListenerTask: Task<Void, Error>? = nil
    
    //PropertyList.plistの情報用の二次元配列
    private let productDict: [String : String]
    
    //イニシャライザでproductDictの情報を取得
    init() {
        
        //PropertyList.plistの有無
        if let plistPath = Bundle.main.path(forResource: "PropertyList", ofType: "plist"),
           //FileManagerを使用してplistPathからproductsの情報を取得
           let plist = FileManager.default.contents(atPath: plistPath) {
            productDict = (try? PropertyListSerialization.propertyList(from: plist, format: nil) as? [String : String]) ?? [:]
        } else {
            productDict = [:]
        }
        
        //トランザクションを見逃さないように、できるだけアプリの起動に近いタイミングでトランザクションを取得
        updateListenerTask = listenForTransactions()
        
        //非同期処理
        Task {
            await requestProducts()
            
            //顧客が購入した商品
            await updateCustomerProductStatus()
        }
    }
    
    //終了時またはアプリ終了時にトランザクションを終了する
    deinit {
        updateListenerTask?.cancel()
    }
    
    //トランザクションを取得 - アプリの開始時に実行
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //'purchase()' への直接呼び出し以外のすべてのトランザクションを繰り返す
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    //トランザクションが検証され、コンテンツがユーザーに配信される
                    await self.updateCustomerProductStatus()
                    
                    //常にトランザクションを終了
                    await transaction.finish()
                    
                } catch {
                    
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    // バックグラウンドでProduct情報を取得処理
    @MainActor
    func requestProducts() async {
        do {
            storeProducts = try await Product.products(for: productDict.values)
            
        } catch {
            print("Failed - error retrieving products \(error)")
        }
    }
    
    
    //ジェネリック型 VerificationResultをチェック
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //JWS が StoreKit 検証に合格するかどうかを確認
        switch result {
            case .unverified:
                //検証失敗
                throw StoreError.failedVerification
            case .verified(let signedType):
                //結果が検証され、ラップされていない値
                return signedType
        }
    }
    
    // 顧客の製品を更新
    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedCourses: [Product] = []
        
        //ユーザーが購入したすべての製品を反復処理
        for await result in Transaction.currentEntitlements {
            do {
                //トランザクションが検証されたかどうかを再度確認
                let transaction = try checkVerified(result)
                
                // producttype は .nonconsumables(非消耗型) の 1 つのタイプしかないため、
                // transaction.productID と一致する storeProducts があるかどうかを確認してから、 purchaseCourses に追加
                if let course = storeProducts.first(where: { $0.id == transaction.productID}) {
                    purchasedCourses.append(course)
                }
                
            } catch {
                print("Transaction failed verification")
            }
            
            //最終的に購入した製品を割り当て
            self.purchasedCourses = purchasedCourses
        }
    }
    
    // 商品購入を呼び出し、オプションのトランザクションを返します
    func purchase(_ product: Product) async throws -> Transaction? {
        //購入リクエストを作成 - オプションのパラメータが利用可能
        let result = try await product.purchase()
        
        // check the results
        switch result {
            case .success(let verificationResult):
                //トランザクションは JWT(jwsRepresentation) を使用して自動的に検証されます - 結果を確認
                let transaction = try checkVerified(verificationResult)
                
                //トランザクションが検証され、コンテンツがユーザーに配信
                await updateCustomerProductStatus()
                
                //常にトランザクションを終了
                await transaction.finish()
                
                return transaction
            case .userCancelled, .pending:
                return nil
            default:
                return nil
        }
        
    }
    
    // 商品が購入済みかどうかを確認
    func isPurchased(_ product: Product) async throws -> Bool {
        //as we only have one product type grouping .nonconsumable - we check if it belongs to the purchasedCourses which ran init()
        return purchasedCourses.contains(product)
    }
    
    // 商品ID "com.AllFunctions.app" が購入済みかどうかを確認
    func isPurchased() async throws -> Bool {
        //この `com.AllFunctions.app` の最新のトランザクション レシートを取得
        guard let result = await Transaction.latest(for: "com.AllFunctions.app") else {
            //最新の取引がない場合、商品は購入されていないのでfalse
            return false
        }
        
        let transaction = try checkVerified(result)
        
        
        
        //サブスクリプションの場合、ユーザーはサブスクリプション期間の途中でアップグレードできます。
        //その後、階層に「isUpgraded」フラグが設定され、より高いサービスの新しいトランザクションが発生します
        //アップグレードされた下位サービス層のトランザクションは無視してください。
    
        return transaction.revocationDate == nil && !transaction.isUpgraded
    }
    
}




