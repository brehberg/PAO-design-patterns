*&---------------------------------------------------------------------*
*&  Sample code for the Decorator Design Pattern in ABAP
*&    based on Chapter 4 : Structural Patterns; Page 175
*&---------------------------------------------------------------------*
*& Purpose:
*&  Attach additional responsibilities to an object dynamically. The
*&   Decorator pattern provides a flexible alternative to subclassing
*&   for extending functionality.
*&  Also known as a Wrapper.
*&---------------------------------------------------------------------*
*& Applications:
*&  To add responsibilities to individual objects dynamically and
*&   transparently, that is, without affecting other objects.
*&  For responsibilities that can be withdrawn.
*&  When extension by subclassing is impractical. Sometimes a large
*&   number of independent extensions are possible and would produce an
*&   explosion of subclasses to support every combination. Or a class
*&   definition may be hidden or otherwise unavailable for subclassing.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_decorator.


*& Component - defines the interface for objects that can have
*&   responsibilities added to them dynamically.
INTERFACE lif_visual_component.
  METHODS:
    draw,
    resize.
  "...
ENDINTERFACE.


*& Concrete Component - defines an object to which additional
*&   responsibilities can be attached.
CLASS lcl_text_view DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES:
      lif_visual_component.
    "...
ENDCLASS.

CLASS lcl_text_view IMPLEMENTATION.
  METHOD lif_visual_component~draw.
    cl_demo_output=>write( |Drawing component LCL_TEXT_VIEW| ).
  ENDMETHOD.
  METHOD lif_visual_component~resize.
    cl_demo_output=>write( |Resizing component LCL_TEXT_VIEW| ).
  ENDMETHOD.
ENDCLASS.


*& Decorator - maintains a reference to a Component object and defines
*&   an interface that conforms to Component's interface.
CLASS lcl_decorator DEFINITION ABSTRACT.
  PUBLIC SECTION.
    INTERFACES:
      lif_visual_component.
    METHODS:
      constructor
        IMPORTING
          io_component TYPE REF TO lif_visual_component.
    "...
  PRIVATE SECTION.
    DATA:
      mo_component TYPE REF TO lif_visual_component.
ENDCLASS.

CLASS lcl_decorator IMPLEMENTATION.
  METHOD constructor.
    mo_component = io_component.
  ENDMETHOD.
  METHOD lif_visual_component~draw.
    mo_component->draw( ).
  ENDMETHOD.
  METHOD lif_visual_component~resize.
    mo_component->resize( ).
  ENDMETHOD.
ENDCLASS.


*& Concrete Decorator A - adds responsibilities to the component.
CLASS lcl_border_decorator DEFINITION INHERITING FROM lcl_decorator.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING io_component    TYPE REF TO lif_visual_component
                  iv_border_width TYPE i,
      lif_visual_component~draw REDEFINITION.
  PRIVATE SECTION.
    METHODS:
      draw_border
        IMPORTING iv_width TYPE i.
    DATA:
      mv_width TYPE i.
ENDCLASS.

CLASS lcl_border_decorator IMPLEMENTATION.
  METHOD constructor.
    super->constructor( io_component ).
    mv_width = iv_border_width.
  ENDMETHOD.
  METHOD lif_visual_component~draw.
    super->lif_visual_component~draw( ).
    draw_border( mv_width ).
  ENDMETHOD.
  METHOD draw_border.
    cl_demo_output=>write( |Drawing decorator LCL_BORDER_DECORATOR| &&
                           | with width = { iv_width }| ).
  ENDMETHOD.
ENDCLASS.


*& Concrete Decorator B - adds responsibilities to the component.
CLASS lcl_scroll_decorator DEFINITION INHERITING FROM lcl_decorator.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING io_component TYPE REF TO lif_visual_component,
      lif_visual_component~draw REDEFINITION.
  PRIVATE SECTION.
    METHODS:
      draw_scroll_bar.
ENDCLASS.

CLASS lcl_scroll_decorator IMPLEMENTATION.
  METHOD constructor.
    super->constructor( io_component ).
  ENDMETHOD.
  METHOD lif_visual_component~draw.
    super->lif_visual_component~draw( ).
    draw_scroll_bar( ).
  ENDMETHOD.
  METHOD draw_scroll_bar.
    cl_demo_output=>write( |Drawing decorator LCL_SCROLL_DECORATOR| ).
  ENDMETHOD.
ENDCLASS.


*& Collaboration
*&  Decorator forwards requests to its Component object. It may
*&   optionally perform addtional operations before and after
*&   forwarding the request.
CLASS lth_window DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      set_contents
        IMPORTING io_contents TYPE REF TO lif_visual_component,
      draw_content,
      resize_content.
    "...
  PRIVATE SECTION.
    DATA:
      mo_contents TYPE REF TO lif_visual_component.
ENDCLASS.

CLASS lth_window IMPLEMENTATION.
  METHOD set_contents.
    mo_contents = io_contents.
  ENDMETHOD.
  METHOD draw_content.
    mo_contents->draw( ).
  ENDMETHOD.
  METHOD resize_content.
    mo_contents->resize( ).
  ENDMETHOD.
ENDCLASS.

CLASS ltc_window_tester DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      setup,
      teardown,
      undecorated_example FOR TESTING,
      decorated_example FOR TESTING.
    DATA:
      mo_window    TYPE REF TO lth_window.
ENDCLASS.

CLASS ltc_window_tester IMPLEMENTATION.
  METHOD undecorated_example.
    cl_demo_output=>next_section( |Undecorated Example| ).

    DATA(lo_text_view) = NEW lcl_text_view( ).
    mo_window->set_contents( lo_text_view ).
  ENDMETHOD.
  METHOD decorated_example.
    cl_demo_output=>next_section( |Decorated Example| ).

    " create Concrete Component and two Decorators
    DATA(lo_text_view) = NEW lcl_text_view( ).
    mo_window->set_contents(
      NEW lcl_scroll_decorator(
        NEW lcl_border_decorator( io_component    = lo_text_view
                                  iv_border_width = 1 ) ) ).
  ENDMETHOD.
  METHOD teardown.
    mo_window->resize_content( ).
    mo_window->draw_content( ).
  ENDMETHOD.
  METHOD setup.
    mo_window = NEW #( ).
  ENDMETHOD.
  METHOD class_teardown.
    cl_demo_output=>display( ).
  ENDMETHOD.
  METHOD class_setup.
    cl_demo_output=>begin_section(
      |Design Pattern Demo for Decorator| ).
    cl_demo_output=>line( ).
  ENDMETHOD.
ENDCLASS.
