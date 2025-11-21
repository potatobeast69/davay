import SwiftUI
import MessageUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showMailComposer = false
    @State private var canSendMail = MFMailComposeViewController.canSendMail()
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            BlueprintGridBackground()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.glassBackground)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.glassBorder, lineWidth: 1)
                                )
                            
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppTheme.playerBAccent)
                        }
                    }
                    
                    Spacer()
                    
                    Text("SETTINGS")
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    AppTheme.textPrimary,
                                    AppTheme.textSecondary
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(3)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .frame(height: 60)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            SettingsRow(
                                icon: "doc.text",
                                title: "Privacy Policy",
                                gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow],
                                action: { RunesUtilities.openPrivacy() }
                            )
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            
                            SettingsRow(
                                icon: "list.bullet.rectangle",
                                title: "Terms of Use",
                                gradient: [AppTheme.playerAAccent, AppTheme.playerAGlow],
                                action: { RunesUtilities.openRules() }
                            )
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            
                            SettingsRow(
                                icon: "star",
                                title: "Rate Us",
                                gradient: [AppTheme.playerBAccent, AppTheme.playerBGlow],
                                action: { RunesUtilities.rateApp() }
                            )
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            
                            if canSendMail {
                                SettingsRow(
                                    icon: "envelope",
                                    title: "Contact Us",
                                    gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow],
                                    action: { showMailComposer = true }
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 20)
                            } else {
                                SettingsRow(
                                    icon: "envelope",
                                    title: "Contact Us",
                                    subtitle: RunesConfig.supportEmail,
                                    gradient: [AppTheme.gridNode, AppTheme.gridNodeGlow],
                                    action: {}
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 20)
                            }
                        }
                        
                        Divider()
                            .background(AppTheme.gridLine.opacity(0.3))
                            .padding(.vertical, 8)
                        
                        VStack(spacing: 16) {
                            HStack(spacing: 0) {
                                Text("App Version")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Text(RunesUtilities.appVersion)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.gridNode,
                                                AppTheme.gridNodeGlow
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.glassBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppTheme.glassBorder, lineWidth: 1)
                                    )
                            )
                            
                            HStack(spacing: 0) {
                                Text("Build Number")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(AppTheme.textSecondary)
                                
                                Spacer()
                                
                                Text(RunesUtilities.buildNumber)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.playerBAccent,
                                                AppTheme.playerBGlow
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.glassBackground)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppTheme.glassBorder, lineWidth: 1)
                                    )
                            )
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        
                        Text("CIRCUIT LINES DUEL")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(AppTheme.textTertiary)
                            .tracking(3)
                            .padding(.top, 20)
                            .opacity(appearAnimation ? 1 : 0)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showMailComposer) {
            RunesMailComposer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    gradient[0].opacity(0.3),
                                    gradient[1].opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 22
                            )
                        )
                        .frame(width: 44, height: 44)
                        .blur(radius: 10)
                    
                    Circle()
                        .fill(AppTheme.glassBackground)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            gradient[0].opacity(0.5),
                                            gradient[1].opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular, design: .default))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 20, height: 20)
            }
            .padding(18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppTheme.glassBackground)
                    
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    gradient[0].opacity(0.05),
                                    gradient[1].opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    AppTheme.glassBorder,
                                    gradient[1].opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .shadow(color: gradient[1].opacity(0.15), radius: 10)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
