//
//  CoffeeBeanViewModel.swift
//  Expresso Notes
//
//  Created by 张艺凡 on 15/7/25.
//

// CoffeeBeanViewModel.swift
import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

class CoffeeBeanViewModel: ObservableObject {
    @Published var beans: [CoffeeBean] = []
    private let db = Firestore.firestore()

    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    /// Real-time listener
    func subscribe() {
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("coffeeBeans")
          .order(by: "dateAdded", descending: true)
          .addSnapshotListener { [weak self] snap, err in
            guard let docs = snap?.documents else { return }
            self?.beans = docs.compactMap { doc in
                CoffeeBean(id: doc.documentID, data: doc.data())
            }
        }
    }

    /// Add or update
    func save(_ bean: CoffeeBean) {
        guard let userId = userId else { return }
        let collection = db.collection("users").document(userId).collection("coffeeBeans")
        let doc: DocumentReference = collection.document(bean.id.uuidString)
        doc.setData(bean.toDict()) { err in
            if let e = err { print("Failed saving: \(e)") }
        }
    }

    /// Delete
    func delete(_ bean: CoffeeBean) {
        guard let userId = userId else { return }
        let idString = bean.id.uuidString
        db.collection("users").document(userId).collection("coffeeBeans")
          .document(idString)
          .delete { err in
            if let e = err { print("Delete error: \(e)") }
        }
    }
}
