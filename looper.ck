me.dir(-5) + "/Samples/DISCRETEENERGYII[SAMPLE PACK]/SYNTHS/152bpm_UO_BELLS_C.wav" => string filename;

SndBuf buffy => dac;

1 => buffy.chunks;
filename => buffy.read;

buffy.samples() => buffy.pos;

0 => buffy.pos;
//1 => buffy.loop;

while (true) {
	//0.2 => buffy.freq;
	buffy.length() => now;
}
<<< buffy.length() >>>;
