//
//  Model.swift
//  hash2017
//
//  Created by Jeremie Girault on 23/02/2017.
//  Copyright © 2017 EC1. All rights reserved.
//

import Foundation

typealias Megabytes = Double

class Video: Hashable, Equatable {
    let identifier: Int
    let size: Megabytes

    init(identifier: Int, size: Megabytes) {
        self.identifier = identifier
        self.size = size
    }

    var hashValue: Int { return identifier }

    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class CacheServer: Hashable, Equatable {
    let identifier: Int
    let capacity: Megabytes

    private var remainingCapacityInvalid: Bool = true
    
    var videos = Set<Video>() {
        didSet { self.remainingCapacityInvalid = true }
    }
    
    private var cachedRemainingCapacity: Megabytes = 0
    var remainingCapacity: Megabytes {
        if remainingCapacityInvalid {
            cachedRemainingCapacity = capacity - videos.reduce(0) { $0 + $1.size }
            remainingCapacityInvalid = false
        }
        
        return cachedRemainingCapacity
    }

    init(identifier: Int, capacity: Megabytes) {
        self.identifier = identifier
        self.capacity = capacity
    }

    var hashValue: Int { return identifier }

    static func == (lhs: CacheServer, rhs: CacheServer) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class Endpoint {
    let identifier: Int
    let latency: TimeInterval
    let connections: Set<CacheConnection>

    init(identifier: Int, latency: TimeInterval, connections: [CacheConnection]) {
        self.identifier = identifier
        self.latency = latency
        self.connections = Set(connections)
    }
}

class CacheConnection: Hashable, Equatable {
    let server: CacheServer
    let latency: TimeInterval

    init(server: CacheServer, latency: TimeInterval) {
        self.server = server
        self.latency = latency
    }

    var hashValue: Int { return server.hashValue }

    static func == (lhs: CacheConnection, rhs: CacheConnection) -> Bool {
        return lhs.server.identifier == rhs.server.identifier
    }
}

class RequestDescription {
    let video: Video
    let endpoint: Endpoint
    let numberOfRequests: Int

    init(video: Video, endpoint: Endpoint, numberOfRequests: Int) {
        self.video = video
        self.endpoint = endpoint
        self.numberOfRequests = numberOfRequests
    }
}

struct Model {

    let videos: [Int: Video]
    let endpoints: [Int: Endpoint]
    let cacheServers: [Int: CacheServer]
    let requestDescriptions: [RequestDescription]

    let cacheServerCapacity: Megabytes

    init(lines: [String]) {

        var currentLine = 0
        let readNextLine = { () -> [String] in 
            defer { currentLine += 1 }
            return lines[currentLine].components(separatedBy: " ")
        }

        let counts = readNextLine()

        let _ = Int(counts[0])! // Unused number of videos
        let numberOfEndpoints = Int(counts[1])!
        let numberOfRequestDescriptions = Int(counts[2])!

        let numberOfCacheServers = Int(counts[3])!

        cacheServerCapacity = Megabytes(counts[4])!

        var cacheServers = [Int: CacheServer]()

        for i in (0..<numberOfCacheServers) {
            cacheServers[i] = CacheServer(identifier: i, capacity: cacheServerCapacity)
        }

        self.cacheServers = cacheServers

        let videosDescription = readNextLine()

        var videos = [Int: Video]()

        for (i, videoDesc) in videosDescription.enumerated() {

            videos[i] = Video(identifier: Int(i), size: Megabytes(videoDesc)!)
        }

        self.videos = videos

        var endpoints = [Int: Endpoint]()

        for i in 0..<numberOfEndpoints {
            let endpointConfig = readNextLine()
            let latency = TimeInterval(endpointConfig[0])!
            let numberOfConnections = Int(endpointConfig[1])!

            var connections = [CacheConnection]()

            for _ in 0..<numberOfConnections {
                let configConnection = readNextLine()
                let serverId = Int(configConnection[0])!
                let latency = TimeInterval(configConnection[1])!
                connections.append(CacheConnection(server: cacheServers[serverId]!, latency: latency))
            }

            endpoints[i] = Endpoint(identifier: i, latency: latency, connections: connections)
        }

        self.endpoints = endpoints


        var requestDescriptions = [RequestDescription]()

        for _ in 0..<numberOfRequestDescriptions {
            let requestDescConfig = readNextLine()

            let videoId = Int(requestDescConfig[0])!
            let endpointId = Int(requestDescConfig[1])!
            let numberOfRequests = Int(requestDescConfig[2])!

            requestDescriptions.append(RequestDescription(video: videos[videoId]!,
                                                          endpoint: endpoints[endpointId]!,
                                                          numberOfRequests: numberOfRequests))
        }

        self.requestDescriptions = requestDescriptions
    }
}

extension Model {

    func computeScore() -> Double {
        
        let numReq = Double(requestDescriptions.reduce(0) { $0 + $1.numberOfRequests })

        return requestDescriptions.reduce (Double(0)) { (acc, requestDescription) in
            let endpoint = requestDescription.endpoint
            let video = requestDescription.video

            let worstLatency = endpoint.latency

            let bestLatency = endpoint.connections
                .filter { connection in
                    connection.server.videos.contains(video)
                }
                .map { connection in
                    connection.latency
                }
                .sorted()
                .first ?? worstLatency

            let gain = worstLatency - bestLatency

            return acc + (gain * Double(requestDescription.numberOfRequests))
        } * 1000 / numReq
    }
}

extension Model {

    func outputSolution() -> String {

        let filledCacheServers = self.cacheServers.values.filter { server in
            !server.videos.isEmpty
        }

        var solution = ""
        let serverCount = filledCacheServers.count
        solution.append(String(serverCount))
        solution.append("\n")

        for server in filledCacheServers {
            let serverId = String(server.identifier)
            let videoIds = server.videos.map { String($0.identifier) }
            let serverDescription = [serverId] + videoIds

            solution.append(serverDescription.joined(separator: " "))
            solution.append("\n")
        }

        return solution
    }



}

