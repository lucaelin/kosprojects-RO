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
        90 - 90 * ((APOAPSIS-turnStart) / (250000-turnStart))^0.4,
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

local dTcurrentTime is TIME:SECONDS.

local circularize is {
  parameter targetApoapsis is 200000.

  CLEARSCREEN.

  local dT is TIME:SECONDS - dTcurrentTime.
  set dTcurrentTime to TIME:SECONDS.
  print "dT: " + dt at (0, 20).
  print "1/dT: " + (1/dt) at (0, 21).
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
  if horizontalDifference - (acceleration*dT) < 0 lock throttle to 0.
  print "horizontalDifference: " + horizontalDifference at (0,7).
  local timeToOrbit is util["burnDuration"](horizontalDifference).
  print "timeToOrbit: " + timeToOrbit at (0,8).

  print "vertialspeed: " + VERTICALSPEED at (0,10).

  // Guidance v2
  //
  // f  (x) =   a*x^4 +   b*x^3 +   c*x^2 +   d*x + e
  // f' (x) =  4*a*x^3 + 3*b*x^2 + 2*c*x   +   d
  // f''(x) = 12*a*x^2 + 6*b*x   + 2*c


  // D = verticalDistance
  // v = VERTICALSPEED
  // t = timeToOrbit
  // f(t)   = 0
  // f(0)   = D
  // f'(t)  = 0
  // f'(0)  = v
  // f''(t) = 0

  // 0 =   a*t^4 +   b*t^3 +   c*t^2 +   d*t + e
  // D =   a*0^4 +   b*0^3 +   c*0^2 +   d*0 + e
  // 0 =  4*a*t^3 + 3*b*t^2 + 2*c*t   +   d
  // v =  4*a*0^3 + 3*b*0^2 + 2*c*0   +   d
  // 0 = 12*a*t^2 + 6*b*t   + 2*c
  //
  // 0 =    a*t^4 +   b*t^3 +   c*t^2 +   d*t + e
  // D =                                        e
  // 0 =  4*a*t^3 + 3*b*t^2 + 2*c*t   +   d
  // v =                                  d
  // 0 = 12*a*t^2 + 6*b*t   + 2*c
  //
  // 0 =    a*t^4 +   b*t^3 +   c*t^2 +   v*t + D
  // 0 =  4*a*t^3 + 3*b*t^2 + 2*c*t   +   v
  // 0 = 12*a*t^2 + 6*b*t   + 2*c
  //
  // c = -3*t*(2*a*t + b)
  // 0 =    a*t^4 +   b*t^3 +   (-3*t*(2*a*t + b))*t^2 +   v*t + D
  // 0 =  4*a*t^3 + 3*b*t^2 + 2*(-3*t*(2*a*t + b))*t   +   v
  //
  // b = ((v - 8*a*t^3)/(3*t^2))
  // 0 =    a*t^4 +   ((v - 8*a*t^3)/(3*t^2))*t^3 +   -3*t*(2*a*t + ((v - 8*a*t^3)/(3*t^2)))*t^2 +   v*t + D
  //
  // a = (-(3*D + t*v)/t^4)
  //
  // f''(x) = 12*a*x^2 + 6*b*x   + 2*c
  // f''(0) = 12*a*0^2 + 6*b*0   + 2*c
  //        = 2*c
  // a = (-(3*D + t*v)/t^4)
  // b = ((v - 8*a*t^3)/(3*t^2))
  //   = ((v - 8*(-(3*D + t*v)/t^4)*t^3)/(3*t^2))
  //   = ((8*D + 3*t*v)/t^3)
  // c = -3*t*(2*a*t + b)
  //   = -3*t*(2*(-(3*D + t*v)/t^4)*t + ((8*D + 3*t*v)/t^3))
  //   = -(3*(2*D + t*v))/t^2
  // f''(0) = 2*c = 2 * (-(3*(2*D + t*v))/t^2) = (-12*D - 6*t*v)/t^2


  local acc is {
    parameter d is -verticalDistance.
    parameter v is VERTICALSPEED.
    parameter t is timeToOrbit.

    return (-12*D - 6*t*v)/t^2. // v2
    //return 2 * (-3 * d - 2 * t * v) / t^2. // v1
  }.

  local targetVerticalAccel is acc() - avgA.
  //local targetVerticalAccel is 2 * (verticalDistance - timeToOrbit * VERTICALSPEED) / timeToOrbit ^ 2 + avgA.
  print "targetVerticalAccel: " + targetVerticalAccel at (0,11).

  if acceleration = 0 {
    print "WARN" at (0, 16).
    return heading(headingCompass, 0).
  }
  if targetVerticalAccel > acceleration {
    print "WARN2" at (0, 17).
    return heading(headingCompass, 90).
  }
  if targetVerticalAccel < -acceleration {
    print "WARN3" at (0, 18).
    return heading(headingCompass, -90).
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
  set dTcurrentTime to TIME:SECONDS.
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
