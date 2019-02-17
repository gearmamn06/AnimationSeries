//
//  AnimListItemCell.swift
//  AnimationSeries-Demo
//
//  Created by ParkHyunsoo on 17/02/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import AnimationSeries

protocol SelfNamable {}
extension SelfNamable {
    var name: String {
        return String(describing: type(of: self))
    }
    static var name: String {
        return String(describing: self)
    }
}

extension UIView {
    func blink(duration: TimeInterval) -> RecursionSeries {
        let anim = disappear(duration: duration) + appear(duration: duration)
        return anim
    }
}

//typealias Animation = (UIView)

enum AnimationExampleType: String, CaseIterable {
    case none = ""
    case blink = "Blink"
    case color = "Color changing"
    case translate = "Move Position"
    case sizing = "Scale"
    case rotate = "Angle"
    case serial = "Serial"
    case all = "All"
    
    var detai: String {
        switch self {
        case .blink:
            return ": (normal * 6 > fast * 12 > slow * 3) * 3"
            
        case .color:
            return ": (red > orange > yellow > green > blue > purple) * 3"
            
        case .translate:
            return ": (bottom > right > top > left) * 3"
            
        case .sizing:
            return ": (x1.5 > x0.7 > x2.2 > x0.1 > x1.0) * 3"
            
        case .rotate:
            return ": (-30º > 30º > -90º > 90º -> 0º) * 3"
            
        case .serial:
            return ": blink > color > move > scale > angle"
            
        case .all:
            return ": start at once"
            
        default: return ""
        }
    }
    
    var animate: (UIView) -> [Recursable] {
        switch self {
        case .blink:
            return { view in
                let anim = view.blink(duration: 0.1) * 6 + view.blink(duration: 0.05) * 12 + view.blink(duration: 0.2) * 3
                return  [anim * 3]
            }
            
        case .color:
            return { view in
                let anim = view.discolor(to: .orange, duration: 1) + view.discolor(to: .yellow, duration: 1) + view.discolor(to: .green, duration: 1) + view.discolor(to: .blue, duration: 1) + view.discolor(to: .purple, duration: 1)
                return [anim * 3]
            }
            
        case .translate:
            return { view in
                let len = view.frame.width * 2
                let anim = view.move(position: CGPoint(x: 0, y: len), duration: 0.5) + view.move(position: CGPoint(x: len, y: 0), duration: 0.5) + view.move(position: CGPoint(x: 0, y: -len), duration: 0.5) + view.move(position: CGPoint(x: -len, y: 0), duration: 0.5) + view.move(position: .zero, duration: 1)
                return [anim * 3]
            }
            
        case .sizing:
            return  { view in
                let anim = view.sizing(scale: (1.5, 1.5), duration: 0.2) + view.sizing(scale: (0.7, 0.7), duration: 0.3) + view.sizing(scale: (2.2, 2.2), duration: 0.5) + view.sizing(scale: (0.1, 0.1), duration: 0.3) + view.sizing(scale: (1.0, 1.0), duration: 1)
                return [anim * 3]
            }
            
        case .rotate:
            return { view in
                let anim = view.rotate(degree: -30, duration: 0.2) + view.rotate(degree: 30, duration: 0.2) + view.rotate(degree: -90, duration: 0.18) + view.rotate(degree: 90, duration: 0.18) + view.rotate(degree: 0, duration: 0.5)
                return [anim * 3]
            }
            
        case .all:
            return { view in
                return [AnimationExampleType.blink.animate(view), AnimationExampleType.color.animate(view), AnimationExampleType.translate.animate(view), AnimationExampleType.sizing.animate(view), AnimationExampleType.rotate.animate(view)].flatMap{ $0 }
            }
            
        case .serial:
            return { view in
                return [AnimationExampleType.blink.animate(view).first! + AnimationExampleType.color.animate(view).first! + AnimationExampleType.translate.animate(view).first! + AnimationExampleType.sizing.animate(view).first! + AnimationExampleType.rotate.animate(view).first!]
                
            }
        case .none:
            return { view in
                return []
            }
        }
    }
}



class AnimListItemCell: UITableViewCell, SelfNamable {
    
    var type: AnimationExampleType = .none {
        didSet {
            self.textLabel?.text = type.rawValue
            self.detailTextLabel?.text = type.detai
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: AnimListItemCell.name)
        self.backgroundColor = UIColor.groupTableViewBackground
        self.textLabel?.textColor = UIColor.darkText
        self.textLabel?.font = UIFont.systemFont(ofSize: 14)
        self.detailTextLabel?.textColor = UIColor.darkGray
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
