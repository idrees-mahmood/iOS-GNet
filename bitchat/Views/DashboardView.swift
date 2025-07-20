//
// DashboardView.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
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
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .center, spacing: 8) {
                        Text("Medical Dashboard")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(textColor)
                        
                        Text("Real-time network and patient status")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(.top)
                    
                    // Network Status Section
                    VStack(alignment: .leading, spacing: 16) {
                        DashboardSectionHeader(title: "NETWORK STATUS", icon: "wifi.circle.fill")
                        
                        HStack(spacing: 16) {
                            // Connected Devices Card
                            DashboardCard(
                                title: "Devices Visible",
                                value: "\(chatViewModel.connectedPeers.count)",
                                subtitle: "Connected peers",
                                icon: "laptopcomputer.and.iphone",
                                color: .blue,
                                backgroundColor: cardBackgroundColor
                            )
                            
                            // Network Signal Card
                            DashboardCard(
                                title: "Network Signal",
                                value: networkSignalStrength,
                                subtitle: "Average RSSI",
                                icon: "antenna.radiowaves.left.and.right",
                                color: networkSignalColor,
                                backgroundColor: cardBackgroundColor
                            )
                        }
                    }
                    
                    // Patient Status Section
                    VStack(alignment: .leading, spacing: 16) {
                        DashboardSectionHeader(title: "PATIENT STATUS", icon: "person.2.circle.fill")
                        
                        HStack(spacing: 16) {
                            // Total Patients Card
                            DashboardCard(
                                title: "Total Patients",
                                value: "\(patientViewModel.totalPatientCount)",
                                subtitle: "Records stored",
                                icon: "person.3.sequence.fill",
                                color: .green,
                                backgroundColor: cardBackgroundColor
                            )
                            
                            // Critical Patients Card
                            DashboardCard(
                                title: "Critical",
                                value: "\(patientViewModel.criticalPatientCount)",
                                subtitle: "Urgent attention",
                                icon: "exclamationmark.triangle.fill",
                                color: .red,
                                backgroundColor: cardBackgroundColor
                            )
                        }
                        
                        HStack(spacing: 16) {
                            // Urgent Priority Card
                            DashboardCard(
                                title: "Urgent Priority",
                                value: "\(patientViewModel.urgentPatientCount)",
                                subtitle: "High priority",
                                icon: "clock.badge.exclamationmark.fill",
                                color: .orange,
                                backgroundColor: cardBackgroundColor
                            )
                            
                            // Sync Status Card
                            DashboardCard(
                                title: "Sync Status",
                                value: syncStatusText,
                                subtitle: syncStatusSubtitle,
                                icon: "arrow.triangle.2.circlepath",
                                color: syncStatusColor,
                                backgroundColor: cardBackgroundColor
                            )
                        }
                    }
                    
                    // System Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        DashboardSectionHeader(title: "SYSTEM INFO", icon: "info.circle.fill")
                        
                        SystemInfoCard(backgroundColor: cardBackgroundColor)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .background(backgroundColor)
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
    }
    
    // MARK: - Computed Properties
    private var networkSignalStrength: String {
        let rssiValues = chatViewModel.meshService.getPeerRSSI().values
        guard !rssiValues.isEmpty else { return "No Signal" }
        
        let averageRSSI = rssiValues.reduce(0) { $0 + $1.intValue } / rssiValues.count
        return "\(averageRSSI) dBm"
    }
    
    private var networkSignalColor: Color {
        let rssiValues = chatViewModel.meshService.getPeerRSSI().values
        guard !rssiValues.isEmpty else { return .gray }
        
        let averageRSSI = rssiValues.reduce(0) { $0 + $1.intValue } / rssiValues.count
        
        if averageRSSI > -50 {
            return .green
        } else if averageRSSI > -70 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private var syncStatusText: String {
        let pendingCount = patientViewModel.syncStatus.values.filter { $0 == .pending }.count
        let failedCount = patientViewModel.syncStatus.values.filter { $0 == .failed }.count
        
        if failedCount > 0 {
            return "\(failedCount) Failed"
        } else if pendingCount > 0 {
            return "\(pendingCount) Pending"
        } else {
            return "All Synced"
        }
    }
    
    private var syncStatusSubtitle: String {
        let pendingCount = patientViewModel.syncStatus.values.filter { $0 == .pending }.count
        let failedCount = patientViewModel.syncStatus.values.filter { $0 == .failed }.count
        
        if failedCount > 0 {
            return "Sync errors"
        } else if pendingCount > 0 {
            return "Syncing..."
        } else {
            return "Up to date"
        }
    }
    
    private var syncStatusColor: Color {
        let failedCount = patientViewModel.syncStatus.values.filter { $0 == .failed }.count
        let pendingCount = patientViewModel.syncStatus.values.filter { $0 == .pending }.count
        
        if failedCount > 0 {
            return .red
        } else if pendingCount > 0 {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - Supporting Views
struct DashboardSectionHeader: View {
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

struct DashboardCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .bold))
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SystemInfoCard: View {
    let backgroundColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? Color.green : Color(red: 0, green: 0.5, blue: 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gear.circle.fill")
                    .foregroundColor(textColor)
                
                Text("System Status")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Active")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.green)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Bluetooth", value: "Connected")
                InfoRow(label: "Encryption", value: "Noise Protocol")
                InfoRow(label: "Storage", value: "Local + Mesh")
                InfoRow(label: "Privacy", value: "End-to-End")
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(ChatViewModel())
            .environmentObject(PatientViewModel())
    }
} 