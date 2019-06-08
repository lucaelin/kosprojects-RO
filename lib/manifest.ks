local event is import("lib/event").
local manifestgui is import("lib/manifest", "gui").

local g is GUI(1100,500).
local ids is LEX().
manifestgui(g, ids).

on AG10 {
  set g:VISIBLE to AG10.
  preserve.
}
set g:VISIBLE to AG10.

on SHIP:PARTS:LENGTH {
  listParts().
  preserve.
}

listParts().
listEvents().

set ids["partsearch"]:ONCHANGE to {
  parameter value.

  for btn in ids["partlist"]:WIDGETS {
    set btn:VISIBLE to (" " + btn:TEXT):CONTAINS(" " + value).
  }
}.

set ids["runevent"]:ONCLICK to {
  local eventname is ids["eventname"]:TEXT.

  event["emit"](eventname).
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

function updateActiongroups {
  parameter btn is 0.
  parameter active is btn:PRESSED.

  if active {
    listActiongroups(true).
  } else {
    listActiongroups(false).
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

function updateSelectedActiongroup {
  parameter ag.
  parameter btn is 0.
  parameter active is btn:PRESSED.

  if active {
    listActiongroupActions(ag, true).
  } else {
    listActiongroupActions(ag, false).
  }
}

function listParts {
  ids["partlist"]:CLEAR().
  listModules().

  local parts is list().
  list parts in parts.

  for part in parts {
    local part is part.
    local btn is ids["partlist"]:ADDRADIOBUTTON(part:TITLE).
    set btn:ONCLICK to {
      if btn:PRESSED
        updateSelectedPart(part, btn).
    }.
  }

  local actiongroups is ids["partlist"]:ADDRADIOBUTTON("Stock Actiongroups").
  set actiongroups:ONCLICK to {
    updateActiongroups(actiongroups).
  }.
}

function listModules {
  parameter part is 0.

  ids["modulelist"]:CLEAR().
  listActions().
  if part:ISTYPE("Part") {
    for module in part:ALLMODULES {
      local module is part:GETMODULE(module).
      local btn is ids["modulelist"]:ADDRADIOBUTTON(module:NAME).
      set btn:ONCLICK to {
        if btn:PRESSED
          updateSelectedModule(part, module, btn).
      }.
    }
  }
}

function listActiongroups {
  parameter yes is false.

  ids["modulelist"]:CLEAR().
  listActiongroupActions().
  if yes {
    local actiongroups is LIST("AG0", "AG1", "AG2", "AG3", "AG4", "AG5", "AG6", "AG7", "AG8", "AG9").
    for ag in actiongroups {
      local ag is ag.
      local btn is ids["modulelist"]:ADDRADIOBUTTON(ag).
      set btn:ONCLICK to {
        if btn:PRESSED
          updateSelectedActiongroup(actiongroups:INDEXOF(ag), btn).
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
        local eventname is ids["eventname"]:TEXT:TOLOWER.
        event["addAction"](eventname, LIST("ACTION", part:CID, module:NAME, action, true)).
        listEvents().
      }.
      local btnfalse is layout:ADDBUTTON("FALSE").
      set btnfalse:ONCLICK to {
        local eventname is ids["eventname"]:TEXT:TOLOWER.
        event["addAction"](eventname, LIST("ACTION", part:CID, module:NAME, action, false)).
        listEvents().
      }.
    }

    for partevent in module:ALLEVENTNAMES {
      local partevent is partevent.
      local btn is ids["actionlist2"]:ADDBUTTON(partevent:TOUPPER).
      set btn:ONCLICK to {
        local eventname is ids["eventname"]:TEXT:TOLOWER.
        event["addAction"](eventname, LIST("EVENT", part:CID, module:NAME, partevent)).
        listEvents().
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
          local eventname is ids["eventname"]:TEXT:TOLOWER.
          event["addAction"](eventname, LIST("FIELD", part:CID, module:NAME, field, input:TEXT:TOSCALAR)).
          listEvents().
        }.
      }
    }
  }
}

function listActiongroupActions {
  parameter ag is 0.
  parameter yes is false.


  ids["actionlist1"]:CLEAR().
  ids["actionlist2"]:CLEAR().
  ids["actionlist3"]:CLEAR().
  if yes {
    local layout is ids["actionlist1"]:ADDHLAYOUT().
    local btntrue is layout:ADDBUTTON("TRUE").
    set btntrue:ONCLICK to {
      local eventname is ids["eventname"]:TEXT:TOLOWER.
      event["addAction"](eventname, LIST("ACTIONGROUP", ag, "ON")).
      listEvents().
    }.
    local btnfalse is layout:ADDBUTTON("FALSE").
    set btnfalse:ONCLICK to {
      local eventname is ids["eventname"]:TEXT:TOLOWER.
      event["addAction"](eventname, LIST("ACTIONGROUP", ag, "OFF")).
      listEvents().
    }.
    local btntoggle is ids["actionlist2"]:ADDBUTTON("TOGGLE").
    set btntoggle:ONCLICK to {
      local eventname is ids["eventname"]:TEXT:TOLOWER.
      event["addAction"](eventname, LIST("ACTIONGROUP", ag, "TOGGLE")).
      listEvents().
    }.
  }
}

function listEvents {
  ids["eventlist"]:CLEAR().

  local events is event["allEvents"]().

  for eventname in events:KEYS {
    local eventname is eventname.
    local actionlist is events[eventname].
    ids["eventlist"]:ADDLABEL(eventname:TOUPPER).
    for action in actionlist {
      local action is action.
      local btn is ids["eventlist"]:ADDBUTTON(action:JOIN(", ")).
      set btn:ONCLICK to {
        event["removeAction"](eventname, actionlist:INDEXOF(action)).
        listEvents().
      }.
    }
  }
}
