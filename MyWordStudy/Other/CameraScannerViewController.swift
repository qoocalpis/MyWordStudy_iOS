//
//  CameraScannerView.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/18.
//

import SwiftUI
import UIKit
import VisionKit


struct CameraScannerViewController: UIViewControllerRepresentable {
    
    @Binding var startScanning: Bool
    @Binding var scanWord: String
    @Binding var scanDefinition: String
    @Binding var selected: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isHighlightingEnabled: true)
        
        viewController.delegate = context.coordinator
        
        return viewController
    }
    
    func updateUIViewController(_ viewController: DataScannerViewController, context: Context) {
        if startScanning {
            try? viewController.startScanning()
        } else {
            viewController.stopScanning()
        }
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        var parent: CameraScannerViewController
        
        init(_ parent: CameraScannerViewController) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if parent.selected == 0 {
                switch item {
                    case .text(let text):
                        parent.scanWord = text.transcript
                    default:
                        break
                }
            }else {
                switch item {
                    case .text(let text):
                        parent.scanDefinition = text.transcript
                    default:
                        break
                }
            }
        }
    }
}
