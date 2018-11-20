runpath("0:/basics/lib/telemetry.ks").

function apoapsisPrograde {
  parameter v is SHIP:VELOCITY:ORBIT.    // velocity vector
  parameter r is -BODY:POSITION.    // position vector
  parameter mu is BODY:MU.

  local h to -VCRS(r, v).   // specific angular momentum vector

  local eccentricityVector is (-VCRS(v, h)) / mu - r / r:mag.
  return VCRS(h, eccentricityVector):NORMALIZED.
}

lock THROTTLE to 1.

local headingCompass is 90.

lock STEERING to LOOKDIRUP(HEADING(headingCompass, MAX(90 - 90*(((APOAPSIS / 2)-40)/140000)^(1/2),0)):VECTOR, SHIP:FACING:TOPVECTOR).
when APOAPSIS > 250000 then {
  lock STEERING to apoapsisPrograde().
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

wait until SHIP:AVAILABLETHRUST = 0.

print "Stage sep...".
print "Firing sep motors...".
wait until stage:ready.
local sep is TIME:SECONDS.
stage.
wait until TIME:SECONDS > sep + 1.
wait until stage:ready.
print "Firing second stage...".
stage.
wait until SHIP:AVAILABLETHRUST > 0.
print "Second stage ignition complete.".

wait until SHIP:AVAILABLETHRUST = 0.
print "Second stage burnout.".

print "Stage sep..".
wait until stage:ready.
RCS on.
stage.

wait 0.
WARPTO(TIME:SECONDS + ETA:APOAPSIS - 50).
wait until ETA:APOAPSIS < 30.

set sep to TIME:SECONDS.
set SHIP:CONTROL:FORE to 1.
wait until TIME:SECONDS > sep + 3.
wait until stage:ready.
print "Orbital insertion...".
stage.
set SHIP:CONTROL:FORE to 0.

wait until APOAPSIS > 350000.
lock THROTTLE to 0.

wait 0.
WARPTO(TIME:SECONDS + ETA:APOAPSIS - 40).
wait until ETA:APOAPSIS < 5.

set sep to TIME:SECONDS.
set SHIP:CONTROL:FORE to 1.
lock THROTTLE to 1.
wait until TIME:SECONDS > sep + 3.
wait until stage:ready.
print "Orbital circularization...".
stage.
set SHIP:CONTROL:FORE to 0.

wait until ETA:APOAPSIS > SHIP:ORBIT:PERIOD * 0.25.
RCS off.
lock THROTTLE to 0.

wait until false.
