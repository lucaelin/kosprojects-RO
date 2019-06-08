local telemetry is import("lib/telemetry").
local nav is import("lib/nav").
local guidance is import("lib/guidance").
local util is import("lib/util").
local event is import("lib/event").

local tgt is BODY("Moon").
set target to tgt.
local targetPeriapsis is 200000.
local targetApoapsis is 200000.
local targetInclination is tgt:ORBIT:INCLINATION + 0.4.
local targetLAN is tgt:ORBIT:LAN.

when ALTITUDE > 80000 then {
  event["emit"]("fairingdeploy").
}

export(LIST({
  util["awaitInput"]().
},{
  guidance["launchWindow"](targetLAN, targetInclination).
},{
  telemetry["start"](5).
  lock STEERING to LOOKDIRUP(UP:VECTOR, SHIP:FACING:TOPVECTOR).
  lock THROTTLE to 1.
  print "5.....".
  util["wait"](1).
  print "4....".
  util["wait"](1).
  print "Engine ignitiön!".
  util["stage"]().
  wait until SHIP:AVAILABLETHRUST > 0.
  print "Engine ignitiøn successful!".
  print "3...".
  util["wait"](1).
  print "2..".
  util["wait"](1).
  print "1.".
  util["wait"](1).
  print "Liftoff!".
  util["stage"]().
},{
  lock STEERING to LOOKDIRUP(UP:VECTOR, SHIP:FACING:TOPVECTOR).
  lock THROTTLE to 1.
  wait until SHIP:VERTICALSPEED > 50.
},{
  guidance["runEarly"](targetPeriapsis, targetApoapsis, targetInclination).
  wait until SHIP:AVAILABLETHRUST = 0.
  print "First stage burnout!".
  util["wait"](1).
  print "Stage sep!".
  util["stage"]().
  util["wait"](1).
  print "Second stage ignition!".
  util["stage"]().
},{
  util["wait"](3).
  guidance["run"](targetPeriapsis, targetApoapsis, targetInclination).
}, {
  wait until util["thrust"]() = 0.
  print "Second stage burnout!".
  lock THROTTLE to 0.
  lock STEERING to PROGRADE.
  util["wait"](1).
  print "Stage sep!".
  util["stage"]().
  util["wait"](1).
  print "Booster program complete!".
  telemetry["stop"]().
})).
