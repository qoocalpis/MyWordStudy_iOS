//
//  ProductView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/26.
//


import SwiftUI
import StoreKit

struct ProductView: View {
    
    @StateObject var storeKit = StoreKitManager()
    @State private var isButtonDisabled = false
    
    var body: some View {
        VStack {
            
            ForEach(storeKit.storeProducts) {product in
                HStack {
                    Text("Unlock all functions")
                    Spacer()
                    Button(action: {
                        isButtonDisabled = true
                        
                        // purchase this product
                        Task { try await storeKit.purchase(product) }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { isButtonDisabled = false }
            
                    }) {
                        CourseItem(storeKit: storeKit, product: product)
                    }
                    .disabled(isButtonDisabled)
                    
                }
                Divider()
            }
            HStack {
                Spacer()
                Button {
                    Task {
                        //This call displays a system prompt that asks users to authenticate with their App Store credentials.
                        //Call this function only in response to an explicit user action, such as tapping a button.
                        try? await AppStore.sync()
                    }
                } label: {
                    Text("Restore Purchases").foregroundColor(Color.blue)
                }
            }
            Divider()
        }
        .padding(30)
    }
}

struct CourseItem: View {
    @ObservedObject var storeKit : StoreKitManager
    @State var isPurchased: Bool = false
    var product: Product
    
    var body: some View {
        VStack {
            if isPurchased {
                ZStack {
                    Text("Purchased")
                        .foregroundColor(Color.green)
                        .font(.headline)
                        .padding(10)
                }
            } else {
                ZStack {
                    Text(product.displayPrice)
                        .foregroundColor(Color.blue)
                        .font(.headline)
                        .padding(10)
                }
                
            }
        }
        .onChange(of: storeKit.purchasedCourses) { course in
            Task {
                isPurchased = (try? await storeKit.isPurchased(product)) ?? false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProductView()
    }
}
