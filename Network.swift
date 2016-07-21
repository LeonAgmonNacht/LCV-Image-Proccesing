//
//  Network.swift
//  LCV
//
//  Created by לאון אגמון נכט on 21/07/2016.
//  Copyright © 2016 Leon. All rights reserved.
//

import Foundation
import Darwin

/**
 a class to send the processed data using UDP connection
 */
class NetworkManager {
    
    /// the host address to send the data to
    static let hostAddress = "roborio-3316-frc.local"
    
    /// the ip address as string of the host to send the data to
    static let IPAddressString = NetworkManager.getIPFromHost(host: NetworkManager.hostAddress)
    
    /// the ip address to the host to send the data to
    static let IPAddress: in_addr = {
        var addr = in_addr()
        inet_pton(AF_INET, NetworkManager.IPAddressString, &addr)
        return addr
    }()
    
    /// the port number to send the data to
    static let portNum: CUnsignedShort = 8080
    
    /// the address holding all the data needed to send data
    static var addr = sockaddr_in(
        sin_len:    __uint8_t(sizeof(sockaddr_in)),
        sin_family: sa_family_t(AF_INET),
        sin_port:   NetworkManager.htons(value: NetworkManager.portNum),
        sin_addr:   NetworkManager.IPAddress,
        sin_zero:   ( 0, 0, 0, 0, 0, 0, 0, 0 )
    )

    /**
     sends the given string to the host configured in the class using UDP connection
     */
    static func sendData(data: String) {
        udpSend(textToSend: data, addr: NetworkManager.addr)
    }
    
    /**
     sends using UDP connection the given string to the given address and port number
     */
    private static func udpSend(textToSend: String, addr: sockaddr_in) {
        
        let fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
        
        textToSend.withCString { cstr -> Void in
            withUnsafePointer(&NetworkManager.addr) { ptr -> Void in
                let addrptr = UnsafePointer<sockaddr>(ptr)
                sendto(fd, cstr, Int(strlen(cstr)), 0, addrptr, socklen_t(addr.sin_len))
            }
        }
        
        close(fd)
    }
    
    private static func htons(value: CUnsignedShort) -> CUnsignedShort {
        return (value << 8) + (value >> 8)
    }
    /**
     - returns: the ip address that matches the given host
     */
    private static func getIPFromHost(host: String) -> String? {
        let host = CFHostCreateWithName(nil,host).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            let theAddress = addresses[1] as? NSData {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(UnsafePointer(theAddress.bytes), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                if let numAddress = String(validatingUTF8: hostname) {
                    print("addr: " + numAddress)
                    return numAddress
                }
            }
        }
        return nil
    }
}
