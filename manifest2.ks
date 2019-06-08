@lazyglobal off.
{
  local events is LEX().
  function emit {
    parameter name.

    if not events:HASKEY(name) return.
    local actions is events[name].
    for action in actions {
      print "Running " + action:JOIN(", ").
    }
  }

  CLEARGUIS().
  local g is GUI(1100,500).
  local ids is LEX().
  run "0:/manifest.gui.ks"(g, ids).

  on AG10 {
    set g:VISIBLE to AG10.
    PRESERVE.
  }
  set g:VISIBLE to AG10.

  listParts().

  set ids["partsearch"]:ONCHANGE to {
    parameter value.

    for btn in ids["partlist"]:WIDGETS {
      set btn:VISIBLE to (" " + btn:TEXT):CONTAINS(" " + value).
    }
  }.

  set ids["runevent"]:ONCLICK to {
    local eventname is ids["eventname"]:TEXT.

    emit(eventname).
  }.

  function updateSelectedPart {
    parameter part is 0.
    parameter btn is 0.
    parameter active is btn:PRESSED.

    local h is highlight(part, blue).
    set h:ENABLED to active.

    if active {
      listModules(part).
    } else {
      listModules(0).
    }
  }

  function updateSelectedModule {
    parameter part is 0.
    parameter module is 0.
    parameter btn is 0.
    parameter active is btn:PRESSED.

    if active {
      listActions(part, module).
    } else {
      listActions().
    }
  }

  function addAction {
    parameter action.

    local event is ids["eventname"]:TEXT:TOLOWER.
    if event = "" return.

    if not events:HASKEY(event) {
      set events[event] to LIST().
    }
    events[event]:ADD(action).

    listEvents().
  }

  function listParts {
    ids["partlist"]:CLEAR().

    local parts is list().
    list parts in parts.

    for part in parts {
      local part is part.
      local btn is ids["partlist"]:ADDRADIOBUTTON(part:TITLE).
      set btn:ONCLICK to {
        updateSelectedPart(part, btn).
      }.
    }
  }

  function listModules {
    parameter part.

    ids["modulelist"]:CLEAR().
    if part:ISTYPE("Part") {
      for module in part:ALLMODULES {
        local module is part:GETMODULE(module).
        local btn is ids["modulelist"]:ADDRADIOBUTTON(module:NAME).
        set btn:ONCLICK to {
          updateSelectedModule(part, module, btn).
        }.
      }
    }
  }

  function listActions {
    parameter part is 0.
    parameter module is 0.

    ids["actionlist1"]:CLEAR().
    ids["actionlist2"]:CLEAR().
    ids["actionlist3"]:CLEAR().

    if module:ISTYPE("PartModule") {
      for action in module:ALLACTIONNAMES {
        local action is action.
        local layout is ids["actionlist1"]:ADDHLAYOUT().
        layout:ADDLABEL(action:TOUPPER).
        local btntrue is layout:ADDBUTTON("TRUE").
        set btntrue:ONCLICK to {
          addAction(LIST("ACTION", part:CID, module:NAME, action, true)).
        }.
        local btnfalse is layout:ADDBUTTON("TRUE").
        set btnfalse:ONCLICK to {
          addAction(LIST("ACTION", part:CID, module:NAME, action, false)).
        }.
      }

      for event in module:ALLEVENTNAMES {
        local event is event.
        local btn is ids["actionlist2"]:ADDBUTTON(event:TOUPPER).
        set btn:ONCLICK to {
          addAction(LIST("EVENT", part:CID, module:NAME, event)).
        }.
      }

      for field in module:ALLFIELDNAMES {
        local field is field.
        local fieldvalue is module:GETFIELD(field).

        ids["actionlist3"]:ADDLABEL(field + ": " + fieldvalue).

        if not fieldvalue:ISTYPE("String") {
          local layout is ids["actionlist3"]:ADDHLAYOUT().
          local input is layout:ADDTEXTFIELD().
          local btn is layout:ADDBUTTON("Set").
          set btn:ONCLICK to {
            if input:TEXT = "" return.
            addAction(LIST("FIELD", part:CID, module:NAME, field, input:TEXT:TOSCALAR)).
          }.
        }
      }
    }
  }

  function listEvents {
    ids["eventlist"]:CLEAR().

    for eventname in events:KEYS {
      local actionlist is events[eventname].
      ids["eventlist"]:ADDLABEL(eventname:TOUPPER).
      for action in actionlist {
        local action is action.
        local btn is ids["eventlist"]:ADDBUTTON(action:JOIN(", ")).
        set btn:ONCLICK to {
          actionlist:REMOVE(actionlist:INDEXOF(action)).
          if actionlist:LENGTH = 0 events:REMOVE(eventname).
          listEvents().
        }.
      }
    }
  }
}

wait until false.
