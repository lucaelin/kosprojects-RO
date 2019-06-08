local Orbit is import("lib/orbit", "class").
local Maneuver is import("lib/maneuver", "class").
local util is import("lib/util").

export(LIST({
  print "running test 2 now.".
  util["awaitInput"]().
},{
  local myOrbit is Orbit()(-BODY:POSITION, SHIP:ORBIT:VELOCITY:ORBIT, BODY).
  //print NORMAL:VECTOR + " vs " + myOrbit[">n"]():NORMALIZED.
  local myManeuver is Maneuver()(myOrbit).

  myManeuver["adjustPeriapsis"](ALTITUDE).

  print myOrbit["e"]() + " vs " + myManeuver["dst"]["e"]().

  print "finished tests".
  util["awaitInput"]().
})).
