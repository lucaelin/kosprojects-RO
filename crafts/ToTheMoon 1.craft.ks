local util is import("lib/util").

local tgt is BODY("Moon").
local lock moonPosition to tgt:POSITION - BODY:POSITION.
local lock position to -BODY:POSITION.
local lock phaseAngle to VANG(moonPosition, position).
local lock allTheSolar to LOOKDIRUP(BODY("Earth"):ORBIT:VELOCITY:ORBIT, BODY("Sun"):POSITION).

export(LIST({
  util["awaitInput"]().
},{
  RCS on.
  lock STEERING to PROGRADE.
  lock THROTTLE to 0.
  set WARP to 2.
  wait until phaseAngle > 135.
  wait until phaseAngle < 135.
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
}, {
  util["wait"](60).
  lock THROTTLE to 1.
  wait until SHIP:ORBIT:APOAPSIS > tgt:ALTITUDE.
  lock THROTTLE to 0.
  print "AND I SAID MAAYBE?".
}, {
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
  wait until PERIAPSIS < 4900000.
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  lock THROTTLE to 0.
}, {
  lock STEERING to allTheSolar.
  print "waiting...".
  wait until ALTITUDE < 4900000.
  print "Deploying science...".
  toggle AG2.
})).
