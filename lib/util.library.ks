local this is LEX(
  "wait", {
    parameter sec.
    local t0 is TIME:SECONDS.
    wait until TIME:SECONDS > t0 + sec.
  },
  "awaitInput", {
    until not TERMINAL:INPUT:HASCHAR()
      TERMINAL:INPUT:GETCHAR().
    print "Press any key to continue...".
    wait until TERMINAL:INPUT:HASCHAR().
    TERMINAL:INPUT:GETCHAR().
  },
  "stage", {
    wait until stage:ready.
    stage.
  },
  "ISP", {
    local enginelist is LIST().
    list ENGINES in enginelist.
    local massFlow is 0.

    for e in enginelist {
      if e:IGNITION and not e:FLAMEOUT {
        set massFlow to massFlow + (e:AVAILABLETHRUST / e:ISPAT(0)). // TODO USE READ PRESSURE
      }
    }

    if massFlow = 0 return 0.
    return SHIP:AVAILABLETHRUST / massFlow.
  },
  "burnDuration", {
    parameter dV.

    local isp is this["ISP"]().
    local f is SHIP:AVAILABLETHRUST.   // Engine Thrust (kg * m/s²)
    local m is SHIP:MASS.        // Starting mass (kg)
    local e is CONSTANT():E.            // Base of natural log
    local g is 9.82.                 // Gravitational acceleration constant (m/s²)

    if isp = 0 or f = 0 or dV = 0 return 0.
    return (m - (m / e^(dv / (isp * g)))) / (f / (isp * g)).
  }
).

export(this).
