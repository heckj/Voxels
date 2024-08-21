import simd
import SwiftUI

struct TopDownVectorImage: View {
    let unitVector: SIMD3<Float>
    var body: some View {
        Canvas { graphicsContext, size in

            // [x,y] has [0,0] is in the upper left corner
            var path = Path()

//            path.move(to: CGPoint(x: 0,y: 0))
//            path.addLine(to: CGPoint(x: 0, y: size.height))
//            path.addLine(to: CGPoint(x: size.width, y: size.height))
//            path.addLine(to: CGPoint(x: size.width, y: 0))
//            path.addLine(to: CGPoint(x: 0,y: 0))

            // bisect it vertically
            path.move(to: CGPoint(x: size.width / 2.0, y: 0))
            path.addLine(to: CGPoint(x: size.width / 2.0, y: size.height))
            // bisect it horizontally
            path.move(to: CGPoint(x: 0, y: size.height / 2.0))
            path.addLine(to: CGPoint(x: size.width, y: size.height / 2.0))

            graphicsContext.stroke(path, with: .foreground, style: .init(lineWidth: 0.5))

            // add a tiny center circle
            let circlePath = Circle().path(in: CGRect(origin: CGPoint(x: size.width / 2.0 - 2.0, y: size.height / 2.0 - 2.0), size: CGSize(width: 4.0, height: 4.0)))
            graphicsContext.fill(circlePath, with: .color(.blue))

            // X label
            graphicsContext.draw(Text("X"), in: CGRect(x: size.width - 10, y: size.height / 2.0 - 8, width: 10, height: 10))

            // Z label
            graphicsContext.draw(Text("Z"), in: CGRect(x: size.width / 2.0 - 4, y: size.height - 14, width: 10, height: 10))

            var unitVectorPath = Path()
            unitVectorPath.move(to: CGPoint(x: size.width / 2.0, y: size.height / 2.0))
            unitVectorPath.addLine(to: CGPoint(x: CGFloat(unitVector.x) * size.width + size.width / 2.0, y: CGFloat(unitVector.z) * size.height + size.height / 2.0))
            graphicsContext.stroke(unitVectorPath, with: .color(.blue), lineWidth: 2.0)
        }
    }
}

#Preview {
    TopDownVectorImage(unitVector: SIMD3<Float>(-0.4, 0, 0.2))
        .background(.white)
        .padding()
        .frame(width: 150, height: 150)
}
