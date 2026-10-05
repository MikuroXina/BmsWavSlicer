import SwiftUI

struct Ruler: View {
    var xScale: Double
    var rulerMarks: [RulerMark]
    
    var body: some View {
        Canvas { context, size in
            let sectionFont = Font.system(size: 0.4 * size.height).monospaced()
            let bpmFont = Font.system(size: 0.5 * size.height).monospaced()
            var path = Path()
            var section = 1
            for mark in rulerMarks {
                switch mark {
                case let .sectionLine(at):
                    let x = at.scaledX(xScale)
                    path.move(to: CGPoint(x: x, y: 0.0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    let resolved = context.resolve(Text("\(section)").font(sectionFont))
                    context.draw(resolved, at: CGPoint(x: x + 1.0, y: 0.6 * size.height), anchor: .topLeading)
                    section += 1
                case let .beatLine(at):
                    let x = at.scaledX(xScale)
                    path.move(to: CGPoint(x: x, y: 0.0))
                    path.addLine(to: CGPoint(x: x, y: 0.5 * size.height))
                case let .tempoChange(at, tempo):
                    let x = at.scaledX(xScale)
                    let resolved = context.resolve(Text(tempo.bpm.description).font(bpmFont))
                    context.draw(resolved, at: CGPoint(x: x, y: 0.0), anchor: .topLeading)
                }
            }
            context.stroke(path, with: .foreground)
        }
    }
}

#Preview {
    Ruler(xScale: 0.5, rulerMarks: defaultRulerMarks)
        .frame(maxHeight: 20.0)
}
