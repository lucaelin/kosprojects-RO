local util is import("lib/util").
local event is import("lib/event").
local Orbit is import("lib/orbit", "class").
local Maneuver is import("lib/maneuver", "class").
local logging is import("lib/logging").
local landing is import("lib/landing").

set CONFIG:IPU to 1000. // TODO remove
local tgt is BODY("Moon").
local lock moonPosition to tgt:ORBIT:POSITION - BODY:ORBIT:POSITION.
local lock position to -BODY:ORBIT:POSITION.
local lock phaseAngle to VANG(moonPosition, position).
local lock allTheSolar to LOOKDIRUP(BODY("Sun"):POSITION, SHIP:FACING:TOPVECTOR).

set STEERINGMANAGER:YAWTORQUEADJUST to 0.005.
set STEERINGMANAGER:PITCHTORQUEADJUST to 0.005.

export(LIST({
  local moonOffset is 65.
  event["emit"]("solar").

  util["wait"](30).

  local myOrbit is Orbit()().
  local moonOrbit is Orbit()(moonPosition, tgt:ORBIT:VELOCITY:ORBIT, BODY).
  local moonAltitude is moonOrbit["altitudeAt"](moonOrbit["ta"]() + moonOffset).
  local moonTa is myOrbit["trueAnomalyAt"](moonPosition).
  local burnTa is moonTa + 180 + moonOffset.
  if burnTa-10 > SHIP:ORBIT:TRUEANOMALY {
    set burnTa to burnTa + 360.
  }
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
  RCS on.
  moonManeuver["exec"](120, 10).
  print "AND I SAID MAAYBE?".
}, {
  util["wait"](5).
  lock STEERING to allTheSolar.
  util["wait"](120).
  unlock STEERING.
  SAS on.
  util["wait"](5).
  set WARP to 4.
  wait until SHIP:BODY = tgt.
  print "you're gonna be the one that saves me!!!!!!!".
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  wait 0.
  SAS off.
}, {
  lock THROTTLE to 0.
  if PERIAPSIS < 50000 {
    lock STEERING to RADIALOUT.
    util["wait"](50).
    set SHIP:CONTROL:FORE to 1.
    util["wait"](10).
    lock THROTTLE to 1.
    set SHIP:CONTROL:FORE to 0.
    wait until PERIAPSIS > 50000 or SHIP:AVAILABLETHRUST = 0.
    lock THROTTLE to 0.
  }
  if PERIAPSIS > 500000 {
    lock STEERING to RADIALIN.
    util["wait"](50).
    set SHIP:CONTROL:FORE to 1.
    util["wait"](10).
    lock THROTTLE to 1.
    set SHIP:CONTROL:FORE to 0.
    wait until PERIAPSIS < 500000 or SHIP:AVAILABLETHRUST = 0.
    lock THROTTLE to 0.
  }
}, {
  lock STEERING to allTheSolar.
  util["wait"](60).
  local myOrbit is Orbit()().
  print "pe: " + myOrbit["pe"]().
  print "ap: " + myOrbit["ap"]().
  local circManeuver is Maneuver()(myOrbit).
  circManeuver["adjustApoapsis"](100000).
  circManeuver["exec"](120, 10).
}, {
  local circManeuver is Maneuver()().
  circManeuver["adjustApoapsis"](100000).
  circManeuver["exec"](120, 10).
  lock STEERING to allTheSolar.
  util["wait"](10).
  util["transmitOrDiscardScience"]().
}, {
  lock STEERING to allTheSolar.
  util["wait"](30).
  unlock STEERING.
  SAS on.
  util["wait"](1).
  set WARP to 2.
  wait until VANG(BODY("Earth"):POSITION, BODY("Moon"):POSITION) < 45.
  wait until VANG(BODY("Earth"):POSITION, BODY("Moon"):POSITION) > 45.
  print "you're gonna be the one that saves me!!!!!!!".
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  util["wait"](1).
  unlock STEERING.
  SAS off.
  stage.
  util["wait"](1).
}, {
  RCS on.
  print "running landing".
  event["emit"]("landing").
  landing["run"]().
}, {
  util["wait"](10).
  event["emit"]("moonscience").
  util["wait"](10).
  util["transmitOrDiscardScience"]().
})).
