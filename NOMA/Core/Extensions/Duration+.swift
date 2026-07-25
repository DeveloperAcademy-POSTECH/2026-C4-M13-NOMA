//
//  Duration+.swift
//  NOMA
//
//  Created by 이은지 on 7/25/26.
//

import Foundation

extension Duration {
    var timeInterval: TimeInterval {
        Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
