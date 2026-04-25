import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    @Published private(set) var currentActivityId: String?
    @Published private(set) var currentStatus: OrderStatus?
    @Published private(set) var currentItemName: String?

    private var activity: Activity<OrderActivityAttributes>?

    private init() {}

    var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    func start(orderId: String, itemName: String) async throws {
        guard isAvailable else {
            throw LiveActivityError.notAuthorized
        }

        if activity != nil {
            await end()
        }

        let attributes = OrderActivityAttributes(
            orderId: orderId,
            itemName: itemName
        )
        let initialState = OrderActivityAttributes.ContentState(
            status: .received,
            estimatedMinutes: 35
        )
        let content = ActivityContent(
            state: initialState,
            staleDate: Date().addingTimeInterval(60 * 60)
        )

        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil
        )
        self.activity = activity
        self.currentActivityId = activity.id
        self.currentStatus = .received
        self.currentItemName = itemName
    }

    func advance() async {
        guard let activity, let current = currentStatus, let next = current.next else { return }

        let remaining = max(0, estimatedMinutes(for: next))
        let newState = OrderActivityAttributes.ContentState(
            status: next,
            estimatedMinutes: remaining
        )
        let content = ActivityContent(
            state: newState,
            staleDate: Date().addingTimeInterval(60 * 60)
        )

        await activity.update(content)
        self.currentStatus = next

        if next == .delivered {
            try? await Task.sleep(for: .seconds(3))
            await end()
        }
    }

    func end() async {
        guard let activity else { return }
        let finalState = OrderActivityAttributes.ContentState(
            status: currentStatus ?? .delivered,
            estimatedMinutes: 0
        )
        await activity.end(
            ActivityContent(state: finalState, staleDate: nil),
            dismissalPolicy: .immediate
        )
        self.activity = nil
        self.currentActivityId = nil
        self.currentStatus = nil
        self.currentItemName = nil
    }

    private func estimatedMinutes(for status: OrderStatus) -> Int {
        switch status {
        case .received:   return 35
        case .preparing:  return 25
        case .delivering: return 12
        case .delivered:  return 0
        }
    }
}

enum LiveActivityError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Live Activities 권한이 꺼져 있습니다. 설정 > LiveOrderTracker 에서 활성화해 주세요."
        }
    }
}
