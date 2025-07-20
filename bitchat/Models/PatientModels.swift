//
// PatientModels.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation

// MARK: - Core Patient Record
struct PatientRecord: Codable, Identifiable {
    let id: String                  // Auto-generated UUID
    let patientId: String           // Human-readable ID (P123456)
    let name: String                // Encrypted in transmission
    let age: Int?
    let gender: String?
    let bloodType: String?
    let allergies: [String]
    let currentMedications: [String]
    let medicalHistory: String
    let presentingComplaint: String
    let treatment: String
    let status: PatientStatus
    let priority: Priority
    let location: String?
    let authorFingerprint: String   // Doctor/medic who created
    let lastModified: Date
    let version: Int                // For conflict resolution
    
    init(
        id: String = UUID().uuidString,
        patientId: String,
        name: String,
        age: Int? = nil,
        gender: String? = nil,
        bloodType: String? = nil,
        allergies: [String] = [],
        currentMedications: [String] = [],
        medicalHistory: String = "",
        presentingComplaint: String = "",
        treatment: String = "",
        status: PatientStatus = .stable,
        priority: Priority = .medium,
        location: String? = nil,
        authorFingerprint: String,
        lastModified: Date = Date(),
        version: Int = 1
    ) {
        self.id = id
        self.patientId = patientId
        self.name = name
        self.age = age
        self.gender = gender
        self.bloodType = bloodType
        self.allergies = allergies
        self.currentMedications = currentMedications
        self.medicalHistory = medicalHistory
        self.presentingComplaint = presentingComplaint
        self.treatment = treatment
        self.status = status
        self.priority = priority
        self.location = location
        self.authorFingerprint = authorFingerprint
        self.lastModified = lastModified
        self.version = version
    }
}

// MARK: - Patient Status
enum PatientStatus: String, Codable, CaseIterable {
    case stable = "stable"
    case critical = "critical"
    case treated = "treated"
    case transferred = "transferred"
    case deceased = "deceased"
    
    var displayName: String {
        switch self {
        case .stable: return "Stable"
        case .critical: return "Critical"
        case .treated: return "Treated"
        case .transferred: return "Transferred"
        case .deceased: return "Deceased"
        }
    }
    
    var color: String {
        switch self {
        case .stable: return "green"
        case .critical: return "red"
        case .treated: return "blue"
        case .transferred: return "orange"
        case .deceased: return "gray"
        }
    }
}

// MARK: - Priority Level
enum Priority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    var color: String {
        switch self {
        case .low: return "gray"
        case .medium: return "yellow"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}

// MARK: - Medical Update
struct MedicalUpdate: Codable, Identifiable {
    let id: String
    let patientId: String
    let updateType: UpdateType
    let notes: String
    let vitals: Vitals?
    let authorFingerprint: String
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        patientId: String,
        updateType: UpdateType,
        notes: String,
        vitals: Vitals? = nil,
        authorFingerprint: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.patientId = patientId
        self.updateType = updateType
        self.notes = notes
        self.vitals = vitals
        self.authorFingerprint = authorFingerprint
        self.timestamp = timestamp
    }
}

// MARK: - Update Type
enum UpdateType: String, Codable, CaseIterable {
    case assessment = "assessment"
    case treatment = "treatment"
    case statusChange = "statusChange"
    case transfer = "transfer"
    
    var displayName: String {
        switch self {
        case .assessment: return "Assessment"
        case .treatment: return "Treatment"
        case .statusChange: return "Status Change"
        case .transfer: return "Transfer"
        }
    }
}

// MARK: - Vitals
struct Vitals: Codable {
    let bloodPressure: String?      // e.g., "120/80"
    let heartRate: Int?             // beats per minute
    let temperature: Double?        // in Celsius
    let oxygenSaturation: Int?      // percentage
    let painLevel: Int?             // 1-10 scale
    
    init(
        bloodPressure: String? = nil,
        heartRate: Int? = nil,
        temperature: Double? = nil,
        oxygenSaturation: Int? = nil,
        painLevel: Int? = nil
    ) {
        self.bloodPressure = bloodPressure
        self.heartRate = heartRate
        self.temperature = temperature
        self.oxygenSaturation = oxygenSaturation
        self.painLevel = painLevel
    }
    
    var hasAnyVitals: Bool {
        return bloodPressure != nil || heartRate != nil || temperature != nil || oxygenSaturation != nil || painLevel != nil
    }
}

// MARK: - App Mode for Tab Navigation
enum AppMode: String, CaseIterable {
    case chat = "Chat"
    case patients = "Patients"
    case dashboard = "Dashboard"
    
    var iconName: String {
        switch self {
        case .chat: return "message.circle.fill"
        case .patients: return "person.2.circle.fill"
        case .dashboard: return "chart.bar.fill"
        }
    }
}

// MARK: - Sync Status for UI
enum SyncStatus: String, Codable {
    case synced = "synced"
    case pending = "pending"
    case failed = "failed"
    case syncing = "syncing"
    
    var displayName: String {
        switch self {
        case .synced: return "Synced"
        case .pending: return "Pending"
        case .failed: return "Failed"
        case .syncing: return "Syncing"
        }
    }
    
    var color: String {
        switch self {
        case .synced: return "green"
        case .pending: return "orange"
        case .failed: return "red"
        case .syncing: return "blue"
        }
    }
} 