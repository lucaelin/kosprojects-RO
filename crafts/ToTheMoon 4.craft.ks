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
  stage.
  util["wait"](1).
  local myOrbit is Orbit()().
  print "pe: " + myOrbit["pe"]().
  print "ap: " + myOrbit["ap"]().
  lock STEERING to allTheSolar.
  util["wait"](60).
  set WARP to 4.
  wait until SHIP:BODY = tgt.
  print "you're gonna be the one that saves me!!!!!!!".
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  wait 0.
}, {
  lock THROTTLE to 0.
  if PERIAPSIS < 50000 {
    lock STEERING to RADIALOUT.
    util["wait"](60).
    lock THROTTLE to 1.
    wait until PERIAPSIS > 50000 or SHIP:AVAILABLETHRUST = 0.
    lock THROTTLE to 0.
  }
  if PERIAPSIS > 100000 {
    lock STEERING to RADIALIN.
    util["wait"](60).
    lock THROTTLE to 1.
    wait until PERIAPSIS < 100000 or SHIP:AVAILABLETHRUST = 0.
    lock THROTTLE to 0.
  }
}, {
  lock STEERING to allTheSolar.
  util["wait"](60).
  local myOrbit is Orbit()().
  print "pe: " + myOrbit["pe"]().
  print "ap: " + myOrbit["ap"]().
  local circManeuver is Maneuver()(myOrbit).
  circManeuver["adjustApoapsis"](myOrbit["pe"]()).
  circManeuver["exec"]().
}, {
  lock STEERING to allTheSolar.
  until false {
    util["wait"](10).
    //util["awaitInput"]().
    event["emit"]("moonscience").
    util["wait"](10).
    util["transmitOrDiscardScience"]().
  }
})).
