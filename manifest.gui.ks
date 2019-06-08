// <label>Ship Manifest</label>
// <hlayout>
//     <vlayout>
//         <textfield id="partsearch"></textfield>
//         <scrollbox id="partlist"></scrollbox>
//     </vlayout>
//     <scrollbox id="modulelist"></scrollbox>
//
//     <vlayout>
//         <label>Actions</label>
//         <scrollbox id="actionlist1"></scrollbox>
//         <label>Events</label>
//         <scrollbox id="actionlist2"></scrollbox>
//         <label>Fields</label>
//         <scrollbox id="actionlist3"></scrollbox>
//     </vlayout>
//     <vlayout>
//         <hlayout>
//             <textfield id="eventname"></textfield>
//             <button id="runevent">Test</button>
//         </hlayout>
//         <scrollbox id="eventlist"></scrollbox>
//     </vlayout>
// </hlayout>

parameter node.
parameter ids is LEX().
  {
    local parent is node.
    local node is parent:addlabel().

    //attributes

    //childnodes
    set node:text to "Ship Manifest".
  }

  {
    local parent is node.
    local node is parent:addhlayout().

    //attributes

    //childnodes
    {
      local parent is node.
      local node is parent:addvlayout().

      //attributes

      //childnodes
      {
        local parent is node.
        local node is parent:addtextfield().

        //attributes
        ids:ADD("partsearch", node).

        //childnodes
      }
      {
        local parent is node.
        local node is parent:addscrollbox().

        //attributes
        ids:ADD("partlist", node).

        //childnodes
      }
    }
    {
      local parent is node.
      local node is parent:addscrollbox().

      //attributes
      ids:ADD("modulelist", node).

      //childnodes
    }
    {
      local parent is node.
      local node is parent:addvlayout().

      //attributes

      //childnodes
      {
        local parent is node.
        local node is parent:addlabel().

        //attributes

        //childnodes
        set node:text to "Actions".
      }
      {
        local parent is node.
        local node is parent:addscrollbox().

        //attributes
        ids:ADD("actionlist1", node).

        //childnodes
      }
      {
        local parent is node.
        local node is parent:addlabel().

        //attributes

        //childnodes
        set node:text to "Events".
      }
      {
        local parent is node.
        local node is parent:addscrollbox().

        //attributes
        ids:ADD("actionlist2", node).

        //childnodes
      }
      {
        local parent is node.
        local node is parent:addlabel().

        //attributes

        //childnodes
        set node:text to "Fields".
      }
      {
        local parent is node.
        local node is parent:addscrollbox().

        //attributes
        ids:ADD("actionlist3", node).

        //childnodes
      }
    }
    {
      local parent is node.
      local node is parent:addvlayout().

      //attributes

      //childnodes
      {
        local parent is node.
        local node is parent:addhlayout().

        //attributes

        //childnodes
        {
          local parent is node.
          local node is parent:addtextfield().

          //attributes
          ids:ADD("eventname", node).

          //childnodes
        }
        {
          local parent is node.
          local node is parent:addbutton().

          //attributes
          ids:ADD("runevent", node).

          //childnodes
          set node:text to "Test".
        }
      }
      {
        local parent is node.
        local node is parent:addscrollbox().

        //attributes
        ids:ADD("eventlist", node).

        //childnodes
      }
    }
  }
