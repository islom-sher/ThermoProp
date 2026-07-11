//
//  SettingsDataModel.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/15/26.
//

import UIKit

enum SettingsAccessoryType {
    case chevron(value: String?)  
    case toggle(isOn: Bool)
    case segment(options: [String])
    case externalLink
    case none
}

enum SettingsIcon {
    case symbol(String)
    case text(String)
}

struct SettingsItem {
    let title: String
    let subtitle: String?
    let icon: SettingsIcon
    let iconColor: UIColor
    let accessory: SettingsAccessoryType
}

struct SettingsSection {
    let title: String?
    let items: [SettingsItem]
}
