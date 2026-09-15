import Foundation
import SwiftUI
import Combine

enum AppRoute: Hashable {
    case helperList(TaskCategory)
    case helperSetup
    case taskDetail(MarketplaceTask)
    case earnings
    case taskType
    case taskForm(TaskCategory)
    case taskQuote
    case searching
    case requesterActive
    case helperActive
    case helperDirectOffer
    case deliveryConfirmation
    case requesterCompletion
    case helperCompletion
    case chat(String)
    case wallet
}

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authScreen: AuthScreen = .welcome
    @Published var mode: UserMode = .requester
    @Published var selectedTab: MainTab = .home
    @Published var path = NavigationPath()
    @Published var draft = TaskDraft()
    @Published var activeTask: MarketplaceTask?
    @Published var taskProgress: TaskProgress = .matched
    @Published var isAvailableToHelp = false
    @Published var matchStrategy: MatchStrategy = .automatic
    @Published var directRequestStatus: DirectRequestStatus = .none
    @Published var matchedHelper: HelperProfile = DemoData.helpers[2]
    @Published var modificationStatus: TaskModificationStatus = .none
    @Published var pendingReward: Decimal?
    @Published var pendingInstructions: String?
    @Published var cancellationResolution: CancellationResolution = .none
    @Published var cancellationRate = 2
    let deliveryPIN = "4821"
    @Published var helperCategories: Set<TaskCategory> = [.coffee, .delivery]
    @Published var helperTransport = "Bike"
    @Published var helperRadius = 1.0
    @Published var helperDestinationMode = "Going home"
    @Published var helperDestination = "Unit 2 Dorm · Berkeley"
    @Published var savedTaskIDs: Set<UUID> = []
    @Published var unreadInbox = 6
    @Published var messages: [ChatMessage] = [
        ChatMessage(text: "Hey! I just accepted your coffee pickup. Heading to Starbucks now.", isMine: false),
        ChatMessage(text: "Thank you! The order is under Emma. Please leave it by the door if I miss the bell.", isMine: true),
        ChatMessage(text: "Got it. I’m about 4 minutes away from the store.", isMine: false),
        ChatMessage(text: "Perfect. Please message me when you’ve picked it up.", isMine: true),
        ChatMessage(text: "Will do. I’ll send a photo once I arrive too.", isMine: false)
    ]

    enum AuthScreen {
        case welcome
        case login
        case signup
    }

    func signIn() {
        withAnimation(.easeOut(duration: 0.2)) {
            isAuthenticated = true
            authScreen = .welcome
        }
    }

    func signOut() {
        isAuthenticated = false
        selectedTab = .home
        path = NavigationPath()
        authScreen = .welcome
    }

    func open(_ route: AppRoute) {
        path.append(route)
    }

    func startTask(_ task: MarketplaceTask) {
        activeTask = task
        taskProgress = .headingToPickup
        open(.helperActive)
    }

    func beginNewTask(category: TaskCategory, helper: HelperProfile? = nil) {
        draft = TaskDraft()
        draft.category = category
        modificationStatus = .none
        cancellationResolution = .none
        if let helper {
            matchStrategy = .direct(helper)
            directRequestStatus = .awaitingResponse
        } else {
            matchStrategy = .automatic
            directRequestStatus = .none
        }
        open(.taskForm(category))
    }

    func prepareQuote() {
        draft.applySuggestedReward()
    }

    func simulateMatchAcceptance() {
        switch matchStrategy {
        case .automatic:
            matchedHelper = DemoData.helpers[2]
        case .direct(let helper):
            matchedHelper = helper
            directRequestStatus = .accepted
        }
        activeTask = DemoData.tasks.first { $0.category == draft.category } ?? DemoData.tasks[0]
        taskProgress = .pickedUp
        open(.requesterActive)
    }

    func declineDirectRequestAndFallback() {
        directRequestStatus = .declinedFallback
        matchStrategy = .automatic
    }

    func presentIncomingDirectOffer() {
        mode = .helper
        matchStrategy = .direct(DemoData.helpers[0])
        directRequestStatus = .awaitingResponse
        open(.helperDirectOffer)
    }

    func acceptIncomingDirectOffer() {
        matchedHelper = DemoData.helpers[0]
        directRequestStatus = .accepted
        startTask(DemoData.tasks[0])
    }

    func requestTaskChange(revisedReward: Decimal, revisedInstructions: String) {
        let previousTotal = draft.total
        var proposal = draft
        proposal.reward = revisedReward
        proposal.rewardWasAdjusted = true
        pendingReward = revisedReward
        pendingInstructions = revisedInstructions
        modificationStatus = .awaitingHelperConsent(previousTotal: previousTotal, revisedTotal: proposal.total)
    }

    func acceptTaskChange() {
        if let pendingReward {
            draft.reward = pendingReward
            draft.rewardWasAdjusted = true
        }
        if let pendingInstructions { draft.instructions = pendingInstructions }
        modificationStatus = .accepted(revisedTotal: draft.total)
        pendingReward = nil
        pendingInstructions = nil
    }

    func declineTaskChangeAndRematch() {
        let proposedTotal: Decimal
        if case let .awaitingHelperConsent(_, revisedTotal) = modificationStatus {
            proposedTotal = revisedTotal
        } else {
            proposedTotal = draft.total
        }
        modificationStatus = .declinedRematching(revisedTotal: proposedTotal)
        pendingReward = nil
        pendingInstructions = nil
        matchStrategy = .automatic
        directRequestStatus = .declinedFallback
    }

    func cancelCurrentTask() {
        let pickedUp = taskProgress.rawValue >= TaskProgress.pickedUp.rawValue
        let helperPayment = pickedUp ? draft.reward : 0
        let refund = pickedUp ? draft.platformFee : draft.total
        cancellationRate += 1
        cancellationResolution = .cancelled(refund: refund, helperPayment: helperPayment, rate: cancellationRate)
        activeTask = nil
    }

    func toggleSaved(_ task: MarketplaceTask) {
        if savedTaskIDs.contains(task.id) { savedTaskIDs.remove(task.id) }
        else { savedTaskIDs.insert(task.id) }
    }

    func advanceTask() {
        guard let next = taskProgress.next else { return }
        taskProgress = next
    }
}
