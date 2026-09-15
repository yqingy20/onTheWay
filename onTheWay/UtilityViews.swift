import SwiftUI

struct ActivityView: View {
    @EnvironmentObject private var app: AppState
    @State private var filter = "All"

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 16) {
                Text("Activity")
                    .font(.largeTitle.weight(.bold))

                Picker("Activity filter", selection: $filter) {
                    Text("All (4)").tag("All")
                    Text("Active (1)").tag("Active")
                    Text("Completed (28)").tag("Completed")
                }
                .pickerStyle(.segmented)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        StatusPill(text: "Requested", icon: "hand.raised.fill", tint: .brandNavy)
                        StatusPill(text: "Helped", icon: "dollarsign.circle.fill", tint: .brandGreen)
                        StatusPill(text: "Cancelled", icon: "nosign", tint: .appDanger)
                    }
                }

                if filter != "Completed" {
                    SectionHeading(title: "In Progress")
                    activityCard(
                        category: .coffee,
                        title: "Coffee Pickup · You requested",
                        subtitle: "Started 3 min ago · Picked Up",
                        person: "Maya J. · 4.92 rating",
                        amount: "$5.75",
                        status: "ETA 12 min",
                        isEarning: false
                    ) { app.open(.requesterActive) }
                }

                if filter != "Active" {
                    SectionHeading(title: "Today")
                    activityCard(category: .returnDropoff, title: "UPS Drop-off · You helped", subtitle: "Completed at 8:45 AM · 14 min", person: "Dorm → UPS Store", amount: "+$7.00", status: "Completed", isEarning: true) { app.open(.earnings) }

                    SectionHeading(title: "Yesterday")
                    activityCard(category: .store, title: "Target Pickup · You requested", subtitle: "Yesterday 6:20 PM · 32 min", person: "Maya J. · 4.92 rating", amount: "$7.50", status: "Completed", isEarning: false) { app.open(.requesterCompletion) }
                    activityCard(category: .coffee, title: "Food Pickup · You helped", subtitle: "Yesterday 12:15 PM · 22 min", person: "Chipotle → Engineering Bldg", amount: "+$6.50", status: "4.9 rating", isEarning: true) { app.open(.earnings) }

                    SectionHeading(title: "This Week")
                    compactActivity(.returnDropoff, "Amazon Return Drop-off", "Mon · You helped · 18 min", "+$5.25")
                    compactActivity(.coffee, "Pizza Pickup", "Sun · You requested · Dana H.", "$8.25")
                    compactActivity(.store, "Grocery Pickup", "Sat · You helped · Trader Joe’s", "+$11.00")
                }
            }
            .padding(.top, 8)
        }
    }

    private func activityCard(
        category: TaskCategory, title: String, subtitle: String, person: String,
        amount: String, status: String, isEarning: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    CircleIcon(systemName: category.icon, tint: category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title).font(.headline).foregroundStyle(Color.appInk)
                        Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    StatusPill(text: status, icon: "checkmark.circle.fill", tint: .brandGreen)
                }
                HStack {
                    Text(person).font(.subheadline).foregroundStyle(Color.appSecondaryInk)
                    Spacer()
                    Text(amount)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(isEarning ? Color.brandGreen : Color.appInk)
                }
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens activity details")
    }

    private func compactActivity(_ category: TaskCategory, _ title: String, _ subtitle: String, _ amount: String) -> some View {
        HStack(spacing: 12) {
            CircleIcon(systemName: category.icon, tint: category.tint, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
            Spacer()
            Text(amount).font(.subheadline.weight(.bold)).monospacedDigit()
        }
        .cardStyle(padding: 12)
        .accessibilityElement(children: .combine)
    }
}

struct InboxView: View {
    @EnvironmentObject private var app: AppState
    @State private var filter = "All"

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Inbox")
                        .font(.largeTitle.weight(.bold))
                    Spacer()
                    Button {
                        filter = filter == "All" ? "Chats" : filter == "Chats" ? "Alerts" : "All"
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Filter inbox")
                }

                Picker("Inbox filter", selection: $filter) {
                    Text("All (6)").tag("All")
                    Text("Chats (3)").tag("Chats")
                    Text("Alerts (3)").tag("Alerts")
                }
                .pickerStyle(.segmented)

                if filter != "Alerts" {
                    SectionHeading(title: "Active Task Chats")
                    chatRow(initials: "MJ", name: "Maya J.", task: "Coffee Pickup", preview: "On my way, about 2 min out!", time: "Now", unread: 2) {
                        app.unreadInbox = 0
                        app.open(.chat("Maya J."))
                    }

                    SectionHeading(title: "Recent Chats")
                    chatRow(initials: "EW", name: "Emma W.", task: "UPS Drop-off", preview: "Left a 5-star review — thank you!", time: "Yesterday") { app.open(.chat("Emma W.")) }
                    chatRow(initials: "DR", name: "Dana R.", task: "Target Pickup", preview: "Delivery photo is ready.", time: "Tue") { app.open(.chat("Dana R.")) }
                }

                if filter != "Chats" {
                    SectionHeading(title: "Notifications")
                    notificationRow(icon: "dollarsign.circle.fill", title: "Payment received", body: "$13.75 added to your wallet from two tasks today.", time: "2h", tint: .brandGreen)
                    notificationRow(icon: "cup.and.saucer.fill", title: "8 coffee helpers near you", body: "Average ETA is 18 minutes in your area.", time: "4h", tint: .accentBlue)
                    notificationRow(icon: "star.fill", title: "You earned a new badge", body: "Route Rockstar — 50 route-matched tasks completed.", time: "1d", tint: .warmAmber)
                    notificationRow(icon: "person.badge.shield.checkmark.fill", title: "Identity verification approved", body: "You can now accept higher-value tasks and access payouts.", time: "2d", tint: .mutedPlum)
                }
            }
            .padding(.top, 8)
        }
    }

    private func chatRow(initials: String, name: String, task: String, preview: String, time: String, unread: Int = 0, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                AvatarView(initials: initials, online: unread > 0)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(name).font(.headline).foregroundStyle(Color.appInk)
                        Spacer()
                        Text(time).font(.caption).foregroundStyle(Color.appSecondaryInk)
                    }
                    Text(task).font(.caption.weight(.semibold)).foregroundStyle(Color.brandGreen)
                    Text(preview).font(.subheadline).foregroundStyle(Color.appSecondaryInk).lineLimit(1)
                }
                if unread > 0 {
                    Text("\(unread)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(minWidth: 22, minHeight: 22)
                        .background(Color.appDanger, in: Circle())
                        .accessibilityLabel("\(unread) unread messages")
                }
            }
            .cardStyle(padding: 12)
        }
        .buttonStyle(.plain)
    }

    private func notificationRow(icon: String, title: String, body: String, time: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            CircleIcon(systemName: icon, tint: tint)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(time).font(.caption).foregroundStyle(Color.appSecondaryInk)
                }
                Text(body).font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
        }
        .cardStyle(padding: 12)
        .accessibilityElement(children: .combine)
    }
}

struct ChatThreadView: View {
    @EnvironmentObject private var app: AppState
    let person: String
    @State private var input = ""
    @State private var notice: String?
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 9) {
                        Text("Today · 9:18 AM")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                            .padding(.vertical, 8)
                        ForEach(app.messages) { message in
                            messageBubble(message)
                                .id(message.id)
                        }
                    }
                    .padding(16)
                    .pageWidth()
                }
                .background(Color.appBackground)
                .onChange(of: app.messages.count) {
                    if let last = app.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            HStack(spacing: 10) {
                Button {
                    app.messages.append(ChatMessage(text: "Shared a demo delivery photo attachment.", isMine: true))
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Add photo or task update")
                TextField("Message \(person)", text: $input, axis: .vertical)
                    .focused($inputFocused)
                    .lineLimit(1...4)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 42)
                    .background(Color.appSurfaceAlt, in: Capsule())
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.appSecondaryInk : Color.brandNavy, in: Circle())
                }
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("Send message")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(.bar)
            .overlay(alignment: .top) { Divider() }
        }
        .navigationTitle(person)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text(person).font(.headline)
                    Text("On the way · Coffee Pickup").font(.caption2).foregroundStyle(Color.brandGreen)
                }
                .accessibilityElement(children: .combine)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { notice = "Calling \(person) through a privacy-protected relay number (demo)." } label: { Image(systemName: "phone.fill") }
                    .accessibilityLabel("Call \(person)")
            }
        }
        .alert("Communication", isPresented: Binding(get: { notice != nil }, set: { if !$0 { notice = nil } })) {
            Button("OK", role: .cancel) { notice = nil }
        } message: {
            Text(notice ?? "")
        }
    }

    private func messageBubble(_ message: ChatMessage) -> some View {
        HStack {
            if message.isMine { Spacer(minLength: 64) }
            Text(message.text)
                .font(.body)
                .foregroundStyle(message.isMine ? Color.white : Color.appInk)
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(message.isMine ? Color.brandNavy : Color.appSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    if !message.isMine {
                        RoundedRectangle(cornerRadius: 18).stroke(Color.appLine)
                    }
                }
                .accessibilityLabel(message.isMine ? "You: \(message.text)" : "\(person): \(message.text)")
            if !message.isMine { Spacer(minLength: 64) }
        }
        .frame(maxWidth: .infinity)
    }

    private func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        app.messages.append(ChatMessage(text: trimmed, isMine: true))
        input = ""
    }
}

struct WalletView: View {
    @State private var alertText: String?

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("AVAILABLE BALANCE").font(.caption2.weight(.semibold)).foregroundStyle(Color.appSecondaryInk)
                        Spacer()
                        StatusPill(text: "Secured", icon: "checkmark.shield.fill", tint: .brandGreen)
                    }
                    Text("$48.25").font(.largeTitle.weight(.bold).monospacedDigit())
                    Text("+$13.75 pending · clears tonight")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSecondaryInk)
                    HStack(spacing: 10) {
                        Button("Withdraw", systemImage: "arrow.up.forward") { alertText = "Withdrawal scheduled for your verified bank account." }
                            .buttonStyle(PrimaryActionStyle())
                        Button("Add Funds", systemImage: "plus") { alertText = "Add Funds is a demo-only action in this build." }
                            .buttonStyle(SecondaryActionStyle())
                    }
                }
                .cardStyle()

                HStack(spacing: 8) {
                    MetricCard(value: "$13.75", label: "Today", tint: .brandGreen)
                    MetricCard(value: "$86.50", label: "This Week", tint: .brandNavy)
                    MetricCard(value: "$342", label: "This Month", tint: .mutedPlum)
                    MetricCard(value: "28", label: "Tasks", tint: .warmAmber)
                }

                SectionHeading(title: "Payment Methods")
                VStack(spacing: 0) {
                    paymentRow(mark: "VISA", title: "•••• 4892", subtitle: "Alex Johnson · Expires 08/28", trailing: "Default", tint: .brandNavy)
                    Divider()
                    paymentRow(mark: "Pay", title: "alex@email.com", subtitle: "PayPal account", trailing: "", tint: .accentBlue)
                    Divider()
                    paymentRow(mark: "BANK", title: "Bank of America", subtitle: "Checking •••• 1029 · Payouts", trailing: "", tint: .brandGreen)
                    Divider()
                    Button { alertText = "Payment setup is represented as a safe demo state." } label: {
                        Label("Add payment method", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.brandNavy)
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    }
                }
                .cardStyle(padding: 12)

                SectionHeading(title: "Recent Transactions", actionTitle: "See all") {
                    alertText = "All demo transactions are already shown in this local build."
                }
                VStack(spacing: 0) {
                    transactionRow(icon: "dollarsign.circle.fill", title: "UPS Drop-off · Earnings", subtitle: "Today · 8:45 AM", amount: "+$7.00", tint: .brandGreen)
                    Divider()
                    transactionRow(icon: "cup.and.saucer.fill", title: "Coffee Pickup · Payment", subtitle: "Today · 9:18 AM", amount: "−$5.75", tint: .accentBlue)
                    Divider()
                    transactionRow(icon: "arrow.up.forward", title: "Withdrawal to Bank", subtitle: "Yesterday · Processing", amount: "−$125.00", tint: .warmAmber)
                    Divider()
                    transactionRow(icon: "fork.knife", title: "Food Pickup · Earnings + Tip", subtitle: "Yesterday · incl. $2 tip", amount: "+$8.50", tint: .brandGreen)
                }
                .cardStyle(padding: 12)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Wallet")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Wallet", isPresented: Binding(get: { alertText != nil }, set: { if !$0 { alertText = nil } })) {
            Button("OK") { alertText = nil }
        } message: {
            Text(alertText ?? "")
        }
    }

    private func paymentRow(mark: String, title: String, subtitle: String, trailing: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Text(mark)
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .frame(width: 48, height: 30)
                .background(tint, in: RoundedRectangle(cornerRadius: 6))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
            Spacer()
            if !trailing.isEmpty { StatusPill(text: trailing, tint: .brandGreen) }
            else { Image(systemName: "chevron.right").foregroundStyle(Color.appSecondaryInk) }
        }
        .frame(minHeight: 54)
        .accessibilityElement(children: .combine)
    }

    private func transactionRow(icon: String, title: String, subtitle: String, amount: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            CircleIcon(systemName: icon, tint: tint, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
            Spacer()
            Text(amount).font(.subheadline.weight(.bold)).foregroundStyle(amount.hasPrefix("+") ? Color.brandGreen : Color.appInk).monospacedDigit()
        }
        .frame(minHeight: 56)
        .accessibilityElement(children: .combine)
    }
}

struct ProfileView: View {
    @EnvironmentObject private var app: AppState
    @State private var showingSignOut = false
    @State private var infoMessage: String?

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                Text("Profile")
                    .font(.largeTitle.weight(.bold))

                HStack(spacing: 14) {
                    AvatarView(initials: "AJ", size: 72, online: true)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Alex Johnson").font(.title3.weight(.bold))
                            StatusPill(text: "Verified", icon: "checkmark.seal.fill", tint: .brandGreen)
                        }
                        Text("alex@email.com · +1 (555) 234-5678")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                        RatingSummary(rating: 4.94, trailing: "142 reviews")
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 8) {
                    MetricCard(value: "86", label: "Tasks Posted", tint: .brandNavy)
                    MetricCard(value: "56", label: "Tasks Helped", tint: .brandGreen)
                    MetricCard(value: "98%", label: "Completion", tint: .accentBlue)
                }

                Button {
                    app.mode = .helper
                    app.selectedTab = .home
                } label: {
                    HStack {
                        CircleIcon(systemName: "dollarsign.circle.fill", tint: .brandGreen)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Helper Mode").font(.headline).foregroundStyle(Color.appInk)
                            Text("Earned $342 this month")
                                .font(.caption)
                                .foregroundStyle(Color.appSecondaryInk)
                        }
                        Spacer()
                        Text("Start Helping").font(.subheadline.weight(.semibold)).foregroundStyle(Color.brandGreen)
                        Image(systemName: "arrow.right").foregroundStyle(Color.brandGreen)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)

                HStack(spacing: 10) {
                    Button { app.open(.wallet) } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Label("Wallet", systemImage: "wallet.bifold.fill").font(.headline)
                            Text("$48.25 available").font(.caption).foregroundStyle(Color.appSecondaryInk)
                        }
                        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                    Button { app.open(.earnings) } label: {
                        VStack(alignment: .leading, spacing: 5) {
                            Label("Earnings", systemImage: "chart.bar.fill").font(.headline)
                            Text("View weekly trends").font(.caption).foregroundStyle(Color.appSecondaryInk)
                        }
                        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                        .cardStyle()
                    }
                    .buttonStyle(.plain)
                }

                profileSection("Account") {
                    profileRow("Saved Addresses", subtitle: "Home, Work, Dorm + 2 more", icon: "location.fill") { infoMessage = "Saved addresses are protected and only the approximate area is shared before a task is accepted." }
                    Divider()
                    profileRow("Payment & Payout", subtitle: "2 cards · 1 bank · PayPal", icon: "creditcard.fill") { app.open(.wallet) }
                    Divider()
                    profileRow("Verification", subtitle: "Identity, phone, background verified", icon: "person.badge.shield.checkmark.fill") { infoMessage = "Identity, phone, and helper background verification are approved in this demo profile." }
                    Divider()
                    profileRow("Ratings & Reviews", subtitle: "4.94 · 142 reviews · 8 badges", icon: "star.fill") { infoMessage = "Rating history includes both requester and helper feedback; individual review details use realistic demo data." }
                }

                profileSection("Preferences") {
                    profileRow("Helper Preferences", subtitle: "Categories, transport, route settings", icon: "slider.horizontal.3") { app.open(.helperSetup) }
                    Divider()
                    profileRow("Notifications", subtitle: "Push, SMS, email preferences", icon: "bell.fill") { infoMessage = "Task offers and handoff updates are enabled; external push delivery is represented locally in this build." }
                    Divider()
                    profileRow("Privacy & Safety", subtitle: "Location sharing, data, block list", icon: "hand.raised.fill") { infoMessage = "Exact addresses and order identifiers stay redacted until a helper accepts. Relay calling and reporting are enabled as demo states." }
                }

                profileSection("Support") {
                    profileRow("Help Center", subtitle: "FAQs and guides", icon: "questionmark.circle.fill") { infoMessage = "Help covers pricing, matching, safe handoffs, cancellations, and payouts." }
                    Divider()
                    profileRow("Contact Support", subtitle: "24/7 chat, email, phone", icon: "headphones") { app.open(.chat("OnTheWay Support")) }
                    Divider()
                    profileRow("Legal", subtitle: "Terms, privacy, community guidelines", icon: "doc.text.fill") { infoMessage = "Demo terms: local errands only, no prohibited items, transparent fees, consent-based changes, and privacy-first matching." }
                }

                Button("Log Out", systemImage: "rectangle.portrait.and.arrow.right") { showingSignOut = true }
                    .foregroundStyle(Color.appDanger)
                    .frame(maxWidth: .infinity, minHeight: 48)
            }
            .padding(.top, 8)
        }
        .confirmationDialog("Log out of OnTheWay?", isPresented: $showingSignOut, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) { app.signOut() }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Profile", isPresented: Binding(get: { infoMessage != nil }, set: { if !$0 { infoMessage = nil } })) {
            Button("OK", role: .cancel) { infoMessage = nil }
        } message: {
            Text(infoMessage ?? "")
        }
    }

    private func profileSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            VStack(spacing: 0) { content() }
                .cardStyle(padding: 12)
        }
    }

    private func profileRow(_ title: String, subtitle: String, icon: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(Color.brandNavy)
                    .frame(width: 26)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(Color.appInk)
                    Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Color.appSecondaryInk).accessibilityHidden(true)
            }
            .frame(minHeight: 58)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens \(title)")
    }
}
