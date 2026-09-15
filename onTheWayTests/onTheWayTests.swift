//
//  onTheWayTests.swift
//  onTheWayTests
//
//  Created by 严清驭 on 2026/9/2.
//

import Foundation
import Testing
@testable import onTheWay

struct onTheWayTests {

    @Test func pricingUsesTransparentFifteenPercentPlatformFee() {
        var draft = TaskDraft()
        draft.reward = 5

        #expect(draft.platformFee == Decimal(string: "0.75"))
        #expect(draft.total == Decimal(string: "5.75"))
    }

    @Test func pricingRoundsToCents() {
        var draft = TaskDraft()
        draft.reward = Decimal(string: "6.50")!

        #expect(draft.platformFee == Decimal(string: "0.98"))
        #expect(draft.total == Decimal(string: "7.48"))
    }

    @Test func progressAdvancesInMarketplaceOrder() {
        #expect(TaskProgress.matched.next == .headingToPickup)
        #expect(TaskProgress.atPickup.next == .pickedUp)
        #expect(TaskProgress.delivered.next == .completed)
        #expect(TaskProgress.completed.next == nil)
    }

    @Test func routeMatchDataPrioritizesMinimalDetour() {
        let recommended = DemoData.tasks.sorted {
            if $0.match == $1.match { return $0.detourDistance < $1.detourDistance }
            return $0.match > $1.match
        }

        #expect(recommended.first?.title == "Coffee Pickup")
        #expect(recommended.first?.match == 92)
        #expect(recommended.first?.detourDistance == 0.1)
    }

    @Test func suggestedRewardReflectsRouteEffortUrgencyAndDemand() {
        var baseline = TaskDraft()
        baseline.isASAP = false
        baseline.demandLevel = "Low"

        var demanding = baseline
        demanding.category = .delivery
        demanding.routeDistance = 2.4
        demanding.estimatedMinutes = 45
        demanding.itemSize = "Large"
        demanding.isFragile = true
        demanding.isASAP = true
        demanding.demandLevel = "High"

        #expect(demanding.suggestedReward > baseline.suggestedReward)
    }

    @MainActor
    @Test func directRequestKeepsChosenHelperUntilFallback() {
        let app = AppState()
        let helper = DemoData.helpers[0]

        app.beginNewTask(category: .coffee, helper: helper)
        #expect(app.matchStrategy == .direct(helper))
        #expect(app.directRequestStatus == .awaitingResponse)

        app.declineDirectRequestAndFallback()
        #expect(app.matchStrategy == .automatic)
        #expect(app.directRequestStatus == .declinedFallback)
    }

    @MainActor
    @Test func acceptedChangeAndPostPickupCancellationResolveMoney() {
        let app = AppState()
        app.draft.reward = 8
        let originalInstructions = app.draft.instructions
        app.requestTaskChange(revisedReward: 10, revisedInstructions: "Meet at the lobby")
        #expect(app.draft.reward == 8)
        #expect(app.draft.instructions == originalInstructions)
        app.acceptTaskChange()
        #expect(app.modificationStatus == .accepted(revisedTotal: Decimal(string: "11.50")!))
        #expect(app.draft.reward == 10)
        #expect(app.draft.instructions == "Meet at the lobby")

        app.activeTask = DemoData.tasks[0]
        app.taskProgress = .pickedUp
        app.cancelCurrentTask()
        #expect(app.cancellationResolution == .cancelled(
            refund: Decimal(string: "1.50")!,
            helperPayment: 10,
            rate: 3
        ))
        #expect(app.activeTask == nil)
    }

}
