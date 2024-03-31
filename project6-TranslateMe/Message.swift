//
//  Message.swift
//  project6-TranslateMe
//
//  Created by Lixing Zheng on 3/31/24.
//

import Foundation

struct Message: Hashable, Identifiable, Codable {
    let id: UUID // Using UUID for identification
    let text: String
}

extension Message {
    static let mockedMessages: [Message] = [
        "Hello",
        "How are you?",
        "Good morning"
    ].enumerated().map { index, text in
        Message(id: UUID(), text: text)
    }
}

