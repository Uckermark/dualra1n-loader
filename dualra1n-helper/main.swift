//
//  main.swift
//  dualra1n-helper
//
//  Created by Amy While on 12/09/2022.
//
// Most of this code belongs to Amy While and is from https://github.com/elihwyma/Pogo

import Foundation
import ArgumentParser
import SWCompression

struct Helper: ParsableCommand {
    @Option(name: .shortAndLong, help: "The path to the .tar file you want to strap with")
    var input: String?
    
    @Flag(name: .shortAndLong, help: "add sources (experimental)")
    var autoSources = false
    
    mutating func run() throws {
        NSLog("[dualra1n helper] Spawned!")
        guard getuid() == 0 else { fatalError() }
        if autoSources {
            addSource()
        } else if let input = input {
            strapTool(input)
        }
    }
    
    func addSource() {
        let ironside = """
        Types: deb
        URIs: https://apt.ironside.org.uk/
        Suites: iphoneos-arm
        Components: dualra1n
        """
        do  {
            try ironside.write(to: URL(string: "file:///etc/apt/sources.list.d/dualra1n.sources")!,
                               atomically: false, encoding: .utf8)
        } catch {
            NSLog("[dualra1n helper] Could not add apt source: \(error.localizedDescription)")
            return
        }
        NSLog("[dualra1n helper] Added source successfully")
    }
    
    func strapTool(_ input: String) {
        NSLog("[dualra1n helper] Attempting to install \(input)")
        let dest = "/"
        do {
            try autoreleasepool {
                let data = try Data(contentsOf: URL(fileURLWithPath: input))
                let container = try TarContainer.open(container: data)
                NSLog("[dualra1n helper] Opened Container")
                for entry in container {
                    do {
                        var path = entry.info.name
                        if path.first == "." {
                            path.removeFirst()
                        }
                        if path == "/" || path == "/var" {
                            continue
                        }
                        path = path.replacingOccurrences(of: "", with: dest)
                        switch entry.info.type {
                        case .symbolicLink:
                            var linkName = entry.info.linkName
                            if !linkName.contains("/") || linkName.contains("..") {
                                var tmp = path.split(separator: "/").map { String($0) }
                                tmp.removeLast()
                                tmp.append(linkName)
                                linkName = tmp.joined(separator: "/")
                                if linkName.first != "/" {
                                    linkName = "/" + linkName
                                }
                                linkName = linkName.replacingOccurrences(of: "", with: dest)
                            } else {
                                linkName = linkName.replacingOccurrences(of: "", with: dest)
                            }
                            NSLog("[dualra1n helper] \(entry.info.linkName) at \(linkName) to \(path)")
                            try FileManager.default.createSymbolicLink(atPath: path, withDestinationPath: linkName)
                        case .directory:
                            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                        case .regular:
                            guard let data = entry.data else { continue }
                            try data.write(to: URL(fileURLWithPath: path))
                        default:
                            NSLog("[dualra1n helper] Unknown Action for \(entry.info.type)")
                        }
                        var attributes = [FileAttributeKey: Any]()
                        attributes[.posixPermissions] = entry.info.permissions?.rawValue
                        attributes[.ownerAccountName] = entry.info.ownerUserName
                        var ownerGroupName = entry.info.ownerGroupName
                        if ownerGroupName == "staff" && entry.info.ownerUserName == "root" {
                            ownerGroupName = "wheel"
                        }
                        attributes[.groupOwnerAccountName] = ownerGroupName
                        do {
                            try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
                        } catch {
                            continue
                        }
                    } catch {
                        NSLog("[dualra1n helper] error \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            NSLog("[dualra1n helper] Failed with error \(error.localizedDescription)")
            return
        }
        NSLog("[dualra1n helper] Strapped to \(dest)")
        var attributes = [FileAttributeKey: Any]()
        attributes[.posixPermissions] = 0o755
        attributes[.ownerAccountName] = "mobile"
        attributes[.groupOwnerAccountName] = "mobile"
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: "/var/mobile")
        } catch {
            NSLog("[dualra1n helper] thats wild")
        }
    }
}
Helper.main()
