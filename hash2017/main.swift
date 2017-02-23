//
//  main.swift
//  hash2017
//
//  Created by Jeremie Girault on 23/02/2017.
//  Copyright © 2017 EC1. All rights reserved.
//

import Foundation

print("# NinjaPirateRockstar hashcode2017")

let filename = "me_at_the_zoo.in"

main(filename, parser: Model.init) { model in
    return "\(model)"
}

