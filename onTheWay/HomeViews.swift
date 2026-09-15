import SwiftUI
import Charts

struct MainShellView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        Group {
            switch app.selectedTab {
            case .home:
                if app.mode == .requester {
                    RequesterHomeView()
                } else {
                    HelperHomeView()
                }
            case .activity:
                ActivityView()
            case .inbox:
                InboxView()
            case .profile:
                ProfileView()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomBar(selectedTab: $app.selectedTab) {
                app.open(.taskType)
            }
        }
        .background(Color.appBackground)
    }
}

struct RequesterHomeView: View {
    @EnvironmentObject private var app: AppState
    @State private var showingFilters = false
    @State private var searchRadius = 1.0

    private let availability: [(TaskCategory, Int, String)] = [
        (.coffee, 12, "Average response ~2 min"),
        (.delivery, 8, "Average response ~4 min"),
        (.store, 5, "Average response ~6 min"),
        (.returnDropoff, 4, "Average response ~7 min")
    ]

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 16) {
                locationHeader(title: "Unit 2 Dorm · Berkeley")
                ModeSwitch(selection: $app.mode)

                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Need Help")
                            .font(.largeTitle.weight(.bold))
                        Text("\(nearbyHelperCount) helpers within \(searchRadius.formatted(.number.precision(.fractionLength(searchRadius == 1 ? 0 : 1)))) mile\(searchRadius == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    Button { showingFilters = true } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                            .font(.subheadline.weight(.semibold))
                            .frame(minHeight: 44)
                    }
                }

                MarketplaceMap(mode: .requester, tasks: Array(DemoData.tasks.prefix(searchRadius < 1 ? 2 : DemoData.tasks.count))) { _ in
                    app.open(.helperList(.coffee))
                }

                SectionHeading(title: "Helpers Nearby")
                Text("Choose a category to see people already available around you.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryInk)
                    .padding(.top, -12)

                VStack(spacing: 10) {
                    ForEach(availability, id: \.0) { item in
                        Button {
                            app.open(.helperList(item.0))
                        } label: {
                            HStack(spacing: 12) {
                                CircleIcon(systemName: item.0.icon, tint: item.0.tint)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.0.rawValue)
                                        .font(.headline)
                                        .foregroundStyle(Color.appInk)
                                    Text("\(item.1) helpers nearby · \(item.2)")
                                        .font(.caption)
                                        .foregroundStyle(Color.appSecondaryInk)
                                        .lineLimit(2)
                                }
                                Spacer(minLength: 4)
                                Text("\(item.1)")
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(Color.appInk)
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.appSecondaryInk)
                                    .accessibilityHidden(true)
                            }
                            .cardStyle(padding: 12)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Shows available helpers")
                    }
                }

                Button {
                    app.open(.taskType)
                } label: {
                    Label("Create a Task", systemImage: "plus")
                }
                .buttonStyle(PrimaryActionStyle())
                .padding(.top, 4)
            }
            .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Helper search radius", isPresented: $showingFilters, titleVisibility: .visible) {
            Button("Within 0.5 mile") { searchRadius = 0.5 }
            Button("Within 1 mile") { searchRadius = 1 }
            Button("Within 2 miles") { searchRadius = 2 }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The helper count and map update immediately without exposing anyone’s exact location.")
        }
    }

    private var nearbyHelperCount: Int { searchRadius < 1 ? 14 : searchRadius > 1 ? 43 : 29 }

    private func locationHeader(title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "location.fill")
                .foregroundStyle(Color.brandGreen)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text("Current location")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryInk)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
            Button { app.selectedTab = .inbox } label: {
                Image(systemName: "bell")
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Notifications")
        }
    }
}

struct HelperHomeView: View {
    @EnvironmentObject private var app: AppState
    @State private var sort = "Recommended"
    @State private var showingFilters = false
    @State private var categoryFilter: TaskCategory?
    private let sorts = ["Recommended", "Route Match", "Closest", "Highest Pay", "Newest"]

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "location.fill")
                        .foregroundStyle(Color.brandGreen)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Current location").font(.caption).foregroundStyle(Color.appSecondaryInk)
                        Text("UC Berkeley Campus").font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                    if app.isAvailableToHelp {
                        StatusPill(text: "Available", icon: "dot.radiowaves.left.and.right", tint: .brandGreen)
                    }
                }

                ModeSwitch(selection: $app.mode)

                Button {
                    app.presentIncomingDirectOffer()
                } label: {
                    HStack(spacing: 12) {
                        CircleIcon(systemName: "paperplane.fill", tint: .brandGreen)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Direct request waiting")
                                .font(.headline)
                                .foregroundStyle(Color.appInk)
                            Text("Emma W. · Coffee Pickup · \(DemoData.tasks[0].reward.currencyText)")
                                .font(.caption)
                                .foregroundStyle(Color.appSecondaryInk)
                        }
                        Spacer()
                        StatusPill(text: "Review", icon: "chevron.right", tint: .brandGreen)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)
                .accessibilityHint("Review and accept or decline the private offer")

                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Nearby Tasks")
                            .font(.largeTitle.weight(.bold))
                        Text("12 tasks within 1 mile")
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    Button { showingFilters = true } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                            .font(.subheadline.weight(.semibold))
                            .frame(minHeight: 44)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(sorts, id: \.self) { item in
                            Button(item) { sort = item }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(sort == item ? Color.white : Color.appSecondaryInk)
                                .padding(.horizontal, 12)
                                .frame(minHeight: 36)
                                .background(sort == item ? Color.brandNavy : Color.appSurfaceAlt, in: Capsule())
                                .overlay { Capsule().stroke(sort == item ? Color.clear : Color.appLine) }
                                .accessibilityAddTraits(sort == item ? .isSelected : [])
                        }
                    }
                }

                MarketplaceMap(mode: .helper, tasks: DemoData.tasks) { task in
                    app.open(.taskDetail(task))
                }

                HStack {
                    SectionHeading(title: "Tasks Near You")
                    Spacer()
                }

                ForEach(sortedTasks) { task in
                    TaskCardView(task: task) { app.open(.taskDetail(task)) }
                }

                Button {
                    if app.isAvailableToHelp {
                        app.isAvailableToHelp = false
                    } else {
                        app.open(.helperSetup)
                    }
                } label: {
                    Label(app.isAvailableToHelp ? "Stop Helping" : "Start Helping", systemImage: app.isAvailableToHelp ? "pause.fill" : "play.fill")
                }
                .buttonStyle(PrimaryActionStyle(color: app.isAvailableToHelp ? .appDanger : .brandGreen))
                .padding(.top, 4)
            }
            .padding(.top, 8)
        }
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("Filter nearby tasks", isPresented: $showingFilters, titleVisibility: .visible) {
            Button("All saved categories") { categoryFilter = nil }
            ForEach(app.helperCategories.sorted { $0.rawValue < $1.rawValue }) { category in
                Button(category.rawValue) { categoryFilter = category }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Results also respect your saved \(app.helperRadius.formatted(.number.precision(.fractionLength(1)))) mile radius and \(app.helperTransport.lowercased()) route.")
        }
    }

    private var sortedTasks: [MarketplaceTask] {
        let eligible = DemoData.tasks.filter { task in
            app.helperCategories.contains(task.category) &&
            task.pickupDistance <= app.helperRadius &&
            (categoryFilter == nil || task.category == categoryFilter)
        }
        switch sort {
        case "Route Match": return eligible.sorted { $0.match > $1.match }
        case "Closest": return eligible.sorted { $0.pickupDistance < $1.pickupDistance }
        case "Highest Pay": return eligible.sorted { $0.reward > $1.reward }
        case "Newest": return Array(eligible.reversed())
        default: return eligible
        }
    }
}

struct HelperListView: View {
    @EnvironmentObject private var app: AppState
    let category: TaskCategory
    @State private var search = ""
    @State private var sort = "Recommended"

    private var filteredHelpers: [HelperProfile] {
        let categoryMatches = DemoData.helpers.filter { $0.services.contains(category) || category == .other }
        let searched = search.isEmpty ? categoryMatches : categoryMatches.filter { $0.name.localizedCaseInsensitiveContains(search) }
        switch sort {
        case "Closest": return searched.sorted { $0.distance < $1.distance }
        case "Fastest": return searched.sorted { responseMinutes($0.response) < responseMinutes($1.response) }
        case "Top Rated": return searched.sorted { $0.rating > $1.rating }
        default: return searched.sorted { ($0.routeMatch ?? 0, $0.rating) > ($1.routeMatch ?? 0, $1.rating) }
        }
    }

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    CircleIcon(systemName: category.icon, tint: category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(category.rawValue)
                            .font(.title2.weight(.bold))
                        Text("12 helpers nearby · Average response ~2 min")
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                }

                Text("Verified local helpers already moving nearby. Request one person directly or post to everyone.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryInk)
                    .cardStyle()

                Label("Search helpers", systemImage: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryInk)
                    .accessibilityHidden(true)
                TextField("Search helpers by name", text: $search)
                    .textInputAutocapitalization(.words)
                    .padding(12)
                    .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))

                Picker("Sort helpers", selection: $sort) {
                    Text("Recommended").tag("Recommended")
                    Text("Closest").tag("Closest")
                    Text("Fastest").tag("Fastest")
                    Text("Top Rated").tag("Top Rated")
                }
                .pickerStyle(.segmented)

                HStack {
                    SectionHeading(title: "Available Helpers")
                    Spacer()
                    StatusPill(text: "\(filteredHelpers.count) online", icon: "dot.radiowaves.left.and.right", tint: .brandGreen)
                }

                ForEach(filteredHelpers) { helper in
                    HelperCardView(helper: helper) {
                        app.beginNewTask(category: category, helper: helper)
                    }
                }

                if filteredHelpers.isEmpty {
                    ContentUnavailableView.search(text: search)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Prefer an automatic match?").font(.headline)
                            Text("Post to every available helper at once.")
                                .font(.caption)
                                .foregroundStyle(Color.appSecondaryInk)
                        }
                        Spacer()
                        StatusPill(text: "Fast", icon: "bolt.fill", tint: .brandGreen)
                    }
                    Button {
                        app.beginNewTask(category: category)
                    } label: {
                        Label("Post to All Helpers", systemImage: "person.3.fill")
                    }
                    .buttonStyle(PrimaryActionStyle())
                }
                .cardStyle()
            }
            .padding(.top, 8)
        }
        .navigationTitle("Available Helpers")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func responseMinutes(_ text: String) -> Int {
        Int(text.first(where: { $0.isNumber }).map(String.init) ?? "9") ?? 9
    }
}

struct HelpingSetupView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 20) {
                Text("Tell us what fits your route. You can change this at any time.")
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryInk)

                setupSection("What can you help with?", subtitle: "Choose one or more task types.") {
                    VStack(spacing: 8) {
                        ForEach(TaskCategory.allCases.dropLast()) { category in
                            Button {
                                if app.helperCategories.contains(category) {
                                    app.helperCategories.remove(category)
                                } else {
                                    app.helperCategories.insert(category)
                                }
                            } label: {
                                HStack {
                                    CircleIcon(systemName: category.icon, tint: category.tint, size: 40)
                                    Text(category.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.appInk)
                                    Spacer()
                                    Image(systemName: app.helperCategories.contains(category) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(app.helperCategories.contains(category) ? Color.brandGreen : Color.appSecondaryInk)
                                }
                                .frame(minHeight: 44)
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(app.helperCategories.contains(category) ? .isSelected : [])
                        }
                    }
                }

                setupSection("Transportation", subtitle: "We’ll estimate realistic detours and timing.") {
                    Picker("Transportation", selection: $app.helperTransport) {
                        Label("Walk", systemImage: "figure.walk").tag("Walk")
                        Label("Bike", systemImage: "bicycle").tag("Bike")
                        Label("Car", systemImage: "car.fill").tag("Car")
                    }
                    .pickerStyle(.segmented)
                }

                setupSection("Maximum radius", subtitle: "How far can pickup be from your route?") {
                    VStack(spacing: 8) {
                        Slider(value: $app.helperRadius, in: 0.5...2, step: 0.5)
                            .tint(Color.brandGreen)
                        HStack {
                            Text("0.5 mi")
                            Spacer()
                            Text("\(app.helperRadius, specifier: "%.1f") mi selected").fontWeight(.semibold)
                            Spacer()
                            Text("2 mi")
                        }
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                    }
                }

                setupSection("Where are you headed?", subtitle: "This lets us prioritize route overlap instead of raw distance.") {
                    VStack(spacing: 10) {
                        Picker("Destination mode", selection: $app.helperDestinationMode) {
                            Text("Staying nearby").tag("Staying nearby")
                            Text("Going home").tag("Going home")
                            Text("Custom route").tag("Custom route")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        TextField("Destination", text: $app.helperDestination)
                            .textContentType(.fullStreetAddress)
                            .padding(12)
                            .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                        Label("About 8 matching tasks per hour on this route", systemImage: "chart.line.uptrend.xyaxis")
                            .font(.caption)
                            .foregroundStyle(Color.brandGreen)
                    }
                }

                Button {
                    app.isAvailableToHelp = true
                    dismiss()
                } label: {
                    Label("Start Helping Now", systemImage: "play.fill")
                }
                .buttonStyle(PrimaryActionStyle())
                .disabled(app.helperCategories.isEmpty)
                .opacity(app.helperCategories.isEmpty ? 0.45 : 1)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Start Helping")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setupSection<Content: View>(_ title: String, subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(Color.appSecondaryInk)
            content()
        }
        .cardStyle()
    }
}

struct TaskDetailView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss
    let task: MarketplaceTask

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Route Match Score", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(task.match)%")
                            .font(.title2.weight(.bold).monospacedDigit())
                    }
                    ProgressView(value: Double(task.match), total: 100)
                        .tint(Color.brandGreen)
                    Text("Extra distance +\(task.detourDistance, specifier: "%.1f") mi · minimal detour")
                        .font(.caption)
                }
                .foregroundStyle(Color.brandGreen)
                .cardStyle()

                HStack(alignment: .top, spacing: 12) {
                    CircleIcon(systemName: task.category.icon, tint: task.category.tint)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Starbucks \(task.title)")
                            .font(.title3.weight(.bold))
                        Text("Posted 3 min ago · Expires in 27 min")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    Text(task.reward.currencyText)
                        .font(.title2.weight(.bold))
                }
                .cardStyle()

                SectionHeading(title: "Pickup & Drop-off")
                VStack(spacing: 0) {
                    LabeledValueRow(label: "Pickup area", value: "Bancroft Way · ~0.2 mi", icon: "mappin.circle.fill")
                    Divider()
                    LabeledValueRow(label: "Drop-off area", value: "Unit 2 residence area", icon: "house.circle.fill")
                }
                .cardStyle(padding: 12)

                SectionHeading(title: "Order Details")
                VStack(spacing: 0) {
                    LabeledValueRow(label: "Payment", value: "Prepaid · verified")
                    Divider()
                    LabeledValueRow(label: "Reference", value: "•••• 8291")
                    Divider()
                    LabeledValueRow(label: "Items", value: task.detail)
                    Divider()
                    LabeledValueRow(label: "Requested", value: task.timing)
                }
                .cardStyle(padding: 12)

                SectionHeading(title: "Special Instructions")
                Label {
                    Text("Exact address, full order reference, requester name, and handoff instructions unlock only after you accept the task.")
                        .font(.subheadline)
                        .foregroundStyle(Color.appSecondaryInk)
                } icon: {
                    Image(systemName: "info.circle.fill").foregroundStyle(Color.accentBlue)
                }
                .cardStyle()

                SectionHeading(title: "Time & Effort")
                VStack(spacing: 0) {
                    LabeledValueRow(label: "Walk to pickup", value: "4 min · 0.2 mi", icon: "figure.walk")
                    Divider()
                    LabeledValueRow(label: "Wait at store", value: "~3 min", icon: "clock")
                    Divider()
                    LabeledValueRow(label: "Route detour", value: "+\(task.detourMinutes) min · +\(task.detourDistance.formatted(.number.precision(.fractionLength(1)))) mi", icon: "point.topleft.down.to.point.bottomright.curvepath")
                    Divider()
                    LabeledValueRow(label: "Estimated total", value: "~14 min")
                }
                .cardStyle(padding: 12)

                HStack(spacing: 12) {
                    Button("Decline") { dismiss() }
                        .buttonStyle(SecondaryActionStyle())
                    Button("Accept Task") { app.startTask(task) }
                        .buttonStyle(PrimaryActionStyle())
                }
            }
            .padding(.top, 8)
        }
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { app.toggleSaved(task) } label: {
                    Image(systemName: app.savedTaskIDs.contains(task.id) ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(app.savedTaskIDs.contains(task.id) ? "Remove saved task" : "Save task")
            }
        }
    }
}

struct EarningsView: View {
    @EnvironmentObject private var app: AppState
    @State private var period = "This Week"
    private let earnings = [
        ("Mon", 4.0), ("Tue", 18.0), ("Wed", 12.0), ("Thu", 22.0),
        ("Today", 13.75), ("Sat", 0.0), ("Sun", 0.0)
    ]

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Week · Sep 1–7")
                            .font(.subheadline)
                            .foregroundStyle(Color.appSecondaryInk)
                        Text("$86.50")
                            .font(.largeTitle.weight(.bold).monospacedDigit())
                        Text("$13.75 pending · 12 tasks · Avg $7.21/task")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                    }
                    Spacer()
                    StatusPill(text: "+23%", icon: "arrow.up.right", tint: .brandGreen)
                }

                HStack(spacing: 10) {
                    MetricCard(value: "4h 12m", label: "Active time", tint: .brandNavy)
                    MetricCard(value: "12.4 mi", label: "Distance", tint: .accentBlue)
                }

                Picker("Earnings period", selection: $period) {
                    Text("Today").tag("Today")
                    Text("This Week").tag("This Week")
                    Text("This Month").tag("This Month")
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Earnings").font(.headline)
                    Chart(earnings, id: \.0) { day, value in
                        BarMark(x: .value("Day", day), y: .value("Earnings", value))
                            .foregroundStyle(day == "Today" ? Color.brandGreen : Color.brandNavy.opacity(0.65))
                            .cornerRadius(5)
                            .annotation(position: .top) {
                                if value > 0 {
                                    Text("$\(value, specifier: "%.0f")")
                                        .font(.caption2)
                                        .foregroundStyle(Color.appSecondaryInk)
                                }
                            }
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 190)
                    .accessibilityLabel("Daily earnings bar chart")
                }
                .cardStyle()

                Button {
                    app.open(.wallet)
                } label: {
                    Label("Withdraw $72.75 to Bank", systemImage: "arrow.up.forward")
                }
                .buttonStyle(PrimaryActionStyle())

                SectionHeading(title: "Top Earning Categories")
                VStack(spacing: 0) {
                    earningRow(.coffee, tasks: 7, amount: "$41.00")
                    Divider()
                    earningRow(.delivery, tasks: 3, amount: "$24.75")
                    Divider()
                    earningRow(.store, tasks: 2, amount: "$15.75")
                    Divider()
                    earningRow(.returnDropoff, tasks: 1, amount: "$5.00")
                }
                .cardStyle(padding: 12)
            }
            .padding(.top, 8)
        }
        .navigationTitle("Earnings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func earningRow(_ category: TaskCategory, tasks: Int, amount: String) -> some View {
        HStack(spacing: 12) {
            CircleIcon(systemName: category.icon, tint: category.tint, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue).font(.subheadline.weight(.semibold))
                Text("\(tasks) tasks").font(.caption).foregroundStyle(Color.appSecondaryInk)
            }
            Spacer()
            Text(amount).font(.subheadline.weight(.bold)).monospacedDigit()
        }
        .frame(minHeight: 56)
        .accessibilityElement(children: .combine)
    }
}
