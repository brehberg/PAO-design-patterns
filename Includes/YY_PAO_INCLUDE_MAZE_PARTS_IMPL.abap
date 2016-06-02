*&---------------------------------------------------------------------*
*&  Include           YY_PAO_INCLUDE_MAZE_PARTS
*&---------------------------------------------------------------------*

*& class declarations for Direction enumeration
CLASS lcl_direction IMPLEMENTATION.
  METHOD class_constructor.
    north = NEW #( 1 ).
    east = NEW #( 2 ).
    south = NEW #( 3 ).
    west = NEW #( 4 ).
  ENDMETHOD.
  METHOD display.
    rv_output = SWITCH #( iv_index
                          WHEN 1 THEN |North Side|
                          WHEN 2 THEN |East Side |
                          WHEN 3 THEN |South Side|
                          WHEN 4 THEN |West Side |
                          ELSE |Broken| ).
  ENDMETHOD.
  METHOD constructor.
    mv_index = iv_index.
  ENDMETHOD.
  METHOD index.
    rv_index = mv_index.
  ENDMETHOD.
ENDCLASS.

*& class declarations for Room
CLASS lcl_room IMPLEMENTATION.
  METHOD constructor.
    mv_room_number = iv_number.
    mt_sides = VALUE #( FOR i = 1 UNTIL i > 4 ( ) ).
  ENDMETHOD.
  METHOD set_side.
    mt_sides[ io_direction->index( ) ] = io_map_site.
  ENDMETHOD.
  METHOD room_number.
    rv_number = mv_room_number.
  ENDMETHOD.
  METHOD lif_map_site~display.
    rv_output = REDUCE #( INIT out = |\n\tRoom { mv_room_number }: \n|
                          FOR side IN mt_sides INDEX INTO index
                          LET text = lcl_direction=>display( index )
                          IN NEXT out = out && |\t\t{ text } : | &&
                                        side->display( ) && |\n| ).
  ENDMETHOD.
ENDCLASS.

*& class declarations for Wall
CLASS lcl_wall IMPLEMENTATION.
  METHOD lif_map_site~display.
    rv_output = |Wall|.
  ENDMETHOD.
ENDCLASS.

*& class declarations for Door
CLASS lcl_door IMPLEMENTATION.
  METHOD constructor.
    mo_room1 = io_room1.
    mo_room2 = io_room2.
  ENDMETHOD.
  METHOD lif_map_site~display.
    rv_output = |Door between rooms { mo_room1->room_number( ) } | &&
                |and { mo_room2->room_number( ) } |.
  ENDMETHOD.
ENDCLASS.

*& class declarations for Maze
CLASS lcl_maze IMPLEMENTATION.
  METHOD add_room.
    APPEND io_room TO mt_rooms.
  ENDMETHOD.
  METHOD display.
    rv_output = REDUCE #( INIT out = |Maze Description: \n|
                          FOR room IN mt_rooms
                          NEXT out = out && room->display( ) ).
  ENDMETHOD.
ENDCLASS.

*& class declarations for Bombed Wall
CLASS lcl_bombed_wall IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mv_bombed = iv_bombed.
  ENDMETHOD.
  METHOD is_bombed.
    rv_flag = xsdbool( mv_bombed = abap_true ).
  ENDMETHOD.
  METHOD lif_map_site~display.
    rv_output = COND #( WHEN is_bombed( )
                        THEN |Bombed Wall|
                        ELSE |Cracked Wall| ).
  ENDMETHOD.
ENDCLASS.

*& class declarations for Room with a Bomb
CLASS lcl_room_with_a_bomb IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_number ).
    mv_bomb = iv_bomb.
  ENDMETHOD.
  METHOD has_bomb.
    rv_flag = xsdbool( mv_bomb = abap_true ).
  ENDMETHOD.
  METHOD lif_map_site~display.
    rv_output = super->display( ) &&
                |\t\tContents   : | &&
                COND #( WHEN has_bomb( )
                        THEN |This room contains a bomb.\n|
                        ELSE |This room is empty.\n| ).
  ENDMETHOD.
ENDCLASS.

*& class declarations for Enchanted Room
CLASS lcl_enchanted_room IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_number ).
    mo_spell = io_spell.
  ENDMETHOD.
  METHOD has_spell.
    rv_flag = xsdbool( mo_spell IS BOUND ).
  ENDMETHOD.
  METHOD lif_map_site~display.
    rv_output = super->display( ) &&
                |\t\tContents   : | &&
                COND #( WHEN has_spell( )
                        THEN |This room contains a spell.\n|
                        ELSE |This room is empty.\n| ).
  ENDMETHOD.
ENDCLASS.

*& class declarations for Door Needing Spell
CLASS lcl_door_needing_spell IMPLEMENTATION.
  METHOD lif_map_site~display.
    rv_output = super->lif_map_site~display( ).
    REPLACE |Door| IN rv_output WITH |Door Needing Spell|.
  ENDMETHOD.
  METHOD try_spell.
    CHECK io_spell IS BOUND.
    "...
  ENDMETHOD.
ENDCLASS.
