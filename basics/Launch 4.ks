runpath("0:/basics/lib/telemetry.ks").

SAS on.
lock THROTTLE to 1.

startTelemetryLogging(4).

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

wait 60 + 1.
print "5 moar seconds...".
wait 5.
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
