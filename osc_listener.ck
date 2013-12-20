OscRecv recv;
8001 => recv.port;
recv.listen();

recv.event("/1/playloop1, f") @=> OscEvent @ oe;

while (true)
{
    oe => now;
    
    while (oe.nextMsg())
    {
        float f;
        
        oe.getFloat() => f;
        
        <<< f >>>;
    }
}