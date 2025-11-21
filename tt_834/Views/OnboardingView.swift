import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    let pages: [(title: String, description: String, icon: String)] = [
        ("CIRCUIT LINES DUEL", "Strategic graph-based duel on a 6x6 grid. Create cycles, control territory, outsmart your opponent.", "network"),
        ("PLACE ARROWS", "Take turns placing directional arrows. Each arrow points to one of 8 directions forming graph edges.", "arrow.up.circle"),
        ("CREATE CYCLES", "Form closed loops to lock territory. Three stable cycles wins the game instantly.", "arrow.triangle.2.circlepath.circle"),
        ("INTERSECTIONS", "Crossing edges cancel each other. Plan carefully to protect your cycles from disruption.", "xmark.circle"),
        ("ONE ROTATION", "Each player gets one chance to rotate an existing arrow. Use it wisely to turn the game.", "arrow.clockwise.circle")
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            BlueprintGridBackground()
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                VStack(spacing: 24) {
                    Image(systemName: pages[currentPage].icon)
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(currentPage % 2 == 0 ? AppTheme.playerAAccent : AppTheme.playerBAccent)
                        .frame(height: 80)
                        .id("icon-\(currentPage)")
                        .transition(.opacity)
                    
                    Text(pages[currentPage].title)
                        .font(.system(size: 24, weight: .light, design: .default))
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .frame(height: 32)
                        .id("title-\(currentPage)")
                        .transition(.opacity)
                    
                    Text(pages[currentPage].description)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .frame(minHeight: 100)
                        .id("desc-\(currentPage)")
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: AppTheme.animationDuration), value: currentPage)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppTheme.gridNode : AppTheme.gridLine)
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                    }
                }
                .animation(.easeInOut(duration: AppTheme.animationDuration), value: currentPage)
                .padding(.bottom, 32)
                .frame(height: 40)
                
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: AppTheme.animationDuration)) {
                                currentPage -= 1
                            }
                        }) {
                            Text("BACK")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.gridLine, lineWidth: 1)
                                )
                        }
                    } else {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation(.easeInOut(duration: AppTheme.animationDuration)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.easeInOut(duration: AppTheme.animationDuration)) {
                                hasCompletedOnboarding = true
                            }
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "NEXT" : "START")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(AppTheme.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.gridNode)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .frame(height: 92)
            }
        }
    }
}
