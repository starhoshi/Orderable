//
//  NestedCollection.swift
//  Pring
//
//  Created by 1amageek on 2017/10/27.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

/**
 Relation class
 Relation works with the property of Object.
 */
public final class NestedCollection<T: Document>: AnySubCollection, Countable, ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = T

    internal var _self: DataSource<T>

    internal var _count: Int = 0

    /// Contains the Object holding the property.
    public weak var parent: Object?

    public var key: String?

    /// It is a Path stored in Firebase.
    public var path: String {
        guard let parent: Object = self.parent else {
            fatalError("[Pring.NestedCollection] It is necessary to set parent.")
        }
        guard let key: String = self.key else {
            fatalError("[Pring.NestedCollection] It is necessary to set key.")
        }
        return "\(parent.path)/\(key)"
    }

    public var reference: CollectionReference {
        return Firestore.firestore().collection(path)
    }

    /// Relation detail value
    public var value: [AnyHashable: Any] {
        let count: Int = self.count
        let value: [AnyHashable: Any] = ["count": count]
        return value
    }

    /// It is an Object whose ID is Key.
    public var references: [AnyHashable: Any] {
        return _self.values()
    }

    /// You can retrieve whether the parent Object is saved.
    public var isSaved: Bool {
        return self.parent?.isSaved ?? false
    }

    public var count: Int {
        return self.isSaved ? _count : _self.count
    }

    @discardableResult
    public func pack(_ type: BatchType, batch: WriteBatch? = nil) -> WriteBatch {
        let batch: WriteBatch = batch ?? Firestore.firestore().batch()
        switch type {
        case .save:
            self.forEach { (document) in
                let reference: DocumentReference = self.reference.document(document.id)
                batch.setData(document.value as! [String : Any], forDocument: reference)
            }
        case .update:
            self.forEach { (document) in
                let reference: DocumentReference = self.reference.document(document.id)
                if document.isSaved {
                    batch.updateData(document.updateValue as! [String: Any], forDocument: reference)
                } else {
                    batch.setData(document.updateValue as! [String: Any], forDocument: reference)
                }
            }
        case .delete:
            self.forEach { (document) in
                let reference: DocumentReference = self.reference.document(document.id)
                batch.deleteDocument(reference)
            }
        }
        return batch
    }

    /**
     Initialize Relation.
     */
    public init(_ elements: [ArrayLiteralElement]) {
        self._self = DataSource(elements)
    }

    public required convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }

    public func setValue(_ value: Any?, forKey key: String) {
        self.key = key
        guard let value: [AnyHashable: Any] = value as? [AnyHashable: Any] else {
            return
        }
        if let count: Int = value["count"] as? Int {
            self._count = count
        }
    }

    /// Returns the Object of the specified indexes.
    public func objects(at indexes: IndexSet) -> [Element] {
        return indexes.filter { $0 < self.count }.map { self[$0] }
    }

    // MARK: -

    /// Save the new Object.
    public func insert(_ newMember: Element) {
        newMember.set(self.reference.document(newMember.id))
        if isSaved {
            fatalError("[Pring.NestedCollection] \(self.parent!) has already been saved. Please use insert(_ newMember: block:)")
        } else {
            _self.insert(newMember)
        }
    }

    public func insert(_ newMember: Element, block: ((Error?) -> Void)? = nil) {
        newMember.set(self.reference.document(newMember.id))
        let reference: DocumentReference = newMember.reference
        let parentRef: DocumentReference = self.parent!.reference
        let key: String = self.key!
        var count: Int = 0
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(parentRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard let oldParent: [String: Any] = document.data() else {
                return nil
            }
            let subCollection: [String: Any] = oldParent[key] as? [String: Any] ?? ["count": 0]
            let oldCount = subCollection["count"] as? Int ?? 0
            count = oldCount + 1
            transaction.updateData([key: ["count": count]], forDocument: parentRef)
            return nil
        }, completion: { (object, error) in
            if let error = error {
                block?(error)
                return
            }
            self._count = count
            let batch: WriteBatch = Firestore.firestore().batch()
            batch.setData(newMember.value as! [String: Any], forDocument: reference)
            batch.commit(completion: { (error) in
                if let error: Error = error {
                    block?(error)
                    return
                }
                self._self.insert(newMember)
                self.batchCompletion()
                block?(error)
            })
        })
    }

    /// Deletes the Object from the reference destination.
    public func remove(_ member: Element) {
        if isSaved {
            fatalError("[Pring.NestedCollection] \(self.parent!) has already been saved. Please use remove(_ newMember: block:)")
        } else {
            _self.remove(member)
            member.set(Element.reference.document())
        }
    }

    public func remove(_ member: Element, block: ((Error?) -> Void)? = nil) {
        let reference: DocumentReference = member.reference
        let parentRef: DocumentReference = self.parent!.reference
        let key: String = self.key!
        var count: Int = 0
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(parentRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            guard let oldParent: [String: Any] = document.data() else {
                return nil
            }
            guard
                let subCollection: [String: Any] = oldParent[key] as? [String: Any],
                let oldCount = subCollection["count"] as? Int else {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Unable to retrieve count from snapshot \(document)"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
            }
            count = oldCount - 1
            transaction.updateData([key: ["count": count]], forDocument: parentRef)
            return nil
        }, completion: { (object, error) in
            if let error = error {
                block?(error)
                return
            }
            self._count = count
            let batch: WriteBatch = Firestore.firestore().batch()
            batch.deleteDocument(reference)
            batch.commit(completion: {(error) in
                member.set(Element.reference.document())
                block?(error)
            })
        })
    }

    public func contains(_ id: String, block: @escaping (Bool) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            return block(snapshot?.exists ?? false)
        }
    }

    public func delete(id: String, block: ((Error?) -> Void)? = nil) {
        self.reference.document(id).delete { (error) in
            block?(error)
        }
    }

    public var description: String {
        if _self.isEmpty {
            return "Nested([])"
        }
        return "\(_self.documents.description)"
    }
}

// MARK: -

public extension NestedCollection {

    public func get(_ id: String, block: @escaping (Element?, Error?) -> Void) {
        self.reference.document(id).getDocument { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot, snapshot.exists else {
                block(nil, error)
                return
            }
            guard let document: Element = ArrayLiteralElement(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    public func listen(_ id: String, block: @escaping (Element?, Error?) -> Void) -> ListenerRegistration {
        let options: DocumentListenOptions = DocumentListenOptions()
        return self.reference.document(id).addSnapshotListener(options: options) { (snapshot, error) in
            guard let snapshot: DocumentSnapshot = snapshot else {
                block(nil, error)
                return
            }
            guard let document: Element = ArrayLiteralElement(snapshot: snapshot) else {
                block(nil, error)
                return
            }
            block(document, nil)
        }
    }

    public func listen(_ id: String, block: @escaping (Element?, Error?) -> Void) -> Disposer<Element> {
        return .init(.value(listen(id, block: block)))
    }
}

extension NestedCollection: Collection {

    public var startIndex: Int {
        return _self.startIndex
    }

    public var endIndex: Int {
        return _self.endIndex
    }

    public var first: T? {
        return _self.first
    }

    public subscript(i: Int) -> T {
        return _self[i]
    }

    public func index(of element: T) -> Int? {
        return _self.index(of: element)
    }

    public func index(where predicate: (T) throws -> Bool) rethrows -> Int? {
        return try _self.index(where: predicate)
    }

    public func index(after i: Int) -> Int {
        return _self.index(after: i)
    }

    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return _self.index(i, offsetBy: n)
    }

    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return _self.index(i, offsetBy: n, limitedBy: limit)
    }
}

fileprivate extension Collection where Iterator.Element: Document {
    func values() -> [String: Any] {
        return reduce(into: [:]) { $0[$1.id] = $1.value }
    }
}