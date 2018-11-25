global lock SURFACEPROGRADE to LOOKDIRUP(SHIP:VELOCITY:SURFACE, SHIP:FACING:TOPVECTOR).
global lock SURFACERETROGRADE to LOOKDIRUP(-SHIP:VELOCITY:SURFACE, SHIP:FACING:TOPVECTOR).
global lock ANTINORMAL to LOOKDIRUP(vcrs(ship:velocity:orbit,body:position), SHIP:FACING:TOPVECTOR).
global lock NORMAL to LOOKDIRUP(-vcrs(ship:velocity:orbit,body:position), SHIP:FACING:TOPVECTOR).
global lock RADIALOUT to LOOKDIRUP(vcrs(ship:velocity:orbit, vcrs(ship:velocity:orbit,body:position)), SHIP:FACING:TOPVECTOR).
global lock RADIALIN to LOOKDIRUP(-vcrs(ship:velocity:orbit, vcrs(ship:velocity:orbit,body:position)), SHIP:FACING:TOPVECTOR).
global lock UPTOP to LOOKDIRUP(SHIP:UP:VECTOR, SHIP:FACING:TOPVECTOR).

global RADTODEG is 180/CONSTANT:PI.
global DEGTORAD is CONSTANT:PI/180.

global function MODMOD {
  parameter v.
  parameter n.

  return MOD(MOD(v, n) + n, n).
}

global function CLAMP {
  parameter a.
  parameter b.
  parameter v.

  return MAX(a, MIN(b, v)).
}
global function SIGN {
  parameter a.

  if a = 0 {
    return 0.
  }

  return a / ABS(a).
}
