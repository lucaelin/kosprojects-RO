set CONFIG:IPU to 1000.
wait until SHIP:UNPACKED and SHIP:LOADED.
local ec is STAGE:RESOURCESLEX["ELECTRICCHARGE"].
if ec:AMOUNT <= ec:CAPACITY * 0.25 print "Waiting for ec to reach >25% of ec-capacity...".
wait until ec:AMOUNT >= ec:CAPACITY * 0.25.
KUNIVERSE:TIMEWARP:CANCELWARP().
CORE:DOEVENT("open terminal").
CLEARVECDRAWS().

if HOMECONNECTION:ISCONNECTED {
  COPYPATH("0:/lib/globals.ks", "1:/lib/globals.ks").
  COPYPATH("0:/lib/templating.ks", "1:/lib/templating.ks").
  COPYPATH("0:/lib/manifest.ks", "1:/lib/manifest.ks").
  COPYPATH("0:/lib/mission.ks", "1:/lib/mission.ks").
} else {
  if not EXISTS("1:/lib/mission.ks") {
    print "NO CONNECTION TO ARCHIVE! WARPING...".
    wait 3.
    set WARP to 2.
    wait until HOMECONNECTION:ISCONNECTED.
    KUNIVERSE:TIMEWARP:CANCELWARP().
    wait until KUNIVERSE:TIMEWARP:ISSETTLED.
    wait 1.
    reboot.
  }
}

RUNPATH("1:/lib/globals.ks").
RUNPATH("1:/lib/templating.ks").
RUNPATH("1:/lib/manifest.ks").
RUNPATH("1:/lib/mission.ks").
