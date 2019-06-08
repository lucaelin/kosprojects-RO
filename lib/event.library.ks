local archiveeventsfile is "0:/crafts/"+SHIP:NAME+".manifest.json".
local eventsfile is "1:/events.json".
local events is LEX().

if HOMECONNECTION:ISCONNECTED {
  if EXISTS(archiveeventsfile) {
    COPYPATH(archiveeventsfile, eventsfile).
  }
}

if EXISTS(eventsfile) {
  set events to READJSON(eventsfile).
}

function save {
  WRITEJSON(events, eventsfile).
  if HOMECONNECTION:ISCONNECTED {
    COPYPATH(eventsfile, "0:/crafts/"+SHIP:NAME+".manifest.json").
  }
}

function findPart {
  parameter cid.

  local parts is LIST().
  list parts in parts.
  for part in parts {
    if part:CID = cid return part.
  }

  return 0.
}

export(LEX(
  "emit", {
    parameter name.

    if not events:HASKEY(name) return.
    local event is events[name].
    for action in event {
      if action:ISTYPE("List") {
        if action[0] = "ACTIONGROUP" {
          local actiongroups is LIST(
            { parameter state is not AG0. set AG0 to state. },
            { parameter state is not AG1. set AG1 to state. },
            { parameter state is not AG2. set AG2 to state. },
            { parameter state is not AG3. set AG3 to state. },
            { parameter state is not AG4. set AG4 to state. },
            { parameter state is not AG5. set AG5 to state. },
            { parameter state is not AG6. set AG6 to state. },
            { parameter state is not AG7. set AG7 to state. },
            { parameter state is not AG8. set AG8 to state. },
            { parameter state is not AG9. set AG9 to state. }
          ).
          if action[2]:TOLOWER = "toggle" {
            actiongroups[action[1]]().
          } else {
            actiongroups[action[1]](action[2]:TOLOWER = "on").
          }
        } else {
          local part is findPart(action[1]).
          if not (part = 0) {
            local module is part:GETMODULE(action[2]).
            if action[0] = "ACTION" {
              module:DOACTION(action[3], action[4]).
            } else if action[0] = "EVENT" {
              module:DOEVENT(action[3]).
            } else if action[0] = "FIELD" {
              module:SETFIELD(action[3], action[4]).
            }
          } else {
            print "Unable to find part " + action[1].
          }
        }
      } else {
        // TODO check kos delegate
        action().
      }
    }
  },
  "addAction", {
    parameter eventname.
    parameter action.

    if eventname = "" return.

    if not events:HASKEY(eventname) {
      set events[eventname] to LIST().
    }
    events[eventname]:ADD(action).

    save().
  },
  "removeAction", {
    parameter eventname.
    parameter actionIndex.

    if eventname = "" return.

    if not events:HASKEY(eventname) return.
    if actionIndex > events[eventname]:LENGTH return.
    events[eventname]:REMOVE(actionIndex).

    if events[eventname]:LENGTH = 0 events:REMOVE(eventname).

    save().
  },
  "allEvents", {
    return events.
  }
)).
