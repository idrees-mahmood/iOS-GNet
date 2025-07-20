//
// PatientViewModel.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import Foundation
import SwiftUI
import Combine

class PatientViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var patients: [PatientRecord] = []
    @Published var medicalUpdates: [String: [MedicalUpdate]] = [:] // patientId -> updates
    @Published var syncStatus: [String: SyncStatus] = [:] // patientId -> sync status
    @Published var selectedPatient: PatientRecord? = nil
    @Published var isShowingAddPatient = false
    @Published var isShowingPatientDetail = false
    @Published var searchText = ""
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let patientsKey = "bitchat.patients"
    private let medicalUpdatesKey = "bitchat.medicalUpdates"
    private var saveTimer: Timer?
    
    // MARK: - Computed Properties
    var filteredPatients: [PatientRecord] {
        if searchText.isEmpty {
            return patients.sorted { $0.lastModified > $1.lastModified }
        } else {
            return patients.filter { patient in
                patient.name.localizedCaseInsensitiveContains(searchText) ||
                patient.patientId.localizedCaseInsensitiveContains(searchText) ||
                patient.presentingComplaint.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.lastModified > $1.lastModified }
        }
    }
    
    var totalPatientCount: Int {
        return patients.count
    }
    
    var criticalPatientCount: Int {
        return patients.filter { $0.status == .critical }.count
    }
    
    var urgentPatientCount: Int {
        return patients.filter { $0.priority == .urgent }.count
    }
    
    // MARK: - Initialization
    init() {
        loadPatients()
        loadMedicalUpdates()
        
        // Add some sample data for demonstration (will be replaced with real sync later)
        if patients.isEmpty {
            addSampleData()
        }
    }
    
    // MARK: - Patient Management
    func addPatient(_ patient: PatientRecord) {
        patients.append(patient)
        syncStatus[patient.id] = .pending
        savePatients()
        
        // TODO: In the future, this will sync via BluetoothMeshService
        // For now, just mark as synced after a delay to simulate sync
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.syncStatus[patient.id] = .synced
        }
    }
    
    func updatePatient(_ updatedPatient: PatientRecord) {
        if let index = patients.firstIndex(where: { $0.id == updatedPatient.id }) {
            patients[index] = updatedPatient
            syncStatus[updatedPatient.id] = .pending
            savePatients()
            
            // TODO: Sync via mesh network
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.syncStatus[updatedPatient.id] = .synced
            }
        }
    }
    
    func deletePatient(_ patient: PatientRecord) {
        patients.removeAll { $0.id == patient.id }
        medicalUpdates.removeValue(forKey: patient.id)
        syncStatus.removeValue(forKey: patient.id)
        savePatients()
        saveMedicalUpdates()
    }
    
    func getPatient(by id: String) -> PatientRecord? {
        return patients.first { $0.id == id }
    }
    
    // MARK: - Medical Updates
    func addMedicalUpdate(_ update: MedicalUpdate) {
        if medicalUpdates[update.patientId] == nil {
            medicalUpdates[update.patientId] = []
        }
        medicalUpdates[update.patientId]?.append(update)
        medicalUpdates[update.patientId]?.sort { $0.timestamp > $1.timestamp }
        saveMedicalUpdates()
    }
    
    func getMedicalUpdates(for patientId: String) -> [MedicalUpdate] {
        return medicalUpdates[patientId] ?? []
    }
    
    // MARK: - Navigation Helpers
    func selectPatient(_ patient: PatientRecord) {
        selectedPatient = patient
        isShowingPatientDetail = true
    }
    
    func showAddPatient() {
        isShowingAddPatient = true
    }
    
    func dismissAddPatient() {
        isShowingAddPatient = false
    }
    
    func dismissPatientDetail() {
        isShowingPatientDetail = false
        selectedPatient = nil
    }
    
    // MARK: - Data Persistence
    private func savePatients() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.performSave()
        }
    }
    
    private func performSave() {
        do {
            let data = try JSONEncoder().encode(patients)
            userDefaults.set(data, forKey: patientsKey)
        } catch {
            print("Failed to save patients: \(error)")
        }
    }
    
    private func loadPatients() {
        guard let data = userDefaults.data(forKey: patientsKey),
              let decodedPatients = try? JSONDecoder().decode([PatientRecord].self, from: data) else {
            return
        }
        patients = decodedPatients
        
        // Initialize sync status for all loaded patients
        for patient in patients {
            if syncStatus[patient.id] == nil {
                syncStatus[patient.id] = .synced
            }
        }
    }
    
    private func saveMedicalUpdates() {
        do {
            let data = try JSONEncoder().encode(medicalUpdates)
            userDefaults.set(data, forKey: medicalUpdatesKey)
        } catch {
            print("Failed to save medical updates: \(error)")
        }
    }
    
    private func loadMedicalUpdates() {
        guard let data = userDefaults.data(forKey: medicalUpdatesKey),
              let decodedUpdates = try? JSONDecoder().decode([String: [MedicalUpdate]].self, from: data) else {
            return
        }
        medicalUpdates = decodedUpdates
    }
    
    // MARK: - Sample Data (for demonstration)
    private func addSampleData() {
        let samplePatients = [
            PatientRecord(
                patientId: "P001",
                name: "Ahmad Hassan",
                age: 32,
                gender: "Male",
                bloodType: "O+",
                allergies: ["Penicillin"],
                currentMedications: ["Ibuprofen"],
                medicalHistory: "No significant medical history",
                presentingComplaint: "Chest pain and shortness of breath",
                treatment: "Oxygen therapy, monitoring vital signs",
                status: .critical,
                priority: .urgent,
                location: "Emergency Ward",
                authorFingerprint: "dev_fingerprint_001"
            ),
            PatientRecord(
                patientId: "P002",
                name: "Fatima Al-Zahra",
                age: 28,
                gender: "Female",
                bloodType: "A-",
                allergies: [],
                currentMedications: [],
                medicalHistory: "Previous fracture in left arm",
                presentingComplaint: "Leg injury from blast",
                treatment: "Wound cleaning, antibiotics",
                status: .stable,
                priority: .medium,
                location: "Ward 2",
                authorFingerprint: "dev_fingerprint_001"
            ),
            PatientRecord(
                patientId: "P003",
                name: "Omar Khalil",
                age: 45,
                gender: "Male",
                bloodType: "B+",
                allergies: ["Latex"],
                currentMedications: ["Metformin"],
                medicalHistory: "Type 2 diabetes",
                presentingComplaint: "Shrapnel wound to abdomen",
                treatment: "Surgery completed, post-op monitoring",
                status: .treated,
                priority: .high,
                location: "Recovery",
                authorFingerprint: "dev_fingerprint_002"
            )
        ]
        
        patients = samplePatients
        
        // Initialize sync status
        for patient in patients {
            syncStatus[patient.id] = .synced
        }
        
        // Add some sample medical updates
        let update1 = MedicalUpdate(
            patientId: "P001",
            updateType: .assessment,
            notes: "Patient showing improvement in breathing. Vitals stable.",
            vitals: Vitals(bloodPressure: "120/80", heartRate: 85, temperature: 37.2, oxygenSaturation: 95, painLevel: 6),
            authorFingerprint: "dev_fingerprint_001"
        )
        
        let update2 = MedicalUpdate(
            patientId: "P002",
            updateType: .treatment,
            notes: "Wound dressing changed. No signs of infection.",
            authorFingerprint: "dev_fingerprint_001"
        )
        
        medicalUpdates["P001"] = [update1]
        medicalUpdates["P002"] = [update2]
        
        savePatients()
        saveMedicalUpdates()
    }
    
    // MARK: - Cleanup
    deinit {
        saveTimer?.invalidate()
    }
} 