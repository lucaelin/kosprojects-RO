wait until SHIP:UNPACKED and SHIP:LOADED.
CORE:DOEVENT("open terminal").

print "Press any key to continue...".
wait until TERMINAL:INPUT:HASCHAR().
TERMINAL:INPUT:GETCHAR().

runpath("0:/basics/"+SHIPNAME+".ks").
