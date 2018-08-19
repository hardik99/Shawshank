//
//  PacketTunnelProvider.swift
//  ShawshankTunnel
//
//  Created by Harry Twan on 2018/8/11.
//  Copyright © 2018 Harry Twan. All rights reserved.
//

import NetworkExtension
import CocoaLumberjackSwift
import NEKit

var IS_TEST = false

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    var lastPath: NWPath?
    var started: Bool = false
    var proxyServer: ProxyServer!
    var proxyPort = 9090

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        NSLog("start tunnel")
        if IS_TEST {
            let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "8.8.8.8")
            networkSettings.mtu = 1500
            let ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
            networkSettings.ipv4Settings = ipv4Settings
            
            setTunnelNetworkSettings(networkSettings) {
                error in
                guard error == nil else {
                    completionHandler(error)
                    return
                }
                completionHandler(nil)
                self.started = true
            }
            return
        }
        
        guard let proto = protocolConfiguration as? NETunnelProviderProtocol, let conf = proto.providerConfiguration else {
            DDLogDebug("[error]]")
            exit(EXIT_FAILURE)
        }
        
        guard let ss_adder = conf["ss_address"] as? String else { exit(EXIT_FAILURE) }
        guard let ss_port_str = conf["ss_port"] as? String else { exit(EXIT_FAILURE) }
        guard let method = conf["ss_method"] as? String else { exit(EXIT_FAILURE) }
        guard let password = conf["ss_password"] as? String else { exit(EXIT_FAILURE) }
        
        guard let ss_port = Int(ss_port_str) else { return }

        let algorithm: CryptoAlgorithm
        
        switch method {
        case "AES128CFB":algorithm = .AES128CFB
        case "AES192CFB":algorithm = .AES192CFB
        case "AES256CFB":algorithm = .AES256CFB
        case "CHACHA20":algorithm = .CHACHA20
        case "SALSA20":algorithm = .SALSA20
        case "RC4MD5":algorithm = .RC4MD5
        default:
            fatalError("Undefined algorithm!")
        }
        
        // Origin
        let obfuscater = ShadowsocksAdapter.ProtocolObfuscater.OriginProtocolObfuscater.Factory()
        
        NSLog("addr: %@\n port:%d\n method:%@\n password:%@\n", ss_adder, ss_port, method, password)
        
        let ssAdapterFactory = ShadowsocksAdapterFactory(serverHost: ss_adder,
                                                         serverPort: ss_port,
                                                         protocolObfuscaterFactory:obfuscater,
                                                         cryptorFactory: ShadowsocksAdapter.CryptoStreamProcessor.Factory(password: password, algorithm: algorithm),
                                                         streamObfuscaterFactory: ShadowsocksAdapter.StreamObfuscater.OriginStreamObfuscater.Factory())
        
        var userRules: [NEKit.Rule] = []
        userRules.append(DNSFailRule(adapterFactory: ssAdapterFactory))
        userRules.append(AllRule(adapterFactory: ssAdapterFactory))
        
        let manager = RuleManager(fromRules: userRules, appendDirect: true)
        RuleManager.currentManager = manager
        
        
        let proxySettings = NEProxySettings()
        proxySettings.httpEnabled = true
        proxySettings.httpServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.httpsEnabled = true
        proxySettings.httpsServer = NEProxyServer(address: "127.0.0.1", port: proxyPort)
        proxySettings.excludeSimpleHostnames = true
        proxySettings.matchDomains = [""]
        
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.0.2.8")
        networkSettings.mtu = 1500
        networkSettings.proxySettings = proxySettings
        
        let ipv4Settings = NEIPv4Settings(addresses: ["192.169.89.1"], subnetMasks: ["255.255.255.0"])
        networkSettings.ipv4Settings = ipv4Settings
        
        setTunnelNetworkSettings(networkSettings) {
            error in
            guard error == nil else {
                completionHandler(error)
                return
            }
            do {
                if !self.started {
                    self.proxyServer = GCDHTTPProxyServer(address: IPAddress(fromString: "127.0.0.1"), port: NEKit.Port(port: 9090))
                    try? self.proxyServer.start()
                } else {
                    self.proxyServer.stop()
                    try? self.proxyServer.start()
                }
            }

            completionHandler(nil)
            self.started = true
        }
    }


    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        completionHandler()
        exit(EXIT_SUCCESS)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "defaultPath" {
            if self.defaultPath?.status == .satisfied && self.defaultPath != lastPath{
                if(lastPath == nil){
                    lastPath = self.defaultPath
                }else{
                    DDLogDebug("received network change notifcation")
                    let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        self.startTunnel(options: nil){_ in}
                    }
                }
            }else{
                lastPath = defaultPath
            }
        }
    }
}
