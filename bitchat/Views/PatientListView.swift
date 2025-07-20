//
// PatientListView.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

struct PatientListView: View {
    @EnvironmentObject var patientViewModel: PatientViewModel
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.8) : Color(red: 0, green: 0.5, blue: 0).opacity(0.8)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Patient Records")
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(textColor)
                            
                            Text("\(patientViewModel.filteredPatients.count) patient\(patientViewModel.filteredPatients.count == 1 ? "" : "s")")
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(secondaryTextColor)
                        }
                        
                        Spacer()
                        
                        // Add Patient Button
                        Button(action: {
                            patientViewModel.showAddPatient()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(textColor)
                            .cornerRadius(8)
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(secondaryTextColor)
                        
                        TextField("Search patients...", text: $patientViewModel.searchText)
                            .font(.system(size: 16))
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                
                // Patient List
                if patientViewModel.filteredPatients.isEmpty {
                    // Empty State
                    EmptyPatientListView()
                } else {
                    List(patientViewModel.filteredPatients) { patient in
                        PatientRowView(patient: patient)
                            .listRowBackground(backgroundColor)
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                patientViewModel.selectPatient(patient)
                            }
                    }
                    .listStyle(PlainListStyle())
                    .background(backgroundColor)
                }
            }
            .background(backgroundColor)
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        .sheet(isPresented: $patientViewModel.isShowingAddPatient) {
            AddPatientView()
                .environmentObject(patientViewModel)
        }
        .sheet(isPresented: $patientViewModel.isShowingPatientDetail) {
            if let selectedPatient = patientViewModel.selectedPatient {
                PatientDetailView(patient: selectedPatient)
                    .environmentObject(patientViewModel)
            }
        }
    }
}

// MARK: - Patient Row View
struct PatientRowView: View {
    let patient: PatientRecord
    @EnvironmentObject var patientViewModel: PatientViewModel
    @Environment(\.colorScheme) var colorScheme
    
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
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                // Patient ID and Name
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.patientId)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text(patient.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Status and Priority Badges
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(text: patient.status.displayName, color: statusColor)
                    PriorityBadge(text: patient.priority.displayName, color: priorityColor)
                }
            }
            
            // Patient Info Row
            HStack {
                if let age = patient.age {
                    InfoChip(icon: "person.fill", text: "\(age)y", color: .blue)
                }
                
                if let gender = patient.gender {
                    InfoChip(icon: "person.circle", text: gender, color: .purple)
                }
                
                if let bloodType = patient.bloodType {
                    InfoChip(icon: "drop.fill", text: bloodType, color: .red)
                }
                
                Spacer()
                
                // Sync Status
                if let syncStatus = patientViewModel.syncStatus[patient.id] {
                    SyncStatusIndicator(status: syncStatus)
                }
            }
            
            // Presenting Complaint
            if !patient.presentingComplaint.isEmpty {
                Text(patient.presentingComplaint)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Footer
            HStack {
                if let location = patient.location {
                    Label(location, systemImage: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(formatDate(patient.lastModified))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(priorityColor.opacity(0.3), lineWidth: 2)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views
struct StatusBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(4)
    }
}

struct PriorityBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 1)
            )
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

struct SyncStatusIndicator: View {
    let status: SyncStatus
    
    private var color: Color {
        switch status.color {
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        default: return .gray
        }
    }
    
    private var icon: String {
        switch status {
        case .synced: return "checkmark.circle.fill"
        case .pending: return "clock.circle.fill"
        case .failed: return "exclamationmark.circle.fill"
        case .syncing: return "arrow.triangle.2.circlepath"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            if status == .syncing {
                Text("...")
                    .font(.system(size: 10))
                    .foregroundColor(color)
            }
        }
    }
}

struct EmptyPatientListView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "person.2.circle")
                .font(.system(size: 80))
                .foregroundColor(textColor.opacity(0.3))
            
            VStack(spacing: 8) {
                Text("No Patients Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Add your first patient record using the + button above")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
struct PatientListView_Previews: PreviewProvider {
    static var previews: some View {
        PatientListView()
            .environmentObject(PatientViewModel())
    }
} 