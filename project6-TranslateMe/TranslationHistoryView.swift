//
//  TranslationHistoryView.swift
//  project6-TranslateMe
//
//  Created by Lixing Zheng on 3/31/24.
//

import SwiftUI

struct TranslationHistoryView: View {
    @Binding var translationHistory: [String]
    let messageManager: MessageManager // Add this line to accept MessageManager instance
        
        init(translationHistory: Binding<[String]>, messageManager: MessageManager) {
            self._translationHistory = translationHistory
            self.messageManager = messageManager // Initialize messageManager
        }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(translationHistory, id: \.self) { translation in
                    Text(translation)
                }
            }
            .navigationTitle("Translation History")
            .navigationBarItems(trailing:
                Button(action: {
                    // Clear translation history
                    messageManager.clearTranslationHistory()
                }) {
                    Text("Clear")
                }
            )
        }
    }
}

struct TranslationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let translationHistory: [String] = ["Hello", "Bonjour", "Hola"]
        let messageManager = MessageManager() // Create an instance of MessageManager
        return TranslationHistoryView(translationHistory: .constant(translationHistory), messageManager: messageManager)
    }
}
