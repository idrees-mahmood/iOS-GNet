//
// MainTabView.swift
// bitchat
//
// This is free and unencumbered software released into the public domain.
// For more information, see <https://unlicense.org>
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct MainTabView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @StateObject private var patientViewModel = PatientViewModel()
    @State private var selectedTab: AppMode = .chat
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
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .environmentObject(chatViewModel)
                .environmentObject(patientViewModel)
                .tabItem {
                    Image(systemName: AppMode.dashboard.iconName)
                    Text(AppMode.dashboard.rawValue)
                }
                .tag(AppMode.dashboard)
            
            // Patients Tab
            PatientListView()
                .environmentObject(patientViewModel)
                .tabItem {
                    Image(systemName: AppMode.patients.iconName)
                    Text(AppMode.patients.rawValue)
                }
                .tag(AppMode.patients)
            
            // Chat Tab (Existing ContentView)
            ContentView()
                .environmentObject(chatViewModel)
                .tabItem {
                    Image(systemName: AppMode.chat.iconName)
                    Text(AppMode.chat.rawValue)
                }
                .tag(AppMode.chat)
        }
        .accentColor(textColor)
        .background(backgroundColor)
        .onAppear {
            // Customize tab bar appearance (iOS only)
            #if os(iOS)
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            
            if colorScheme == .dark {
                tabBarAppearance.backgroundColor = UIColor.black
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.green.withAlphaComponent(0.6)
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.green.withAlphaComponent(0.6)
                ]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.green
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor.green
                ]
            } else {
                tabBarAppearance.backgroundColor = UIColor.white
                let greenColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1.0)
                tabBarAppearance.stackedLayoutAppearance.normal.iconColor = greenColor.withAlphaComponent(0.6)
                tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: greenColor.withAlphaComponent(0.6)
                ]
                tabBarAppearance.stackedLayoutAppearance.selected.iconColor = greenColor
                tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: greenColor
                ]
            }
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            #endif
        }
    }
}

// MARK: - Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(ChatViewModel())
    }
} 