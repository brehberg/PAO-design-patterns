*&---------------------------------------------------------------------*
*&  Sample code for the Adapter Design Pattern in ABAP
*&    based on Chapter 4 : Structural Patterns; Page 139
*&---------------------------------------------------------------------*
*& Purpose:
*&  Convert the interface of a class into another interface clients
*&   expect. The Adapter pattern lets classes work together that
*&   couldn’t otherwise because of incompatible interfaces.
*&  Also known as a Wrapper.
*&---------------------------------------------------------------------*
*& Applications:
*&  You want to use an existing class, and its interface does not match
*&   the one you need.
*&  You want to create a reusable class that cooperates with unrelated
*&   or unforeseen classes, that is, classes that don’t necessarily have
*&   compatible interfaces.
*&  You need to use several existing subclasses, but it’s impractical to
*&   adapt their interface by subclassing every one. An object adapter
*&   can adapt the interface of its parent class.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_adapter.

INCLUDE yy_pao_include_foundation.


*& Target - defines the domain-specific interface that Client uses.
CLASS lcl_manipulator DEFINITION DEFERRED.

CLASS lcl_shape DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING
          io_origin TYPE REF TO lcl_point OPTIONAL
          io_size   TYPE REF TO lcl_point OPTIONAL,
      bounding_box
        EXPORTING
          VALUE(eo_bottom_left) TYPE REF TO lcl_point
          VALUE(eo_top_right)   TYPE REF TO lcl_point,
      create_manipulator
        RETURNING VALUE(ro_obj) TYPE REF TO lcl_manipulator.
  PRIVATE SECTION.
    DATA:
      mo_origin TYPE REF TO lcl_point,
      mo_size   TYPE REF TO lcl_point.
ENDCLASS.


*& Client - collaborates w/ objects conforming to the Target interface.
CLASS lcl_manipulator DEFINITION.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING io_shape TYPE REF TO lcl_shape,
      display
        RETURNING VALUE(rv_output) TYPE string.
  PRIVATE SECTION.
    DATA:
      mo_shape TYPE REF TO lcl_shape.
ENDCLASS.

CLASS lcl_shape IMPLEMENTATION.
  METHOD constructor.
    mo_origin = COND #( WHEN io_origin IS BOUND
                        THEN io_origin ELSE lcl_point=>zero ).
    mo_size   = COND #( WHEN io_size IS BOUND
                        THEN io_size ELSE lcl_point=>zero ).
  ENDMETHOD.
  METHOD bounding_box.
    eo_bottom_left = NEW #( iv_x = mo_origin->x( )
                            iv_y = mo_origin->y( ) ).
    eo_top_right = NEW #( iv_x = mo_origin->x( ) + mo_size->x( )
                          iv_y = mo_origin->y( ) + mo_size->y( ) ).
  ENDMETHOD.
  METHOD create_manipulator.
    ro_obj = NEW lcl_manipulator( me ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_manipulator IMPLEMENTATION.
  METHOD constructor.
    mo_shape = io_shape.
  ENDMETHOD.
  METHOD display.
    mo_shape->bounding_box(
      IMPORTING
        eo_bottom_left = DATA(lo_bl)
        eo_top_right   = DATA(lo_tr) ).

    rv_output = |Bottom-left is at | &&
                |{ lo_bl->x( ) },{ lo_bl->y( ) }| &&
                |\n| && |Top-right is at | &&
                |{ lo_tr->x( ) },{ lo_tr->y( ) }|.
  ENDMETHOD.
ENDCLASS.


*& Adaptee - defines an existing interface that needs adapting.
CLASS lcl_text_view DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor,
      " these methods form the legacy API of the Adaptee
      get_origin
        EXPORTING
          ev_x TYPE ty_coordinate
          ev_y TYPE ty_coordinate,
      get_extent
        EXPORTING
          ev_width TYPE ty_coordinate
          ev_height TYPE ty_coordinate,
      is_empty
        RETURNING VALUE(rv_flag) TYPE abap_bool.
  PRIVATE SECTION.
    DATA:
      mv_origin_x TYPE ty_coordinate,
      mv_origin_y TYPE ty_coordinate,
      mv_width    TYPE ty_coordinate,
      mv_height   TYPE ty_coordinate,
      mv_empty    TYPE abap_bool.
ENDCLASS.

CLASS lcl_text_view IMPLEMENTATION.
  METHOD constructor.
    " dummy data values in the Adaptee from some legacy source
    mv_origin_x = 4.
    mv_origin_y = 5.
    mv_width    = 10.
    mv_height   = 5.
    mv_empty    = abap_true.
  ENDMETHOD.
  METHOD get_origin.
    ev_x = mv_origin_x.
    ev_y = mv_origin_y.
  ENDMETHOD.
  METHOD get_extent.
    ev_width  = mv_width.
    ev_height = mv_height.
  ENDMETHOD.
  METHOD is_empty.
    rv_flag = mv_empty.
  ENDMETHOD.
ENDCLASS.


*& Adapter - adapts the interface of Adaptee to the Target interface.
CLASS lcl_text_shape DEFINITION FINAL INHERITING FROM lcl_shape.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING io_text_view TYPE REF TO lcl_text_view,
      is_empty
        RETURNING VALUE(rv_flag) TYPE abap_bool,
      bounding_box REDEFINITION,
      create_manipulator REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mo_text TYPE REF TO lcl_text_view.
ENDCLASS.

CLASS lcl_text_manipulator DEFINITION FINAL
  INHERITING FROM lcl_manipulator.

  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING io_text_shape TYPE REF TO lcl_text_shape,
      display REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mo_text_shape TYPE REF TO lcl_text_shape.
ENDCLASS.

CLASS lcl_text_shape IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mo_text = io_text_view.
  ENDMETHOD.
  METHOD bounding_box.
    " convert the Adaptee interface to support the Target interface
    mo_text->get_origin( IMPORTING
                           ev_x = DATA(lv_bottom)
                           ev_y = DATA(lv_left) ).
    mo_text->get_extent( IMPORTING
                           ev_width  = DATA(lv_width)
                           ev_height = DATA(lv_height) ).

    eo_bottom_left = NEW #( iv_x = lv_bottom
                            iv_y = lv_left ).
    eo_top_right = NEW #( iv_x = lv_bottom + lv_height
                          iv_y = lv_left + lv_width ).
  ENDMETHOD.
  METHOD is_empty.
    " directly forward supported requests to the Adaptee object
    rv_flag = mo_text->is_empty( ).
  ENDMETHOD.
  METHOD create_manipulator.
    " implement new methods not supported by Adaptee interface
    ro_obj = NEW lcl_text_manipulator( me ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_text_manipulator IMPLEMENTATION.
  METHOD constructor.
    super->constructor( io_text_shape ).
    mo_text_shape = io_text_shape.
  ENDMETHOD.
  METHOD display.
    rv_output = super->display( ) && |\n| &&
                COND #( WHEN mo_text_shape->is_empty( )
                        THEN |The text view is empty|
                        ELSE |The text view is not empty| ).
  ENDMETHOD.
ENDCLASS.


*& Collaboration
*&  Clients call operations on an Adapter instance. In turn, the adapter
*&    calls Adaptee operations that carry out the request.
CLASS ltc_adapter_tester DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    CLASS-DATA:
      go_output TYPE REF TO if_demo_output.
    METHODS:
      teardown,
      no_adapter_example FOR TESTING,
      with_adapter_example FOR TESTING.
    DATA:
      mo_client TYPE REF TO lcl_manipulator.
ENDCLASS.

CLASS ltc_adapter_tester IMPLEMENTATION.
  METHOD no_adapter_example.
    go_output->next_section( |Unadapted Example| ).

    " Non-adapted Shape object
    DATA(lo_shape) = NEW lcl_shape( ).
    mo_client = lo_shape->create_manipulator( ).
  ENDMETHOD.
  METHOD with_adapter_example.
    go_output->next_section( |Adapted Example| ).

    " Text_View object adapted to Shape interface
    DATA(lo_view) = NEW lcl_text_view( ).
    DATA(lo_text) = NEW lcl_text_shape( lo_view ).
    mo_client = lo_text->create_manipulator( ).
  ENDMETHOD.
  METHOD teardown.
    go_output->write( mo_client->display( ) ).
  ENDMETHOD.
  METHOD class_teardown.
    go_output->display( ).
  ENDMETHOD.
  METHOD class_setup.
    go_output = cl_demo_output=>new(
      )->begin_section( |Design Pattern Demo for Adapter|
      )->line( ).
  ENDMETHOD.
ENDCLASS.
