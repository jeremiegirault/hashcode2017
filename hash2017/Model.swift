//
//  Model.swift
//  hash2017
//
//  Created by Jeremie Girault on 23/02/2017.
//  Copyright © 2017 EC1. All rights reserved.
//

import Foundation

typealias Megabytes = Double

struct Video {
    let identifier: Int
    let size: Megabytes
}

struct CacheServer {
    let identifier: Int
    let capacity: Megabytes
}

struct Endpoint {
    let identifier: Int
    let latency: TimeInterval
    let connections: [CacheConnection]
}

struct CacheConnection {
    let serverId: Int
    let latency: TimeInterval
}

struct RequestDescription {

    let videoId: Int
    let endpointId: Int
    let numberOfRequests: Int
}

struct Model {

    let videos: [Video]
    let endpoints: [Endpoint]
    let requestDescriptions: [RequestDescription]
    let cacheServers: [CacheServer]

    init(lines: [String]) {

        var mutableLines = lines

        let counts = mutableLines.removeFirst().components(separatedBy: " ")

        let _ = Int(counts[0])! // Unused number of videos
        let numberOfEndpoints = Int(counts[1])!
        let numberOfRequestDescriptions = Int(counts[2])!

        let numberOfCacheServers = Int(counts[3])!
        let capacityOfCacheServers = Megabytes(counts[4])!

        cacheServers = (0..<numberOfCacheServers).map { CacheServer(identifier: $0, capacity: capacityOfCacheServers) }

        let videosDescription = mutableLines.removeFirst().components(separatedBy: " ")
        videos = videosDescription.enumerated().map { Video(identifier: Int($0), size: Megabytes($1)!) }

        var endpoints = [Endpoint]()

        for i in 0..<numberOfEndpoints {
            let endpointConfig = mutableLines.removeFirst().components(separatedBy: " ")
            let latency = TimeInterval(endpointConfig[0])!
            let numberOfConnections = Int(endpointConfig[1])!

            var connections = [CacheConnection]()

            for _ in 0..<numberOfConnections {
                let configConnection = mutableLines.removeFirst().components(separatedBy: " ")
                let serverId = Int(configConnection[0])!
                let latency = TimeInterval(configConnection[1])!
                connections.append(CacheConnection(serverId: serverId, latency: latency))
            }

            endpoints.append(Endpoint(identifier: i, latency: latency, connections: connections))
        }

        self.endpoints = endpoints


        var requestDescriptions = [RequestDescription]()

        for _ in 0..<numberOfRequestDescriptions {
            let requestDescConfig = mutableLines.removeFirst().components(separatedBy: " ")

            let videoId = Int(requestDescConfig[0])!
            let endpointId = Int(requestDescConfig[1])!
            let numberOfRequests = Int(requestDescConfig[2])!

            requestDescriptions.append(RequestDescription(videoId: videoId,
                                                          endpointId: endpointId,
                                                          numberOfRequests: numberOfRequests))
        }

        self.requestDescriptions = requestDescriptions
    }
}

