//
//  Triangle.swift
//  AiBuddy
//
//  Created by Steven Sullivan on 10/16/23.
//

import SwiftUI

struct Triangle: Shape {
    var direction: TriangleDirection
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startPoint = CGPoint(x: rect.width * direction.startPoint.x, y: rect.height * direction.startPoint.y)
        let midPoint = CGPoint(x: rect.width * direction.middlePoint.x, y: rect.height * direction.middlePoint.y)
        let endPoint = CGPoint(x: rect.width * direction.endPoint.x, y: rect.height * direction.endPoint.y)
        
        path.move(to: startPoint)
        path.addLine(to: midPoint)
        path.addLine(to: endPoint)
        path.closeSubpath()
        
        return path
    }
}

enum TriangleDirection {
    case north, northeast, east, southeast, south, southwest, west, northwest
    
    var startPoint: CGPoint {
        switch self {
        case .north: return CGPoint(x: 0.5, y: 0)
        case .northeast: return CGPoint(x: 1, y: 0)
        case .east: return CGPoint(x: 1, y: 0.5)
        case .southeast: return CGPoint(x: 1, y: 1)
        case .south: return CGPoint(x: 0.5, y: 1)
        case .southwest: return CGPoint(x: 0, y: 1)
        case .west: return CGPoint(x: 0, y: 0.5)
        case .northwest: return CGPoint(x: 0, y: 0)
        }
    }
    
    var middlePoint: CGPoint {
        return CGPoint(x: 0.5, y: -0.5)
    }
    
    var endPoint: CGPoint {
        return CGPoint(x: 0.5, y: 0.5)
    }
}
