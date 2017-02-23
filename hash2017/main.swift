//
//  main.swift
//  hash2017
//
//  Created by Jeremie Girault on 23/02/2017.
//  Copyright © 2017 EC1. All rights reserved.
//

import Foundation

print("# NinjaPirateRockstar hashcode2017")

let filename = "videos_worth_spreading.in"

struct ComputedScore: CustomStringConvertible {
    let endpoint: Endpoint
    let video: Video
    let score: Double
    
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
            
            let magic = latency
            
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
    
    print("# Computing cache videos...")
    //
    
    i = 0
    for (_, cache) in model.cacheServers {
        guard let proposition = tab[cache] else { continue }
        
        let sortedScores = proposition.scores.sorted { $0.score > $1.score }
        for score in sortedScores {
            guard cache.remainingCapacity > 0 else { break }
            if score.video.size < cache.remainingCapacity {
                cache.videos.insert(score.video)
            }
        }
        
        i += 1
        print("## \(100 * Double(i) / Double(model.cacheServers.count))%")
    }
    
    
    print("# final score: \(model.computeScore())")
    
    return "\(model.outputSolution())"
}

