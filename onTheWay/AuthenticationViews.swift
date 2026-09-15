import SwiftUI

struct AuthenticationRootView: View {
    @EnvironmentObject private var app: AppState

    var body: some View {
        NavigationStack {
            Group {
                switch app.authScreen {
                case .welcome:
                    WelcomeView()
                case .login:
                    LoginView()
                case .signup:
                    SignupView()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Color.brandGreen)
    }
}

struct WelcomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private let features = [
        ("location.fill", "Hyperlocal Matching", "Find trusted helpers in your neighborhood in real time."),
        ("point.topleft.down.to.point.bottomright.curvepath", "Route Overlap", "Match with people already going your way, with minimal detour."),
        ("checkmark.shield.fill", "Safe & Verified", "Identity checks, secure payments, and ratings you can trust.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(Color.brandNavy, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.brandNavy.opacity(0.18), radius: 15, y: 8)
                    .accessibilityLabel("OnTheWay")
                    .padding(.bottom, 24)

                Text("Turn spare time\ninto instant help.")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color.appInk)
                    .tracking(-0.5)
                    .padding(.bottom, 12)

                Text("Connect with people nearby who are already heading your way. Get help or earn money on the go.")
                    .font(.body)
                    .foregroundStyle(Color.appSecondaryInk)
                    .lineSpacing(4)
                    .padding(.bottom, 32)

                VStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { _, feature in
                        HStack(alignment: .top, spacing: 14) {
                            CircleIcon(systemName: feature.0, tint: .brandGreen, size: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feature.1)
                                    .font(.headline)
                                    .foregroundStyle(Color.appInk)
                                Text(feature.2)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appSecondaryInk)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom, 36)

                VStack(spacing: 12) {
                    Button {
                        app.authScreen = .signup
                    } label: {
                        Label("Create Account", systemImage: "person.badge.plus")
                    }
                    .buttonStyle(PrimaryActionStyle(color: .brandNavy))

                    Button("Already have an account? Log in") {
                        app.authScreen = .login
                    }
                    .buttonStyle(SecondaryActionStyle())
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 56)
            .padding(.bottom, 28)
            .pageWidth()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared || reduceMotion ? 0 : 10)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) {
                appeared = true
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var app: AppState
    @State private var email = "alex@email.com"
    @State private var password = "OnTheWay1!"
    @State private var rememberMe = true
    @State private var submitted = false
    @State private var showingReset = false

    private var isValid: Bool { email.contains("@") && password.count >= 8 }

    var body: some View {
        ScreenScaffold {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    app.authScreen = .welcome
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .frame(minHeight: 44)
                }
                .foregroundStyle(Color.brandNavy)
                .padding(.bottom, 20)

                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.brandNavy, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityHidden(true)
                    .padding(.bottom, 20)

                Text("Welcome back")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color.appInk)
                Text("Sign in to continue to OnTheWay")
                    .font(.body)
                    .foregroundStyle(Color.appSecondaryInk)
                    .padding(.top, 6)
                    .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Email or Phone").font(.subheadline.weight(.semibold))
                        TextField("Enter email or phone", text: $email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding(14)
                            .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                            .accessibilityHint("Enter the email or phone linked to your account")
                    }
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Password").font(.subheadline.weight(.semibold))
                        SecureField("Enter password", text: $password)
                            .textContentType(.password)
                            .padding(14)
                            .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                    }
                }

                if submitted && !isValid {
                    Label("Enter a valid email and a password with at least 8 characters.", systemImage: "exclamationmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(Color.appDanger)
                        .padding(.top, 10)
                }

                HStack {
                    Toggle("Remember me", isOn: $rememberMe)
                    Spacer()
                    Button("Forgot Password?") { showingReset = true }
                        .font(.subheadline.weight(.semibold))
                }
                .padding(.vertical, 18)

                Button("Sign In") {
                    submitted = true
                    if isValid { app.signIn() }
                }
                .buttonStyle(PrimaryActionStyle())

                HStack {
                    Rectangle().fill(Color.appLine).frame(height: 1)
                    Text("or continue with")
                        .font(.caption)
                        .foregroundStyle(Color.appSecondaryInk)
                    Rectangle().fill(Color.appLine).frame(height: 1)
                }
                .padding(.vertical, 22)

                HStack(spacing: 12) {
                    socialButton("apple.logo", "Continue with Apple")
                    socialButton("g.circle.fill", "Continue with Google")
                    socialButton("person.crop.circle", "Continue with another account")
                }
                .frame(maxWidth: .infinity)

                Button("Don’t have an account? Sign up") {
                    app.authScreen = .signup
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.top, 16)
            }
            .padding(.top, 8)
        }
        .alert("Reset link ready", isPresented: $showingReset) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A password reset link would be sent to the email or phone entered above. No message is sent in this demo build.")
        }
    }

    private func socialButton(_ icon: String, _ label: String) -> some View {
        Button(action: app.signIn) {
            Image(systemName: icon)
                .font(.title3)
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color.appSurface, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                .overlay { RoundedRectangle(cornerRadius: AppTheme.compactRadius).stroke(Color.appLine) }
        }
        .foregroundStyle(Color.appInk)
        .accessibilityLabel(label)
    }
}

struct SignupView: View {
    @EnvironmentObject private var app: AppState
    @State private var step = 0
    @State private var name = "Alex Johnson"
    @State private var email = "alex@email.com"
    @State private var phone = "(555) 234-5678"
    @State private var password = "OnTheWay1!"
    @State private var agreed = true
    @State private var code = "4829"
    @State private var locationAllowed = true
    @State private var notificationsAllowed = true

    private let stepNames = ["Profile", "Verify", "Access", "Done"]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    if step == 0 { app.authScreen = .welcome } else { step -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Back")
                Spacer()
                Text("Create Account")
                    .font(.headline)
                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 8)

            HStack(spacing: 8) {
                ForEach(stepNames.indices, id: \.self) { index in
                    VStack(spacing: 5) {
                        ZStack {
                            Circle()
                                .fill(index <= step ? Color.brandNavy : Color.appSurfaceAlt)
                                .frame(width: 28, height: 28)
                            if index < step {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(index == step ? Color.white : Color.appSecondaryInk)
                            }
                        }
                        Text(stepNames[index])
                            .font(.caption2)
                            .foregroundStyle(index <= step ? Color.appInk : Color.appSecondaryInk)
                    }
                    if index < stepNames.count - 1 {
                        Rectangle()
                            .fill(index < step ? Color.brandGreen : Color.appLine)
                            .frame(height: 2)
                            .accessibilityHidden(true)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step \(step + 1) of 4, \(stepNames[step])")

            ScrollView {
                Group {
                    switch step {
                    case 0: profileStep
                    case 1: verificationStep
                    case 2: accessStep
                    default: doneStep
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, 28)
                .pageWidth()
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .tint(Color.brandGreen)
    }

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            stepIntro("Your info", "We’ll use this to verify your account and build trust in the community.")
            formField("Full Name", prompt: "First and last name", text: $name, contentType: .name)
            formField("Email", prompt: "your@email.com", text: $email, contentType: .emailAddress)
            formField("Phone Number", prompt: "Phone number", text: $phone, contentType: .telephoneNumber)
            VStack(alignment: .leading, spacing: 7) {
                Text("Password").font(.subheadline.weight(.semibold))
                SecureField("Create a password", text: $password)
                    .textContentType(.newPassword)
                    .padding(14)
                    .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
                Text("Use 8+ characters with a mix of letters, numbers, and symbols.")
                    .font(.caption)
                    .foregroundStyle(Color.appSecondaryInk)
            }
            Toggle(isOn: $agreed) {
                Text("I agree to OnTheWay’s Terms of Service and Privacy Policy.")
                    .font(.footnote)
            }
            Button("Continue") { step = 1 }
                .buttonStyle(PrimaryActionStyle())
                .disabled(!agreed || name.isEmpty || !email.contains("@") || password.count < 8)
                .opacity(agreed && !name.isEmpty && email.contains("@") && password.count >= 8 ? 1 : 0.45)
        }
    }

    private var verificationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepIntro("Verify your phone", "We sent a four-digit code to +1 \(phone).")
            TextField("Verification code", text: $code)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .font(.title.weight(.bold).monospacedDigit())
                .padding(18)
                .background(Color.appSurface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
                .overlay { RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(Color.appLine) }
                .accessibilityHint("Enter the four digit code")
            Label("Your exact phone number is never shown to other marketplace users.", systemImage: "lock.shield.fill")
                .font(.subheadline)
                .foregroundStyle(Color.appSecondaryInk)
                .cardStyle()
            Button("Verify & Continue") { step = 2 }
                .buttonStyle(PrimaryActionStyle())
                .disabled(code.count != 4)
                .opacity(code.count == 4 ? 1 : 0.45)
        }
    }

    private var accessStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepIntro("Set up access", "OnTheWay uses these permissions to find relevant help and keep you updated.")
            permissionRow(icon: "location.fill", title: "Approximate Location", description: "See helpers and tasks nearby. Exact locations are revealed only after a match.", isOn: $locationAllowed)
            permissionRow(icon: "bell.fill", title: "Notifications", description: "Receive direct requests, task status, chat, and delivery updates.", isOn: $notificationsAllowed)
            Label("You can change these choices later in Settings.", systemImage: "hand.raised.fill")
                .font(.footnote)
                .foregroundStyle(Color.appSecondaryInk)
            Button("Finish Setup") { step = 3 }
                .buttonStyle(PrimaryActionStyle())
        }
    }

    private var doneStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(Color.brandGreen)
                .accessibilityHidden(true)
            Text("You’re ready to go")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)
            Text("Request local help or switch to Help & Earn whenever you have spare time and an overlapping route.")
                .font(.body)
                .foregroundStyle(Color.appSecondaryInk)
                .multilineTextAlignment(.center)
            VStack(spacing: 10) {
                Label("Phone verified", systemImage: "checkmark.circle.fill")
                Label("Location privacy configured", systemImage: "location.circle.fill")
                Label("Secure payments ready for demo", systemImage: "creditcard.fill")
            }
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
            Button("Explore OnTheWay") { app.signIn() }
                .buttonStyle(PrimaryActionStyle())
        }
        .padding(.top, 32)
    }

    private func stepIntro(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(.title2.weight(.bold))
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.appSecondaryInk)
        }
        .padding(.top, 8)
    }

    private func formField(_ title: String, prompt: String, text: Binding<String>, contentType: UITextContentType?) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title).font(.subheadline.weight(.semibold))
            TextField(prompt, text: text)
                .textContentType(contentType)
                .padding(14)
                .background(Color.appSurfaceAlt, in: RoundedRectangle(cornerRadius: AppTheme.compactRadius))
        }
    }

    private func permissionRow(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 14) {
            CircleIcon(systemName: icon, tint: .brandGreen)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.appSecondaryInk)
            }
            Spacer(minLength: 4)
            Toggle(title, isOn: isOn)
                .labelsHidden()
        }
        .cardStyle()
    }
}
