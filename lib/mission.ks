@lazyglobal off.
{
  local statefile is "1:/state.json".
  global state is LEX().

  if EXISTS(statefile) {
    set state to READJSON(statefile).
  } else {
    state:ADD("initialName", SHIP:NAME).
    state:ADD("initialStageNumber", stage:number).
    local crafts is SHIP:NAME:SPLIT(" @ ").
    state:ADD("crafts", crafts:SUBLIST(0, crafts:LENGTH)). // strange bug causing the return of :SPLIT to be of type ListValue`1 instead of List or ListValue
    state:ADD("missionstep", 0).
  }

  state:ADD("save", {
    local save is state["save"].
    state:REMOVE("save").
    WRITEJSON(state, statefile).
    state:ADD("save", save).
  }).
  state["save"]().

  until state["crafts"]:LENGTH <= 0 {
    local mission is LIST().
    for craft in state["crafts"] {
      set mission to import("crafts/"+craft, "craft").
    }
    until state["missionstep"] >= mission:LENGTH {
      mission[state["missionstep"]]().
      set state["missionstep"] to state["missionstep"] + 1.
      state["save"]().
    }

    set state["missionstep"] to 0.
    state["crafts"]:REMOVE(state["crafts"]:LENGTH - 1).
    state["save"]().
  }
}
