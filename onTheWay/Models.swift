import Foundation
import MapKit

enum UserMode: String, CaseIterable, Identifiable, Codable {
    case requester = "Need Help"
    case helper = "Help & Earn"

    var id: String { rawValue }
}

enum MainTab: Hashable {
    case home
    case activity
    case inbox
    case profile
}

enum TaskCategory: String, CaseIterable, Identifiable, Hashable, Codable {
    case coffee = "Food / Coffee"
    case delivery = "Pickup & Deliver"
    case store = "Store Errands"
    case returnDropoff = "Return / Drop-off"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .coffee: "cup.and.saucer.fill"
        case .delivery: "shippingbox.fill"
        case .store: "bag.fill"
        case .returnDropoff: "arrow.up.doc.fill"
        case .other: "ellipsis"
        }
    }

    var colorName: String {
        switch self {
        case .coffee: "coffee"
        case .delivery: "blue"
        case .store: "amber"
        case .returnDropoff: "plum"
        case .other: "navy"
        }
    }

    var subtitle: String {
        switch self {
        case .coffee: "Prepaid orders and takeout"
        case .delivery: "Fast for small items"
        case .store: "Target, CVS, local shops"
        case .returnDropoff: "UPS, FedEx, USPS"
        case .other: "Tell us what you need"
        }
    }
}

struct MarketplaceTask: Identifiable, Hashable {
    let id: UUID
    let category: TaskCategory
    let title: String
    let place: String
    let reward: Decimal
    let pickupDistance: Double
    let detourDistance: Double
    let detourMinutes: Int
    let timing: String
    let match: Int
    let detail: String
    let coordinate: CLLocationCoordinate2D

    init(
        id: UUID = UUID(), category: TaskCategory, title: String, place: String,
        reward: Decimal, pickupDistance: Double, detourDistance: Double,
        detourMinutes: Int, timing: String, match: Int, detail: String,
        latitude: Double, longitude: Double
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.place = place
        self.reward = reward
        self.pickupDistance = pickupDistance
        self.detourDistance = detourDistance
        self.detourMinutes = detourMinutes
        self.timing = timing
        self.match = match
        self.detail = detail
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: MarketplaceTask, rhs: MarketplaceTask) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct HelperProfile: Identifiable, Hashable {
    let id: UUID
    let name: String
    let initials: String
    let rating: Double
    let completed: Int
    let distance: Double
    let response: String
    let services: [TaskCategory]
    let routeMatch: Int?

    init(
        id: UUID = UUID(), name: String, initials: String, rating: Double,
        completed: Int, distance: Double, response: String,
        services: [TaskCategory], routeMatch: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.initials = initials
        self.rating = rating
        self.completed = completed
        self.distance = distance
        self.response = response
        self.services = services
        self.routeMatch = routeMatch
    }
}

enum TaskProgress: Int, CaseIterable, Identifiable {
    case matched
    case headingToPickup
    case atPickup
    case pickedUp
    case headingToRequester
    case delivered
    case completed

    var id: Int { rawValue }
    var title: String {
        switch self {
        case .matched: "Matched"
        case .headingToPickup: "Heading to Pickup"
        case .atPickup: "At Pickup"
        case .pickedUp: "Picked Up"
        case .headingToRequester: "Heading Your Way"
        case .delivered: "Delivered"
        case .completed: "Completed"
        }
    }

    var next: TaskProgress? { TaskProgress(rawValue: rawValue + 1) }
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isMine: Bool
    let timestamp: Date

    init(id: UUID = UUID(), text: String, isMine: Bool, timestamp: Date = .now) {
        self.id = id
        self.text = text
        self.isMine = isMine
        self.timestamp = timestamp
    }
}

struct TaskDraft: Equatable {
    var category: TaskCategory = .coffee
    var store = "Starbucks — Bancroft Way"
    var pickupAddress = "2301 Bancroft Way, Berkeley, CA"
    var orderName = "Emma Wilson"
    var orderNumber = "SB-48291"
    var itemDetails = "2x Medium Iced Latte"
    var deliveryAddress = "Unit 2 Dormitory, Apt 3B"
    var isASAP = true
    var scheduledFor = Date.now.addingTimeInterval(60 * 45)
    var itemSize = "Small"
    var packageWeight = "Under 5 lb"
    var isFragile = false
    var pickupContact = "Front desk"
    var deadline = Date.now.addingTimeInterval(60 * 60 * 3)
    var routeDistance = 0.6
    var estimatedMinutes = 20
    var demandLevel = "High"
    var instructions = "Ring doorbell. Contactless delivery OK — leave by door if no answer."
    var contactless = true
    var reward: Decimal = 5
    var rewardWasAdjusted = false

    var categoryBase: Decimal {
        switch category {
        case .coffee: Decimal(string: "3.50")!
        case .delivery: Decimal(string: "4.50")!
        case .store: Decimal(string: "4.00")!
        case .returnDropoff: Decimal(string: "4.25")!
        case .other: Decimal(string: "5.00")!
        }
    }

    var distancePrice: Decimal {
        (Decimal(routeDistance) * Decimal(string: "1.15")!).rounded(scale: 2)
    }

    var timePrice: Decimal {
        (Decimal(estimatedMinutes) * Decimal(string: "0.06")!).rounded(scale: 2)
    }

    var effortPrice: Decimal {
        let sizePrice: Decimal = switch itemSize {
        case "Large": 2
        case "Medium": 1
        default: 0
        }
        return sizePrice + (isFragile ? Decimal(string: "0.75")! : 0)
    }

    var urgencyPrice: Decimal { isASAP ? Decimal(string: "0.75")! : 0 }
    var demandPrice: Decimal { demandLevel == "High" ? Decimal(string: "0.65")! : demandLevel == "Medium" ? Decimal(string: "0.30")! : 0 }

    var suggestedReward: Decimal {
        let raw = categoryBase + distancePrice + timePrice + effortPrice + urgencyPrice + demandPrice
        return max(Decimal(3), (raw * 2).rounded(scale: 0) / 2)
    }

    mutating func applySuggestedReward(force: Bool = false) {
        guard force || !rewardWasAdjusted else { return }
        reward = suggestedReward
    }

    var platformFee: Decimal { (reward * Decimal(string: "0.15")!).rounded(scale: 2) }
    var total: Decimal { reward + platformFee }
}

enum MatchStrategy: Equatable {
    case automatic
    case direct(HelperProfile)
}

enum DirectRequestStatus: Equatable {
    case none
    case awaitingResponse
    case accepted
    case declinedFallback
}

enum TaskModificationStatus: Equatable {
    case none
    case drafting
    case awaitingHelperConsent(previousTotal: Decimal, revisedTotal: Decimal)
    case accepted(revisedTotal: Decimal)
    case declinedRematching(revisedTotal: Decimal)
}

enum CancellationResolution: Equatable {
    case none
    case cancelled(refund: Decimal, helperPayment: Decimal, rate: Int)

    var summary: String? {
        switch self {
        case .none: nil
        case let .cancelled(refund, helperPayment, rate):
            "Cancelled · Refund \(refund.currencyText) · Helper payment \(helperPayment.currencyText) · Cancellation rate \(rate)%"
        }
    }
}

extension Decimal {
    func rounded(scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .bankers)
        return result
    }

    var currencyText: String {
        formatted(.currency(code: "USD"))
    }
}

enum DemoData {
    static let tasks: [MarketplaceTask] = [
        MarketplaceTask(category: .coffee, title: "Coffee Pickup", place: "Starbucks · Bancroft Way", reward: 5, pickupDistance: 0.2, detourDistance: 0.1, detourMinutes: 7, timing: "ASAP", match: 92, detail: "2 prepaid drinks", latitude: 37.8692, longitude: -122.2585),
        MarketplaceTask(category: .returnDropoff, title: "UPS Drop-off", place: "Unit 2 Dorm → UPS", reward: 7, pickupDistance: 0.4, detourDistance: 0.3, detourMinutes: 12, timing: "Before 5 PM", match: 75, detail: "Small package · label ready", latitude: 37.8664, longitude: -122.2609),
        MarketplaceTask(category: .store, title: "Target Pickup", place: "Target · Shattuck Ave", reward: 6.5, pickupDistance: 0.5, detourDistance: 0.4, detourMinutes: 15, timing: "In 30 min", match: 68, detail: "2 prepaid items", latitude: 37.8721, longitude: -122.2681),
        MarketplaceTask(category: .delivery, title: "Book Delivery", place: "Doe Library → Downtown", reward: 4.5, pickupDistance: 0.3, detourDistance: 0.2, detourMinutes: 9, timing: "By 2 PM", match: 84, detail: "One small tote", latitude: 37.8720, longitude: -122.2595)
    ]

    static let helpers: [HelperProfile] = [
        HelperProfile(name: "Alex J.", initials: "AJ", rating: 4.90, completed: 184, distance: 0.2, response: "Usually responds in under 1 min", services: [.coffee, .delivery]),
        HelperProfile(name: "Ryan K.", initials: "RK", rating: 4.80, completed: 96, distance: 0.3, response: "Usually responds in 2 min", services: [.coffee, .store]),
        HelperProfile(name: "Maya J.", initials: "MJ", rating: 4.92, completed: 248, distance: 0.2, response: "Usually responds in 1 min", services: [.coffee], routeMatch: 95),
        HelperProfile(name: "Dana N.", initials: "DN", rating: 4.90, completed: 321, distance: 0.4, response: "Usually responds in 3 min", services: [.delivery, .store])
    ]
}
