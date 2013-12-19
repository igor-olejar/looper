public class Sampleholder
{
    SndBuf buffy;
    string path;
    string sampleLocation;
    int toLoop; // whether to loop the sample
    
    // initialise
    buffy => JCRev reverb => Gain g => dac;
    
    fun void setSamplePath(string givenPath)
    {
        givenPath => path;
    }
    
    fun void setSample(string filename)
    {
        path + "/" + filename => sampleLocation;
        
        sampleLocation => buffy.read;
        
        buffy.samples() => buffy.pos;
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
        givenGain => g.gain;
    }
    
    fun void setPlayRate(dur bar)
    {
        Math.round(this.getSampleLength()/bar)::bar => dur proposedLength;
        proposedLength / this.getSampleLength() => buffy.rate;
    }
}

60.0 => float BPM;
4 => int signature;
60.0 / BPM => float crotchet; //float representing the number of seconds that a crotched lasts
crotchet::second => dur cr;
signature::cr => dur bar;

Sampleholder s;

me.dir(-5) + "/Samples/DISCRETEENERGYII[SAMPLE PACK]/SYNTHS" => s.setSamplePath;
"152bpm_UO_BELLS_C.wav" => s.setSample;

1 => s.setLoop;
s.setPositionToStart();
bar => s.setPlayRate;


while (true) {
    bar => now;
}