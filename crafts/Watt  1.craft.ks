local logTelemetry is import("lib/telemetry").
local nav is import("lib/nav").
local util is import("lib/util").

local headingCompass to 90.
local ascend is {
  parameter turnStart is 0.
  return LOOKDIRUP(
    HEADING(
      headingCompass,
      MAX(
        90 - 90 * ((APOAPSIS-turnStart) / (200000-turnStart))^0.4,
        90 - VANG(
          SHIP:UP:VECTOR,
          nav["circularVelocityVector"]() - SHIP:ORBIT:VELOCITY:ORBIT
        )
      )
    ):VECTOR,
    SHIP:FACING:TOPVECTOR
  ).
}.

local getG is {
  parameter altitude is ALTITUDE.
  return BODY:MU / (BODY:RADIUS + altitude)^2.
}.

local circularize is {
  parameter targetApoapsis is 200000.

  CLEARSCREEN.

  local targetHorizontalSpeed is SQRT(BODY:MU/(BODY:RADIUS + targetApoapsis)).
  print "targetHorizontalSpeed: " + targetHorizontalSpeed at (0,0).
  local avgG is getG((ALTITUDE + targetApoapsis) / 2).
  print "avgG: " + avgG at (0,1).
  local verticalDistance is targetApoapsis - ALTITUDE.
  print "verticalDistance: " + verticalDistance at (0,2).
  local currentHorizontalSpeed is VXCL(UP:VECTOR, SHIP:ORBIT:VELOCITY:ORBIT):MAG.
  print "currentHorizontalSpeed: " + currentHorizontalSpeed at (0,3).
  local avgA is avgG - ((currentHorizontalSpeed + targetHorizontalSpeed) / 2) ^ 2 / BODY:POSITION:MAG.
  print "avgA: " + avgA at (0,4).
  local acceleration is SHIP:AVAILABLETHRUST / SHIP:MASS.
  print "acceleration: " + acceleration at (0,5).

  local horizontalDifference is targetHorizontalSpeed - currentHorizontalSpeed.
  if horizontalDifference < 0 lock throttle to 0.
  print "horizontalDifference: " + horizontalDifference at (0,7).
  local timeToOrbit is util["burnDuration"](horizontalDifference).
  print "timeToOrbit: " + timeToOrbit at (0,8).

  local targetVerticalSpeed is verticalDistance / (timeToOrbit / 2).
  print "targetVerticalSpeed: " + targetVerticalSpeed at (0,10).
  print "VERTICALSPEED: " + VERTICALSPEED at (0,11).
  // // (VERTICALSPEED + x * timeToOrbit / 2 - avgA * timeToOrbit / 2) * timeToOrbit = verticalDistance
  // //  verticalDistance = VERTICALSPEED * timeToOrbit + 1/2 * (x - avgA) * timeToOrbit^2
  //
  // // x * timeToOrbit / 2 = verticalDistance / timeToOrbit + avgA * timeToOrbit / 2 - VERTICALSPEED
  // //local targetVerticalAccel is
  // //  (verticalDistance / timeToOrbit + avgA * timeToOrbit / 2 - VERTICALSPEED)
  // //  / (timeToOrbit / 2).
  // //timeToOrbit * VERTICALSPEED = verticalDistance
  // d = verticalDistance
  // v = VERTICALSPEED
  // t = timeToOrbit
  // // f(t) = 0
  // // f(0) = d
  // // f'(t) = 0
  // // f'(0) = v
  //
  // f  (x) =   a*x^3 +   b*x^2 +   c*x +   d
  // f' (x) = 3*a*x^2 + 2*b*x   +   c
  // f''(x) = 6*a*x   + 2*b
  //

  //   a*t^3 +   b*t^2 +   v*t +   d = 0
  //   a*t^3 +   ((-v - 2*a*t^2) / t / 2)*t^2 +   v*t +   d = 0
  //   a*t^3 +   ((-v - 2*a*t^2) / t / 2)*t^2  = -d - v*t
  //   a = (2 d + t v)/t^3
  //
  //
  // 3*a*t^2 + 2*b*t   +   v         = 0
  //             b = -(3 a t^2 + v)/(2 t)
  //
  //   b = -(3 ((2 d + t v)/t^3) t^2 + v)/(2 t)
  //   b = (-3 d - 2 t v)/t^2

  //

  local acc is {
    parameter d is -verticalDistance.
    parameter v is VERTICALSPEED.
    parameter t is timeToOrbit.

    return 2 * (-3 * d - 2 * t * v) / t^2.
    //return 2 * (v - 3*v*t - 3*d) / (5 * t^2).
  }.

  local targetVerticalAccel is acc() - avgA.
  //local targetVerticalAccel is 2 * (verticalDistance - timeToOrbit * VERTICALSPEED) / timeToOrbit ^ 2 + avgA.
  print "targetVerticalAccel: " + targetVerticalAccel at (0,12).

  if acceleration = 0 {
    print "WARN" at (0, 16).
    return heading(headingCompass, 0).
  }
  if targetVerticalAccel > acceleration {
    print "WARN2" at (0, 17).
    return heading(headingCompass, 0).
  }
  if targetVerticalAccel < -acceleration {
    print "WARN3" at (0, 18).
    return heading(headingCompass, 0).
  }
  local pitch is ARCSIN(targetVerticalAccel / acceleration).
  print "targetPitch: " + pitch at (0,13).
  print "pitch: " + (90 - VANG(UP:VECTOR, SHIP:FACING:FOREVECTOR)) at (0,14).

  return heading(headingCompass, pitch).
}.

export(LIST({
  util["awaitInput"]().
},{
  logTelemetry(5).
  lock STEERING to ascend().
  lock THROTTLE to 1.
  print "5.....".
  util["wait"](1).
  print "4....".
  util["wait"](1).
  print "Engine ignition!".
  util["stage"]().
  wait until SHIP:AVAILABLETHRUST > 0.
  print "Engine ignition successful!".
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
  local turnStart is APOAPSIS.
  lock STEERING to ascend(turnStart).
  wait until SHIP:AVAILABLETHRUST = 0.
  print "First stage burnout!".
  util["wait"](1).
  print "Stage sep!".
  util["stage"]().
  util["wait"](1).
  print "Second stage ignition!".
  util["stage"]().
},{
  lock STEERING to circularize(250000).
  lock THROTTLE to 1.
  wait until SHIP:AVAILABLETHRUST = 0.
  print "Second stage burnout!".
  lock THROTTLE to 0.
  util["wait"](1).
  print "Stage sep!".
  util["stage"]().
  util["wait"](5).
},{
  RCS on.
  if ETA:APOAPSIS < 200 warpTo(TIME:SECONDS + SHIP:ORBIT:PERIOD / 2).
  wait until KUNIVERSE:TIMEWARP:ISSETTLED.
  wait 0.
  warpTo(TIME:SECONDS + ETA:APOAPSIS - 200).
  lock THROTTLE to 0.
  lock STEERING to PROGRADE.
  wait until ETA:APOAPSIS > 200.
  wait until ETA:APOAPSIS < 150.
  lock THROTTLE to 1.
},{
  wait until false.
})).
