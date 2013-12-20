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
    
    // initialise the filter, reverb mix, dry and wet gain
    (20000.0, 1.0) => this.setFilter;
    0.0 => this.setReverbMix;
    0.0 => this.setWetGain;
    0.0 => this.setFeedbackGain;
    0.16 => this.setGain;
    
    
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
    
    fun void setWetGain(float wGain)
    {
        wGain => wetGain.gain;
    }
    
    fun void setFeedbackGain(float fGain)
    {
        fGain => feedbackGain.gain;
    }
    
    fun void setFilter(float frequency, float qvalue)
    {
        (frequency, qvalue) => filter.set;
    }
}

// OSC stuff
OscRecv recv;
8001 => recv.port;
recv.listen();

// define BPM
120.0 => float BPM;
4 => int signature;
60.0 / BPM => float crotchet; //float representing the number of seconds that a crotched lasts
crotchet::second => dur cr;
signature::cr => dur bar;

fun void touchSampleShred(int sampleIndex, Sampleholder sample)
{
    recv.event("/chooper/touchloop/" + sampleIndex + ", f") @=> OscEvent touchEvent;
    
    while (true)
    {
        //touchEvent => now;
        0.5::bar - (now % 0.5::bar) => now;
        
        while (touchEvent.nextMsg()) {
            touchEvent.getFloat() => float f;
            
            if (f > 0) {
                sample.setPositionToStart();
            } else {
                sample.setPositionToEnd();
            }
        }
    }
}

fun void loopSampleShred(int sampleIndex, Sampleholder sample)
{
    recv.event("/chooper/looploop/" + sampleIndex + ", f") @=> OscEvent loopEvent;
    
    while (true)
    {
        0.5::bar - (now % 0.5::bar) => now;
        
        while (loopEvent.nextMsg()) {
            loopEvent.getFloat() => float f;
            
            if (f > 0) {
                1 => sample.setLoop;
                sample.setPositionToStart();
            } else {
                0 => sample.setLoop;
                sample.setPositionToEnd;
            }
        }
    }
}

fun void volumeShred(int sampleIndex, Sampleholder sample)
{
    recv.event("/chooper/volume/" + sampleIndex + ", f") @=> OscEvent volumeEvent;
    
    while (true)
    {
        volumeEvent => now;
        
        while (volumeEvent.nextMsg()) {
            volumeEvent.getFloat() => float f;
            
            f => sample.setGain;
        }
    }
}

fun void reverbShred(int sampleIndex, Sampleholder sample)
{
    recv.event("/chooper/reverbmix/" + sampleIndex + ", f") @=> OscEvent reverbEvent;
    
    while (true)
    {
        reverbEvent => now;
        
        while (reverbEvent.nextMsg()) {
            reverbEvent.getFloat() => float f;
            
            f => sample.setReverbMix;
        }
    }
}

fun void delayWetMixShred(int sampleIndex, Sampleholder sample)
{
    recv.event("/chooper/delayvolume/" + sampleIndex + ", f") @=> OscEvent wetEvent;
    
    while (true) {
        wetEvent => now;
        
        while (wetEvent.nextMsg()) {
            wetEvent.getFloat() => float f;
            f => sample.setWetGain;
        }
    }
}

fun void delayFeedbackShred(int sampleIndex, Sampleholder sample)
{
    recv.event("/chooper/feedbackvolume/" + sampleIndex + ", f") @=> OscEvent feedbackEvent;
    
    while (true) {
        feedbackEvent => now;
        
        while (feedbackEvent.nextMsg()) {
            feedbackEvent.getFloat() => float f;
            f => sample.setFeedbackGain;
        }
    }
}

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

// initialize delay and set play rates
for (0 => int i; i < files.cap(); i++) {
    bar => s[i].setDelayMax;
    cr => s[i].setDelayTime;
    bar => s[i].setPlayRate;
}

// spork 'em all
for (0 => int i; i < files.cap(); i++) {
    spork ~ touchSampleShred(i, s[i]);
    spork ~ loopSampleShred(i, s[i]);
    spork ~ volumeShred(i, s[i]);
    spork ~ reverbShred(i, s[i]);
    spork ~ delayWetMixShred(i, s[i]);
    spork ~ delayFeedbackShred(i, s[i]);
}

while (true) 
{
    bar => now;
}
