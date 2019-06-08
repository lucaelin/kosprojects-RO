local trigon is import("lib/trigonometry").

function eccToTrue {
  parameter eccAnomaly.
  parameter eccentricity is SHIP:ORBIT:ECCENTRICITY.

  if eccentricity > 1 return ARCTAN(SQRT((eccentricity + 1) / (eccentricity - 1)) * trigon["tanh"](eccAnomaly / 2)) * 2.

  local halforbits is FLOOR(eccAnomaly/180).
  set eccAnomaly to MODMOD(eccAnomaly, 360).
  local invert is MOD(halforbits, 2) * (-2) + 1.
  return 360 * FLOOR(halforbits/2) + MOD(invert * ARCTAN(SQRT((1 + eccentricity) / (1 - eccentricity)) * TAN(eccAnomaly / 2)) * 2 + 360, 360).
}
function trueToEcc {
  parameter trueAnomaly.
  parameter eccentricity is SHIP:ORBIT:ECCENTRICITY.

  if eccentricity > 1 return trigon["arcosh"]((eccentricity + COS(trueAnomaly)) / (1 + eccentricity * COS(trueAnomaly))).

  local halforbits is FLOOR(trueAnomaly/180).
  set trueAnomaly to MODMOD(trueanomaly, 360).
  local invert is MOD(halforbits, 2) * (-2) + 1.
  return 360 * FLOOR(halforbits/2) + MOD(invert * ARCCOS((eccentricity + COS(trueAnomaly)) / (1 + eccentricity * COS(trueAnomaly))) + 360, 360).
}
function eccToMean {
  parameter eccentricAnomaly.
  parameter eccentricity is SHIP:ORBIT:ECCENTRICITY.

  if eccentricity > 1 return eccentricity * trigon["sinh"](eccentricAnomaly) * RADTODEG - eccentricAnomaly.
  local m is floor(eccentricAnomaly/360).
  set eccentricAnomaly to mod(eccentricAnomaly, 360).

  return m * 360 + eccentricAnomaly - (eccentricity * SIN(eccentricAnomaly)) * (180 / constant:pi).
}
function trueToMean {
  parameter trueAnomaly.
  parameter eccentricity is SHIP:ORBIT:ECCENTRICITY.

  return eccToMean(trueToEcc(trueAnomaly, eccentricity), eccentricity).
}
function meanToTrue {
  parameter meanAnomaly.
  parameter eccentricity is SHIP:ORBIT:ECCENTRICITY.

  local m is floor(meanAnomaly/360).
  set meanAnomaly to mod(meanAnomaly, 360).
  if eccentricity > 0.25 {
    print "The use of meanToTrue might be significantly off in this Orbit!".
  }

  return 360 * m + meanAnomaly + (2 * eccentricity * SIN(meanAnomaly) * (180 / constant:pi) + 1.25 * eccentricity ^ 2 * SIN(2*meanAnomaly) * (180 / constant:pi)).
}
function planarAngle {
  parameter posA.
  parameter posB.
  parameter nrml is NORMAL.

  local rotDir is VCRS(posA:NORMALIZED, nrml:NORMALIZED).

  if VANG(rotDir, posB)<90 {
    return VANG(posA, posB).
  } else {
    return 360-VANG(posA, posB).
  }
}


export(lex(
  "eccToTrue", eccToTrue@,
  "trueToEcc", trueToEcc@,
  "eccToMean", eccToMean@,
  "trueToMean", trueToMean@,
  "meanToTrue", meanToTrue@,
  "planarAngle", planarAngle@
)).
