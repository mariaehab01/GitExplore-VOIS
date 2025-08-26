//
//  SplashScreen.swift
//  GitExplore
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .playOnce
    var onCompleted: (() -> Void)? = nil
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit
        container.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        if let anim = LottieAnimation.named(name) {
            animationView.animation = anim
            animationView.loopMode = loopMode
            animationView.play { _ in onCompleted?() }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { onCompleted?() }
        }
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


struct SplashView: View {
    @Binding var isPresented: Bool
    
    private let minShowSeconds: Double = 2.4
    private let fadeOutSeconds: Double = 0.02
    
    @State private var popped = false
    @State private var breathe = false
    @State private var fadeOut = false
    
    var body: some View {
        ZStack {
            VOISGradient().ignoresSafeArea()
            
            LottieView(name: "splash", loopMode: .loop)
                .frame(width: 240, height: 240)
                .opacity(0.65)
                .allowsHitTesting(false)
            
            VStack(spacing: 2) {
                // MARK: Logo with smooth orbital motion
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let period = 4.0
                    let angle = (t.truncatingRemainder(dividingBy: period) / period) * (.pi * 2)
                    let radius: CGFloat = 12
                    let x = cos(angle) * radius
                    let y = sin(angle) * (radius * 0.8)
                    
                    Image("GitHubMark")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .scaleEffect(popped ? 1.0 : 0.86)
                        .scaleEffect(breathe ? 1.02 : 0.98)
                        .rotationEffect(.degrees(sin(angle) * 4)) // tiny tilt
                        .offset(x: x, y: y)
                        .animation(.spring(response: 0.55, dampingFraction: 0.75), value: popped)
                        .animation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: breathe)
                }
                
                TimelineView(.animation) { timeline in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let period = 4.0
                    let angle = (t.truncatingRemainder(dividingBy: period) / period) * (.pi * 2)
                    let y = sin(angle) * 1.5
                    
                    Text("GitExplore")
                        .font(.system(size: 32, weight: .heavy, design: .default))
                        .kerning(0.3)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.22), radius: 8, y: 3)
                        .scaleEffect(popped ? 1.0 : 0.92)
                        .scaleEffect(breathe ? 1.015 : 0.985)
                        .offset(y: breathe ? -y : y)
                        .opacity(popped ? 1 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.8), value: popped)
                        .animation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: breathe)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .compositingGroup()
        .opacity(fadeOut ? 0 : 1)
        .onAppear {
            popped = true
            breathe = true
            
            Task {
                try? await Task.sleep(nanoseconds: UInt64(minShowSeconds * 1_000_000_000))
                await MainActor.run {
                    withAnimation(.easeOut(duration: fadeOutSeconds)) {
                        fadeOut = true
                    }
                }
                try? await Task.sleep(nanoseconds: UInt64(fadeOutSeconds * 1_000_000_000))
                isPresented = false
            }
        }
    }
}
