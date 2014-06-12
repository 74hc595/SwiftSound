//
//  Note.swift
//  SwiftSound
//
//  Created by Matt Sarnoff on 6/11/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

import Foundation

struct Note {
    var baseFrequency:Rate
}

// Define the frequencies of each note in the major scale in octave 0.
// A Note cannot be used for anything on its own; it must be combined with
// an octave number (using the - or + operators declared below)
// to produce a Rate.
let C = Note(baseFrequency: 16.3515978312874.Hz)
let D = Note(baseFrequency: 18.354047994838.Hz)
let E = Note(baseFrequency: 20.6017223070544.Hz)
let F = Note(baseFrequency: 21.8267644645627.Hz)
let G = Note(baseFrequency: 24.4997147488593.Hz)
let A = Note(baseFrequency: 27.5000000000000.Hz)
let B = Note(baseFrequency: 30.8677063285078.Hz)

struct IntervalBase: UnitBase { static var unitLabel = "semitones" }
typealias Interval = Unit<IntervalBase,IntervalBase>

extension Double {
    var semitones:Interval  { return Interval(self) }
    var semitone:Interval   { return self.semitones }
    var octaves:Interval    { return Interval(self*12) }
    var octave:Interval     { return self.octaves }
}

// Override - and + to get convenient syntax for note names,
// e.g. C-4, C+4, D-5, etc.
func -(note:Note, octave:Double) -> Rate { return note.baseFrequency + octave.octaves }
func +(note:Note, octave:Double) -> Rate { return note.baseFrequency + 1.semitone + octave.octaves }


// Transposition
func + (n:Rate, i:Interval) -> Rate         { return Rate(n.value * pow(2, i.value/12.0)) }
func - (n:Rate, i:Interval) -> Rate         { return n + (-i) }
@prefix func - (i:Interval) -> Interval     { return Interval(-i.value) }

// Sharp/flat
func sharp(note:Rate) -> Rate       { return note + 1.semitone }
func flat(note:Rate) -> Rate        { return note - 1.semitone }
func octaveUp(note:Rate) -> Rate    { return note + 1.octave }
func octaveDown(note:Rate) -> Rate  { return note - 1.octave }
