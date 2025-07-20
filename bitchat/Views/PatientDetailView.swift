//
// PatientDetailView.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

struct PatientDetailView: View {
    let patient: PatientRecord
    @EnvironmentObject var patientViewModel: PatientViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.8) : Color(red: 0, green: 0.5, blue: 0).opacity(0.8)
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05)
    }
    
    private var statusColor: Color {
        switch patient.status.color {
        case "green": return .green
        case "red": return .red
        case "blue": return .blue
        case "orange": return .orange
        case "gray": return .gray
        default: return .gray
        }
    }
    
    private var priorityColor: Color {
        switch patient.priority.color {
        case "gray": return .gray
        case "yellow": return .yellow
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    PatientHeaderSection(patient: patient, statusColor: statusColor, priorityColor: priorityColor, cardBackgroundColor: cardBackgroundColor)
                    
                    // Basic Information Section
                    PatientBasicInfoSection(patient: patient, cardBackgroundColor: cardBackgroundColor)
                    
                    // Medical Information Section
                    PatientMedicalInfoSection(patient: patient, cardBackgroundColor: cardBackgroundColor)
                    
                    // Latest Vitals Section
                    if let latestUpdate = patientViewModel.getMedicalUpdates(for: patient.id).first(where: { $0.vitals?.hasAnyVitals == true }) {
                        PatientVitalsSection(vitals: latestUpdate.vitals!, timestamp: latestUpdate.timestamp, cardBackgroundColor: cardBackgroundColor)
                    }
                    
                    // Medical Updates Section
                    PatientUpdatesSection(patientId: patient.id, cardBackgroundColor: cardBackgroundColor)
                        .environmentObject(patientViewModel)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .background(backgroundColor)
            .navigationTitle("Patient Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        patientViewModel.dismissPatientDetail()
                    }
                    .foregroundColor(textColor)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // TODO: Implement edit functionality
                    }
                    .foregroundColor(textColor)
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        patientViewModel.dismissPatientDetail()
                    }
                    .foregroundColor(textColor)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        // TODO: Implement edit functionality
                    }
                    .foregroundColor(textColor)
                }
            }
            #endif
        }
    }
}

// MARK: - Header Section
struct PatientHeaderSection: View {
    let patient: PatientRecord
    let statusColor: Color
    let priorityColor: Color
    let cardBackgroundColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(patient.patientId)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(textColor)
                    
                    Text(patient.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let location = patient.location {
                        Label(location, systemImage: "location.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    StatusBadge(text: patient.status.displayName, color: statusColor)
                    PriorityBadge(text: patient.priority.displayName, color: priorityColor)
                }
            }
            
            HStack {
                Text("Last Updated: \(formatDateTime(patient.lastModified))")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Sync status
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    Text("Synced")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Basic Information Section
struct PatientBasicInfoSection: View {
    let patient: PatientRecord
    let cardBackgroundColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PatientSectionHeader(title: "BASIC INFORMATION", icon: "person.circle.fill")
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if let age = patient.age {
                    InfoCard(title: "Age", value: "\(age) years", icon: "calendar", color: .blue)
                }
                
                if let gender = patient.gender {
                    InfoCard(title: "Gender", value: gender, icon: "person.circle", color: .purple)
                }
                
                if let bloodType = patient.bloodType {
                    InfoCard(title: "Blood Type", value: bloodType, icon: "drop.fill", color: .red)
                }
                
                InfoCard(title: "Patient ID", value: patient.patientId, icon: "tag.fill", color: .orange)
            }
            
            // Allergies
            if !patient.allergies.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Allergies")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100))
                    ], spacing: 8) {
                        ForEach(patient.allergies, id: \.self) { allergy in
                            Text(allergy)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            // Current Medications
            if !patient.currentMedications.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Medications")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 120))
                    ], spacing: 8) {
                        ForEach(patient.currentMedications, id: \.self) { medication in
                            Text(medication)
                                .font(.system(size: 14))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Medical Information Section
struct PatientMedicalInfoSection: View {
    let patient: PatientRecord
    let cardBackgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PatientSectionHeader(title: "MEDICAL INFORMATION", icon: "cross.circle.fill")
            
            // Medical History
            if !patient.medicalHistory.isEmpty {
                DetailRow(title: "Medical History", content: patient.medicalHistory)
            }
            
            // Presenting Complaint
            if !patient.presentingComplaint.isEmpty {
                DetailRow(title: "Presenting Complaint", content: patient.presentingComplaint)
            }
            
            // Treatment
            if !patient.treatment.isEmpty {
                DetailRow(title: "Current Treatment", content: patient.treatment)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Vitals Section
struct PatientVitalsSection: View {
    let vitals: Vitals
    let timestamp: Date
    let cardBackgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                PatientSectionHeader(title: "LATEST VITALS", icon: "heart.circle.fill")
                Spacer()
                Text(formatTime(timestamp))
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                if let bp = vitals.bloodPressure {
                    VitalCard(title: "Blood Pressure", value: bp, unit: "mmHg", icon: "waveform.path.ecg", color: .red)
                }
                
                if let hr = vitals.heartRate {
                    VitalCard(title: "Heart Rate", value: "\(hr)", unit: "bpm", icon: "heart.fill", color: .pink)
                }
                
                if let temp = vitals.temperature {
                    VitalCard(title: "Temperature", value: String(format: "%.1f", temp), unit: "°C", icon: "thermometer", color: .orange)
                }
                
                if let oxygen = vitals.oxygenSaturation {
                    VitalCard(title: "O₂ Saturation", value: "\(oxygen)", unit: "%", icon: "lungs.fill", color: .blue)
                }
                
                if let pain = vitals.painLevel {
                    VitalCard(title: "Pain Level", value: "\(pain)", unit: "/10", icon: "exclamationmark.triangle.fill", color: pain > 7 ? .red : pain > 4 ? .orange : .green)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Updates Section
struct PatientUpdatesSection: View {
    let patientId: String
    let cardBackgroundColor: Color
    @EnvironmentObject var patientViewModel: PatientViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                PatientSectionHeader(title: "MEDICAL UPDATES", icon: "doc.text.fill")
                Spacer()
                Button("Add Update") {
                    // TODO: Implement add update functionality
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.blue)
            }
            
            let updates = patientViewModel.getMedicalUpdates(for: patientId)
            
            if updates.isEmpty {
                Text("No medical updates yet")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(updates) { update in
                    UpdateRow(update: update)
                }
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views
struct PatientSectionHeader: View {
    let title: String
    let icon: String
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(textColor)
                .font(.system(size: 18, weight: .bold))
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(textColor)
            
            Spacer()
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct VitalCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
                Text(unit)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct UpdateRow: View {
    let update: MedicalUpdate
    
    private var updateTypeColor: Color {
        switch update.updateType {
        case .assessment: return .blue
        case .treatment: return .green
        case .statusChange: return .orange
        case .transfer: return .purple
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(update.updateType.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(updateTypeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(updateTypeColor.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Text(formatDateTime(update.timestamp))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            
            Text(update.notes)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePatient = PatientRecord(
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
        )
        
        PatientDetailView(patient: samplePatient)
            .environmentObject(PatientViewModel())
    }
} 