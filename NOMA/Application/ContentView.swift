//
//  ContentView.swift
//  NOMA
//
//  Created by 이은지 on 7/9/26.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Properties
    
    // private let userID: Int
    
    // MARK: - Initializer

    // init(userID: Int) {
    //    self.userID = userID
    // }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            title
            content
        }
        .padding()
    }
}

// MARK: - Subviews

extension ContentView {
    private var title: some View {
        Text("Title")
    }
  
    private var content: some View {
        Text("Content")
    }
}

#Preview {
    ContentView()
}
