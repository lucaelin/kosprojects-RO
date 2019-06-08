local util is import("lib/util").
local event is import("lib/event").
local Orbit is import("lib/orbit", "class").
local Maneuver is import("lib/maneuver", "class").

set CONFIG:IPU to 1000. // TODO remove
local tgt is BODY("Moon").
local lock moonPosition to tgt:ORBIT:POSITION - BODY:ORBIT:POSITION.
local lock position to -BODY:ORBIT:POSITION.
local lock phaseAngle to VANG(moonPosition, position).
local lock allTheSolar to LOOKDIRUP(BODY("Earth"):ORBIT:VELOCITY:ORBIT, BODY("Sun"):POSITION).

set STEERINGMANAGER:YAWTORQUEADJUST to 0.01.
set STEERINGMANAGER:PITCHTORQUEADJUST to 0.01.

export(LIST({
  local moonOffset is 65.

  local myOrbit is Orbit()().
  local moonOrbit is Orbit()(moonPosition, tgt:ORBIT:VELOCITY:ORBIT, BODY).
  local moonAltitude is moonOrbit["altitudeAt"](moonOrbit["ta"]() + moonOffset).
  local moonTa is myOrbit["trueAnomalyAt"](moonPosition).
  local burnTa is moonTa + 180 + moonOffset.
  local moonManeuver is Maneuver()(myOrbit).
  moonManeuver["adjustApoapsis"](moonAltitude).
  set moonManeuver["trueAnomaly"] to burnTa.
  moonManeuver["update"]().
  print "myOrbit pe: " + myOrbit["pe"]().
  print "myOrbit ap: " + myOrbit["ap"]().
  print "moonOrbit pe: " + moonOrbit["pe"]().
  print "moonOrbit ap: " + moonOrbit["ap"]().
  print "moonManeuver pe: " + moonManeuver["dst"]["pe"]().
  print "moonManeuver ap: " + moonManeuver["dst"]["ap"]().
  print "maneuver progradeDv: " + moonManeuver["progradeDv"].
  print "moon maneuver exec?". util["awaitInput"]().
  RCS on.
  moonManeuver["exec"]().
  print "AND I SAID MAAYBE?".
}, {
  local myOrbit is Orbit()().
  print "pe: " + myOrbit["pe"]().
  print "ap: " + myOrbit["ap"]().
  lock STEERING to allTheSolar.
  wait until SHIP:BODY = tgt.
  print "you're gonna be the one that saves me!!!!!!!".
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  wait 0.
}, {
  lock STEERING to RADIALIN.
  util["wait"](60).
  lock THROTTLE to 1.
  wait until PERIAPSIS < -tgt:RADIUS/2 or SHIP:AVAILABLETHRUST = 0.
  KUNIVERSE:TIMEWARP:CANCELWARP().
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  lock THROTTLE to 0.
}, {
  lock STEERING to allTheSolar.
  print "waiting...".
  wait until ALTITUDE < 4900000.
  KUNIVERSE:TIMEWARP:CANCELWARP().
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  print "Deploying science...".
  event["emit"]("moonscience").
}, {
  print "waiting...".
  wait until ALTITUDE < 10000.
  KUNIVERSE:TIMEWARP:CANCELWARP().
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  print "Deploying science...".
  event["emit"]("moonscience").
})).
