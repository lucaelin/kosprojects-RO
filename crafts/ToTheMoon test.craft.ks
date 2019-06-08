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
local lock allTheSolar to LOOKDIRUP(BODY("Earth"):ORBIT:VELOCITY:ORBIT, BODY("Sun"):POSITION).

set STEERINGMANAGER:YAWTORQUEADJUST to 0.01.
set STEERINGMANAGER:PITCHTORQUEADJUST to 0.01.

export(LIST({
  util["wait"](1).
  wait until stage:ready.
  stage.
  wait until stage:ready.
  util["wait"](10).
  set WARP to 2.
  wait until VANG(BODY("Earth"):POSITION, BODY("Moon"):POSITION) < 45.
  wait until VANG(BODY("Earth"):POSITION, BODY("Moon"):POSITION) > 45.
  print "you're gonna be the one that saves me!!!!!!!".
  set WARP to 0.
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
}, {
  RCS on.
  print "running landing".
  landing["run"]().
})).
