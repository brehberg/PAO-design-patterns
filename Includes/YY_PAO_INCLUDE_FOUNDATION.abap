*&---------------------------------------------------------------------*
*&  Include           YY_PAO_INCLUDE_FOUNDATION
*&---------------------------------------------------------------------*

TYPES:
  ty_coordinate  TYPE i.

CLASS lcl_point DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      class_constructor.
    CLASS-DATA
      zero TYPE REF TO lcl_point READ-ONLY.
    METHODS:
      constructor
        IMPORTING
          iv_x TYPE ty_coordinate DEFAULT 0
          iv_y TYPE ty_coordinate DEFAULT 0,
      x RETURNING VALUE(rv_x) TYPE ty_coordinate,
      y RETURNING VALUE(rv_y) TYPE ty_coordinate.
  PRIVATE SECTION.
    DATA:
      mv_x TYPE ty_coordinate,
      mv_y TYPE ty_coordinate.
ENDCLASS.

CLASS lcl_point IMPLEMENTATION.
  METHOD class_constructor.
    zero = NEW #( ).
  ENDMETHOD.
  METHOD constructor.
    mv_x = iv_x.
    mv_y = iv_y.
  ENDMETHOD.
  METHOD x.
    rv_x = mv_x.
  ENDMETHOD.
  METHOD y.
    rv_y = mv_y.
  ENDMETHOD.
ENDCLASS.
