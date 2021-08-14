//
//  Model.swift
//  figure8
//
//  Created by Nathan Stankevicius on 9/6/21.
//

import Foundation
import SwiftUI

let middlePosition = Position(x: Distance(value: 1.93, unit: .nauticalMiles), y: Distance(value: -1.07, unit: .nauticalMiles))

struct Position {
    var x:Distance
    var y:Distance
    var time = Date()
    var speedUpFactor:Double = 1
    
    static var zero:Position {
        return Position(x: Distance(value: 1.38, unit: .nauticalMiles), y: Distance(value: -0.21, unit: .nauticalMiles))
    }
    
    init(x:Distance,y:Distance) {
        self.x = x
        self.y = y
    }
    init(radial:Angle, range:Distance, fromPosition position:Position) {
        self.x = range * sin(radial) + position.x
        self.y = range * cos(radial) + position.y
    }
    var point:CGPoint {
        return CGPoint(x: x.converted(to: .meters).value, y: -y.converted(to: .meters).value)
    }
    
    func distanceTo(_ position:Position) -> Distance {
        let dist = sqrt(pow((self.x - position.x).value,2) + pow((self.y - position.y).value,2))
        return Distance(value: dist, unit: position.x.unit)
    }
}

func +(lhs:Position, rhs:Position) -> Position {
    return Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
func +=(lhs:inout Position, rhs:Position) {
    lhs = lhs + rhs
}

class Model: ObservableObject {
    static let shared = Model()
    var speedUpFactor = 1.0
    
    var positions:[Position] {
        return _positions
    }
    @Published var _positions = [Position]()
    
    func _currentPosition() -> Position {
        return _positions.last ?? Position.zero
    }
    
    func clearPositions() {
        _positions = [_positions.last!]
    }
    
    func resetPositions() {
        _positions = []
    }
    
    func restorePosition() {
        resetPositions()
        position = Position(radial: Angle(value: track - Double.pi/2, unit: .radians), range: Distance(value: 1.7/2.0, unit: .nauticalMiles), fromPosition: middlePosition)
    }
    
    var position:Position {
        get {
            return _positions.last ?? Position.zero
        }
        set {
            var position = newValue
            position.time = Date()
            _positions.append(position)
        }
    }
        
    let maxPositions = 2000
    
    func updatePosition() {
        let v = speed.converted(to: .metersPerSecond).value
        let g = 9.81
        let b = bank.radians
        var t = Date().timeIntervalSince(_currentPosition().time)*speedUpFactor
        if t > 3 * 60 {
            _positions = [Position.zero]
            t = 1
        }
        var phi = 0.0
        var s = 0.0
        
        guard v != 0 else {
            if _positions.count > 0 {
                _positions[_positions.count-1].time = Date()
            }
            return
        }
        if b != 0, v != 0 {
            phi = (t*g*tan(b)/v).truncatingRemainder(dividingBy: 2 * Double.pi)
            s = sqrt((2.0*pow(v*v/(g*tan(b)),2.0))*(1.0-cos(phi)))
        } else {
            s = v * t
        }
        let oldHeading = heading.radians + phi/2
        let h = (phi/2 + heading.radians)

        heading = Angle(value:phi + heading.radians, unit:.radians)
        let windSpeed = self.windSpeed.converted(to: .metersPerSecond).value
        let xComp = s * sin(h) + windSpeed * sin(windDirection) * t
        let yComp = s * cos(h) + windSpeed * cos(windDirection) * t
        track = atan2(xComp, yComp)
        var currentPos = Position(x: _currentPosition().x + Distance(value:xComp, unit:.meters), y: _currentPosition().y + Distance(value:yComp, unit:.meters))
        groundSpeed = Speed(value: pow(pow(windSpeed,2.0) + pow(v,2) - 2 * windSpeed * v * cos(Angle(value: oldHeading, unit:.radians) - windDirection + Angle(value: 180, unit: .degrees)),0.5), unit: .metersPerSecond)
         let groundSpeed2 = Speed(value: currentPos.distanceTo(_currentPosition()).converted(to: .nauticalMiles).value / Measurement<UnitDuration>(value: t, unit: .seconds).converted(to: .hours).value, unit: .knots)
        print((groundSpeed - groundSpeed2).converted(to: .knots))
        currentPos.speedUpFactor = speedUpFactor
        _positions.append(currentPos)
        if _positions.count > maxPositions {
            _positions.removeFirst(maxPositions/1000)
        }
    }
    
    var speed = Speed.zero { didSet { updatePosition() }}
    @Published var bank = Angle.zero
    var heading = Angle.zero
    var track = 0.0

    var windSpeed = Speed.zero { didSet { updatePosition() }}
    var windDirection = Angle.zero  { didSet { updatePosition() }}
    var groundSpeed = Speed.zero
    
    
    init() {
        speed = Measurement<UnitSpeed>(value: 240, unit: .knots)
        heading = Angle(value: 90, unit: .degrees)
        windSpeed = Speed(value: 0, unit: .metersPerSecond)
        _positions.reserveCapacity(10000)
    }
}

extension Measurement where UnitType:UnitAngle {
    var radians:Double {
        return (self as! Measurement<UnitAngle>).converted(to: .radians).value
    }
    var degrees:Double {
        return (self as! Measurement<UnitAngle>).converted(to: .degrees).value
    }
}


typealias Angle = Measurement<UnitAngle>
typealias Distance = Measurement<UnitLength>
typealias Speed = Measurement<UnitSpeed>

extension Measurement where UnitType:UnitAngle {
    static var zero:Angle {
        return Angle(value: 0, unit: .radians)
    }
    var degrees360Int:Int  {
        guard self is Angle else { return 0 }
        var degrees = (self as! Angle).converted(to: .degrees).value.rounded(.toNearestOrAwayFromZero).truncatingRemainder(dividingBy: 360)
        if degrees < 0 { degrees += 360 }
        return Int(degrees)
    }
    
    var degrees360minusInt: Int {
        guard self is Angle else { return 0 }
        let degrees = (self as! Angle).converted(to: .degrees).value.rounded(.toNearestOrAwayFromZero).truncatingRemainder(dividingBy: 360)
        return Int(degrees)
    }
    var degrees360:Double  {
        guard self is Angle else { return 0 }
        var degrees = (self as! Angle).converted(to: .degrees).value.truncatingRemainder(dividingBy: 360)
        if degrees < 0 { degrees += 360 }
        return (degrees)
    }
    
    var degrees360minus: Double {
        guard self is Angle else { return 0 }
        let degrees = (self as! Angle).converted(to: .degrees).value.truncatingRemainder(dividingBy: 360)
        return (degrees)
    }
}
extension Measurement where UnitType:UnitLength {
    static var zero:Distance {
        return Distance(value: 0, unit: .nauticalMiles)
    }
}
extension Measurement where UnitType:UnitSpeed {
    static var zero:Speed {
        return Speed(value: 0, unit: .knots)
    }
}

public func sin(_ angle:Measurement<UnitAngle>) -> Double {
    return sin(angle.radians)
}
public func cos(_ angle:Measurement<UnitAngle>) -> Double {
    return cos(angle.radians)
}
