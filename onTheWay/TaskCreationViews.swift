import SwiftUI

struct TaskTypeView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 16) {
                Text("What do you need?")
                    .font(.largeTitle.weight(.bold))
                Text("Choose one to get started. The next questions adapt to your task.")
                    .font(.body)
                    .foregroundStyle(Color.appSecondaryInk)
                    .padding(.bottom, 8)

                ForEach(TaskCategory.allCases) { category in
                    Button {
                        app.beginNewTask(category: category)
                    } label: {
                        HStack(spacing: 14) {
                            CircleIcon(systemName: category.icon, tint: category.tint)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .foregroundStyle(Color.appInk)
                                Text(category.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appSecondaryInk)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.appSecondaryInk)
                                .accessibilityHidden(true)
                        }
                        .cardStyle(padding: 14)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Starts a \(category.rawValue) task")
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("New Task")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TaskFormView: View {
    @EnvironmentObject private var app: AppState
    let category: TaskCategory
    @State private var showingValidation = false
    @State private var savedDraft = false
    @FocusState private var focusedField: Field?

    private enum Field { case store, pickup, name, number, item, delivery, contact, instructions }

    private var formIsValid: Bool {
        !app.draft.store.trimmingCharacters(in: .whitespaces).isEmpty &&
        !app.draft.pickupAddress.trimmingCharacters(in: .whitespaces).isEmpty &&
        !app.draft.deliveryAddress.trimmingCharacters(in: .whitespaces).isEmpty &&
        (category != .delivery || !app.draft.pickupContact.trimmingCharacters(in: .whitespaces).isEmpty) &&
        (category != .returnDropoff || !app.draft.orderNumber.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                ProgressView(value: 2, total: 4) {
                    Text("Step 2 of 4 · Details")
                        .font(.caption.weight(.semibold))
                }
                .tint(Color.brandGreen)

                HStack(spacing: 12) {
                    CircleIcon(systemName: category.icon, tint: category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(category.rawValue)
                            .font(.title3.weight(.bold))
                        Text(categoryDescription)
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    StatusPill(text: category == .returnDropoff ? "Label ready" : "Prepaid", icon: "checkmark.circle.fill", tint: .brandGreen)
                }
                .cardStyle()

                formSection(title: storeLabel, icon: "storefront.fill") {
                    labeledTextField(storeLabel, placeholder: "Search or select a place", text: $app.draft.store, field: .store)
                    labeledTextField("Pickup Address", placeholder: "Street address", text: $app.draft.pickupAddress, field: .pickup)
                }

                formSection(title: detailSectionTitle, icon: "doc.text.fill") {
                    labeledTextField(primaryNameLabel, placeholder: primaryNamePlaceholder, text: $app.draft.orderName, field: .name)
                    labeledTextField(referenceLabel, placeholder: referencePlaceholder, text: $app.draft.orderNumber, field: .number)
                    labeledTextField(itemLabel, placeholder: itemPlaceholder, text: $app.draft.itemDetails, field: .item)
                    if category == .delivery {
                        labeledTextField("Pickup Contact", placeholder: "Name, desk, or safe meeting point", text: $app.draft.pickupContact, field: .contact)
                    }
                }

                formSection(title: "Delivery", icon: "house.fill") {
                    labeledTextField("Delivery Address", placeholder: "Where should it go?", text: $app.draft.deliveryAddress, field: .delivery)
                    Picker("When do you need it?", selection: $app.draft.isASAP) {
                        Label("ASAP", systemImage: "bolt.fill").tag(true)
                        Label("Schedule", systemImage: "clock.fill").tag(false)
                    }
                    .pickerStyle(.segmented)
                    if !app.draft.isASAP {
                        DatePicker("Scheduled for", selection: $app.draft.scheduledFor, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                            .frame(minHeight: 44)
                    }
                    if category == .returnDropoff || category == .other {
                        DatePicker("Must be completed by", selection: $app.draft.deadline, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                            .frame(minHeight: 44)
                    }
                }

                formSection(title: "Size & Preferences", icon: "shippingbox.fill") {
                    Picker("Item size", selection: $app.draft.itemSize) {
                        Text("Small").tag("Small")
                        Text("Medium").tag("Medium")
                        Text("Large").tag("Large")
                    }
                    .pickerStyle(.segmented)
                    if category == .delivery || category == .returnDropoff || category == .other {
                        Picker("Package weight", selection: $app.draft.packageWeight) {
                            Text("Under 5 lb").tag("Under 5 lb")
                            Text("5–10 lb").tag("5–10 lb")
                            Text("10–20 lb").tag("10–20 lb")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        Toggle("Fragile item", isOn: $app.draft.isFragile)
                            .frame(minHeight: 44)
                    }
                    Toggle("Contactless delivery", isOn: $app.draft.contactless)
                        .frame(minHeight: 44)
                }

                formSection(title: "Route & Effort", icon: "point.topleft.down.to.point.bottomright.curvepath") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated route · \(app.draft.routeDistance, specifier: "%.1f") mi")
                            .font(.caption.weight(.semibold))
                        Slider(value: $app.draft.routeDistance, in: 0.2...3, step: 0.1)
                            .tint(Color.brandGreen)
                    }
                    Stepper("About \(app.draft.estimatedMinutes) minutes of helper time", value: $app.draft.estimatedMinutes, in: 10...60, step: 5)
                        .frame(minHeight: 44)
                    Picker("Local demand", selection: $app.draft.demandLevel) {
                        Text("Low").tag("Low")
                        Text("Medium").tag("Medium")
                        Text("High").tag("High")
                    }
                    .pickerStyle(.segmented)
                    LabeledValueRow(label: "Live suggested reward", value: app.draft.suggestedReward.currencyText, valueTint: .brandGreen)
                }

                formSection(title: "Special Instructions", icon: "text.bubble.fill") {
                    TextEditor(text: $app.draft.instructions)
                        .focused($focusedField, equals: .instructions)
                        .frame(minHeight: 100)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                        .accessibilityLabel("Special instructions")
                }

                VStack(spacing: 0) {
                    LabeledValueRow(label: "Suggested helper reward", value: app.draft.suggestedReward.currencyText, valueTint: .brandGreen)
                    Divider()
                    LabeledValueRow(label: "Estimated platform fee", value: suggestedFee.currencyText)
                    Divider()
                    LabeledValueRow(label: "Estimated total", value: suggestedTotal.currencyText)
                }
                .cardStyle(padding: 12)

                if showingValidation && !formIsValid {
                    Label("Add the store, pickup address, and delivery address before continuing.", systemImage: "exclamationmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(Color.appDanger)
                }

                Button {
                    showingValidation = true
                    if formIsValid {
                        focusedField = nil
                        app.prepareQuote()
                        app.open(.taskQuote)
                    }
                } label: {
                    Label("Continue to Pricing", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryActionStyle())
            }
            .padding(.top, 8)
        }
        .navigationTitle(category == .coffee ? "Coffee Pickup" : category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save draft") {
                    focusedField = nil
                    savedDraft = true
                }
                    .font(.subheadline)
            }
        }
        .onAppear { app.draft.category = category }
        .alert("Draft saved", isPresented: $savedDraft) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your task details are stored locally in this demo and can be resumed from Activity.")
        }
    }

    private var categoryDescription: String {
        switch category {
        case .coffee: "Best for prepaid mobile orders"
        case .delivery: "Small items with clear pickup instructions"
        case .store: "Prepaid store and curbside orders"
        case .returnDropoff: "Package label or QR code ready"
        case .other: "Describe a safe, local, lightweight errand"
        }
    }

    private var suggestedFee: Decimal { (app.draft.suggestedReward * Decimal(string: "0.15")!).rounded(scale: 2) }
    private var suggestedTotal: Decimal { app.draft.suggestedReward + suggestedFee }

    private var storeLabel: String { category == .returnDropoff ? "Drop-off Provider" : "Store / Restaurant" }
    private var detailSectionTitle: String { category == .returnDropoff ? "Package Details" : "Order Details" }
    private var primaryNameLabel: String { category == .delivery ? "Pickup Contact" : "Order Name" }
    private var primaryNamePlaceholder: String { category == .delivery ? "Who has the item?" : "Name on the order" }
    private var referenceLabel: String { category == .returnDropoff ? "Label or QR Code" : "Order Number" }
    private var referencePlaceholder: String { category == .returnDropoff ? "Label details" : "Order or reference number" }
    private var itemLabel: String { category == .returnDropoff ? "Package" : "Items" }
    private var itemPlaceholder: String { category == .returnDropoff ? "Size, weight, fragile status" : "What should the helper collect?" }

    private func formSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(Color.appInk)
            content()
        }
        .cardStyle()
    }

    private func labeledTextField(_ label: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Color.appSecondaryInk)
            TextField(placeholder, text: text)
                .focused($focusedField, equals: field)
                .padding(12)
                .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                .accessibilityLabel(label)
        }
    }
}

struct TaskQuoteView: View {
    @EnvironmentObject private var app: AppState
    @State private var paymentAuthorized = false

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                ProgressView(value: 3, total: 4) {
                    Text("Step 3 of 4 · Price")
                        .font(.caption.weight(.semibold))
                }
                .tint(Color.brandGreen)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ESTIMATED ARRIVAL")
                            .font(.caption2.weight(.semibold))
                        HStack(alignment: .firstTextBaseline, spacing: 5) {
                            Text("18–28").font(.title.weight(.bold)).monospacedDigit()
                            Text("min").font(.subheadline.weight(.medium))
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("HELPERS NEAR").font(.caption2.weight(.semibold))
                        Text("12").font(.title.weight(.bold)).monospacedDigit()
                    }
                }
                .foregroundStyle(Color.brandGreen)
                .cardStyle()
                .overlay(alignment: .bottomLeading) {
                    StatusPill(text: "High availability right now", icon: "bolt.fill", tint: .brandGreen)
                        .offset(x: 16, y: 16)
                }
                .padding(.bottom, 12)

                SectionHeading(title: "Suggested Helper Reward")
                VStack(spacing: 16) {
                    Text("Based on distance, time, and current demand")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                    HStack(spacing: 20) {
                        rewardButton(systemName: "minus") {
                            app.draft.reward = max(Decimal(3), app.draft.reward - Decimal(1))
                            app.draft.rewardWasAdjusted = true
                        }
                        Text(app.draft.reward.currencyText)
                            .font(.largeTitle.weight(.bold).monospacedDigit())
                            .contentTransition(.numericText())
                            .accessibilityLabel("Helper reward \(app.draft.reward.currencyText)")
                        rewardButton(systemName: "plus", tint: .brandGreen) {
                            app.draft.reward = min(Decimal(20), app.draft.reward + Decimal(1))
                            app.draft.rewardWasAdjusted = true
                        }
                    }
                    StatusPill(text: "\(matchChance)% chance of match", icon: "chart.line.uptrend.xyaxis", tint: .brandGreen)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            rewardPreset("Suggested", value: app.draft.suggestedReward)
                            rewardPreset("Good", value: app.draft.suggestedReward + 1)
                            rewardPreset("Great", value: app.draft.suggestedReward + 2)
                            rewardPreset("Turbo", value: app.draft.suggestedReward + 4)
                        }
                    }
                    Text("Increasing the reward can get your task matched faster and attract highly rated helpers.")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                }
                .cardStyle()

                SectionHeading(title: "How pricing works")
                VStack(spacing: 0) {
                    pricingRow(icon: app.draft.category.icon, title: "Category Base", detail: app.draft.category.rawValue, amount: app.draft.categoryBase.currencyText, tint: app.draft.category.tint)
                    Divider()
                    pricingRow(icon: "point.topleft.down.to.point.bottomright.curvepath", title: "Route & Time", detail: "\(app.draft.routeDistance.formatted(.number.precision(.fractionLength(1)))) mi · ~\(app.draft.estimatedMinutes) min", amount: "+\((app.draft.distancePrice + app.draft.timePrice).currencyText)", tint: .accentBlue)
                    Divider()
                    pricingRow(icon: "shippingbox.fill", title: "Effort", detail: "\(app.draft.itemSize)\(app.draft.isFragile ? " · fragile" : "")", amount: "+\(app.draft.effortPrice.currencyText)", tint: .mutedPlum)
                    Divider()
                    pricingRow(icon: "bolt.fill", title: "Urgency & Demand", detail: "\(app.draft.isASAP ? "ASAP" : "Scheduled") · \(app.draft.demandLevel.lowercased()) demand", amount: "+\((app.draft.urgencyPrice + app.draft.demandPrice).currencyText)", tint: .warmAmber)
                    Divider()
                    pricingRow(icon: "dollarsign.circle.fill", title: "Helper earnings", detail: "Transparent · no hidden cuts", amount: app.draft.reward.currencyText, tint: .brandGreen)
                }
                .cardStyle(padding: 12)

                SectionHeading(title: "Payment Summary")
                VStack(spacing: 0) {
                    LabeledValueRow(label: "Helper reward", value: app.draft.reward.currencyText)
                    Divider()
                    LabeledValueRow(label: "Platform fee", value: app.draft.platformFee.currencyText)
                    Divider()
                    LabeledValueRow(label: "Service & safety", value: "Included")
                    Divider()
                    LabeledValueRow(label: "You pay today", value: app.draft.total.currencyText, valueTint: .brandGreen)
                }
                .cardStyle(padding: 12)

                HStack(spacing: 14) {
                    Text("VISA")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 30)
                        .background(Color.brandNavy, in: RoundedRectangle(cornerRadius: 6))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("•••• 4892").font(.subheadline.weight(.semibold))
                        Text("Expires 08/28 · Alex Johnson")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(Color.appSecondaryInk)
                }
                .cardStyle()
                .accessibilityElement(children: .combine)

                Label {
                    Text("Protected by OnTheWay Guarantee. Payment is held until you confirm delivery.")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "checkmark.shield.fill")
                }
                .foregroundStyle(Color.appSecondaryInk)
                .cardStyle()

                Button {
                    paymentAuthorized = true
                    if case .direct = app.matchStrategy { app.directRequestStatus = .awaitingResponse }
                    app.open(.searching)
                } label: {
                    Label(authorizationTitle, systemImage: "lock.fill")
                }
                .buttonStyle(PrimaryActionStyle())
                .accessibilityHint("Authorizes the demo payment and starts matching")
            }
            .padding(.top, 8)
        }
        .navigationTitle("Review & Price")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { app.prepareQuote() }
    }

    private var matchChance: Int {
        min(99, 72 + NSDecimalNumber(decimal: app.draft.reward).intValue * 4)
    }

    private var authorizationTitle: String {
        if case let .direct(helper) = app.matchStrategy {
            return "Authorize \(app.draft.total.currencyText) & Request \(helper.name)"
        }
        return "Authorize \(app.draft.total.currencyText) & Find Helper"
    }

    private func rewardButton(systemName: String, tint: Color = .appInk, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.1), in: Circle())
                .overlay { Circle().stroke(tint.opacity(0.3)) }
        }
        .accessibilityLabel(systemName == "plus" ? "Increase reward" : "Decrease reward")
    }

    private func rewardPreset(_ title: String, value: Decimal) -> some View {
        Button("\(title) \(value.currencyText)") {
            app.draft.reward = value
            app.draft.rewardWasAdjusted = value != app.draft.suggestedReward
        }
            .font(.caption.weight(.semibold))
            .foregroundStyle(app.draft.reward == value ? Color.white : Color.appSecondaryInk)
            .padding(.horizontal, 12)
            .frame(minHeight: 36)
            .background(app.draft.reward == value ? Color.brandNavy : Color.appSurfaceAlt, in: Capsule())
            .accessibilityAddTraits(app.draft.reward == value ? .isSelected : [])
    }

    private func pricingRow(icon: String, title: String, detail: String, amount: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            CircleIcon(systemName: icon, tint: tint, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
            Spacer()
            Text(amount).font(.subheadline.weight(.bold)).monospacedDigit()
        }
        .frame(minHeight: 58)
        .accessibilityElement(children: .combine)
    }
}

struct SearchingHelperView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.38
    @State private var boosted = false

    var body: some View {
        ScreenScaffold {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.appLine, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.brandGreen, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(Color.brandNavy)
                }
                .frame(width: 130, height: 130)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Live helper search")
                .accessibilityValue("Offers sent to \(boosted ? 12 : 7) of 12 helpers")

                VStack(spacing: 7) {
                    Text(searchTitle)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                    Text(searchDetail)
                        .font(.subheadline)
                        .foregroundStyle(Color.appSecondaryInk)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 10) {
                    MetricCard(value: "< 1 min", label: "Expected match", tint: .brandGreen)
                    MetricCard(value: offerCount, label: "Offers sent", tint: .brandNavy)
                }

                VStack(spacing: 0) {
                    if let helper = directHelper {
                        offerRow(initials: helper.initials, name: helper.name, detail: "\(helper.rating.formatted(.number.precision(.fractionLength(2)))) · \(helper.completed) tasks · \(helper.distance.formatted(.number.precision(.fractionLength(1)))) mi away", status: "Reviewing", tint: .brandGreen)
                    } else {
                        offerRow(initials: "MJ", name: "Maya J.", detail: "4.92 · 248 tasks · 0.2 mi detour", status: "Viewing", tint: .brandGreen)
                        Divider()
                        offerRow(initials: "SK", name: "Sam K.", detail: "4.87 · 156 tasks · 0.3 mi detour", status: "Notified", tint: .accentBlue)
                        Divider()
                        offerRow(initials: "DR", name: "Dana R.", detail: "4.95 · 321 tasks · 0.4 mi detour", status: "Queued", tint: .appSecondaryInk)
                    }
                }
                .cardStyle(padding: 12)

                if !boosted && directHelper == nil {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Need a faster match?").font(.headline)
                                Text("Add $1 and notify the full pool.")
                                    .font(.caption)
                                    .foregroundStyle(Color.appSecondaryInk)
                            }
                            Spacer()
                            Text("+$1.00").font(.headline.monospacedDigit())
                        }
                        Button {
                            boosted = true
                            app.draft.reward += Decimal(1)
                            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { progress = 0.82 }
                        } label: {
                            Label("Boost Find", systemImage: "bolt.fill")
                        }
                        .buttonStyle(SecondaryActionStyle())
                    }
                    .cardStyle()
                }

                Button {
                    app.simulateMatchAcceptance()
                } label: {
                    Label(primarySimulationTitle, systemImage: "checkmark.circle.fill")
                }
                .buttonStyle(PrimaryActionStyle())

                if directHelper != nil {
                    Button {
                        app.declineDirectRequestAndFallback()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { progress = 0.62 }
                    } label: {
                        Label("Simulate Decline & Post to All", systemImage: "person.3.fill")
                    }
                    .buttonStyle(SecondaryActionStyle())
                    Text("If the selected helper declines or times out, your authorized offer moves to the automatic pool without exposing your exact address.")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                        .multilineTextAlignment(.center)
                }

                Button("Cancel search") { dismiss() }
                    .foregroundStyle(Color.appDanger)
                    .frame(minHeight: 44)
            }
            .padding(.top, 24)
        }
        .navigationTitle("Finding Your Helper")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", systemImage: "xmark") { dismiss() }
            }
        }
    }

    private var directHelper: HelperProfile? {
        if case let .direct(helper) = app.matchStrategy { return helper }
        return nil
    }

    private var searchTitle: String { directHelper.map { "Waiting for \($0.name)" } ?? "Finding the best helper nearby" }
    private var searchDetail: String {
        directHelper.map { "Your private offer is reserved for \($0.name). Exact handoff details unlock only after acceptance." }
        ?? "We’re notifying verified helpers whose route matches your \(app.draft.category.rawValue.lowercased()) task."
    }
    private var offerCount: String { directHelper == nil ? (boosted ? "12 / 12" : "7 / 12") : "1 / 1" }
    private var primarySimulationTitle: String { directHelper.map { "Simulate \($0.name) Accepting" } ?? "Simulate Best Match" }

    private func offerRow(initials: String, name: String, detail: String, status: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            AvatarView(initials: initials, tint: .brandNavy, size: 42, online: true)
            VStack(alignment: .leading, spacing: 3) {
                Text(name).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
            Spacer()
            StatusPill(text: status, tint: tint)
        }
        .frame(minHeight: 58)
        .accessibilityElement(children: .combine)
    }
}
