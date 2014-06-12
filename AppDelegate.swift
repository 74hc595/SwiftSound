//
//  AppDelegate.swift
//  SwiftSound
//
//  Created by Matt Sarnoff on 6/12/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//
//  Experiments with simple sound synthesis in Swift.
//  Sounds are created by forming a graph of connected nodes,
//  which might generate waveforms or perform arithmetic.
//  Sound quality is not great and can be glitchy, and performance
//  is not great (yet).

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // --- Units --- //
        
        // Frequencies can be expressed using the suffixes Hz and kHz.
        println(440.Hz)
        println(1.2.kHz)
        
        // Durations can be expressed using the suffixes sec, msec, and min.
        println(5.sec)
        println(33.msec)
        println(3.min)
        
        // Compatible units can be compared.
        println(1000.Hz == 1.kHz)
        println(60.sec == 1.min)
        println(59.sec < 1.min)
        
        // Compatible units can be added and subtracted.
        println(50.Hz + 20.Hz)
        println(20.sec - 500.msec)
        
        // Units can be scaled by constants.
        println(100.Hz * 2)
        println(5 * 60.sec)
        println(10.min / 12)
        
        // Taking the reciprocal returns a quantity with the inverse unit.
        println(1/(10.Hz))
        println(1/(3.sec))
        
        // Multiplying inverse units returns a dimensionless quantity.
        println(5.Hz * 20.sec)
        
        // Attempting to work with incompatible units raises a compiler error.
        //println(50.Hz + 2.sec)
        
        
        
        // --- Waveforms --- //
        
        // Sine, sawtooth, and triangle wave oscillators can be constructed
        // using their frequency:
        let sine = SineWave(440.Hz)
        let saw = SawtoothWave(440.Hz)
        let tri = TriangleWave(440.Hz)
        
        // Pulse waves can be constructed using a frequency and duty cycle:
        let pulse = PulseWave(440.Hz, dutyCycle: 0.25)
        
        // The square wave is a special case of PulseWave with a duty cycle of 0.5.
        let sqr = SquareWave(440.Hz)
        
        // SineWave, SawtoothWave, TriangleWave, etc. are all instance of
        // the Node class.
        // A sound is comprised of a directed graph of nodes.
        // By specifying a sample rate and duration, a node can be exported to
        // WAV data, an NSSound, or played:
        println(sine.toWAV(22050.Hz, duration: 1.sec).length)
        println(saw.toSound(22050.Hz, duration: 1.sec))
        //tri.play(0.25.sec) // if sample rate is not specified, 44100 Hz is assumed
        
        // ArbitraryFunctionWave can be used to generate arbitrary periodic waveforms.
        // This example approximates a square wave using the first three terms of its
        // Fourier series.
        let approxSquare = { sin($0*2*M_PI) + sin($0*6*M_PI)/3 + sin($0*10*M_PI)/5 }
        let arbitraryWave = ArbitraryFunctionWave(440.Hz, function: approxSquare)

        
        
        // --- Composing nodes --- //
        
        // Oscillators output a signal with an amplitude ranging from -1 to +1.
        // Multiplying a node by a scalar adjusts its amplitude.
        let softerSqr = 0.25 * SquareWave(440.Hz)
        
        // Adding two or more nodes together produces a chord.
        let unison = 0.5*TriangleWave(440.Hz) + 0.5*SawtoothWave(440.Hz)
        let octave = SawtoothWave(440.Hz) + SawtoothWave(880.Hz)
        
        // Adding oscillators with slightly detuned pitches produces a
        // "coursing" effect.
        let supersaw = SawtoothWave(440.Hz) + SawtoothWave(439.Hz)
        
        // Multiplying two oscillators produces amplitude modulation.
        let ampMod = SawtoothWave(440.Hz) * SawtoothWave(2.Hz)
        
        // Using an oscillator to specify frequency produces frequency modulation.
        let freqMod = SawtoothWave(440.Hz + 100*SineWave(1.Hz))
        
        
        
        // --- Noise --- //
        
        // A noise generator produces a continuous stream of random numbers in
        // the range (-1, +1).
        // Sample-and-hold can be used to create pitched noise.
        let eightBitNoise = SampleAndHold(500.Hz, input: Noise())
        
        // This can be applied to the frequency input of an oscillator to produce
        // random tones:
        let beepsAndBoops = SquareWave(440.Hz + 100*SampleAndHold(10.Hz, input: Noise()))
        
        
        
        // --- Notes --- //
        
        // Instead of using absolute frequencies in hertz, pitches can be specified by
        // note name and octave number.
        let middleC:Rate = C-4
        println("Middle C is \(middleC)")
        let a440 = SineWave(A-4)
        
        // The + operator between a note and and octave number creates sharps.
        // It would be great if Swift allowed you to use the # character in operators...
        let cSharp = C+4
        
        // Intervals can be specified with various suffixes and added to (or subtracted
        // from) notes.
        let fifth = 7.semitones
        let upAFifth = C-4 + fifth
        let upAnOctave = C-4 + 1.octave
        let bFlat = C-4 - 1.semitone
        
        // There are a few convenience functions for transposition.
        let cSharp5 = sharp(C-5)
        let dNatural5 = sharp(C+5)
        let dSharp5 = flat(E-5)
        let c6 = octaveUp(C-5)
        let e3 = octaveDown(E-4)
        
        // This makes it easy to play chords.
        let cMajor = SineWave(C-4) + SineWave(E-4) + SineWave(G-4)
        let majorSeventhChord = { SineWave($0)+SineWave($0+4.semitones)+SineWave($0+7.semitones)+SineWave($0+11.semitones) }
        let cMaj7 = majorSeventhChord(C-4)
        
        // As oscillators are added together, it's a good idea to scale down the sum to avoid clipping.
        //(cMaj7*0.25).play(1.sec)
        
        
        
        // --- Sequences --- //
        
        // A piecewise generator can be used as a custom oscillator.
        let loFiTriangle = Piecewise(C-4, values: [0, 0.5, 1, 0.5, 0, -0.5, -1, -0.5])
        
        // A piecewise generator can also be used to play an arpeggio by
        // plugging it into the frequency input of an oscillator.
        let arp = SquareWave(Piecewise(2.Hz, values: [C-4, E-4, G-4]))
        
        // The speed of a piecewise generator can also be specified by passing
        // the desired duration of one iteration.
        let fastArp = SquareWave(Piecewise(0.1.sec, values: [C-4, E-4, G-4]))
        
        // A piecewise linear generator interpolates smoothly between values.
        let wavy = SquareWave(PiecewiseLinear(0.5.sec, values: [C-4, E-4, E-3, C-5]))
        
        // A familiar tune.
        let organ = { 0.4*(sin($0*2*M_PI) + sin($0*4*M_PI) + sin($0*8*M_PI)) }
        let notes:Scalar[] = [
            E-5, D-5, F+4, F+4, G+4, G+4,
            C+5, B-4, D-4, D-4, E-4, E-4,
            B-4, A-4, C+4, C+4, E-4, E-4,
            A-4, A-4, A-4, A-4, A-4, A-4
        ]
        let harmony:Scalar[] = [B-2, E-3, A-2, A-2]
        let tune = 0.5*ArbitraryFunctionWave(Piecewise(3.sec, values:notes), function:organ) +
            0.25*ArbitraryFunctionWave(Piecewise(3.sec, values:harmony), function:approxSquare)
        tune.play(3.sec)
    }
}

