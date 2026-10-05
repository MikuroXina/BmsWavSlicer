import SwiftUI

extension Binding where Value == Double {
    func decibel() -> Binding<Double> {
        Binding.init(
            get: {
                20.0 * log10(self.wrappedValue)
            },
            set: { newValue in
                self.wrappedValue = pow(10.0, newValue / 20.0)
            }
        )
    }
}

struct Ribbon: View {
    @Binding var xScale: Double
    @Binding var quantizeMode: QuantizeMode

    var body: some View {
        HStack {
            Spacer()
            HStack {
                Slider(value: $xScale.decibel(), in: -10.0...10.0, step: 1.0) {
                    Image(systemName: "arrow.left.and.right")
                }
                Picker("Q", selection: $quantizeMode.type) {
                    ForEach(QuantizeType.allCases) { option in
                        Text(option.description).tag(option)
                    }
                }
            }
            .frame(maxWidth: 400.0)
        }
    }
}

#Preview {
    @Previewable @State var xScale = 1.0
    @Previewable @State var quantizeMode = QuantizeMode.init(type: .oneEight, isTriplet: false)
    Ribbon(xScale: $xScale, quantizeMode: $quantizeMode)
}
