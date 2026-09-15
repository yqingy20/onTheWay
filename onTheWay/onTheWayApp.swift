//
//  onTheWayApp.swift
//  onTheWay
//
//  Created by 严清驭 on 2026/9/2.
//

import SwiftUI

@main
struct onTheWayApp: App {
    @StateObject private var app = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)
                .onAppear {
                    let arguments = ProcessInfo.processInfo.arguments

                    if arguments.contains("UITEST_AUTHENTICATED") {
                        app.isAuthenticated = true
                    }
                    if arguments.contains("UITEST_HELPER_MODE") {
                        app.mode = .helper
                    }
                    if arguments.contains("UITEST_PROFILE_TAB") {
                        app.selectedTab = .profile
                    }
                    if arguments.contains("UITEST_TASK_TYPE") {
                        app.path.append(AppRoute.taskType)
                    }
                    if arguments.contains("UITEST_TASK_DETAIL") {
                        app.isAuthenticated = true
                        app.mode = .helper
                        app.path.append(AppRoute.taskDetail(DemoData.tasks[0]))
                    }
                    if arguments.contains("UITEST_DIRECT_SEARCH") {
                        app.isAuthenticated = true
                        app.draft.category = .coffee
                        app.matchStrategy = .direct(DemoData.helpers[0])
                        app.directRequestStatus = .awaitingResponse
                        app.path.append(AppRoute.searching)
                    }
                    if arguments.contains("UITEST_DELIVERY_CONFIRMATION") {
                        app.isAuthenticated = true
                        app.matchedHelper = DemoData.helpers[0]
                        app.path.append(AppRoute.deliveryConfirmation)
                    }
                    if arguments.contains("UITEST_HELPER_PIN") {
                        app.isAuthenticated = true
                        app.mode = .helper
                        app.activeTask = DemoData.tasks[0]
                        app.taskProgress = .delivered
                        app.path.append(AppRoute.helperActive)
                    }
                    if arguments.contains("UITEST_HELPER_DIRECT_OFFER") {
                        app.isAuthenticated = true
                        app.mode = .helper
                        app.matchStrategy = .direct(DemoData.helpers[0])
                        app.directRequestStatus = .awaitingResponse
                        app.path.append(AppRoute.helperDirectOffer)
                    }
                    if arguments.contains("UITEST_PENDING_CHANGE") {
                        app.isAuthenticated = true
                        app.activeTask = DemoData.tasks[0]
                        app.draft.reward = 8
                        app.requestTaskChange(revisedReward: 10, revisedInstructions: "Meet at the lobby")
                        app.path.append(AppRoute.requesterActive)
                    }
                    if arguments.contains("UITEST_CANCELLED_TASK") {
                        app.isAuthenticated = true
                        app.activeTask = DemoData.tasks[0]
                        app.taskProgress = .pickedUp
                        app.cancelCurrentTask()
                        app.path.append(AppRoute.requesterActive)
                    }
                }
        }
    }
}
