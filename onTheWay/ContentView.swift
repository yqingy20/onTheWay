//
//  ContentView.swift
//  onTheWay
//
//  Created by 严清驭 on 2026/9/2.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        Group {
            if app.isAuthenticated {
                NavigationStack(path: $app.path) {
                    MainShellView()
                        .navigationDestination(for: AppRoute.self) { route in
                            destination(for: route)
                        }
                }
                .transition(.opacity)
            } else {
                AuthenticationRootView()
                    .transition(.opacity)
            }
        }
        .tint(Color.brandGreen)
        .preferredColorScheme(nil)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .helperList(let category):
            HelperListView(category: category)
        case .helperSetup:
            HelpingSetupView()
        case .taskDetail(let task):
            TaskDetailView(task: task)
        case .earnings:
            EarningsView()
        case .taskType:
            TaskTypeView()
        case .taskForm(let category):
            TaskFormView(category: category)
        case .taskQuote:
            TaskQuoteView()
        case .searching:
            SearchingHelperView()
        case .requesterActive:
            RequesterActiveTaskView()
        case .helperActive:
            HelperActiveTaskView()
        case .helperDirectOffer:
            HelperDirectOfferView()
        case .deliveryConfirmation:
            DeliveryConfirmationView()
        case .requesterCompletion:
            TaskCompletionView(reviewerMode: .requester)
        case .helperCompletion:
            TaskCompletionView(reviewerMode: .helper)
        case .chat(let person):
            ChatThreadView(person: person)
        case .wallet:
            WalletView()
        }
    }
}
