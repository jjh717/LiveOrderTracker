import ActivityKit
import Foundation

public struct OrderActivityAttributes: ActivityAttributes, Sendable {
    public struct ContentState: Codable, Hashable, Sendable {
        public var status: OrderStatus
        public var estimatedMinutes: Int
        public var updatedAt: Date

        public init(status: OrderStatus, estimatedMinutes: Int, updatedAt: Date = .now) {
            self.status = status
            self.estimatedMinutes = estimatedMinutes
            self.updatedAt = updatedAt
        }
    }

    public var orderId: String
    public var itemName: String
    public var orderedAt: Date

    public init(orderId: String, itemName: String, orderedAt: Date = .now) {
        self.orderId = orderId
        self.itemName = itemName
        self.orderedAt = orderedAt
    }
}
