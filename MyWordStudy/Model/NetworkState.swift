//
//  NetworkState.swift
//  MyWordStudy
//
//  Created by 川人悠生 on 2023/01/26.
//

import Foundation
import Network


//network監視モデルクラスの定義
class MonitoringNetworkState: ObservableObject {

    //NWPathMonitorのインスタンス化
    let monitor = NWPathMonitor()
    //接続
    let queue = DispatchQueue.global(qos: .background)

    //初期値はfalse
    @Published var isConnected = false

    init() {
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.isConnected = true
                }
            } else {
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            }
        }
    }
}
