//
//  HexDump.swift
//  XHex
//
//  Created by Ali Hammoud on 3/28/24.
//

import Foundation
import os
import Combine
import FileProviderUI


class HexDump: Process, ObservableObject {
    
    //let output = Pipe()
    let finder = FileManager()
    var terminal: Process = {
        let process = Process()
        return Process()
    }()
    
    static let handler = HexDump()
    @Published var result: String?
    @Published var dumpResults = [String:[String]]()
    @Published var addresses = [String]()
    
    func fileSelect() -> URL? {
        return nil
    }
    
    func runDump(file: [String] = []) {
        
        if file.isEmpty {
            return
        }
        
        let output = Pipe()
        let terminal = Process()
        terminal.executableURL = URL(filePath: "/usr/bin/env")
        terminal.standardOutput = output
        terminal.arguments = ["xxd"] + file
        
        do {
            try terminal.run()
            terminal.waitUntilExit()
            
            if let result = try output.fileHandleForReading.readToEnd(), let dump = String(data: result, encoding: .utf8) {
                
                var arrayDump = dump.components(separatedBy: "\n")

                while arrayDump.count > 1 {
                    let row = arrayDump.removeFirst()
                    if row.isEmpty {
                        break
                    }
                    if let bytes = row.range(of: ": "), let ascii = row.range(of: "  ") {
                        let key = String(row[row.startIndex...bytes.lowerBound])
                        let value = [String(row[bytes.upperBound...ascii.lowerBound]), String(row[ascii.upperBound..<row.endIndex])]
                        dumpResults[key] = value
                    }
                }
                // dumpResults.sorted(by: {$0.key < $1.key})
            }
            addresses = dumpResults.keys.sorted()
            
            /*
             expected format
            [     key   : [                  bytes                              ,       ascii        ] ]
             00000000: 4c6f 7265 6d20 6970 7375 6d20 646f 6c6f  Lorem ipsum dolo
             */
            
            terminal.terminate()
            
        } catch {
            if terminal.isRunning {
                terminal.suspend()
                terminal.terminate()
            }
            print("Failed to execute hex dump: \(error.localizedDescription)")
        }
        
    }
}


class XHexTest {
    
    static let tester = XHexTest()
    var mockData = [String: [String]]()
    
    init() {
        setupMockDict()
    }
    
    func setupMockDict() {
        for _ in 0...30 {
            mockData["\(String(format: "%08X", Int.random(in: 0...127)))"] = ["\(hex())", "\(ascii())"]
        }
        
    }
    
    func hex() -> String {
        var bytes = ""
        for i in 0...15 {
            bytes.append(String(format: "%02X", Int.random(in: 0...127)))
            if i % 2 == 0 && i >= 1 {
                bytes.append(" ")
            }
        }
        return bytes
    }
    
    func ascii() -> String {
        var ascii = ""
        for _ in 0...15 {
            ascii.append(String(data: Data(repeating: UInt8.random(in: 32...122), count: 1) , encoding: .ascii)!)
        }
        return ascii
    }
}
