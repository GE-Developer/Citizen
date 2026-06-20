//
//  ProgressRing.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct ProgressRing: View {
    private let progress: Double
    private let subtitle: String?
    private let withPercent: Bool
    private let lineWidth: CGFloat
    
    private var progressColor: Color { .citizen.progress(progress) }
    private var progressGradient: LinearGradient { Gradient.progress(progress) }
    private var percentText: String { "\(Int(progress * 100))%" }
    
    init(
        progress: Double,
        subtitle: String? = nil,
        withPercent: Bool = true,
        lineWidth: CGFloat = 5
    ) {
        self.progress = progress
        self.subtitle = subtitle
        self.withPercent = withPercent
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        progressRing
    }
}

// MARK: - Builder
extension ProgressRing {
    private var progressRing: some View {
        ZStack {
            trackLine
            fillLine
            percentLabel
        }
    }
    
    private var trackLine: some View {
        Circle()
            .stroke(lineWidth: lineWidth)
            .fill(Color.citizen.groupBackground)
    }
    
    private var fillLine: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(style: .init(lineWidth: lineWidth, lineCap: .round))
            .fill(progressGradient)
            .rotationEffect(.degrees(-90))
    }
    
    private var percentLabel: some View {
        VStack {
            if withPercent {
                Text(percentText)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(subtitle == nil ? AnyShapeStyle(progressGradient) : AnyShapeStyle(Color.citizen.mainText))
            }
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(Color.citizen.secondaryText)
                    .tracking(1.5)
            }
        }
        .fontDesign(.rounded)
    }
}
