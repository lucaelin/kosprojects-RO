SAS on.
lock THROTTLE to 1.

wait 1.
print "3...".
wait 1.
print "2..".
wait 1.
print "1.".
wait 1.
print "GO!".

stage.
wait 0.8.
print "Booster burnout.".
stage.

when ALTITUDE > 141000 then {
  toggle AG1.
  toggle AG3.
}

when ALTITUDE > 1000 then {
  toggle AG3.
}

when ALTITUDE > 10000 then {
  toggle AG3.
}

when ALTITUDE > 50000 then {
  toggle AG3.
}

when ALTITUDE > 102000 then {
  toggle AG3.
}


wait 60.
print "5 moar seconds...".
wait 6.
print "Stage sep.".
stage.
wait until stage:ready.
wait 0.1.
print "Stage sep.".
stage.
wait 2.
print "Ignition.".
stage.

when ALTITUDE > 1000 then {
  when VERTICALSPEED < 0 then {
    print "Releasing payload.".
    stage.
    when ALT:RADAR < 4000 then {
      toggle AG2.
    }
  }
}

wait until false.
