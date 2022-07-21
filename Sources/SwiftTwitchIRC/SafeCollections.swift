//
//  SafeCollections.swift
//  
//
//  Created by pkulik0 on 21/07/2022.
//

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
