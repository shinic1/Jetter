import SwiftUI

struct TipsListView: View {
    let tips: [TipItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Tips for Your Flight", systemImage: "lightbulb.fill")
                .font(JetterTypography.headline)
                .foregroundStyle(JetterColors.amberGold)

            ForEach(Array(tips.enumerated()), id: \.element.id) { index, tip in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: tip.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(JetterColors.amberGold)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(tip.title)
                            .font(JetterTypography.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text(tip.body)
                            .font(JetterTypography.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if index < tips.count - 1 {
                    Divider()
                        .padding(.leading, 38)
                }
            }
        }
        .padding(20)
        .background(JetterColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
