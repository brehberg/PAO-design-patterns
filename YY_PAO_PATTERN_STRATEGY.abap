*&---------------------------------------------------------------------*
*&  Sample code for the Strategy Design Pattern in ABAP
*&    based on Chapter 5 : Behavioral Patterns; Page 315
*&---------------------------------------------------------------------*
*& Purpose:
*&  Define a family of algorithms, encapsulate each one, and make them
*&   interchangeable. The Strategy pattern lets the algorithm vary
*&   independently from clients that use it.
*&  Also known as a Policy.
*&---------------------------------------------------------------------*
*& Applications:
*&  Many related classes differ only in their behavior. Strategies
*&   provide a way to configure a class with one of many behaviors.
*&  You need different variants of an algorithm. For example, you might
*&   define algorithms reflecting different space/time trade-offs.
*&   Strategies can be used when these variants are implemented as a
*&   class hierarchy of algorithms.
*&  An algorithm uses data that clients shouldn't know about. Use the
*&   Strategy pattern to avoid exposing complex, algorithm-specific data
*&   structures.
*&  A class defines many behaviors, and these appear as multiple
*&   conditional statements in its operations. Instead of many
*&   conditionals, move related conditional branches into their own
*&   Strategy class.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_strategy.


*& Strategy - declares an interface common to all supported algorithms.
*&   Context uses this interface to call the algorithm defined by a
*&   Concrete Strategy.
INTERFACE lif_compositor.
  METHODS:
    compose
      IMPORTING
        it_natural    TYPE integers
        it_stretch    TYPE integers
        it_shrink     TYPE integers
        iv_line_count TYPE i
        iv_line_width TYPE i
        it_breaks     TYPE integers
      RETURNING VALUE(rv_break_count) TYPE i.
ENDINTERFACE.


*& Concrete Strategy A - implements the algorithm using the Strategy
*&   interface.
CLASS lcl_simple_compositor DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES:
      lif_compositor.
    "...
ENDCLASS.

CLASS lcl_simple_compositor IMPLEMENTATION.
  METHOD lif_compositor~compose.
    cl_demo_output=>write( |Called COMPOSE for LCL_SIMPLE_COMPOSITOR| ).
    rv_break_count = 1.
  ENDMETHOD.
ENDCLASS.


*& Concrete Strategy B - implements the algorithm using the Strategy
*&   interface.
CLASS lcl_text_compositor DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES:
      lif_compositor.
    "...
ENDCLASS.

CLASS lcl_text_compositor IMPLEMENTATION.
  METHOD lif_compositor~compose.
    cl_demo_output=>write( |Called COMPOSE for LCL_TEXT_COMPOSITOR| ).
    rv_break_count = 2.
  ENDMETHOD.
ENDCLASS.


*& Concrete Strategy C - implements the algorithm using the Strategy
*&   interface.
CLASS lcl_array_compositor DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES:
      lif_compositor.
    METHODS:
      constructor
        IMPORTING iv_interval TYPE i.
    "...
  PRIVATE SECTION.
    DATA:
      mv_interval TYPE i.
ENDCLASS.

CLASS lcl_array_compositor IMPLEMENTATION.
  METHOD constructor.
    mv_interval = iv_interval.
  ENDMETHOD.
  METHOD lif_compositor~compose.
    cl_demo_output=>write( |Called COMPOSE for LCL_ARRAY_COMPOSITOR | &&
                           |with an interval of { mv_interval }| ).
    rv_break_count = 3.
  ENDMETHOD.
ENDCLASS.


*& Context - is configured with a Concrete Strategy object. Also it
*&   maintains a reference to a Strategy object and may define an
*&   interface that lets Strategy access its data.
CLASS lcl_composition DEFINITION FINAL.
  PUBLIC SECTION.
    METHODS:
      constructor
        IMPORTING io_compositor TYPE REF TO lif_compositor,
      repair.
  PRIVATE SECTION.
    DATA:
      mo_compositor TYPE REF TO lif_compositor,
      mv_line_width      TYPE i,        " the compositions's line width
      mv_line_count      TYPE i,        " the number of lines
      mt_line_breaks     TYPE integers. " the position of line breaks
ENDCLASS.

CLASS lcl_composition IMPLEMENTATION.
  METHOD constructor.
    mo_compositor      = io_compositor.
    mv_line_width      = 72.
    mv_line_count      = 20.
    mt_line_breaks     = VALUE integers( ( 1 ) ( 2 ) ).
  ENDMETHOD.
  METHOD repair.
    DATA(lt_dummy_data) = VALUE integers( ( 1 ) ( 2 ) ( 3 ) ).
    " prepare the arrays with the desired sizes
    DATA(lt_natural)         = lt_dummy_data.
    DATA(lt_stretchability)  = lt_dummy_data.
    DATA(lt_shrinkability)   = lt_dummy_data.
    " determine where the breaks are
    DATA(lv_break_count) = mo_compositor->compose(
                             it_natural    = lt_natural
                             it_stretch    = lt_stretchability
                             it_shrink     = lt_shrinkability
                             iv_line_count = mv_line_count
                             iv_line_width = mv_line_width
                             it_breaks     = mt_line_breaks ).
    " layout lines according to breaks
    cl_demo_output=>write( |Adjusting layout in LCL_COMPOSITION | &&
                           |with { lv_break_count } line breaks.| ).
  ENDMETHOD.
ENDCLASS.


*& Collaboration:
*&  Strategy and Context interact to implement the chosen algorithm. A
*&   context may pass all data required by the algorithm to the strategy
*&   when the algorithm is called. Alternatively, the context can pass
*&   itself as an argument to Strategy operations. That lets the
*&   strategy call back on the context as required.
*&  A context forwards requests from its clients to its strategy.
*&   Clients usually create and pass a Concrete Strategy object to the
*&   context; thereafter, clients interact with the context exclusively.
*&   There is often a family of Concrete Strategy classes for a client
*&   to choose from.
CLASS ltc_compose_strategy_tester DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      teardown,
      dummy_simple_composition FOR TESTING,
      dummy_text_composition FOR TESTING,
      dummy_array_composition FOR TESTING.
    DATA:
      mo_composition TYPE REF TO lcl_composition.
ENDCLASS.

CLASS ltc_compose_strategy_tester IMPLEMENTATION.
  METHOD dummy_simple_composition.
    cl_demo_output=>next_section( |Simple Compositor Example| ).

    DATA(lo_quick) = NEW lcl_composition(
                       NEW lcl_simple_compositor( ) ).
    mo_composition = lo_quick.
  ENDMETHOD.
  METHOD dummy_text_composition.
    cl_demo_output=>next_section( |Text Compositor Example| ).

    DATA(lo_slick) = NEW lcl_composition(
                       NEW lcl_text_compositor( ) ).
    mo_composition = lo_slick.
  ENDMETHOD.
  METHOD dummy_array_composition.
    cl_demo_output=>next_section( |Array Compositor Example| ).

    DATA(lo_iconic) = NEW lcl_composition(
                        NEW lcl_array_compositor( 100 ) ).
    mo_composition = lo_iconic.
  ENDMETHOD.
  METHOD teardown.
    " three contexts each following different strategies
    mo_composition->repair( ).
  ENDMETHOD.
  METHOD class_teardown.
    cl_demo_output=>display( ).
  ENDMETHOD.
  METHOD class_setup.
    cl_demo_output=>begin_section( |Design Pattern Demo for Strategy| ).
    cl_demo_output=>line( ).
  ENDMETHOD.
ENDCLASS.
