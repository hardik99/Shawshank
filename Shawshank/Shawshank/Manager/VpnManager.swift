//
//  VpnManager.swift
//  Shawshank
//
//  Created by Gua on 2018/8/13.
//  Copyright © 2018 Harry Twan. All rights reserved.
//

import UIKit
import Foundation
import NetworkExtension
import NEKit

class VpnManager {

    enum Status {
        case off
        case connecting
        case on
        case disconnecting
    }

    static let shared = VpnManager()

    /// VPN 状态
    private(set) var status: Status = .off {
        didSet {

        }
    }

    init() {

    }
}

// MARK: - NEKit Helper
extension VpnManager {

    // MARK: - 创建 Provider
    private func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        conf.serverAddress = "Shawshank"
        manager.protocolConfiguration = conf
        manager.localizedDescription = "Shawshank VPN"
        return NETunnelProviderManager()
    }

    // MAKR: - 载入并创建 Provider
    private func loadAndCreateProviderManager(_ completion: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            guard let managers = managers else { return }
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                self.deleteComfig(managers)
            } else {
                manager = self.createProviderManager()
            }

            manager.isEnabled = true
            manager.saveToPreferences { error in
                if let error = error {
                    completion(nil)
                    print(error.localizedDescription)
                    return
                }
                manager.loadFromPreferences { error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil)
                        return
                    }
                    completion(manager)
                }
            }
        }
    }

    // MARK: - 载入 provider
    private func loadProviderManager(_ completion: @escaping (NETunnelProviderManager?) -> Void) {
        
    }

    // MARK: - 删除配置
    private func deleteComfig(_ arrays: [NETunnelProviderManager]) {
        if arrays.count > 1 {
            for item in arrays {
                print("Delete DUP Profiles")
                item.removeFromPreferences { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
