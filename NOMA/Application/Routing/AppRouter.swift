//
//  AppRouter.swift
//  NOMA
//
//  Created by 이은지 on 7/21/26.
//

import SwiftUI

@Observable
final class AppRouter {
    
    // MARK: - Properties
    
    var path = NavigationPath()

    // MARK: - Functions
    
    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
