//
//  DeviceSizing.swift
//  CoolProp_UIKit
//
//  Created by Islombek Sheraliev on 6/20/26.
//

import UIKit

func adaptiveSize(phone: CGFloat, pad: CGFloat) -> CGFloat {
    return UIDevice.isPad ? pad : phone
}



