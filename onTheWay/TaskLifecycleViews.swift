import SwiftUI

struct HelperActiveTaskView: View {
    @EnvironmentObject private var app: AppState
    @State private var showingIssue = false
    @State private var handoffPIN = ""
    @State private var pinError = false
    @State private var notice: String?

    private var task: MarketplaceTask { app.activeTask ?? DemoData.tasks[0] }

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(timeTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appSecondaryInk)
                        Text(timeValue)
                            .font(.largeTitle.weight(.bold).monospacedDigit())
                    }
                    Spacer()
                    StatusPill(text: taskProgressLabel, icon: "figure.walk.motion", tint: .brandGreen)
                }

                MarketplaceMap(mode: .helper, tasks: [task]) { _ in }
                    .frame(height: 230)

                HStack(spacing: 12) {
                    CircleIcon(systemName: task.category.icon, tint: task.category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title).font(.headline)
                        Text("Task #TK-39201 · \(app.taskProgress.title)")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Earning").font(.caption).foregroundStyle(Color.appSecondaryInk)
                        Text(task.reward.currencyText).font(.title3.weight(.bold)).foregroundStyle(Color.brandGreen)
                    }
                }
                .cardStyle()

                SectionHeading(title: "Route")
                VStack(spacing: 0) {
                    LabeledValueRow(label: "Pickup · Starbucks", value: "2301 Bancroft Way", icon: "mappin.circle.fill")
                    Divider()
                    LabeledValueRow(label: "Drop-off · Unit 2 Dorm", value: "2650 Durant Ave, Apt 3B", icon: "house.circle.fill")
                }
                .cardStyle(padding: 12)

                SectionHeading(title: "Order")
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("#SB-48291").font(.subheadline.weight(.semibold)).monospacedDigit()
                        Spacer()
                        StatusPill(text: "Prepaid", icon: "checkmark.circle.fill", tint: .brandGreen)
                    }
                    Label("2× Medium Iced Latte", systemImage: "cup.and.saucer.fill")
                        .font(.subheadline)
                    Text("Name: Emma Wilson · Ring doorbell; leave by door if there is no answer.")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                }
                .cardStyle()

                HStack(spacing: 10) {
                    Button {
                        app.open(.chat("Emma W."))
                    } label: {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .buttonStyle(SecondaryActionStyle())
                    Button { notice = "Calling the requester through a privacy-protected relay number (demo)." } label: {
                        Label("Call", systemImage: "phone.fill")
                    }
                    .buttonStyle(SecondaryActionStyle())
                    Button { showingIssue = true } label: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .frame(width: 44, height: 44)
                    }
                    .foregroundStyle(Color.warmAmber)
                    .accessibilityLabel("Report an issue")
                }

                if app.taskProgress == .delivered {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Secure handoff", systemImage: "key.fill")
                            .font(.headline)
                        Text("Ask the requester for the 4-digit delivery PIN. Payment stays in escrow until it is verified.")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                        TextField("Delivery PIN", text: $handoffPIN)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .multilineTextAlignment(.center)
                            .font(.title2.monospacedDigit().weight(.bold))
                            .padding(12)
                            .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                            .accessibilityLabel("Four digit delivery PIN")
                        if pinError {
                            Label("That PIN does not match. Recheck it with the requester.", systemImage: "exclamationmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.appDanger)
                        }
                    }
                    .cardStyle()
                }

                Button {
                    if app.taskProgress == .delivered {
                        if handoffPIN == app.deliveryPIN {
                            pinError = false
                            app.taskProgress = .completed
                            app.open(.helperCompletion)
                        } else {
                            pinError = true
                        }
                    } else {
                        app.advanceTask()
                    }
                } label: {
                    Label(nextActionTitle, systemImage: nextActionIcon)
                }
                .buttonStyle(PrimaryActionStyle())
            }
            .padding(.top, 8)
        }
        .navigationTitle("Active Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("End", systemImage: "flag.fill") { showingIssue = true }
                    .foregroundStyle(Color.appDanger)
            }
        }
        .alert("Task support", isPresented: $showingIssue) {
            Button("Contact Support") { notice = "A priority support chat has been queued with the task ID and current route state." }
            Button("Keep Working", role: .cancel) { }
        } message: {
            Text("For safety issues, contact emergency services first. Support can help with cancellations, address problems, or handoff questions.")
        }
        .alert("Communication", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
            Button("OK", role: .cancel) { notice = nil }
        } message: {
            Text(notice ?? "")
        }
    }

    private var taskProgressLabel: String { app.taskProgress.title }
    private var timeTitle: String { app.taskProgress.rawValue < TaskProgress.pickedUp.rawValue ? "TIME TO PICKUP" : "TIME TO DROP-OFF" }
    private var timeValue: String { app.taskProgress.rawValue < TaskProgress.pickedUp.rawValue ? "4 min" : "12 min" }

    private var nextActionTitle: String {
        switch app.taskProgress {
        case .matched, .headingToPickup: "I’m Arrived at Pickup"
        case .atPickup: "Confirm Order Picked Up"
        case .pickedUp, .headingToRequester: "I’m Arrived at Drop-off"
        case .delivered: "Verify PIN & Complete"
        case .completed: "Task Completed"
        }
    }

    private var nextActionIcon: String {
        switch app.taskProgress {
        case .matched, .headingToPickup, .pickedUp, .headingToRequester: "location.fill"
        case .atPickup: "bag.fill.badge.checkmark"
        case .delivered, .completed: "checkmark.circle.fill"
        }
    }
}

struct HelperDirectOfferView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var declined = false

    private let task = DemoData.tasks[0]

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                if declined {
                    VStack(spacing: 18) {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.accentBlue)
                        Text("Offer declined")
                            .font(.largeTitle.weight(.bold))
                        Text("The requester’s authorized offer has returned to the automatic helper pool. Your exact location was not shared.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondaryInk)
                            .multilineTextAlignment(.center)
                        Button("Back to Nearby Tasks", systemImage: "map.fill") { dismiss() }
                            .buttonStyle(PrimaryActionStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 44)
                } else {
                    HStack(spacing: 12) {
                        AvatarView(initials: "EW", tint: .accentBlue, online: true)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Direct request from Emma W.")
                                .font(.title3.weight(.bold))
                            RatingSummary(rating: 4.91, trailing: "36 completed requests")
                        }
                        Spacer()
                        StatusPill(text: "2 min left", icon: "timer", tint: .warmAmber)
                    }
                    .cardStyle()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title).font(.title2.weight(.bold))
                            Text("Private offer · prepaid")
                                .font(.caption)
                                .foregroundStyle(Color.appSecondaryInk)
                        }
                        Spacer()
                        Text(task.reward.currencyText)
                            .font(.largeTitle.weight(.bold).monospacedDigit())
                            .foregroundStyle(Color.brandGreen)
                    }
                    .cardStyle()

                    SectionHeading(title: "Route preview")
                    VStack(spacing: 0) {
                        LabeledValueRow(label: "Pickup area", value: "Bancroft Way · ~0.2 mi", icon: "mappin.circle.fill")
                        Divider()
                        LabeledValueRow(label: "Drop-off area", value: "Unit 2 residence area", icon: "house.circle.fill")
                        Divider()
                        LabeledValueRow(label: "Route detour", value: "+0.1 mi · ~7 min", icon: "point.topleft.down.to.point.bottomright.curvepath")
                    }
                    .cardStyle(padding: 12)

                    Label("Exact addresses, requester contact, order reference, and handoff instructions unlock only after you accept.", systemImage: "lock.shield.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSecondaryInk)
                        .cardStyle()

                    HStack(spacing: 12) {
                        Button("Decline", systemImage: "xmark") {
                            app.declineDirectRequestAndFallback()
                            declined = true
                        }
                        .buttonStyle(SecondaryActionStyle())

                        Button("Accept Request", systemImage: "checkmark") {
                            app.acceptIncomingDirectOffer()
                        }
                        .buttonStyle(PrimaryActionStyle())
                    }
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Direct Offer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RequesterActiveTaskView: View {
    @EnvironmentObject private var app: AppState
    @State private var showingCancel = false
    @State private var showingIssue = false
    @State private var showingEdit = false
    @State private var revisedReward: Decimal = 6
    @State private var revisedInstructions = "Ring doorbell, then leave beside the lobby desk."
    @State private var notice: String?

    private var helper: HelperProfile { app.matchedHelper }
    private var timeline: [(String, String, String, Bool)] { [
        ("9:28 AM", "Order placed", "Task published to nearby helpers", true),
        ("9:30 AM", "\(helper.name) accepted your task", "\(helper.rating.formatted(.number.precision(.fractionLength(2)))) rated helper · \(helper.completed) completed tasks", true),
        ("9:34 AM", "Arrived at Starbucks", "Picking up your order", true),
        ("9:41 AM", "Order picked up", "On the way to your location · ETA 12 min", true),
        ("~9:53 AM", "Arriving at your door", "Please be ready to receive", false)
    ] }

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                if isCancelled {
                    VStack(spacing: 18) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.appDanger)
                            .accessibilityHidden(true)
                        Text("Task cancelled")
                            .font(.largeTitle.weight(.bold))
                        Text("The active delivery has ended. No delivery or edit actions remain available.")
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondaryInk)
                            .multilineTextAlignment(.center)
                        if let summary = app.cancellationResolution.summary {
                            Label(summary, systemImage: "dollarsign.arrow.circlepath")
                                .font(.subheadline)
                                .foregroundStyle(Color.appDanger)
                                .cardStyle()
                        }
                        Button("Return to Activity", systemImage: "list.bullet.rectangle") {
                            app.path = NavigationPath()
                            app.selectedTab = .activity
                        }
                        .buttonStyle(PrimaryActionStyle())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 44)
                } else {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("ARRIVING IN")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appSecondaryInk)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("12").font(.largeTitle.weight(.bold).monospacedDigit())
                            Text("min").font(.headline)
                        }
                    }
                    Spacer()
                    StatusPill(text: "Picked Up", icon: "cup.and.saucer.fill", tint: .brandGreen)
                }

                ProgressView(value: 0.58) {
                    HStack {
                        Text("Ordered")
                        Spacer()
                        Text("Pickup ✓")
                        Spacer()
                        Text("Delivering")
                        Spacer()
                        Text("Complete")
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.appSecondaryInk)
                }
                .tint(Color.brandGreen)

                HStack(spacing: 12) {
                    AvatarView(initials: helper.initials, online: true)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 5) {
                            Text(helper.name).font(.headline)
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(Color.accentBlue)
                        }
                        RatingSummary(rating: helper.rating, trailing: "\(helper.completed) tasks · \(app.helperTransport)")
                        Label("0.3 mi away · Heading your way", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.brandGreen)
                    }
                    Spacer()
                    Button { notice = "Calling \(helper.name) through a privacy-protected relay number (demo)." } label: {
                        Image(systemName: "phone.fill").frame(width: 44, height: 44)
                    }
                    .background(Color.accentBlue.opacity(0.1), in: Circle())
                    .accessibilityLabel("Call \(helper.name)")
                    Button { app.open(.chat(helper.name)) } label: {
                        Image(systemName: "message.fill").frame(width: 44, height: 44)
                    }
                    .background(Color.brandNavy.opacity(0.1), in: Circle())
                    .accessibilityLabel("Chat with \(helper.name)")
                }
                .cardStyle()

                modificationCard

                if let summary = app.cancellationResolution.summary {
                    Label(summary, systemImage: "arrow.uturn.backward.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.appDanger)
                        .cardStyle()
                }

                MarketplaceMap(mode: .requester, tasks: [DemoData.tasks[0]]) { _ in }
                    .frame(height: 230)

                SectionHeading(title: "Live Timeline")
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(timeline.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(item.3 ? Color.brandGreen : Color.appLine)
                                    .frame(width: 14, height: 14)
                                if index < timeline.count - 1 {
                                    Rectangle()
                                        .fill(item.3 ? Color.brandGreen.opacity(0.35) : Color.appLine)
                                        .frame(width: 2)
                                        .frame(minHeight: 58)
                                }
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.0)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(item.3 ? Color.brandGreen : Color.appSecondaryInk)
                                Text(item.1).font(.subheadline.weight(.semibold))
                                Text(item.2).font(.caption).foregroundStyle(Color.appSecondaryInk)
                            }
                            .padding(.bottom, 18)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .cardStyle()

                HStack(spacing: 8) {
                    Button("Cancel", systemImage: "nosign") { showingCancel = true }
                        .buttonStyle(SecondaryActionStyle(compact: true))
                    Button("Edit", systemImage: "pencil") {
                        revisedReward = app.draft.reward + 1
                        revisedInstructions = app.draft.instructions
                        showingEdit = true
                    }
                        .buttonStyle(SecondaryActionStyle(compact: true))
                    Button("Issue", systemImage: "exclamationmark.triangle") { showingIssue = true }
                        .buttonStyle(SecondaryActionStyle(compact: true))
                }

                Button {
                    app.taskProgress = .delivered
                    app.open(.deliveryConfirmation)
                } label: {
                    Label("Simulate Delivery", systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(PrimaryActionStyle())
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Your Coffee Order")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                TaskChangeSheet(revisedReward: $revisedReward, revisedInstructions: $revisedInstructions)
            }
            .environmentObject(app)
        }
        .confirmationDialog("Cancel this task?", isPresented: $showingCancel, titleVisibility: .visible) {
            Button("Cancel Task & Resolve Payment", role: .destructive) {
                app.cancelCurrentTask()
                notice = app.cancellationResolution.summary
            }
            Button("Keep Task", role: .cancel) { }
        } message: {
            Text("Because \(helper.name) has already picked up the order, the helper reward is paid for completed work; the platform fee is refunded and your cancellation rate increases by 1 point.")
        }
        .alert("Report a problem", isPresented: $showingIssue) {
            Button("Contact Support") { notice = "A priority support case has been opened with the active task timeline attached." }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("Support can help with safety, missing items, delays, or delivery problems.")
        }
        .alert("Task update", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
            Button("OK", role: .cancel) { notice = nil }
        } message: {
            Text(notice ?? "")
        }
    }

    private var isCancelled: Bool {
        if case .cancelled = app.cancellationResolution { return true }
        return false
    }

    @ViewBuilder
    private var modificationCard: some View {
        switch app.modificationStatus {
        case .none, .drafting:
            EmptyView()
        case let .awaitingHelperConsent(previousTotal, revisedTotal):
            VStack(alignment: .leading, spacing: 12) {
                Label("Change awaiting helper consent", systemImage: "clock.badge.questionmark")
                    .font(.headline)
                Text("Total changes from \(previousTotal.currencyText) to \(revisedTotal.currencyText). The current task stays active until \(helper.name) responds.")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryInk)
                HStack(spacing: 10) {
                    Button("Simulate Accept") {
                        app.acceptTaskChange()
                        notice = "\(helper.name) accepted the revised task. Escrow was updated to \(app.draft.total.currencyText)."
                    }
                    .buttonStyle(PrimaryActionStyle(compact: true))
                    Button("Decline & Rematch") {
                        app.declineTaskChangeAndRematch()
                        notice = "The change was declined. The revised offer is now being rematched automatically; exact address remains private."
                    }
                    .buttonStyle(SecondaryActionStyle(compact: true))
                }
            }
            .cardStyle()
        case let .accepted(revisedTotal):
            StatusPill(text: "Change accepted · Escrow \(revisedTotal.currencyText)", icon: "checkmark.circle.fill", tint: .brandGreen)
        case let .declinedRematching(revisedTotal):
            StatusPill(text: "Rematching revised task · \(revisedTotal.currencyText)", icon: "arrow.triangle.2.circlepath", tint: .accentBlue)
        }
    }
}

private struct TaskChangeSheet: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss
    @Binding var revisedReward: Decimal
    @Binding var revisedInstructions: String

    var body: some View {
        Form {
            Section("Requested change") {
                Stepper("Helper reward · \(revisedReward.currencyText)", value: $revisedReward, in: 3...20, step: 1)
                TextField("Updated handoff instructions", text: $revisedInstructions, axis: .vertical)
                    .lineLimit(2...5)
            }
            Section("Recalculation") {
                LabeledContent("Current total", value: app.draft.total.currencyText)
                LabeledContent("Revised reward", value: revisedReward.currencyText)
                LabeledContent("Revised total", value: (revisedReward + (revisedReward * Decimal(string: "0.15")!).rounded(scale: 2)).currencyText)
                Text("The helper must consent before the change takes effect. A decline starts automatic rematching without exposing your exact address.")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryInk)
            }
            Button("Send Change Request", systemImage: "paperplane.fill") {
                app.requestTaskChange(revisedReward: revisedReward, revisedInstructions: revisedInstructions)
                dismiss()
            }
        }
        .navigationTitle("Edit Active Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
        }
    }
}

struct DeliveryConfirmationView: View {
    @EnvironmentObject private var app: AppState
    @State private var showingProblem = false

    var body: some View {
        ScreenScaffold {
            VStack(spacing: 20) {
                Image(systemName: "shippingbox.and.arrow.backward.fill")
                    .font(.largeTitle)
                    .foregroundStyle(Color.brandGreen)
                Text("Confirm your handoff")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                Text("Only confirm after you have the order. Payment remains held in escrow until confirmation.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryInk)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    Text("DELIVERY PIN")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.appSecondaryInk)
                    Text(app.deliveryPIN)
                        .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                        .accessibilityLabel("Delivery PIN \(app.deliveryPIN.map(String.init).joined(separator: " "))")
                    Text("Share this with \(app.matchedHelper.name) at the door. It cannot be used before arrival.")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                        .multilineTextAlignment(.center)
                }
                .cardStyle()

                Button("I Received the Order", systemImage: "checkmark.circle.fill") {
                    app.taskProgress = .completed
                    app.open(.requesterCompletion)
                }
                .buttonStyle(PrimaryActionStyle())

                Button("There’s a Problem", systemImage: "exclamationmark.triangle.fill") {
                    showingProblem = true
                }
                .buttonStyle(SecondaryActionStyle())
            }
            .padding(.top, 24)
        }
        .navigationTitle("Delivery Confirmation")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Payment remains on hold", isPresented: $showingProblem) {
            Button("Open Support Chat") { app.open(.chat("OnTheWay Support")) }
            Button("Keep Reviewing", role: .cancel) { }
        } message: {
            Text("Report missing items, damage, or a failed handoff before escrow is released.")
        }
    }
}

struct TaskCompletionView: View {
    @EnvironmentObject private var app: AppState
    let reviewerMode: UserMode
    @State private var overallRating = 5
    @State private var reliability = 5
    @State private var communication = 5
    @State private var quality = 5
    @State private var tip: Decimal = 2
    @State private var comment = "Everything was perfect — fast updates and careful delivery."
    @State private var submitted = false

    private var isRequester: Bool { reviewerMode == .requester }
    private var subjectName: String { isRequester ? app.matchedHelper.name : "Emma W." }
    private var subjectInitials: String { isRequester ? app.matchedHelper.initials : "EW" }

    var body: some View {
        ScreenScaffold {
            VStack(spacing: 20) {
                Image(systemName: submitted ? "paperplane.circle.fill" : "checkmark.circle.fill")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.brandGreen)
                    .accessibilityHidden(true)
                VStack(spacing: 5) {
                    Text(submitted ? "Thanks for your feedback" : (isRequester ? "Delivered!" : "Task complete!"))
                        .font(.largeTitle.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text(submitted ? "Your rating helps keep the marketplace trusted." : completionDetail)
                        .font(.subheadline)
                        .foregroundStyle(Color.appSecondaryInk)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    AvatarView(initials: subjectInitials)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 5) {
                            Text(subjectName).font(.headline)
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(Color.accentBlue)
                        }
                        Text(isRequester ? "Helped with your \(app.draft.category.rawValue.lowercased()) task" : "Requested this completed \(app.draft.category.rawValue.lowercased()) task")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                        HStack {
                            StatusPill(text: isRequester ? app.helperTransport : "Verified requester", icon: isRequester ? "bicycle" : "checkmark.shield.fill", tint: .accentBlue)
                            StatusPill(text: isRequester ? "Elite Helper" : "Reliable", icon: "star.fill", tint: .warmAmber)
                        }
                    }
                    Spacer()
                }
                .cardStyle()

                if submitted {
                    Button("Return Home") {
                        app.path = NavigationPath()
                        app.selectedTab = .home
                    }
                    .buttonStyle(PrimaryActionStyle())
                } else {
                    ratingContent
                }
            }
            .padding(.top, 24)
        }
        .navigationBarBackButtonHidden(submitted)
    }

    private var ratingContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 10) {
                Text("How was your experience with \(subjectName)?")
                    .font(.headline)
                StarRating(rating: $overallRating, label: "Overall rating")
                Text("Excellent · \(overallRating) stars")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.warmAmber)
            }
            .frame(maxWidth: .infinity)

            SectionHeading(title: "Rate specific categories")
            VStack(spacing: 0) {
                categoryRating(title: "Reliability", subtitle: isRequester ? "Arrived on time and followed through" : "Was ready and provided accurate details", icon: "clock.fill", rating: $reliability)
                Divider()
                categoryRating(title: "Communication", subtitle: "Clear updates and responses", icon: "message.fill", rating: $communication)
                Divider()
                categoryRating(title: isRequester ? "Task Quality" : "Handoff", subtitle: isRequester ? "Order correct and in good condition" : "Pickup and delivery handoff were smooth", icon: "cup.and.saucer.fill", rating: $quality)
            }
            .cardStyle(padding: 12)

            if isRequester {
                SectionHeading(title: "Leave a tip (Optional)")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach([Decimal(0), 1, 2, 3, 5], id: \.self) { amount in
                            Button(amount == 0 ? "No tip" : amount.currencyText) { tip = amount }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(tip == amount ? Color.white : Color.appInk)
                                .frame(minWidth: 64, minHeight: 44)
                                .background(tip == amount ? Color.brandNavy : Color.appSurfaceAlt, in: Capsule())
                                .accessibilityAddTraits(tip == amount ? .isSelected : [])
                        }
                    }
                }
                Label("100% of your tip goes directly to \(subjectName).", systemImage: "info.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryInk)
            }

            SectionHeading(title: "Leave a comment (Optional)")
            TextEditor(text: $comment)
                .frame(minHeight: 110)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                .accessibilityLabel("Comment for \(subjectName)")

            Label(paymentResolution, systemImage: "checkmark.shield.fill")
                .font(.subheadline)
                .foregroundStyle(Color.brandGreen)
                .cardStyle()

            Button {
                submitted = true
            } label: {
                Label("Submit Rating", systemImage: "paperplane.fill")
            }
            .buttonStyle(PrimaryActionStyle())
        }
    }

    private var completionDetail: String {
        isRequester
        ? "Your task was confirmed in 21 minutes · \(app.draft.total.currencyText) total"
        : "The delivery PIN was verified · \(app.draft.reward.currencyText) moved to pending earnings"
    }

    private var paymentResolution: String {
        isRequester
        ? "Payment released to \(subjectName): \(app.draft.reward.currencyText) reward + \(tip.currencyText) tip"
        : "Requester payment confirmed · your \(app.draft.reward.currencyText) reward is pending settlement"
    }

    private func categoryRating(title: String, subtitle: String, icon: String, rating: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                CircleIcon(systemName: icon, tint: .accentBlue, size: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
                }
            }
            StarRating(rating: rating, label: title)
        }
        .padding(.vertical, 8)
    }
}

struct StarRating: View {
    @Binding var rating: Int
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating = star
                } label: {
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(Color.warmAmber)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(star) stars")
                .accessibilityAddTraits(star == rating ? .isSelected : [])
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }
}
