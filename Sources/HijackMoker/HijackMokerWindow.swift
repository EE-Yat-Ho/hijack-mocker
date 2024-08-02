//
//  HijackMokerWindow.swift
//  HiJackMoker
//
//  Created by 영호 박 on 7/30/24.
//

import Foundation
import UIKit


public final class HijackMokerWindow: UIWindow {
    
    let blue = UIColor(red: 0, green: 123.0/255.0, blue: 247.0/255.0, alpha: 1).withAlphaComponent(0.5)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        drawSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let apiMokerSwitch = UISwitch(frame: .zero)
    
    public func drawSwitch() {
        apiMokerSwitch.thumbTintColor = blue
        apiMokerSwitch.onTintColor = blue
        
        apiMokerSwitch.translatesAutoresizingMaskIntoConstraints = false
        apiMokerSwitch.removeFromSuperview()
        addSubview(apiMokerSwitch)
        apiMokerSwitch.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        apiMokerSwitch.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        bringSubviewToFront(apiMokerSwitch)
        apiMokerSwitch.setOn(HijackMoekrIsOn, animated: false)
        apiMokerSwitch.addTarget(self, action: #selector(apiMokerSwitchDidChange), for: .valueChanged)
    }
    
    @objc func apiMokerSwitchDidChange() {
        HijackMoekrIsOn = apiMokerSwitch.isOn
    }
    
    public override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        bringSubviewToFront(apiMokerSwitch)
    }
    
}
