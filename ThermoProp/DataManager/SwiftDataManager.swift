//
//  SwiftDataManager.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/23/26.
//

import Foundation
import SwiftData

class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    let container: ModelContainer
    let context: ModelContext
    
    private init() {
        do {
            // Initializes the database. If it doesn't exist, SwiftData creates it!
            container = try ModelContainer(for: HistoryRecord.self)
            context = ModelContext(container)
        } catch {
            fatalError("Could not initialize SwiftData container: \(error)")
        }
    }
    
    // MARK: - Core Operations
    func saveRecord(_ record: HistoryRecord) {
        context.insert(record)
        do {
            try context.save()
        } catch {
            print("Failed to save record: \(error)")
        }
    }
    
    func fetchAllRecords() -> [HistoryRecord] {
        // FetchDescriptor natively sorts the database BEFORE loading it into RAM!
        let descriptor = FetchDescriptor<HistoryRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    func deleteRecord(_ record: HistoryRecord) {
        context.delete(record)
        do {
            try context.save()
        } catch {
            print("Failed to delete record: \(error)")
        }
    }
}
