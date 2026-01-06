//
//  PrivateNetworkURLSessionDelegate.swift
//  romm
//
//  Created by Ilyas Hallak on 13.12.25.
//

import Foundation
import os

/// URLSessionDelegate that accepts HTTP connections and self-signed certificates
/// ONLY for private IP addresses (Tailscale VPN and local networks).
/// Public servers still require valid HTTPS certificates.
class PrivateNetworkURLSessionDelegate: NSObject, URLSessionDelegate {

    private let logger = Logger.network

    // MARK: - Private IP Range Detection

    /// Checks if the given host is a private IP address
    /// Supports:
    /// - Tailscale: 100.64.0.0/10 (CGNAT range used by Tailscale)
    /// - Private Class A: 10.0.0.0/8
    /// - Private Class B: 172.16.0.0/12
    /// - Private Class C: 192.168.0.0/16
    /// - Localhost: 127.0.0.0/8
    private func isPrivateIPAddress(_ host: String) -> Bool {
        // Handle localhost special cases
        if host == "localhost" || host == "::1" {
            return true
        }

        // Try to parse as IPv4
        if let ipv4Components = parseIPv4(host) {
            return isPrivateIPv4(ipv4Components)
        }

        // Try to parse as IPv6 (basic check for local addresses)
        if host.contains(":") {
            // fe80::/10 (link-local)
            // fc00::/7 (unique local)
            // ::1 (localhost - already handled above)
            return host.hasPrefix("fe80:") || host.hasPrefix("fc") || host.hasPrefix("fd")
        }

        return false
    }

    /// Parses IPv4 address string into components
    private func parseIPv4(_ host: String) -> [UInt8]? {
        let components = host.split(separator: ".").compactMap { UInt8($0) }
        guard components.count == 4 else { return nil }
        return components
    }

    /// Checks if IPv4 address is in private ranges
    private func isPrivateIPv4(_ components: [UInt8]) -> Bool {
        guard components.count == 4 else { return false }

        let octet1 = components[0]
        let octet2 = components[1]

        // 10.0.0.0/8 (Class A private)
        if octet1 == 10 {
            return true
        }

        // 100.64.0.0/10 (CGNAT - used by Tailscale)
        // Range: 100.64.0.0 - 100.127.255.255
        if octet1 == 100 && octet2 >= 64 && octet2 <= 127 {
            return true
        }

        // 172.16.0.0/12 (Class B private)
        // Range: 172.16.0.0 - 172.31.255.255
        if octet1 == 172 && octet2 >= 16 && octet2 <= 31 {
            return true
        }

        // 192.168.0.0/16 (Class C private)
        if octet1 == 192 && octet2 == 168 {
            return true
        }

        // 127.0.0.0/8 (Loopback)
        if octet1 == 127 {
            return true
        }

        return false
    }

    /// Gets a human-readable description of the IP type
    private func getIPTypeDescription(_ host: String) -> String {
        if host == "localhost" || host == "::1" || host.hasPrefix("127.") {
            return "Localhost"
        }

        if let components = parseIPv4(host) {
            let octet1 = components[0]
            let octet2 = components[1]

            if octet1 == 10 {
                return "Private Class A (10.x.x.x)"
            } else if octet1 == 100 && octet2 >= 64 && octet2 <= 127 {
                return "Tailscale VPN (100.x.x.x)"
            } else if octet1 == 172 && octet2 >= 16 && octet2 <= 31 {
                return "Private Class B (172.x.x.x)"
            } else if octet1 == 192 && octet2 == 168 {
                return "Private Class C (192.168.x.x)"
            }
        }

        if host.contains(":") {
            if host.hasPrefix("fe80:") {
                return "IPv6 Link-Local"
            } else if host.hasPrefix("fc") || host.hasPrefix("fd") {
                return "IPv6 Unique Local"
            }
        }

        return "Public IP/Domain"
    }

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let host = challenge.protectionSpace.host
        let authMethod = challenge.protectionSpace.authenticationMethod

        // Only handle ServerTrust authentication (HTTPS certificate validation)
        guard authMethod == NSURLAuthenticationMethodServerTrust else {
            logger.debug("🔐 Non-ServerTrust challenge for \(host) - using default handling")
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Check if this is a private IP address
        let isPrivate = isPrivateIPAddress(host)
        let ipType = getIPTypeDescription(host)

        if isPrivate {
            // Private IP: Accept self-signed certificates and HTTP
            logger.info("🔓 Private IP detected [\(ipType)]: \(host) - accepting ServerTrust")

            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                logger.warning("⚠️ ServerTrust is nil for \(host) - using credential anyway")
                completionHandler(.useCredential, nil)
            }
        } else {
            // Public IP/Domain: Use strict iOS HTTPS validation
            logger.info("🔒 Public server detected [\(ipType)]: \(host) - using default HTTPS validation")
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
