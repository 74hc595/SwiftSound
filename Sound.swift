//
//  Sound.swift
//  SwiftSound
//
//  Created by Matt Sarnoff on 6/11/14.
//  Copyright (c) 2014 Matt Sarnoff. All rights reserved.
//

import Cocoa

// Converts a UInt32 to 4 little-endian bytes
func b1(n:UInt32) -> UInt8 { return UInt8(n & 0xFF) }
func b2(n:UInt32) -> UInt8 { return UInt8((n>>8) & 0xFF) }
func b3(n:UInt32) -> UInt8 { return UInt8((n>>16) & 0xFF) }
func b4(n:UInt32) -> UInt8 { return UInt8((n>>24) & 0xFF) }


extension Node {
    
    func toWAV(sampleRate:Rate, duration:Duration) -> NSData {
        return stream(sampleRate, duration: duration).toWAV()
    }
    
    func toWAV(duration:Duration) -> NSData {
        return stream(44100.Hz, duration: duration).toWAV()
    }
    
    func toSound(sampleRate:Rate, duration:Duration) -> NSSound {
        return NSSound(data: toWAV(sampleRate, duration: duration))
    }

    func toSound(duration:Duration) -> NSSound {
        return NSSound(data: toWAV(duration))
    }
    
    func play(sampleRate:Rate, duration:Duration) {
        toSound(sampleRate, duration: duration).play()
    }
    
    func play(duration:Duration) {
        toSound(duration).play()
    }
}


extension SampleSequence {
    func toWAV() -> NSData {
        let bps:UInt8 = 2                               // bytes per sample
        var sr:UInt32 = UInt32(sampleRate.value)        // sample rate
        let br:UInt32 = sr*UInt32(bps)                  // byte rate
        
        let header:UInt8[] = [
            0x52, 0x49, 0x46, 0x46,     // "RIFF"
            0,0,0,0,                    // chunk size (to be filled in)
            0x57, 0x41, 0x56, 0x45,     // "WAVE"
            0x66, 0x6d, 0x74, 0x20,     // subchunk ID ("fmt ")
            0x10, 0x00, 0x00, 0x00,     // subchunk size (16 bytes)
            0x01, 0x00,                 // format (1=PCM)
            0x01, 0x00,                 // number of channels (mono)
            b1(sr),b2(sr),b3(sr),b4(sr),// sample rate
            b1(br),b2(br),b3(br),b4(br),// byte rate
            bps, 0x00,                  // block align
            bps*8, 0x00,                // bits per sample
            0x64, 0x61, 0x74, 0x61,     // subchunk ID ("data")
            0,0,0,0                     // data subchunk size (to be filled in)
        ]

        var data = NSMutableData(bytes: header, length: header.count)
        var dataSize:UInt32 = 0
        for sample in self {
            var intSample:Int16 = 0
            if sample <= -1.0 {
                intSample = Int16.min
            } else if sample >= 1.0 {
                intSample = Int16.max
            } else {
                intSample = Int16(sample*Double(Int16.max))
            }
            data.appendBytes(&intSample, length:2)
            dataSize += 2
        }
        
        // plug in the computed sizes
        var chunkSize:UInt32 = dataSize+36
        data.replaceBytesInRange(NSMakeRange(4, 4), withBytes: &chunkSize)
        data.replaceBytesInRange(NSMakeRange(40, 4), withBytes: &dataSize)
        
        return data
    }
    
    func play() {
        NSSound(data: toWAV()).play()
    }
}
