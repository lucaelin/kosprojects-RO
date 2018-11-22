local this is LEX(
  "apoapsisPrograde", {
    parameter v is SHIP:VELOCITY:ORBIT.    // velocity vector
    parameter r is -BODY:POSITION.    // position vector
    parameter mu is BODY:MU.

    local h to -VCRS(r, v).   // specific angular momentum vector

    local eccentricityVector is (-VCRS(v, h)) / mu - r / r:mag.
    return VCRS(h, eccentricityVector):NORMALIZED.
  },
  "circularVelocity", {
    parameter r is SHIP:ALTITUDE + BODY:RADIUS.
    parameter mu is BODY:MU.

    return SQRT(mu/r).
  },
  "circularVelocityVector", {
    parameter bodyPosition is BODY:POSITION.
    parameter currentPrograde is SHIP:ORBIT:VELOCITY:ORBIT.
    parameter mu is BODY:MU.

    local normal is VCRS(bodyPosition, currentPrograde).
    local dir is VCRS(normal, bodyPosition).
    set dir:MAG to this["circularVelocity"](bodyPosition:MAG, mu).

    return dir.
  }
).

export(this).
