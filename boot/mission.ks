CORE:DOEVENT("open terminal").
wait until SHIP:UNPACKED and SHIP:LOADED.

if HOMECONNECTION:ISCONNECTED {
  COPYPATH("0:/lib/mission.ks", "1:/lib/mission.ks").
  COPYPATH("0:/lib/templating.ks", "1:/lib/templating.ks").
}

RUNPATH("1:/lib/templating.ks").
RUNPATH("1:/lib/mission.ks").
