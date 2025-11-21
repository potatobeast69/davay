import SwiftUI

struct BlueprintGridBackground: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.backgroundGradientTop,
                    AppTheme.backgroundGradientBottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            GeometryReader { geometry in
                Canvas { context, size in
                    let spacing: CGFloat = 30
                    
                    var path = Path()
                    
                    var x: CGFloat = 0
                    while x <= size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        x += spacing
                    }
                    
                    var y: CGFloat = 0
                    while y <= size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        y += spacing
                    }
                    
                    context.stroke(
                        path,
                        with: .color(AppTheme.gridLine.opacity(0.2)),
                        lineWidth: 0.5
                    )
                }
                
                Canvas { context, size in
                    let spacing: CGFloat = 90
                    
                    var path = Path()
                    
                    var x: CGFloat = animationOffset
                    while x <= size.width + spacing {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        x += spacing
                    }
                    
                    var y: CGFloat = animationOffset
                    while y <= size.height + spacing {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        y += spacing
                    }
                    
                    context.stroke(
                        path,
                        with: .color(AppTheme.gridLineGlow.opacity(0.15)),
                        lineWidth: 1
                    )
                }
            }
            
            RadialGradient(
                colors: [
                    AppTheme.gridNodeGlow.opacity(0.03),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                animationOffset = 90
            }
        }
    }
}
