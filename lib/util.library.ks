local enginelist is LIST().
list ENGINES in enginelist.
on SHIP:PARTS:LENGTH {
  list ENGINES in enginelist.
  PRESERVE.
}

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
    local massFlow is 0.

    for e in enginelist {
      if e:IGNITION and not e:FLAMEOUT {
        if not e:ISPAT(0) = 0 set massFlow to massFlow + (e:AVAILABLETHRUST / e:ISPAT(0)). // TODO USE REAL PRESSURE
      }
    }

    if massFlow = 0 return 0.
    return SHIP:AVAILABLETHRUST / massFlow.
  },
  "THRUST", {
    local thrust is 0.

    for e in enginelist {
      if e:IGNITION and not e:FLAMEOUT {
        set thrust to thrust + e:THRUST.
      }
    }

    return thrust.
  },
  "flamedOutEngines", {
    local num is 0.

    for e in enginelist {
      if e:IGNITION and e:FLAMEOUT {
        set num to num + 1.
      }
    }

    return num.
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
  },
  "storeVector", {
    parameter vec.
    parameter spv is SOLARPRIMEVECTOR.

    return V( vec:x * spv:x + vec:z * spv:z, vec:z * spv:x - vec:x * spv:z, vec:y).
  },
  "loadVector", {
    parameter p.
    parameter spv is SOLARPRIMEVECTOR.

    return V( p:x * spv:x - p:y * spv:z, p:z, p:x * spv:z + p:y * spv:x ).
  },
  "transmitOrDiscardScience", {
    local parts is LIST().
    list parts in parts.
    for part in parts {
      local part is part.
      for module in part:ALLMODULES {
        local module is part:GETMODULE(module).
        if module:HASSUFFIX("TRANSMIT") {
          if module:HASDATA {
            local transmitValue is 0.
            for data in module:DATA {
              set transmitValue to transmitValue + data:TRANSMITVALUE.
            }
            if transmitValue > 0 {
              wait until HOMECONNECTION:ISCONNECTED.
              module:TRANSMIT().
            } else {
              module:DUMP().
            }
          }
        }
      }
    }
  }
).

export(this).
