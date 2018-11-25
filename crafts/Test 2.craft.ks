local Orbit is import("lib/orbit", "class").

export(LIST({
  print "running test 2 now.".
},{
  local myOrbit is Orbit()(10).
  myOrbit["addOne"]().
  print myOrbit["toString"]().
})).
