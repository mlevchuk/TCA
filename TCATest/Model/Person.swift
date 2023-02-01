//
//  Person.swift
//  TCATest
//
//  Created by Mykhaylo Levchuk on 31/01/2023.
//

import Foundation

struct Person: Decodable, Equatable {
    let age: Int
    let count: Int
    let name: String
}
