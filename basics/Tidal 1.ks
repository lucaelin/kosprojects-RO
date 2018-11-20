runpath("0:/basics/lib/telemetry.ks").

lock THROTTLE to 1.

local headingCompass is -3.

lock STEERING to LOOKDIRUP(HEADING(headingCompass, MAX(90 - 90*((ALTITUDE-90)/140000)^(1/2),0)):VECTOR, SHIP:FACING:TOPVECTOR).
when APOAPSIS > 250000 then {
  lock STEERING to HEADING(headingCompass, -7).
}

when ALTITUDE > 90000 then {
  toggle AG1.
}

startTelemetryLogging(7).

print "7.......".
wait 1.
print "6......".
wait 1.
print "5.....".
wait 1.
print "4....".
wait 1.

print "Engine ignition...".
stage.
print "3..".
wait 1.
print "2..".
wait 1.
print "1.".
wait 1.
print "0".
wait until SHIP:AVAILABLETHRUST > 0 and SHIP:AVAILABLETHRUST / SHIP:MASS > 10.
wait until stage:ready.
print "GO!".
stage.
local s0 is TIME:SECONDS.

when TIME:SECONDS > s0 + 80 then {
  print "Preparing stage sep...".
  lock STEERING to LOOKDIRUP(SRFPROGRADE:VECTOR, SHIP:FACING:TOPVECTOR).
}

when TIME:SECONDS > s0 + 180 then {
  print "Preparing stage sep...".
  unlock steering.
  set SHIP:CONTROL:ROLL to 0.2.
}

wait until SHIP:AVAILABLETHRUST = 0.

print "Stage sep...".
print "Fireing sep motors...".
wait until stage:ready.
local sep is TIME:SECONDS.
stage.
wait until TIME:SECONDS > sep + 1.
wait until stage:ready.
print "Fireing second stage...".
stage.
wait until SHIP:AVAILABLETHRUST > 0.
print "Second stage ignition complete.".

wait until SHIP:AVAILABLETHRUST = 0.
print "Second stage burnout.".

wait until ETA:APOAPSIS < 90.

wait until stage:ready.
print "Stage sep..".
print "Fireing sep motors...".
stage.
set sep to TIME:SECONDS.
wait until TIME:SECONDS > sep + 3.
wait until stage:ready.
print "Fireing last stage...".
stage.

wait until false.
