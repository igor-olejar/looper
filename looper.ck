public class Sampleholder
{
    SndBuf buffy;
    string path;
    string sampleLocation;
    0 => int toLoop; // whether to loop the sample
    
    
    // initialise sound chain
    buffy => Gain dryGain => LPF filter => JCRev reverb => dac;
    dryGain => Gain wetGain => Delay delay => filter;
    delay => Gain feedbackGain => delay;
    
    // initialise the filter
    (20000.0, 1.0) => this.setFilter;
    
    fun void setSamplePath(string givenPath)
    {
        givenPath => path;
    }
    
    fun void setSample(string filename)
    {
        path + "/" + filename => sampleLocation;
        
        sampleLocation => buffy.read;
        
        this.setPositionToEnd();
    }
    
    fun void setLoop(int givenLoop)
    {
        givenLoop != 0 => toLoop;
        
        toLoop => buffy.loop;
    }
    
    fun void setPositionToStart()
    {
        0 => buffy.pos;
    }
    
    fun void setPositionToEnd()
    {
        buffy.samples() => buffy.pos;
    }
    
    fun dur getSampleLength()
    {
        return buffy.length();
    }
    
    fun void setReverbMix(float reverbMix)
    {
        reverbMix => reverb.mix;
    }
    
    fun void setGain(float givenGain) 
    {   
        givenGain => dryGain.gain;
    }
    
    fun void setPlayRate(dur bar)
    {
        Math.round(this.getSampleLength()/bar)::bar => dur proposedLength;
        proposedLength / this.getSampleLength() => float newRate;
        newRate => buffy.rate;
    }
    
    fun void setDelayMax(dur bar)
    {
        bar => delay.max;
    }
    
    fun void setDelayTime(dur delayTime)
    {
        0.5::delayTime => delay.delay;
    }
    
    fun void setFeedbackGain(float wGain, float fGain)
    {
        wGain => wetGain.gain;
        fGain => feedbackGain.gain;
    }
    
    fun void setFilter(float frequency, float qvalue)
    {
        (frequency, qvalue) => filter.set;
    }
}

120.0 => float BPM;
4 => int signature;
60.0 / BPM => float crotchet; //float representing the number of seconds that a crotched lasts
crotchet::second => dur cr;
signature::cr => dur bar;

// array of files to load
[
[me.dir(-5) + "/Samples/DISCRETEENERGYII[SAMPLE PACK]/SYNTHS", "152bpm_UO_BELLS_C.wav"],
[me.dir(-5) + "/Samples/DISCRETE ENERGY [SAMPLE PACK]/DRUM LOOPS", "76_IN_DRUMLOOP.wav"]
] @=> string files[][];

// create instances of Sampleholder
Sampleholder s[files.cap()];

// load the files
for (0 => int i; i < files.cap(); i++) {
    files[i][0] => s[i].setSamplePath;
    files[i][1] => s[i].setSample;
}

// initialize delay
for (0 => int i; i < files.cap(); i++) {
    bar => s[i].setDelayMax;
    cr => s[i].setDelayTime;
    (0, 0) => s[i].setFeedbackGain;
}

1 => s[0].setLoop;
1 => s[1].setLoop;
s[0].setPositionToStart();
s[1].setPositionToStart();
bar => s[0].setPlayRate;
bar => s[1].setPlayRate;

0.3 => s[0].setGain;
0.6 => s[1].setGain;
0.02 => s[1].setReverbMix;

(0.6, 0.2) => s[0].setFeedbackGain;

// put drums through filter
(150.0, 1.0) => s[1].setFilter;


while (true) {
    bar => now;
}