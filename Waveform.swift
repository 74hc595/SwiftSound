//
//  Waveform.swift
//  SwiftSound
//
//  Created by Matt Sarnoff on 6/11/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

import Foundation

class Waveform : Node {
    var frequency:Node
    var phase:Double
    
    // TODO: I don't understand constructors well yet...
    // How can I have a Node initializer and a Rate initializer
    // that share common code?
    init(_ freq:Node) {
        frequency = freq
        phase = 0
        super.init()
        childNodes = [frequency]
    }
    
    init(_ freq:Rate) {
        frequency = Constant(freq)
        phase = 0
        super.init()
        childNodes = [frequency]
    }
    
    override func resetState() {
        phase = 0
    }
    
    override func nextSample(sampleRate: Rate) -> Double? {
        if let freq = frequency.output {
            let period = freq/sampleRate
            if let amp = phaseToAmplitude(phase) {
                phase = (phase + period.value) % 1.0
                return amp
            }
        }
        return nil
    }
    
    // to be overridden
    func phaseToAmplitude(phase:Double)->Double? { return 0 }
}


class SawtoothWave : Waveform {
    override func phaseToAmplitude(phase: Double) -> Double? {
        return 2*(1-phase)-1
    }
}


class PulseWave : Waveform {
    var dutyCycle:Node
    
    // TODO: there must be a way to avoid all this repetition
    init(_ freq:Node, dutyCycle:Node) {
        self.dutyCycle = dutyCycle
        super.init(freq)
        childNodes = [frequency,dutyCycle]
    }

    init(_ freq:Node, dutyCycle:Double) {
        self.dutyCycle = Constant(dutyCycle)
        super.init(freq)
        childNodes = [frequency,self.dutyCycle]
    }
    
    init(_ freq:Rate, dutyCycle:Node) {
        self.dutyCycle = dutyCycle
        super.init(freq)
        childNodes = [frequency,dutyCycle]
    }
    
    init(_ freq:Rate, dutyCycle:Double) {
        self.dutyCycle = Constant(dutyCycle)
        super.init(freq)
        childNodes = [frequency,self.dutyCycle]
    }
    
    override func phaseToAmplitude(phase: Double) -> Double? {
        if let dc = dutyCycle.output {
            return (phase <= dc) ? 1.0 : -1.0
        } else {
            return nil
        }
    }
}


class SquareWave : PulseWave {
    init(_ freq:Node) {
        super.init(freq, dutyCycle: 0.5)
    }
    
    init (_ freq:Rate) {
        super.init(freq, dutyCycle: 0.5)
    }
}


class SineWave : Waveform {
    override func phaseToAmplitude(phase: Double) -> Double? {
        return sin(phase*2*M_PI)
    }
}


class TriangleWave : Waveform {
    override func phaseToAmplitude(phase: Double) -> Double? {
        return ((phase < 0.5) ? phase : (1-phase))*4 - 1
    }
}


class ArbitraryFunctionWave : Waveform {
    var function:(Double) -> Double
    
    init(_ freq:Node, function:(Double) -> Double) {
        self.function = function
        super.init(freq)
    }
    
    init(_ freq:Rate, function:(Double) -> Double) {
        self.function = function
        super.init(freq)
    }
    
    override func phaseToAmplitude(phase: Double) -> Double? {
        return function(phase)
    }
}


class Piecewise : Waveform {
    var values:Scalar[]
    
    init(_ freq:Node, values:Scalar[]) {
        self.values = values
        super.init(freq)
    }
    
    init(_ freq:Rate, values:Scalar[]) {
        self.values = values
        super.init(freq)
    }

    init(_ length:Duration, values:Scalar[]) {
        self.values = values
        super.init(1/length)
    }
    
    override func phaseToAmplitude(phase: Double) -> Double? {
        let pieceIndex = Int(phase*Double(values.count))
        return values[pieceIndex].value
    }
}


class PiecewiseLinear : Piecewise {
    override func phaseToAmplitude(phase: Double) -> Double? {
        let index = phase*Double(values.count)
        let pieceIndex = Int(index)
        let nextPieceIndex = (pieceIndex+1) % values.count
        let a = values[pieceIndex].value
        let b = values[nextPieceIndex].value
        return a + (index % 1.0)*(b-a)
    }
}


class SampleAndHold : Waveform {
    var input:Node
    var heldValue:Double
    
    init(_ freq:Node, input:Node) {
        self.input = input
        heldValue = 0
        super.init(freq)
        childNodes = [frequency,input]
    }
    
    init(_ freq:Rate, input:Node) {
        self.input = input
        heldValue = 0
        super.init(freq)
        childNodes = [frequency,input]
    }
    
    override func nextSample(sampleRate: Rate) -> Double? {
        if let freq = frequency.output {
            let oldPhase = phase
            let period = freq/sampleRate
            phase = (phase + period.value) % 1.0
            
            // sample the input node when the phase wraps around
            if oldPhase > phase {
                if let inputSample = input.output {
                    heldValue = inputSample
                } else {
                    return nil
                }
            }
            return heldValue
        }
        return nil
    }
}
