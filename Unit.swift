//
//  Unit.swift
//  SwiftSound
//
//  Created by Matt Sarnoff on 6/11/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

protocol UnitBase {
    class var unitLabel:String { get }
}

protocol Scalar {
    var value:Double { get }
}

extension Double : Scalar {
    var value:Double { return self }
}

// T: the unit
// U: its inverse
struct Unit<T:UnitBase,U:UnitBase> : Printable, Comparable, Scalar {
    var value:Double
    init(_ v:Double) { value = v }
    var description:String { return "\(value) \(T.unitLabel)" }
    var inverse:Unit<U,T> { return Unit<U,T>(1/value) }
}

func == <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Bool           { return lhs.value == rhs.value }
func <= <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Bool           { return lhs.value <= rhs.value }
func >= <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Bool           { return lhs.value >= rhs.value }
func <  <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Bool           { return lhs.value < rhs.value }
func >  <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Bool           { return lhs.value > rhs.value }
func +  <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Unit<T,U>      { return Unit<T,U>(lhs.value + rhs.value) }
func -  <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Unit<T,U>      { return Unit<T,U>(lhs.value - rhs.value) }
func *  <T,U>(lhs:Double, rhs:Unit<T,U>) -> Unit<T,U>         { return Unit<T,U>(lhs * rhs.value) }
func *  <T,U>(lhs:Unit<T,U>, rhs:Double) -> Unit<T,U>         { return Unit<T,U>(lhs.value * rhs) }
func *  <T,U>(lhs:Unit<T,U>, rhs:Unit<U,T>) -> Double         { return lhs.value * rhs.value }
func /  <T,U>(lhs:Double, rhs:Unit<T,U>) -> Unit<U,T>         { return lhs * rhs.inverse }
func /  <T,U>(lhs:Unit<T,U>, rhs:Double) -> Unit<T,U>         { return Unit<T,U>(lhs.value / rhs) }
func /  <T,U>(lhs:Unit<T,U>, rhs:Unit<T,U>) -> Double         { return lhs.value / rhs.value }
@assignment func += <T,U>(inout lhs:Unit<T,U>, rhs:Unit<T,U>) { lhs = lhs + rhs; }
@assignment func -= <T,U>(inout lhs:Unit<T,U>, rhs:Unit<T,U>) { lhs = lhs - rhs; }
@assignment func *= <T,U>(inout lhs:Unit<T,U>, rhs:Double)    { lhs = lhs * rhs; }
@assignment func /= <T,U>(inout lhs:Unit<T,U>, rhs:Double)    { lhs = lhs / rhs; }

struct RateBase: UnitBase { static var unitLabel = "Hz" }
struct DurationBase: UnitBase { static var unitLabel = "sec" }
typealias Rate = Unit<RateBase,DurationBase>
typealias Duration = Unit<DurationBase,RateBase>

extension Double {
    var Hz:Rate         { return Rate(self) }
    var kHz:Rate        { return Rate(self*1000) }
    var sec:Duration    { return Duration(self) }
    var msec:Duration   { return Duration(self*0.001) }
    var min:Duration    { return Duration(self*60) }
}
