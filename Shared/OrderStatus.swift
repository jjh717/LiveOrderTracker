import Foundation
import SwiftUI

public enum OrderStatus: String, Codable, Hashable, CaseIterable, Sendable {
    case received = "주문 접수"
    case preparing = "준비 중"
    case delivering = "배송 중"
    case delivered = "배송 완료"

    public var progress: Double {
        switch self {
        case .received:   return 0.10
        case .preparing:  return 0.40
        case .delivering: return 0.75
        case .delivered:  return 1.00
        }
    }

    public var systemImage: String {
        switch self {
        case .received:   return "doc.text.fill"
        case .preparing:  return "frying.pan.fill"
        case .delivering: return "bicycle"
        case .delivered:  return "checkmark.seal.fill"
        }
    }

    public var tint: Color {
        switch self {
        case .received:   return .blue
        case .preparing:  return .orange
        case .delivering: return .purple
        case .delivered:  return .green
        }
    }

    public var next: OrderStatus? {
        let all = OrderStatus.allCases
        guard let idx = all.firstIndex(of: self), idx + 1 < all.count else { return nil }
        return all[idx + 1]
    }
}
