*&---------------------------------------------------------------------*
*&  Include           YY_PAO_INCLUDE_MAZE_PARTS
*&---------------------------------------------------------------------*
CLASS lcl_maze DEFINITION DEFERRED.
CLASS lcl_wall DEFINITION DEFERRED.
CLASS lcl_door DEFINITION DEFERRED.
CLASS lcl_room DEFINITION DEFERRED.

*& class declarations for Direction enumeration
CLASS lcl_direction DEFINITION FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS:
      class_constructor,
      display
        IMPORTING iv_index TYPE i
        RETURNING VALUE(rv_output) TYPE string.
    CLASS-DATA:
      north TYPE REF TO lcl_direction READ-ONLY,
      east TYPE REF TO lcl_direction READ-ONLY,
      south TYPE REF TO lcl_direction READ-ONLY,
      west TYPE REF TO lcl_direction READ-ONLY.
    METHODS:
      constructor
        IMPORTING iv_index TYPE i,
      index
        RETURNING VALUE(rv_index) TYPE i.
    DATA:
      mv_index TYPE i.
ENDCLASS.

*& class declarations for Map Site
INTERFACE lif_map_site.
  METHODS:
    display
      RETURNING VALUE(rv_output) TYPE string.
ENDINTERFACE.

*& class declarations for Wall
CLASS lcl_wall DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_map_site.
ENDCLASS.

*& class declarations for Door
CLASS lcl_door DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_map_site.
    METHODS:
      constructor
        IMPORTING
          io_room1 TYPE REF TO lcl_room
          io_room2 TYPE REF TO lcl_room.
  PRIVATE SECTION.
    DATA:
      mo_room1 TYPE REF TO lcl_room,
      mo_room2 TYPE REF TO lcl_room.
ENDCLASS.

*& class declarations for Maze
CLASS lcl_maze DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      add_room
        IMPORTING io_room TYPE REF TO lcl_room,
      display
        RETURNING VALUE(rv_output) TYPE string.
  PRIVATE SECTION.
    DATA:
      mt_rooms TYPE STANDARD TABLE OF REF TO lcl_room WITH EMPTY KEY.
ENDCLASS.

*& class declarations for Bombed Wall
CLASS lcl_bombed_wall DEFINITION FINAL INHERITING FROM lcl_wall.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING iv_bombed TYPE abap_bool DEFAULT abap_false,
      is_bombed
        RETURNING VALUE(rv_flag) TYPE abap_bool,
      lif_map_site~display REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mv_bombed TYPE abap_bool.
ENDCLASS.

*& class declarations for Enchanted Room
CLASS lcl_spell DEFINITION.
  "...
ENDCLASS.

*& class declarations for Door Needing Spell
CLASS lcl_door_needing_spell DEFINITION FINAL INHERITING FROM lcl_door.
  PUBLIC SECTION.
    METHODS:
      try_spell
        IMPORTING io_spell TYPE REF TO lcl_spell
        RETURNING VALUE(ro_flag) TYPE abap_bool,
      lif_map_site~display REDEFINITION.
ENDCLASS.
