local Orbit is import("lib/orbit", "class").
local math is import("lib/math").
local util is import("lib/util").
local logging is import("lib/logging").


export(LEX("run", {
  local ctx is logging["createContext"]("Landing").

  local steer is -SHIP:VELOCITY:SURFACE.
  lock STEERING to LOOKDIRUP(steer, SHIP:FACING:TOPVECTOR).
  wait 0.
  wait until ABS(STEERINGMANAGER:ANGLEERROR) < 5.
  local thrott is 0.
  lock THROTTLE to thrott.

  until PERIAPSIS < 0 {
    set thrott to 1.
  }
  set thrott to 0.

  wait until VERTICALSPEED < -1. // TODO FIGURE OUT WHY!


  local myOrbit is Orbit()().
  local shortOrbit is Orbit()().
  local done is false.

  on (VERTICALSPEED > -1) {
    set thrott to 0.
    set done to true.
  }
  until done {
    CLEARVECDRAWS().
    local vel is VELOCITY:ORBIT.
    VECDRAW(V(0,0,0), vel, green, "orig", 1, true).
    local hVel is VXCL(SHIP:UP:VECTOR, vel).
    local vVel is VXCL(hVel, vel).
    local adjustedVel is vVel + hVel/2.
    set adjustedVel:MAG to vel:MAG.
    VECDRAW(V(0,0,0), adjustedVel, red, "adjusted", 1, true).
    myOrbit["update"]().
    shortOrbit["update"](-BODY:POSITION, adjustedVel, BODY).

    local impactTA is 360 - shortOrbit["trueAnomalyAtRadius"](BODY:RADIUS + ALTITUDE - ALT:RADAR + 1).
    local fallTA is 360 - myOrbit["trueAnomalyAtRadius"](BODY:RADIUS + ALTITUDE - ALT:RADAR + 1).
    local impactVel is myOrbit["velocityAt"](fallTA).
    ctx["log"]("impactVel", impactVel:MAG).
    local impactPos is BODY:GEOPOSITIONOF(shortOrbit["positionAt"](impactTA)).
    local impactPosVel is impactPos:VELOCITY:ORBIT.
    ctx["log"]("impactPosVel", impactPosVel:MAG).
    local impactRelVel is impactVel - impactPosVel.
    ctx["log"]("impactRelVel", impactRelVel:MAG).
    local impactMA is math["trueToMean"](impactTA).
    local fallMA is math["trueToMean"](fallTA).

    local meanToImpact is impactMA - math["trueToMean"](shortOrbit["ta"]()).
    local meanToFall is fallMA - math["trueToMean"](myOrbit["ta"]()).
    local impactTime is meanToImpact / shortOrbit["n"]().
    local fallTime is meanToFall / myOrbit["n"]().
    ctx["log"]("impactTime", impactTime).
    ctx["log"]("fallTime", fallTime).
    if impactTime > fallTime set impactTime to fallTime.

    local landingBurnDuration is util["burnDuration"](impactVel:MAG).
    ctx["log"]("landingBurnDuration", landingBurnDuration).

    if landingBurnDuration * 1.1 > impactTime {
      set thrott to 1.
    }
    if landingBurnDuration * 1.3 < impactTime {
      set thrott to 0.
    }
    set steer to -SHIP:VELOCITY:SURFACE.
  }
  set thrott to 0.

  logging["removeContext"](ctx).
})).
