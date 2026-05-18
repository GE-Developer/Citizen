//
//  Color + Ext.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

extension Color {
    static let citizen = CitizenColor()
}

struct CitizenColor {
    let background = Color("Background")
    let blackAndWhite = Color("Black And White")
    let whiteAndBlack = Color("White And Black")
    let groupBackground = Color("Group Background")
    let secondaryText = Color("Secondary Text")
    let accentDark = Color("Accent Dark")
    let accentLight = Color("Accent Georgian")
    let goldLight = Color("Gold Light")
    let goldDark = Color("Gold Dark")
    let grayLight = Color("Gray Light")
    let grayDark = Color("Gray Dark")
    let navBarShadow = Color("NavBar Shadow")
    let viewShadow = Color("View Shadow")
    let textFieldBackground = Color("Text Field Background")
    let mainText = Color("Main Text")
    let greenDark = Color("Green Dark")
    let greenLight = Color("Green Light")
    let yellowLight = Color("Yellow Light")
    let yellowDark = Color("Yellow Dark")
    let redLight = Color("Red Light")
    let redDark = Color("Red Dark")
    let payWallAccentDark = Color("PayWallAccentDark")
    let payWallAccentLight = Color("PayWallAccentLight")
    
    func progress(_ progress: Double) -> Color {
        if progress == 1    { return greenLight }
        if progress > 0.3   { return yellowLight }
        if progress > 0     { return redLight }
        return secondaryText
    }

    func phase(_ phase: TopicPhase) -> Color {
        switch phase {
        case .completed:         greenLight
        case .inProgress:        yellowLight
        case .workingOnMistakes: redLight
        case .notStarted:        secondaryText
        }
    }
}
