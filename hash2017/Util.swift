//
//  Files.swift
//  hash2017
//
//  Created by Jeremie Girault on 23/02/2017.
//  Copyright © 2017 EC1. All rights reserved.
//

import Foundation

@discardableResult
private func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

private func readData<T>(_ filename: String, parser: ([String]) -> T) -> T {
    
    let fullFile = NSString(string: FileManager.default.currentDirectoryPath).appendingPathComponent(filename)
    
    print("# Reading \(fullFile)...")
    return try! parser(String(contentsOfFile: fullFile, encoding: .utf8).components(separatedBy: "\n"))
}

private func write(response: String, to filename: String, open: Bool = true) {
    let fullFile = NSString(string: FileManager.default.currentDirectoryPath).appendingPathComponent(filename)
    
    print("# Writing to \(fullFile)...")
    try! response.write(toFile: fullFile, atomically: true, encoding: .utf8)
    
    if open {
        shell("open", fullFile)
    }
}

func main<T>(_ filename: String, parser: ([String]) -> T, block: (T) -> String) {
    let data = readData(filename, parser: parser)
    print("# Executing program...")
    let result = block(data)
    write(response: result, to: "output-\(filename)")
}
