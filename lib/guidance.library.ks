local logging is import("lib/logging").
local nav is import("lib/nav").
local util is import("lib/util").

local azimuth is 90.
local turnStart is APOAPSIS.

local properAzimuth is {
  parameter targetPeriapsis is 200000.
  parameter targetApoapsis is 250000.
  parameter targetInclination is 0.
  parameter south is true.

  local targetSMA is BODY:RADIUS + (targetApoapsis + targetPeriapsis) / 2.
  local targetHorizontalSpeed is SQRT(BODY:MU * ((2 / (BODY:RADIUS + targetPeriapsis)) - (1 / targetSMA))).
  local eqSpeed is 2 * CONSTANT:PI * BODY:RADIUS / BODY:ROTATIONPERIOD.

  print targetInclination + " vs " + SHIP:GEOPOSITION:LAT.
  local betaInertidal is ARCSIN(COS(targetInclination) / COS(SHIP:GEOPOSITION:LAT)).
  if south set betaInertidal to betaInertidal.

  local velocityRotationX is targetHorizontalSpeed * SIN(betaInertidal) - eqSpeed*COS(SHIP:GEOPOSITION:LAT).
  local velocityRotationY is targetHorizontalSpeed * COS(betaInertidal).

  local betaRotation is ARCTAN(velocityRotationX / velocityRotationY).

  if south return 180 - betaRotation.
  return betaRotation.
}.

local earlyPitch is {
  parameter turnStart is 0.
  parameter targetAlt is 200000.
  return MAX(
    90 - 90 * ((APOAPSIS-turnStart) / (targetAlt-turnStart))^0.4,
    90 - VANG(
      SHIP:UP:VECTOR,
      nav["circularVelocityVector"]() - SHIP:ORBIT:VELOCITY:ORBIT
    )
  ).
}.

local pitch is {
  parameter targetPeriapsis is 200000.
  parameter targetApoapsis is 250000.
  parameter dT is 1/50.

  local targetSMA is BODY:RADIUS + (targetApoapsis + targetPeriapsis) / 2.

  //CLEARSCREEN.

  //print "dT: " + dt at (0, 20).
  //print "1/dT: " + (1/dt) at (0, 21).

  local currentG is BODY:MU / (BODY:RADIUS + ALTITUDE)^2.
  local targetHorizontalSpeed is SQRT(BODY:MU * ((2 / (BODY:RADIUS + targetPeriapsis)) - (1 / targetSMA))).
  //print "targetHorizontalSpeed: " + targetHorizontalSpeed at (0,0).
  local avgG is BODY:MU / (BODY:RADIUS + (ALTITUDE + targetPeriapsis) / 2)^2.
  //print "avgG: " + avgG at (0,1).
  local verticalDistance is targetPeriapsis - ALTITUDE.
  //print "verticalDistance: " + verticalDistance at (0,2).
  local currentHorizontalSpeed is VXCL(UP:VECTOR, SHIP:ORBIT:VELOCITY:ORBIT):MAG.
  //print "currentHorizontalSpeed: " + currentHorizontalSpeed at (0,3).
  local a is currentG - currentHorizontalSpeed ^ 2 / BODY:POSITION:MAG.
  //print "a: " + a at (0,4).
  local acceleration is SHIP:AVAILABLETHRUST / SHIP:MASS.
  //print "acceleration: " + acceleration at (0,5).

  local horizontalDifference is targetHorizontalSpeed - currentHorizontalSpeed.
  if horizontalDifference - (acceleration*dT) < 0 {
    print "Guidance finished.".
    lock throttle to 0.
    return 0.
  }
  //print "horizontalDifference: " + horizontalDifference at (0,7).
  local timeToOrbit is util["burnDuration"](horizontalDifference).
  //print "timeToOrbit: " + timeToOrbit at (0,8).
  if timeToOrbit = 0 {
    print "Guidance finished.".
    lock throttle to 0.
    return 0.
  }

  //print "vertialspeed: " + VERTICALSPEED at (0,10).

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


  local targetVerticalAccel is (-12 * -verticalDistance - 6 * timeToOrbit * VERTICALSPEED) / timeToOrbit^2. // v2
  //print "targetVerticalAccel: " + targetVerticalAccel at (0,11).
  //local acc is  2 * (-3 * -verticalDistance - 2 * timeToOrbit * VERTICALSPEED) / timeToOrbit^2. // v1

  local deltaVerticalAccel is targetVerticalAccel - (-a).
  //print "deltaVerticalAccel: " + targetVerticalAccel at (0,12).

  if acceleration = 0 {
    //print "WARN" at (0, 17).
    return 0.
  }
  if deltaVerticalAccel > acceleration {
    //print "WARN2" at (0, 18).
    return 89.
  }
  if deltaVerticalAccel < -acceleration {
    //print "WARN3" at (0, 19).
    return -89.
  }
  local pitch is ARCSIN(deltaVerticalAccel / acceleration).
  //print "targetPitch: " + pitch at (0,14).
  //print "pitch: " + (90 - VANG(UP:VECTOR, SHIP:FACING:FOREVECTOR)) at (0,15).

  return pitch.
}.


export(LEX(
  "run", {
    parameter targetPeriapsis is 200000.
    parameter targetApoapsis is 250000.
    parameter targetInclination is 0.

    local dTcurrentTime to TIME:SECONDS.
    local ctx is logging["createContext"]("Late Guidance").

    ctx["log"]("azimuth", { return azimuth. }).

    local converged is false.
    local p is earlyPitch(turnStart, targetPeriapsis).
    local early is earlyPitch(turnStart, targetPeriapsis).
    local late is 0.
    local pitchdiff is 90.
    ctx["log"]("converged", { return converged. }).
    ctx["log"]("pitch", { return p. }).
    ctx["log"]("pitchEarly", { return early. }).
    ctx["log"]("pitchLate", { return late. }).
    lock STEERING to HEADING(azimuth, p).
    until THROTTLE = 0 {
      local now is TIME:SECONDS.
      set early to earlyPitch(turnStart, targetPeriapsis).
      set late to pitch(targetPeriapsis, targetApoapsis, now-dTcurrentTime).
      set dTcurrentTime to now.
      if late < early + 1 and late > early - 1 set converged to true.
      if ABS(late - early) > pitchdiff set converged to true.
      set pitchdiff to ABS(late - early).
      if converged {
        set p to late.
      } else {
        set p to early.
      }
    }
    ctx["remove"]().
  },
  "runEarly", {
    parameter targetPeriapsis is 200000.
    parameter targetApoapsis is 250000.
    parameter targetInclination is 0.
    parameter reset is true.

    local ctx is logging["createContext"]("Early Guidance").

    if reset {
      set turnStart to APOAPSIS.
      set azimuth to properAzimuth(targetPeriapsis, targetApoapsis, targetInclination).
    }
    ctx["log"]("turnStart", { return turnStart. }).
    ctx["log"]("azimuth", { return azimuth. }).

    local p is earlyPitch(turnStart, targetPeriapsis).
    ctx["log"]("pitch", { return p. }).

    lock STEERING to HEADING(azimuth, p).
    until util["flamedOutEngines"]() > 0 {
      set p to earlyPitch(turnStart, targetPeriapsis).
    }
    ctx["remove"]().
  },
  "launchWindow", {
    parameter LAN is SHIP:ORBIT:LAN.
    parameter INC is SHIP:ORBIT:INCLINATION.

    local ctx is logging["createContext"]("Launchwindow").
    local ascendingVec is ANGLEAXIS(LAN, BODY:ANGULARVEL) * SOLARPRIMEVECTOR.
    local tgtnrml is ANGLEAXIS(-INC,ascendingVec) * -BODY:ANGULARVEL.

    local inc is VANG(tgtnrml, -BODY:ANGULARVEL).
    local myinc is VANG(-BODY:ANGULARVEL, NORMAL:VECTOR).

    print "Awaiting launch window.".

    local currentHead is VXCL(-BODY:ANGULARVEL:NORMALIZED, NORMAL:VECTOR).

    local tgtHead is VXCL(-BODY:ANGULARVEL:NORMALIZED, tgtnrml).

    if VANG(-BODY:ANGULARVEL:NORMALIZED, tgtnrml) < 1 {
      print "Target is almost equatorial. Launching now.".
      return { return 90. }.
    }

    local meanAtLowestInc is VANG(currentHead, tgtHead).

    if VDOT(SHIP:VELOCITY:ORBIT, tgtHead) > 0 {
      set meanAtLowestInc to 360-meanAtLowestInc.
    }

    local myinc is VANG(-BODY:ANGULARVEL, NORMAL:VECTOR).
    local tgtinc is VANG(-BODY:ANGULARVEL, tgtnrml).
    local launchAngle is 0.
    if (myinc<tgtinc) {
      print "Instantaneous window found.".
      set launchAngle to 90-ARCSIN(myinc/inc).
      print "launchAngle: " + launchAngle.
    } else {
      print "Target has a low inclination. Lauching at lowest relative inclination.".
    }

    local offsetTime is -7 * 60.
    local launchtime is TIME:SECONDS + offsetTime + (meanAtLowestInc + launchAngle)/360 * BODY:ROTATIONPERIOD.
    ctx["log"]("offsetTime", offsetTime).
    ctx["log"]("launchTime", launchTime).
    ctx["log"]("delta launchTime", { return launchTime - TIME:SECONDS. }).
    wait until KUNIVERSE:TIMEWARP:MODE = "RAILS".
    KUNIVERSE:TIMEWARP:WARPTO(launchtime - 10).
    wait until TIME:SECONDS > launchtime.
    wait until KUNIVERSE:TIMEWARP:ISSETTLED.
    wait 1.
    ctx["remove"]().
  }
)).
