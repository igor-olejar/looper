OscRecv recv;
8001 => recv.port;
recv.listen();

recv.event("/chooper/touchloop/0, f") @=> OscEvent oe;


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