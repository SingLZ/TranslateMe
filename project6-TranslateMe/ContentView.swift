//
//  ContentView.swift
//  project6-TranslateMe
//
//  Created by Lixing Zheng on 3/30/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var messageManager = MessageManager()
    @State private var inputText = ""
    @State private var translatedText = ""
    @State private var translationHistory: [String] = []
    @State private var selectedSourceLanguage = "en"
        @State private var selectedTargetLanguage = "es"
    @State private var showingHistory = false
    
    let languages = ["en", "es", "fr", "de"]
    
    init() {
            messageManager.fetchTranslationHistory() // Fetch translation history when ContentView initializes
        }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Source Language", selection: $selectedSourceLanguage) {
                                    ForEach(languages, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                                
                Picker("Target Language", selection: $selectedTargetLanguage) {
                                    ForEach(languages, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                
                TextField("Enter text to translate", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    // Call translateMessage function from MessageManager
                    messageManager.translateText(inputText, sourceLanguage: selectedSourceLanguage, targetLanguage: selectedTargetLanguage) { translatedText in
                            DispatchQueue.main.async {
                                if let translatedText = translatedText {
                                    self.translatedText = translatedText
                                    self.messageManager.translationHistory.append(translatedText)
                                } else {
                                    self.translatedText = "Error translating text"
                                }
                            }
                        }
                }) {
                    Text("Translate")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                TextField("Translated Text", text: $translatedText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .disabled(true) // Disable editing
                
                Button(action: {
                    showingHistory = true
                }) {
                    Text("View History")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("Translation")
            .sheet(isPresented: $showingHistory) {
                TranslationHistoryView(translationHistory: $messageManager.translationHistory, messageManager: messageManager)
                    .onAppear {
                        messageManager.fetchTranslationHistory() // Fetch translation history whenever TranslationHistoryView appears
                    }

            }
        }
    }
}

#Preview {
    ContentView()
}
