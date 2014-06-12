SwiftSound
==========

Experiements with simple sound synthesis in Swift.

Sounds are created by instantiating nodes (which might generate waveforms,
perform arithmetic, etc.) and connecting them in a directed graph. Sound quality
is not great (there's noticeable aliasing and glitching), but the purpose of
this experiment is not exactly to create a world-class softsynth.

Examples
--------

See [AppDelegate.swift](AppDelegate.swift) for some simple examples.

The following creates a sine wave with a frequency of 440 Hz and an amplitude of
1:

```swift
var osc = SineWave(440.Hz)
```

Any node can be converted to WAV `NSData` or played for a given duration:
```swift
osc.toWAV(44100.Hz, duration: 2.sec).writeToURL(url, atomically: true)
osc.play(2.sec) // 44100 sample rate is implied if not specified
```

Musical notes can be referenced with a shorthand notation:
```swift
var middleC = SineWave(C-4)
var cSharp  = SineWave(C+4)
```

Chords can be created by adding oscillators together:
```swift
var cMajor = SineWave(C-4) + SineWave(E-4) + SineWave(G-4)
```

Multiplying an oscillator by a low-frequency oscillator produces amplitude
modulation.
```swift
var am = SawtoothWave(A-4) * TriangleWave(2.Hz)
```

Multiplying an oscillator by another audio-frequency oscillator produces ring
modulation.
```swift
var ringMod = SquareWave(A-2) * TriangleWave(700.Hz)
```

Using one oscillator as the frequency input of another produces frequency
modulation. (Also note that the amplitude of any node can be scaled by
multiplying it by a constant.)
```swift
var siren = TriangleWave(1000.Hz + 400*SineWave(1.Hz))
```

Notes can be transposed by semitones or octaves:
```swift
let majorSeventhChord = {
  SineWave($0) + 
  SineWave($0+4.semitones) + 
  SineWave($0+7.semitones) +
  SineWave($0+11.semitones)
}
let cMaj7 = majorSeventhChord(C-4)
```

The `Noise` node generates a constant stream of white noise. It can be
tuned/quantized using the `SampleAndHold` node.
```swift
let eightBitNoise = SampleAndHold(500.Hz, input: Noise())
let beepsAndBoops = SquareWave(440.Hz + 100*SampleAndHold(10.Hz, input: Noise()))
```

Piecewise nodes can be used to create custom waveforms and to play arpeggios and
tunes.
```swift
let loFiTriangle = Piecewise(C-4, values: [0, 0.5, 1, 0.5, 0, -0.5, -1, -0.5])
let arp = SquareWave(Piecewise(2.Hz, values: [C-4, E-4, G-4]))
```


Notes
-----

This is my first significant venture into Swift. I haven't learned all the idioms yet; feel free to submit a pull request correcting anything that looks weird.

I'm on Twitter: [@autorelease](https://twitter.com/autorelease)
