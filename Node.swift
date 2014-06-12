//
//  Node.swift
//  SwiftSound
//
//  Created by Matt Sarnoff on 6/11/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

import Foundation

class Node {
    var output:Double? = nil
    var sequenceNumber:UInt64 = 0
    var childNodes:Node[] = []
    
    @final func reset() {
        sequenceNumber = 0
        resetState()
        for childNode in childNodes {
            childNode.reset()
        }
    }
    
    @final func advance(sampleRate:Rate) {
        // If a node is the child of one or more nodes,
        // make sure it's only advanced one time when the root node is advanced.
        for childNode in childNodes {
            if childNode.sequenceNumber == sequenceNumber {
                // Recursively advances the child nodes of childNode and
                // increments its sequence number so it cannot be advanced twice
                childNode.advance(sampleRate)
            }
        }
        sequenceNumber++
        output = nextSample(sampleRate)
    }
    
    @final func stream(sampleRate:Rate, duration:Duration) -> SampleSequence {
        return SampleSequence(node: self, sampleRate: sampleRate, duration: duration)
    }
    
    // to be overridden
    func nextSample(sampleRate:Rate) -> Double? {
        return nil
    }
    
    // to be overridden
    func resetState() {
    }
}


struct SampleSequence : Sequence {
    var node:Node
    var sampleRate:Rate
    var duration:Duration

    init(node:Node, sampleRate:Rate, duration:Duration) {
        self.node = node
        self.sampleRate = sampleRate
        self.duration = duration
    }
    
    typealias GeneratorType = SampleGenerator
    func generate() -> GeneratorType {
        return SampleGenerator(node:node, sampleRate: sampleRate, duration: duration)
    }
}


struct SampleGenerator : Generator {
    typealias Element = Double
    var node:Node
    var sampleRate:Rate
    var samplesLeft:Int
    init(node:Node, sampleRate:Rate, duration:Duration) {
        self.node = node
        self.sampleRate = sampleRate
        self.samplesLeft = Int(sampleRate * duration)
        node.reset()
    }

    mutating func next() -> Element?  {
        if samplesLeft == 0 {
            return nil
        }
        --samplesLeft
        node.advance(sampleRate)
        if let sample = node.output {
            return sample
        } else {
            return nil
        }
    }
}


class Constant : Node {
    var constant:Double
    init(_ c:Double) {
        constant = c
    }
    
    init<T,U>(_ c:Unit<T,U>) {
        constant = c.value
    }

    override func nextSample(sampleRate:Rate) -> Double? {
        return constant
    }
}


class Noise : Node {
    override func nextSample(sampleRate:Rate) -> Double? {
        return drand48()*2 - 1
    }
}

class Complement : Node {
    init(_ node:Node) {
        super.init()
        childNodes = [node]
    }
    
    override func nextSample(sampleRate:Rate) -> Double? {
        if let sample = childNodes[0].output {
            return -sample
        } else {
            return nil
        }
    }
}


class DyadicOperator : Node {
    init(_ node1:Node, _ node2:Node) {
        super.init()
        childNodes = [node1, node2]
    }
    
    func combine(s1:Double, _ s2:Double) -> Double { return 0 }
    
    override func nextSample(sampleRate: Rate) -> Double? {
        if let sample1 = childNodes[0].output {
            if let sample2 = childNodes[1].output {
                return combine(sample1, sample2)
            }
        }
        return nil
    }
}


class Sum : DyadicOperator {
    override func combine(s1:Double, _ s2:Double) -> Double { return s1 + s2 }
}


class Product : DyadicOperator {
    override func combine(s1:Double, _ s2:Double) -> Double { return s1 * s2 }
}


func + (n1:Node, n2:Node) -> Node           { return Sum(n1, n2) }
func + (c:Double, n2:Node) -> Node          { return Sum(Constant(c), n2) }
func + <T,U>(c:Unit<T,U>, n2:Node) -> Node  { return Sum(Constant(c.value), n2) }
func + (n1:Node, c:Double) -> Node          { return Sum(n1, Constant(c)) }
func + <T,U>(n1:Node, c:Unit<T,U>) -> Node  { return Sum(n1, Constant(c.value)) }
func * (n1:Node, n2:Node) -> Node           { return Product(n1, n2) }
func * (c:Double, n2:Node) -> Node          { return Product(Constant(c), n2) }
func * <T,U>(c:Unit<T,U>, n2:Node) -> Node  { return Product(Constant(c.value), n2) }
func * (n1:Node, c:Double) -> Node          { return Product(n1, Constant(c)) }
func * <T,U>(n1:Node, c:Unit<T,U>) -> Node  { return Product(n1, Constant(c.value)) }
@prefix func - (n:Node) -> Node             { return Complement(n) }

