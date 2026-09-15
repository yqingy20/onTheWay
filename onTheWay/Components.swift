import SwiftUI
import MapKit

extension TaskCategory {
    var tint: Color {
        switch self {
        case .coffee: Color(red: 143 / 255, green: 106 / 255, blue: 69 / 255)
        case .delivery: .accentBlue
        case .store: .warmAmber
        case .returnDropoff: .mutedPlum
        case .other: .brandNavy
        }
    }
}

struct PrimaryActionStyle: ButtonStyle {
    var color: Color = .brandGreen
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .subheadline.weight(.semibold) : .body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: compact ? nil : .infinity, minHeight: 44)
            .padding(.horizontal, compact ? 14 : 20)
            .background(color.opacity(configuration.isPressed ? 0.82 : 1), in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct SecondaryActionStyle: ButtonStyle {
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(compact ? .subheadline.weight(.semibold) : .body.weight(.semibold))
            .foregroundStyle(Color.appInk)
            .frame(maxWidth: compact ? nil : .infinity, minHeight: 44)
            .padding(.horizontal, compact ? 14 : 20)
            .background(configuration.isPressed ? Color.appLine : Color.appSurfaceAlt, in: Capsule())
            .overlay { Capsule().stroke(Color.appLine, lineWidth: 1) }
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct ModeSwitch: View {
    @Binding var selection: UserMode

    var body: some View {
        Picker("Marketplace mode", selection: $selection) {
            ForEach(UserMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityHint("Switch between requesting help and earning as a helper")
    }
}

struct CircleIcon: View {
    let systemName: String
    var tint: Color = .brandNavy
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemName)
            .font(.body.weight(.semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: AppTheme.compactRadius, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct AvatarView: View {
    let initials: String
    var tint: Color = .brandNavy
    var size: CGFloat = 52
    var online = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Text(initials)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(tint, in: Circle())
                .accessibilityHidden(true)
            if online {
                Circle()
                    .fill(Color.brandGreen)
                    .frame(width: 14, height: 14)
                    .overlay { Circle().stroke(Color.appSurface, lineWidth: 2) }
                    .accessibilityHidden(true)
            }
        }
    }
}

struct RatingSummary: View {
    let rating: Double
    var trailing: String = ""

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundStyle(Color.warmAmber)
                .accessibilityHidden(true)
            Text(rating, format: .number.precision(.fractionLength(2)))
                .fontWeight(.semibold)
            if !trailing.isEmpty {
                Text("· \(trailing)")
            }
        }
        .font(.caption)
        .foregroundStyle(Color.appSecondaryInk)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rated \(rating.formatted(.number.precision(.fractionLength(2)))) out of 5\(trailing.isEmpty ? "" : ", \(trailing)")")
    }
}

struct StatusPill: View {
    let text: String
    var icon: String?
    var tint: Color = .brandGreen

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .accessibilityHidden(true)
            }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.1), in: Capsule())
        .overlay { Capsule().stroke(tint.opacity(0.2), lineWidth: 1) }
    }
}

struct SectionHeading: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.appInk)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandNavy)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
    }
}

struct MarketplaceMap: View {
    let mode: UserMode
    let tasks: [MarketplaceTask]
    var onSelect: (MarketplaceTask) -> Void

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.8696, longitude: -122.2620),
            span: MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
        )
    )

    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            UserAnnotation()
            ForEach(tasks) { task in
                Annotation(task.title, coordinate: task.coordinate, anchor: .bottom) {
                    Button {
                        onSelect(task)
                    } label: {
                        VStack(spacing: 4) {
                            HStack(spacing: 5) {
                                Image(systemName: mode == .helper ? task.category.icon : "person.fill")
                                Text(mode == .helper ? task.reward.currencyText : "Ready")
                            }
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color.appInk)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(.regularMaterial, in: Capsule())
                            Circle()
                                .fill(mode == .helper ? task.category.tint : Color.brandGreen)
                                .frame(width: 12, height: 12)
                                .overlay { Circle().stroke(.white, lineWidth: 2) }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(mode == .helper ? "\(task.title), \(task.reward.currencyText)" : "Available helper near \(task.place)")
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll, showsTraffic: false))
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(alignment: .topLeading) {
            StatusPill(
                text: mode == .helper ? "12 tasks nearby" : "29 helpers nearby",
                icon: "location.fill",
                tint: mode == .helper ? .brandNavy : .brandGreen
            )
            .padding(12)
        }
        .overlay(alignment: .topTrailing) {
            if mode == .requester {
                StatusPill(text: "Live", tint: .brandGreen)
                    .padding(12)
            }
        }
        .overlay(alignment: .bottomLeading) {
            if mode == .requester {
                VStack(alignment: .leading, spacing: 2) {
                    Text("AVERAGE RESPONSE")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.appSecondaryInk)
                    Text("~2 min")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appInk)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius, style: .continuous))
                .padding(12)
            }
        }
        .dynamicTypeSize(.small ... .large)
        .accessibilityLabel(mode == .helper ? "Map of nearby tasks" : "Map of nearby available helpers")
    }
}

struct TaskCardView: View {
    let task: MarketplaceTask
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    CircleIcon(systemName: task.category.icon, tint: task.category.tint)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title)
                            .font(.headline)
                            .foregroundStyle(Color.appInk)
                        Label(task.place, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appSecondaryInk)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    Text(task.reward.currencyText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.appInk)
                }

                HStack(spacing: 8) {
                    StatusPill(text: "+\(task.detourDistance.formatted(.number.precision(.fractionLength(1)))) mi", icon: "point.topleft.down.to.point.bottomright.curvepath", tint: .brandGreen)
                    StatusPill(text: "+\(task.detourMinutes) min", icon: "clock", tint: .accentBlue)
                    Spacer(minLength: 0)
                }

                HStack {
                    Label(task.timing, systemImage: "bolt.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                    Spacer()
                    Label("\(task.match)% Route Match", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.brandGreen)
                }
            }
            .cardStyle(padding: 15)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens task details")
    }
}

struct HelperCardView: View {
    let helper: HelperProfile
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(initials: helper.initials, online: true)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Text(helper.name).font(.headline)
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Color.accentBlue)
                            .accessibilityLabel("Verified")
                    }
                    RatingSummary(rating: helper.rating, trailing: "\(helper.completed) tasks · \(helper.distance.formatted(.number.precision(.fractionLength(1)))) mi")
                    Text(helper.response)
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                }
                Spacer(minLength: 0)
            }
            HStack {
                HStack(spacing: 6) {
                    ForEach(helper.services.prefix(2)) { service in
                        StatusPill(text: service.rawValue.replacingOccurrences(of: "Food / ", with: ""), icon: service.icon, tint: service.tint)
                    }
                }
                Spacer(minLength: 4)
                Button("Request \(helper.name.components(separatedBy: " ").first ?? helper.name)", action: action)
                    .buttonStyle(PrimaryActionStyle(compact: true))
            }
            if let routeMatch = helper.routeMatch {
                ProgressView(value: Double(routeMatch), total: 100) {
                    Text("\(routeMatch)% route match")
                        .font(.caption.weight(.semibold))
                }
                .tint(Color.brandGreen)
            }
        }
        .cardStyle(padding: 14)
        .accessibilityElement(children: .contain)
    }
}

struct MetricCard: View {
    let value: String
    let label: String
    var tint: Color = .appInk

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .monospacedDigit()
                .minimumScaleFactor(0.75)
            Text(label.uppercased())
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.appSecondaryInk)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .padding(.horizontal, 4)
        .background(Color.appSurface, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius, style: .continuous))
        .overlay { RoundedRectangle(cornerRadius: AppTheme.compactRadius).stroke(Color.appLine, lineWidth: 1) }
        .accessibilityElement(children: .combine)
    }
}

struct LabeledValueRow: View {
    let label: String
    let value: String
    var icon: String?
    var valueTint: Color = .appInk

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(Color.brandNavy)
                    .frame(width: 24)
                    .accessibilityHidden(true)
            }
            Text(label)
                .foregroundStyle(Color.appSecondaryInk)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(valueTint)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .frame(minHeight: 44)
        .accessibilityElement(children: .combine)
    }
}

struct AppBottomBar: View {
    @Binding var selectedTab: MainTab
    var newTask: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let items: [(MainTab, String, String)] = [
        (.home, "Home", "house.fill"),
        (.activity, "Activity", "list.bullet.rectangle"),
        (.inbox, "Inbox", "envelope.fill"),
        (.profile, "Profile", "person.fill")
    ]

    var body: some View {
        HStack(spacing: 0) {
            tabButton(items[0])
            tabButton(items[1])
            Button(action: newTask) {
                VStack(spacing: 3) {
                    Image(systemName: "plus")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.brandGreen, in: Circle())
                        .shadow(color: Color.brandGreen.opacity(0.25), radius: 8, y: 4)
                    if !dynamicTypeSize.isAccessibilitySize {
                        Text("New")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.brandGreen)
                    }
                }
                .frame(minWidth: 64, minHeight: 64)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Create a new task")
            .offset(y: -14)
            tabButton(items[2])
            tabButton(items[3])
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 7)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
        .dynamicTypeSize(.small ... .large)
    }

    @ViewBuilder
    private func tabButton(_ item: (MainTab, String, String)) -> some View {
        Button {
            selectedTab = item.0
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.2)
                    .font(.body)
                if !dynamicTypeSize.isAccessibilitySize {
                    Text(item.1)
                        .font(.caption2)
                }
            }
            .foregroundStyle(selectedTab == item.0 ? Color.brandNavy : Color.appSecondaryInk)
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.1)
        .accessibilityAddTraits(selectedTab == item.0 ? .isSelected : [])
    }
}

struct ScreenScaffold<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            content
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, 24)
                .pageWidth()
        }
        .background(Color.appBackground)
        .scrollDismissesKeyboard(.interactively)
    }
}
