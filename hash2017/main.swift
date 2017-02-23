//
//  main.swift
//  hash2017
//
//  Created by Jeremie Girault on 23/02/2017.
//  Copyright © 2017 EC1. All rights reserved.
//

import Foundation

print("# NinjaPirateRockstar hashcode2017")

let filename = "kittens.in"

struct ComputedScore: CustomStringConvertible {
    let endpoint: Endpoint
    let video: Video
    var score: Double
    
    var description: String {
        return "ComputedScore(endpoint: \(endpoint.identifier), video: \(video.identifier), score: \(score))"
    }
}

class Propositions: CustomStringConvertible {
    var scores = [ComputedScore]()
    
    var description: String {
        return "Propositions(\(scores))"
    }
}

main(filename, parser: Model.init) { model in
    
    var tab = [CacheServer:Propositions]()
    
    print("# Computing Score Data structures...")
    var i = 0
    for req in model.requestDescriptions {
        for connection in req.endpoint.connections {
            let latency = (req.endpoint.latency - connection.latency) * Double(req.numberOfRequests)
            
            let magic = latency * (1 - (req.video.size / connection.server.capacity))
            
            //let connectedCaches = req.endpoint.connections.lazy.map { $0.server }.
            
            let score = ComputedScore(endpoint: req.endpoint, video: req.video, score: magic)
            
            if let propositions = tab[connection.server] {
                propositions.scores.append(score)
            } else {
                let propositions = Propositions()
                tab[connection.server] = propositions
                propositions.scores.append(score)
            }
        }
        
        i += 1
        print("## \(100 * Double(i) / Double(model.requestDescriptions.count))%")
    }
    
    print("# Sorting scores...")
    //
    
    i = 0
    let count = tab.values.count
    for prop in tab.values {
        prop.scores.sort { $0.score > $1.score }
        
        i += 1
        print("## \(100 * Double(i) / Double(count))%")
    }
    
    print("# Computing cache videos...")
    
    i = 0
    for cache in model.cacheServers.values {
        guard let proposition = tab[cache] else { continue }
        
        for score in proposition.scores {
            let capa = cache.remainingCapacity
            guard capa > 0 else { break }
            if score.video.size < capa {
                cache.videos.insert(score.video)
            }
        }
        
        i += 1
        print("## \(100 * Double(i) / Double(model.cacheServers.count))%")
    }
    
    
    print("# final score: \(model.computeScore())")
    
    return "\(model.outputSolution())"
}

