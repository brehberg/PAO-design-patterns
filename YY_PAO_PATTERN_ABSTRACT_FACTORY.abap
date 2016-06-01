*&---------------------------------------------------------------------*
*&  Sample code for the Abstract Factory Design Pattern in ABAP
*&    based on Chapter 3 : Creational Patterns; Page 87
*&---------------------------------------------------------------------*
*& Purpose:
*&  Provide an interface for creating families of related or dependent
*&  objects without specifying their concrete classes.
*&  Also known as a Kit.
*&---------------------------------------------------------------------*
*& Applications:
*&  A system should be independent of how its products are created,
*&   composed, and represented.
*&  A system should be configured with one of multiple families of
*&   products.
*&  A family of related product objects is designed to be used together,
*&   and you need to enforce this constraint.
*&  You want to provide a class library of products, and you want to
*&   reveal just their interfaces, not their implementations.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_abstract_factory.

INCLUDE yy_pao_include_maze_parts.


*& Abstract Product - declares an interface for a type of product
*&   object.
CLASS lcl_room DEFINITION.
  PUBLIC SECTION.
    INTERFACES:
      lif_map_site.
    ALIASES:
      display FOR lif_map_site~display.
    METHODS:
      constructor
        IMPORTING iv_number TYPE i DEFAULT 0,
      set_side
        IMPORTING
          io_direction TYPE REF TO lcl_direction
          io_map_site TYPE REF TO lif_map_site,
      room_number
        RETURNING VALUE(rv_number) TYPE i.
  PRIVATE SECTION.
    DATA:
      mt_sides TYPE STANDARD TABLE OF REF TO lif_map_site
        WITH EMPTY KEY INITIAL SIZE 4,
      mv_room_number TYPE i.
ENDCLASS.


*& Concrete Product A - defines a product object to be created by the
*&   corresponding concrete factory. Also implements the Abstract
*&   Product interface.
CLASS lcl_enchanted_room DEFINITION FINAL INHERITING FROM lcl_room.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          iv_number TYPE i DEFAULT 0
          io_spell TYPE REF TO lcl_spell OPTIONAL
        PREFERRED PARAMETER iv_number,
      has_spell
        RETURNING VALUE(rv_flag) TYPE abap_bool,
      lif_map_site~display REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mo_spell TYPE REF TO lcl_spell.
ENDCLASS.


*& Concrete Product B - defines a product object to be created by the
*&   corresponding concrete factory. Also implements the Abstract
*&   Product interface.
CLASS lcl_room_with_a_bomb DEFINITION FINAL INHERITING FROM lcl_room.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          iv_number TYPE i DEFAULT 0
          iv_bomb   TYPE abap_bool DEFAULT abap_false
        PREFERRED PARAMETER iv_number,
      has_bomb
        RETURNING VALUE(rv_flag) TYPE abap_bool,
      lif_map_site~display REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mv_bomb TYPE abap_bool.
ENDCLASS.


*& Abstract Factory - declares an interface for operations that create
*&   abstract product objects.
CLASS lcl_maze_factory DEFINITION.
  PUBLIC SECTION.
    METHODS:
      make_maze
        RETURNING VALUE(ro_maze) TYPE REF TO lcl_maze,
      make_wall
        RETURNING VALUE(ro_wall) TYPE REF TO lcl_wall,
      make_room
        IMPORTING iv_number TYPE i
        RETURNING VALUE(ro_room) TYPE REF TO lcl_room,
      make_door
        IMPORTING
          io_room1 TYPE REF TO lcl_room
          io_room2 TYPE REF TO lcl_room
        RETURNING VALUE(ro_door) TYPE REF TO lcl_door.
ENDCLASS.

CLASS lcl_maze_factory IMPLEMENTATION.
  METHOD make_maze.
    ro_maze = NEW #( ).
  ENDMETHOD.
  METHOD make_wall.
    ro_wall = NEW #( ).
  ENDMETHOD.
  METHOD make_room.
    ro_room = NEW #( iv_number ).
  ENDMETHOD.
  METHOD make_door.
    ro_door = NEW #( io_room1 = io_room1 io_room2 = io_room2 ).
  ENDMETHOD.
ENDCLASS.


*& Concrete Factory A - implements the operations to create concrete
*&   product objects.
CLASS lcl_enchanted_maze_factory DEFINITION FINAL
  INHERITING FROM lcl_maze_factory.

  PUBLIC SECTION.
    METHODS:
      make_room REDEFINITION,
      make_door REDEFINITION.
  PROTECTED SECTION.
    METHODS:
      cast_spell
        RETURNING VALUE(ro_spell) TYPE REF TO lcl_spell.
ENDCLASS.

CLASS lcl_enchanted_maze_factory IMPLEMENTATION.
  METHOD make_room.
    ro_room = NEW lcl_enchanted_room( iv_number = iv_number
                                      io_spell = cast_spell( ) ).
  ENDMETHOD.
  METHOD make_door.
    ro_door = NEW lcl_door_needing_spell( io_room1 = io_room1
                                          io_room2 = io_room2 ).
  ENDMETHOD.
  METHOD cast_spell.
    ro_spell = NEW lcl_spell( ).
  ENDMETHOD.
ENDCLASS.


*& Concrete Factory B - implements the operations to create concrete
*&   product objects.
CLASS lcl_bombed_maze_factory DEFINITION FINAL
  INHERITING FROM lcl_maze_factory.

  PUBLIC SECTION.
    METHODS:
      make_wall REDEFINITION,
      make_room REDEFINITION.
ENDCLASS.

CLASS lcl_bombed_maze_factory IMPLEMENTATION.
  METHOD make_wall.
    ro_wall = NEW lcl_bombed_wall( ).
  ENDMETHOD.
  METHOD make_room.
    ro_room = NEW lcl_room_with_a_bomb( iv_number ).
  ENDMETHOD.
ENDCLASS.


*& Client - uses only interfaces declared by Abstract Factory and
*&   Abstract Product classes.
CLASS lcl_maze_game DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      create_maze
        IMPORTING io_factory TYPE REF TO lcl_maze_factory
        RETURNING VALUE(ro_maze) TYPE REF TO lcl_maze.
ENDCLASS.

CLASS lcl_maze_game IMPLEMENTATION.
  METHOD create_maze.
    DATA(lo_maze) = io_factory->make_maze( ).
    DATA(lo_room1) = io_factory->make_room( 1 ).
    DATA(lo_room2) = io_factory->make_room( 2 ).
    DATA(lo_door) = io_factory->make_door( io_room1 = lo_room1
                                           io_room2 = lo_room2 ).

    lo_maze->add_room( lo_room1 ).
    lo_maze->add_room( lo_room2 ).

    lo_room1->set_side( io_direction = lcl_direction=>north
                        io_map_site  = io_factory->make_wall( ) ).
    lo_room1->set_side( io_direction = lcl_direction=>east
                        io_map_site  = lo_door ).
    lo_room1->set_side( io_direction = lcl_direction=>south
                        io_map_site  = io_factory->make_wall( ) ).
    lo_room1->set_side( io_direction = lcl_direction=>west
                        io_map_site  = io_factory->make_wall( ) ).

    lo_room2->set_side( io_direction = lcl_direction=>north
                        io_map_site  = io_factory->make_wall( ) ).
    lo_room2->set_side( io_direction = lcl_direction=>east
                        io_map_site  = io_factory->make_wall( ) ).
    lo_room2->set_side( io_direction = lcl_direction=>south
                        io_map_site  = io_factory->make_wall( ) ).
    lo_room2->set_side( io_direction = lcl_direction=>west
                        io_map_site  = lo_door ).

    ro_maze = lo_maze.
  ENDMETHOD.
ENDCLASS.


*& Collaboration:
*&  Normally a single instance of a Concrete Factory class is created
*&   at run-time. This concrete factory creates product objects having
*&   a particular implementation. To create different product objects,
*&   clients should use a different concrete factory.
*&  Abstract Factory defers creation of product objects to its Concrete
*&   Factory subclass.
INCLUDE yy_pao_include_maze_parts_impl.

CLASS ltc_maze_game_tester DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    CLASS-DATA:
      go_output TYPE REF TO if_demo_output.
    METHODS:
      teardown,
      dummy_bombed_maze FOR TESTING,
      dummy_enchanted_maze FOR TESTING.
    DATA:
      mo_maze TYPE REF TO lcl_maze.
ENDCLASS.

CLASS ltc_maze_game_tester IMPLEMENTATION.
  METHOD dummy_bombed_maze.
    go_output->next_section( |Bombed Maze Example| ).

    DATA(lo_game) = NEW lcl_maze_game( ).
    DATA(lo_factory) = NEW lcl_bombed_maze_factory( ).
    mo_maze = lo_game->create_maze( lo_factory ).
  ENDMETHOD.
  METHOD dummy_enchanted_maze.
    go_output->next_section( |Enchanted Maze Example| ).

    DATA(lo_game) = NEW lcl_maze_game( ).
    DATA(lo_factory) = NEW lcl_enchanted_maze_factory( ).
    mo_maze = lo_game->create_maze( lo_factory ).
  ENDMETHOD.
  METHOD teardown.
    go_output->write( mo_maze->display( ) ).
  ENDMETHOD.
  METHOD class_teardown.
    go_output->display( ).
  ENDMETHOD.
  METHOD class_setup.
    go_output = cl_demo_output=>new(
      )->begin_section( |Design Pattern Demo for Abstract Factory|
      )->line( ).
  ENDMETHOD.
ENDCLASS.
