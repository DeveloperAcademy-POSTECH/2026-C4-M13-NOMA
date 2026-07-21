//
//  Effect.swift
//  NOMA
//
//  Created by 이은지 on 7/22/26.
//

import Foundation

struct Effect<Action> {
    
    // MARK: - Propertise
    
    typealias Send = (Action) async -> Void
    private let operation: ((Send) async -> Void)?

    static var none: Effect { Effect(operation: nil) }

    // MARK: - Functions
    
    static func run(
        _ operation: @escaping (Send) async -> Void
    ) -> Effect {
        Effect(operation: operation)
    }

    func run(_ send: @escaping (Action) -> Void) async {
        guard let operation else { return }
        await operation { action in
            send(action)
        }
    }
}
