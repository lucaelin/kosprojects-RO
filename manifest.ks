CLEARGUIS().

local g is GUI(1000,500).

on AG10 {
    if AG10 {
        g:SHOW().
    } else {
        g:HIDE().
    }
    PRESERVE.
}
g:SHOW().
AG10 on.
g:ADDLABEL("SHIP Manifest").

local layout is g:ADDHLAYOUT().
local pl is layout:ADDSCROLLBOX().
local ml is layout:ADDSCROLLBOX().
local eal is layout:ADDSCROLLBOX().
local selection is layout:ADDSCROLLBOX().

local parts is LIST().
list parts in parts.
local highlights is LIST().
listParts().

function selectButton {
    parameter parent.
    parameter button.

    for e in parent:WIDGETS {
        if e:ISTYPE("Button") and not (e = button) {
            set e:PRESSED to false.
        }
    }
    set button:PRESSED to true.
}

function listParts {
    parameter ship is ship.
    parameter parent is pl.

    for h in highlights {
        set h:ENABLED to false.
    }
    highlights:CLEAR().
    parent:CLEAR().
    for part in ship:parts {
        local part is part.
        local pbutton is parent:addbutton(part:TITLE).
        set pbutton:TOGGLE to true.
        local h is HIGHLIGHT(part, blue).
        highlights:ADD(h).
        set h:ENABLED to false.
        set pbutton:ONCLICK to {
            if not pbutton:PRESSED {
                for h in highlights {
                    set h:ENABLED to false.
                }

                listEventsAndActions(0).
                listModules(0).
                return.
            }
            selectButton(parent, pbutton).
            for h in highlights {
                set h:ENABLED to false.
            }
            set h:ENABLED to pbutton:PRESSED.
            listEventsAndActions(0).
            listModules(part).
        }.
    }
}
function listModules {
    parameter part.
    parameter parent is ml.

    parent:CLEAR().
    if not part:ISTYPE("Part") return.
    for module in part:ALLMODULES {
        local module is part:GETMODULE(module).
        local mbutton is parent:addbutton(module:NAME).
        set mbutton:TOGGLE to true.
        set mbutton:ONCLICK to {
            if not mbutton:PRESSED return listEventsAndActions(0).
            selectButton(parent, mbutton).
            listEventsAndActions(module).
        }.
    }
}
function listEventsAndActions {
    parameter module.
    parameter parent is eal.

    parent:CLEAR().
    if not module:ISTYPE("PartModule") return.
    parent:ADDLABEL("Actions").
    for action in module:ALLACTIONNAMES {
        local action is action.

        local atbutton is parent:addbutton(action + " true").
        set atbutton:ONCLICK to {
            module:DOACTION(action, true).
            listEventsAndActions(module).
            listSelection().
        }.

        local afbutton is parent:addbutton(action + " false").
        set afbutton:ONCLICK to {
            module:DOACTION(action, false).
            listEventsAndActions(module).
            listSelection().
        }.
    }
    parent:ADDLABEL("Events").
    for event in module:ALLEVENTNAMES {
        local event is event.
        local ebutton is parent:addbutton(event).
        set ebutton:ONCLICK to {
            module:DOEVENT(event).
            listEventsAndActions(module).
            listSelection().
        }.
    }
    parent:ADDLABEL("Fields").
    for field in module:ALLFIELDNAMES {
        local field is field.
        print field.
        print field:TYPENAME.
        local value is module:GETFIELD(field).
        local fbutton is parent:addbutton(field+": "+value).
        set fbutton:ONCLICK to {
            set fbutton:TEXT to field+": "+value.
        }.
    }
}
function listSelection {

}

wait until false.
