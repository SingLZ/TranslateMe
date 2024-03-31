//
//  MessageManager.swift
//  project6-TranslateMe
//
//  Created by Lixing Zheng on 3/31/24.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessageManager: ObservableObject{
    @Published var translatedText: String?
    @Published var translationHistory: [String] = []
    
    private var db = Firestore.firestore()
    
    func translateText(_ text: String, sourceLanguage: String, targetLanguage: String, completion: @escaping (String?) -> Void) {
        guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Error encoding input text")
            completion(nil)
            return
        }
        
        let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=\(sourceLanguage)|\(targetLanguage)"
        
        guard let url = URL(string: urlString) else {
            print("Error creating URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let translationResponse = try JSONDecoder().decode(TranslationResponse.self, from: data)
                completion(translationResponse.responseData.translatedText)
                
                // Save translated text to Firebase
                    if let translatedText = translationResponse.responseData.translatedText {
                        self.saveToFirebase(originalText: text, translatedText: translatedText)
                    }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    private func saveToFirebase(originalText: String, translatedText: String) {
            let document = db.collection("translations").document()
            document.setData([
                "originalText": originalText,
                "translatedText": translatedText
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added with ID: \(document.documentID)")
                }
            }
        }
    
    func fetchTranslationHistory() {
            db.collection("translations").getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                self.translationHistory = documents.compactMap { $0.data()["translatedText"] as? String }
            }
        }
    
    
    func clearTranslationHistory() {
        let batch = db.batch()

        db.collection("translations").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for document in documents {
                batch.deleteDocument(document.reference)
            }

            batch.commit { error in
                if let error = error {
                    print("Error clearing translation history: \(error.localizedDescription)")
                } else {
                    print("Translation history cleared successfully")
                    self.translationHistory = [] // Clear local translation history array
                }
            }
        }
    }

}

struct TranslationResponse: Codable {
    let responseData: ResponseData
    
    enum CodingKeys: String, CodingKey {
        case responseData = "responseData"
    }
}

struct ResponseData: Codable {
    let translatedText: String?
    
    enum CodingKeys: String, CodingKey {
        case translatedText = "translatedText"
    }
}
