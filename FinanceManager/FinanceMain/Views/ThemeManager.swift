import SwiftUI

struct ThemeColors {
    static let darkBlue = Color(red: 10/255, green: 20/255, blue: 50/255)
    static let cardBackground = Color.white.opacity(0.1)
    static let inputBackground = Color.white.opacity(0.07)
    static let accent = Color.blue
    static let incomeGreen = Color.green
    static let expenseRed = Color.red
    
    // Text colors
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
    static let placeholderText = Color.white.opacity(0.4)
}

struct GlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial.opacity(0.3))
            .background(ThemeColors.cardBackground)
            .cornerRadius(16)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassEffect())
    }
}

struct InputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(ThemeColors.inputBackground)
            .cornerRadius(10)
            .foregroundColor(ThemeColors.primaryText)
    }
}

extension View {
    func inputStyle() -> some View {
        modifier(InputFieldStyle())
    }
} 