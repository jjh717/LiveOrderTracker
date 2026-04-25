import ActivityKit
import WidgetKit
import SwiftUI

struct OrderLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderActivityAttributes.self) { context in
            LockScreenView(
                attributes: context.attributes,
                state: context.state
            )
            .padding()
            .activityBackgroundTint(Color(.systemBackground))
            .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: context.state.status.systemImage)
                            .font(.title2)
                            .foregroundStyle(context.state.status.tint)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.state.status.rawValue)
                                .font(.caption)
                                .foregroundStyle(context.state.status.tint)
                            Text(context.attributes.itemName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(context.state.estimatedMinutes)분")
                            .font(.title3).bold()
                            .monospacedDigit()
                            .foregroundStyle(context.state.status.tint)
                        Text("예상 시간")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: context.state.status.progress)
                        .tint(context.state.status.tint)
                }
            } compactLeading: {
                Image(systemName: context.state.status.systemImage)
                    .foregroundStyle(context.state.status.tint)
            } compactTrailing: {
                Text("\(context.state.estimatedMinutes)분")
                    .monospacedDigit()
                    .foregroundStyle(context.state.status.tint)
            } minimal: {
                Image(systemName: context.state.status.systemImage)
                    .foregroundStyle(context.state.status.tint)
            }
            .widgetURL(URL(string: "liveordertracker://order/\(context.attributes.orderId)"))
            .keylineTint(context.state.status.tint)
        }
    }
}

private struct LockScreenView: View {
    let attributes: OrderActivityAttributes
    let state: OrderActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: state.status.systemImage)
                    .font(.title2)
                    .foregroundStyle(state.status.tint)
                    .frame(width: 36, height: 36)
                    .background(state.status.tint.opacity(0.15), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(attributes.itemName)
                        .font(.headline)
                        .lineLimit(1)
                    Text(state.status.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(state.status.tint)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(state.estimatedMinutes)분")
                        .font(.title3).bold()
                        .monospacedDigit()
                    Text("예상 시간")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            ProgressView(value: state.status.progress)
                .tint(state.status.tint)

            HStack {
                ForEach(OrderStatus.allCases, id: \.self) { s in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(s.progress <= state.status.progress ? s.tint : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                        Text(s.rawValue)
                            .font(.caption2)
                            .foregroundStyle(s == state.status ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
