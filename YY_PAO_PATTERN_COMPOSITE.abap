*&---------------------------------------------------------------------*
*&  Sample code for the Composite Design Pattern in ABAP
*&    based on Chapter 4 : Structural Patterns; Page 163
*&---------------------------------------------------------------------*
*& Purpose:
*&  Compose objects into tree structures to represent part-whole
*&   hierarchies. The Composite pattern lets clients treat individual
*&   objects and compositions of objects uniformly.
*&---------------------------------------------------------------------*
*& Applications:
*&  You want to represent part-whole hierarchies of objects.
*&  You want clients to be able to ignore the difference between
*&   compositions of objects and individual objects. Clients will treat
*&   all objects in the composite structure uniformly.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_composite.


*& Component - declares the interface for objects in the composition.
*&   Also implements default behavior for the interface common to all
*&   classes, as appropriate, and declares an interface for accessing
*&   and managing its child components. Optionally, it also defines an
*&   interface for accessing a component's parent in the recursive
*&   structure, and implements it if that's appropriate.
CLASS lcl_equipment DEFINITION ABSTRACT.
  PUBLIC SECTION.
    TYPES:
      ty_watt TYPE i,
      ty_currency TYPE i.
    METHODS:
      constructor
        IMPORTING iv_name TYPE string,
      name
        RETURNING VALUE(rv_name) TYPE string,
      discount_price
        RETURNING VALUE(rv_price) TYPE ty_currency,
      power ABSTRACT
        RETURNING VALUE(rv_power) TYPE ty_watt,
      net_price ABSTRACT
        RETURNING VALUE(rv_price) TYPE ty_currency,
      add ABSTRACT
        IMPORTING io_equipment TYPE REF TO lcl_equipment,
      remove ABSTRACT
        IMPORTING io_equipment TYPE REF TO lcl_equipment.
  PROTECTED SECTION.
    DATA:
      mv_power TYPE i VALUE 0,
      mv_price TYPE i VALUE 1.
  PRIVATE SECTION.
    DATA:
      mv_name  TYPE string.
ENDCLASS.

CLASS lcl_equipment IMPLEMENTATION.
  METHOD constructor.
    mv_name = iv_name.
  ENDMETHOD.
  METHOD name.
    rv_name = mv_name.
  ENDMETHOD.
  METHOD discount_price.
    rv_price = net_price( ) / 2.
  ENDMETHOD.
ENDCLASS.

CLASS lcx_unsupported_operation DEFINITION FINAL
  INHERITING FROM cx_dynamic_check.

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING iv_text TYPE string,
      get_text REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mv_text TYPE string.
ENDCLASS.

CLASS lcx_unsupported_operation IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mv_text = iv_text.
  ENDMETHOD.
  METHOD get_text.
    result = mv_text.
  ENDMETHOD.
ENDCLASS.


*& Leaf - represents leaf objects in the composition. A leaf has no
*&   children. Also defines behavior for primitive objects in the
*&   composition.
CLASS lcl_primitive_equipment DEFINITION ABSTRACT
  INHERITING FROM lcl_equipment.

  PUBLIC SECTION.
    METHODS:
      power REDEFINITION,
      net_price REDEFINITION,
      add REDEFINITION,
      remove REDEFINITION.
ENDCLASS.

CLASS lcl_primitive_equipment IMPLEMENTATION.
  METHOD power.
    rv_power = mv_power.
  ENDMETHOD.
  METHOD net_price.
    rv_price = mv_price.
  ENDMETHOD.
  METHOD add.
    RAISE EXCEPTION TYPE lcx_unsupported_operation
      EXPORTING iv_text = |Cannot add to Primitive Equipment|.
  ENDMETHOD.
  METHOD remove.
    RAISE EXCEPTION TYPE lcx_unsupported_operation
      EXPORTING iv_text = |Cannot remove from Primitive Equipment|.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_disk_drive DEFINITION INHERITING FROM lcl_primitive_equipment.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING iv_name TYPE string.
ENDCLASS.

CLASS lcl_disk_drive IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_name ).
    mv_power = 2.
    mv_price = 10.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_card DEFINITION INHERITING FROM lcl_primitive_equipment.
  "...
ENDCLASS.


*& Composite - defines behavior for components having children. Also
*&   stores child components and implements child-related operations in
*&   the Component interface.
CLASS lcl_composite_equipment DEFINITION ABSTRACT
  INHERITING FROM lcl_equipment.

  PUBLIC SECTION.
    METHODS:
      power REDEFINITION,
      net_price REDEFINITION,
      add REDEFINITION,
      remove REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mt_equipment
        TYPE STANDARD TABLE OF REF TO lcl_equipment WITH EMPTY KEY.
ENDCLASS.

CLASS lcl_composite_equipment IMPLEMENTATION.
  METHOD power.
    " accumulate the total power for all child equipment of this node
    rv_power = REDUCE #( INIT total = mv_power
                         FOR item IN mt_equipment
                         NEXT total = total + item->power( ) ).
  ENDMETHOD.
  METHOD net_price.
    " accumulate the total price for all child equipment of this node
    rv_price = REDUCE #( INIT total = mv_price
                         FOR item IN mt_equipment
                         NEXT total = total + item->net_price( ) ).
  ENDMETHOD.
  METHOD add.
    APPEND io_equipment TO mt_equipment.
  ENDMETHOD.
  METHOD remove.
    DELETE mt_equipment WHERE table_line = io_equipment.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_chassis DEFINITION INHERITING FROM lcl_composite_equipment.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING iv_name TYPE string.
ENDCLASS.

CLASS lcl_chassis IMPLEMENTATION.
  METHOD constructor.
    super->constructor( iv_name ).
    mv_power = 42.
    mv_price = 100.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_cabinet DEFINITION INHERITING FROM lcl_composite_equipment.
  "...
ENDCLASS.
CLASS lcl_bus DEFINITION INHERITING FROM lcl_composite_equipment.
  "...
ENDCLASS.


*& Client - manipulates objects in the composition through the
*&   Component interface.
CLASS lcl_simple_computer DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      assemble
        RETURNING VALUE(ro_comp) TYPE REF TO lcl_equipment.
ENDCLASS.

CLASS lcl_simple_computer IMPLEMENTATION.
  METHOD assemble.
    DATA(lo_cabinet) = NEW lcl_cabinet( |PC cabinet| ).
    DATA(lo_chassis) = NEW lcl_chassis( |PC chassis| ).

    lo_cabinet->add( lo_chassis ).

    DATA(lo_bus) = NEW lcl_bus( |MCA Bus| ).
    lo_bus->add( NEW lcl_card( |16Mbs Token Ring| ) ).

    lo_chassis->add( lo_bus ).
    lo_chassis->add( NEW lcl_disk_drive( |3.5in Floppy| ) ).

    lo_cabinet->remove( lo_chassis ).

    ro_comp = lo_chassis.
  ENDMETHOD.
ENDCLASS.


*& Collaboration
*&  Clients use the Component class interface to interact with objects
*&   in the composite structure. If the recipient is a Leaf, then the
*&   request is handled directly. If the recipient is a Composite, then
*&   it usually forwards requests to its child components, possibly
*&   performing additional operations before and/or after forwarding.
CLASS ltc_computer_tester DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    CLASS-DATA:
      go_output TYPE REF TO if_demo_output.
    METHODS:
      teardown,
      check_computer_equipment FOR TESTING,
      check_basic_equipment FOR TESTING.
    DATA:
      mo_component TYPE REF TO lcl_equipment.
ENDCLASS.

CLASS ltc_computer_tester IMPLEMENTATION.
  METHOD check_basic_equipment.
    go_output->next_section( |Leaf Component Example| ).

    mo_component = NEW lcl_disk_drive( |3.5in Floppy| ).
  ENDMETHOD.
  METHOD check_computer_equipment.
    go_output->next_section( |Composite Component Example| ).

    " create a complex tree structure
    mo_component = lcl_simple_computer=>assemble( ).
  ENDMETHOD.
  METHOD teardown.
    go_output->write( |{ mo_component->name( ) }:|
      )->write( |\tTotal power is { mo_component->power( ) } kW|
      )->write( |\tNet price is ${ mo_component->net_price( ) }|
      )->write( |\tDiscount is ${ mo_component->discount_price( ) }| ).
  ENDMETHOD.
  METHOD class_teardown.
    go_output->display( ).
  ENDMETHOD.
  METHOD class_setup.
    go_output = cl_demo_output=>new(
      )->begin_section( |Design Pattern Demo for Composite|
      )->line( ).
  ENDMETHOD.
ENDCLASS.
