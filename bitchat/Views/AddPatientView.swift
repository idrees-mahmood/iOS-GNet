//
// AddPatientView.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct AddPatientView: View {
    @EnvironmentObject var patientViewModel: PatientViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    // Form Fields
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String = ""
    @State private var bloodType: String = ""
    @State private var allergiesText: String = ""
    @State private var medicationsText: String = ""
    @State private var medicalHistory: String = ""
    @State private var presentingComplaint: String = ""
    @State private var treatment: String = ""
    @State private var status: PatientStatus = .stable
    @State private var priority: Priority = .medium
    @State private var location: String = ""
    
    // Vitals (optional initial)
    @State private var includeVitals: Bool = false
    @State private var bloodPressure: String = ""
    @State private var heartRate: String = ""
    @State private var temperature: String = ""
    @State private var oxygenSaturation: String = ""
    @State private var painLevel: String = ""
    
    // UI State
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
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
            Form {
                // Basic Information Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        AddPatientSectionHeader(title: "BASIC INFORMATION", icon: "person.circle.fill")
                        
                        FormField(title: "Full Name", text: $name, placeholder: "Enter patient's full name", isRequired: true)
                        
                        HStack(spacing: 16) {
                            FormField(title: "Age", text: $age, placeholder: "25")
                                .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Gender")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Picker("Gender", selection: $gender) {
                                    Text("Select").tag("")
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                    Text("Other").tag("Other")
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Blood Type")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Picker("Blood Type", selection: $bloodType) {
                                    Text("Unknown").tag("")
                                    Text("A+").tag("A+")
                                    Text("A-").tag("A-")
                                    Text("B+").tag("B+")
                                    Text("B-").tag("B-")
                                    Text("AB+").tag("AB+")
                                    Text("AB-").tag("AB-")
                                    Text("O+").tag("O+")
                                    Text("O-").tag("O-")
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .frame(maxWidth: .infinity)
                            
                            FormField(title: "Location", text: $location, placeholder: "Ward, Room #")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Medical Information Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        AddPatientSectionHeader(title: "MEDICAL INFORMATION", icon: "cross.circle.fill")
                        
                        FormTextArea(title: "Medical History", text: $medicalHistory, placeholder: "Previous conditions, surgeries, etc.")
                        
                        FormTextArea(title: "Presenting Complaint", text: $presentingComplaint, placeholder: "Current symptoms and concerns", isRequired: true)
                        
                        FormTextArea(title: "Current Treatment", text: $treatment, placeholder: "Treatment plan and interventions")
                        
                        FormTextArea(title: "Known Allergies", text: $allergiesText, placeholder: "Separate multiple allergies with commas")
                        
                        FormTextArea(title: "Current Medications", text: $medicationsText, placeholder: "Separate multiple medications with commas")
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Status and Priority Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        AddPatientSectionHeader(title: "STATUS & PRIORITY", icon: "flag.circle.fill")
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Patient Status")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Picker("Status", selection: $status) {
                                    ForEach(PatientStatus.allCases, id: \.self) { status in
                                        Text(status.displayName).tag(status)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Priority Level")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                Picker("Priority", selection: $priority) {
                                    ForEach(Priority.allCases, id: \.self) { priority in
                                        Text(priority.displayName).tag(priority)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Optional Vitals Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            AddPatientSectionHeader(title: "INITIAL VITALS", icon: "heart.circle.fill")
                            Spacer()
                            Toggle("Include Vitals", isOn: $includeVitals)
                                .font(.system(size: 14))
                        }
                        
                        if includeVitals {
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    FormField(title: "Blood Pressure", text: $bloodPressure, placeholder: "120/80")
                                        .frame(maxWidth: .infinity)
                                    FormField(title: "Heart Rate (bpm)", text: $heartRate, placeholder: "72")
                                        .frame(maxWidth: .infinity)
                                }
                                
                                HStack(spacing: 16) {
                                    FormField(title: "Temperature (°C)", text: $temperature, placeholder: "37.0")
                                        .frame(maxWidth: .infinity)
                                    FormField(title: "O₂ Saturation (%)", text: $oxygenSaturation, placeholder: "98")
                                        .frame(maxWidth: .infinity)
                                }
                                
                                FormField(title: "Pain Level (1-10)", text: $painLevel, placeholder: "5")
                            }
                        }
                    }
                    .padding()
                    .background(cardBackgroundColor)
                    .cornerRadius(12)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                
                // Save Button Section
                Section {
                    Button(action: savePatient) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Saving..." : "Save Patient Record")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(textColor)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .background(backgroundColor)
            .navigationTitle("Add Patient")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        patientViewModel.dismissAddPatient()
                    }
                    .foregroundColor(textColor)
                }
            }
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        patientViewModel.dismissAddPatient()
                    }
                    .foregroundColor(textColor)
                }
            }
            #endif
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !presentingComplaint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Helper Functions
    private func savePatient() {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields (Name and Presenting Complaint)."
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Parse arrays from comma-separated strings
        let allergies = allergiesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let medications = medicationsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Generate patient ID
        let patientId = generatePatientId()
        
        // Create patient record
        let patient = PatientRecord(
            patientId: patientId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            age: Int(age),
            gender: gender.isEmpty ? nil : gender,
            bloodType: bloodType.isEmpty ? nil : bloodType,
            allergies: allergies,
            currentMedications: medications,
            medicalHistory: medicalHistory.trimmingCharacters(in: .whitespacesAndNewlines),
            presentingComplaint: presentingComplaint.trimmingCharacters(in: .whitespacesAndNewlines),
            treatment: treatment.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            priority: priority,
            location: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
            authorFingerprint: "local_user_001" // TODO: Replace with actual user fingerprint
        )
        
        // Add patient to view model
        patientViewModel.addPatient(patient)
        
        // Add initial vitals if provided
        if includeVitals && hasValidVitals() {
            let vitals = Vitals(
                bloodPressure: bloodPressure.isEmpty ? nil : bloodPressure,
                heartRate: Int(heartRate),
                temperature: Double(temperature),
                oxygenSaturation: Int(oxygenSaturation),
                painLevel: Int(painLevel)
            )
            
            let initialUpdate = MedicalUpdate(
                patientId: patient.id,
                updateType: .assessment,
                notes: "Initial assessment and vitals recorded",
                vitals: vitals,
                authorFingerprint: "local_user_001"
            )
            
            patientViewModel.addMedicalUpdate(initialUpdate)
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            patientViewModel.dismissAddPatient()
        }
    }
    
    private func generatePatientId() -> String {
        let existingIds = patientViewModel.patients.map { $0.patientId }
        var counter = 1
        
        while existingIds.contains("P\(String(format: "%03d", counter))") {
            counter += 1
        }
        
        return "P\(String(format: "%03d", counter))"
    }
    
    private func hasValidVitals() -> Bool {
        return !bloodPressure.isEmpty ||
               !heartRate.isEmpty ||
               !temperature.isEmpty ||
               !oxygenSaturation.isEmpty ||
               !painLevel.isEmpty
    }
}

// MARK: - Form Components
struct AddPatientSectionHeader: View {
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

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    #if os(iOS)
    var keyboardType: UIKeyboardType
    #endif
    var isRequired: Bool
    
    init(title: String, text: Binding<String>, placeholder: String, isRequired: Bool = false) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isRequired = isRequired
        #if os(iOS)
        self.keyboardType = .default
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                #if os(iOS)
                .keyboardType(keyboardType)
                #endif
        }
    }
}

struct FormTextArea: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            
            TextEditor(text: $text)
                .font(.system(size: 16))
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    Group {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
}

// MARK: - Preview
struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        AddPatientView()
            .environmentObject(PatientViewModel())
    }
} 