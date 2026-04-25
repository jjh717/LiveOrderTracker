import SwiftUI

struct ContentView: View {
    @StateObject private var manager = LiveActivityManager.shared
    @State private var errorMessage: String?

    private let sampleItems = [
        "후라이드 치킨",
        "마르게리타 피자",
        "제주 흑돼지 정식",
        "김치찌개 + 공기밥"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                header

                if let status = manager.currentStatus, let itemName = manager.currentItemName {
                    activeOrderCard(itemName: itemName, status: status)
                    controlButtons(status: status)
                } else {
                    idleCard
                }

                Spacer()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("Live Order Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "bag.fill")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(.tint)
            Text("주문 상태를 Live Activity 와 Dynamic Island 로 추적")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 16)
    }

    private var idleCard: some View {
        VStack(spacing: 16) {
            Text("진행 중인 주문이 없어요")
                .font(.headline)
            Text("아래 버튼으로 주문을 시작하면 잠금 화면과 Dynamic Island 에 상태가 표시됩니다.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await startRandomOrder() }
            } label: {
                Label("주문 시작", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func activeOrderCard(itemName: String, status: OrderStatus) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: status.systemImage)
                    .font(.title)
                    .foregroundStyle(status.tint)
                    .frame(width: 44, height: 44)
                    .background(status.tint.opacity(0.15), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(itemName).font(.headline)
                    Text(status.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(status.tint)
                }
                Spacer()
            }

            ProgressView(value: status.progress)
                .tint(status.tint)

            HStack {
                ForEach(OrderStatus.allCases, id: \.self) { s in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(s.progress <= status.progress ? s.tint : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                        Text(s.rawValue)
                            .font(.caption2)
                            .foregroundStyle(s == status ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func controlButtons(status: OrderStatus) -> some View {
        HStack(spacing: 12) {
            Button {
                Task { await manager.end() }
            } label: {
                Label("종료", systemImage: "xmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                Task { await manager.advance() }
            } label: {
                if let next = status.next {
                    Label("다음: \(next.rawValue)", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                } else {
                    Label("완료", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(status == .delivered)
        }
    }

    private func startRandomOrder() async {
        let item = sampleItems.randomElement() ?? "샘플 주문"
        let orderId = "ORD-\(Int.random(in: 1000...9999))"
        do {
            try await manager.start(orderId: orderId, itemName: item)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
