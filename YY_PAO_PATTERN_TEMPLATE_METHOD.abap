*&---------------------------------------------------------------------*
*&  Sample code for the Template Method Design Pattern in ABAP
*&    based on Chapter 5 : Behavioral Patterns; Page 325
*&---------------------------------------------------------------------*
*& Purpose:
*&  Define the skeleton of an algorithm in an operation, deferring some
*&   steps to subclasses. The Template Method pattern lets subclasses
*&   redefine certain steps of an algorithm without changing the
*&   algorithm's structure.
*&---------------------------------------------------------------------*
*& Applications:
*&  To implement the invariant parts of an algorithm once and leave it
*&   up to subclasses to implement the behavior that can vary.
*&  When common behavior among subclasses should be refactored and
*&   localized in a common class to avoid code duplication. This is a
*&   good example of "refactoring to generalize". You first identify the
*&   differences in the existing code and then separate the differences
*&   into new operations. Finally, you replace the differing code with a
*&   template method that calls one of these new operations.
*&  To control subclasses extensions. You can define a template method
*&   that calls "hook" operations at specific points, thereby permitting
*&   extensions only at those points.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_template_method.


*& Abstract Class - defines abstract primitive operations that concrete
*&   subclasses define to implement steps of an algorithm. Also it
*&   implements a template method defining the skeleton of an algorithm.
*&   The template method calls primitive operations as well as
*&   operations defined in Abstract Class or those of other objects.
CLASS lcl_view DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      display.
  PROTECTED SECTION.
    METHODS:
      do_display ABSTRACT.
  PRIVATE SECTION.
    METHODS:
      set_focus,
      reset_focus.
ENDCLASS.

CLASS lcl_view IMPLEMENTATION.
  METHOD display.
    " the template method
    set_focus( ).
    do_display( ).
    reset_focus( ).
  ENDMETHOD.
  METHOD set_focus.
    cl_demo_output=>write( |Called SET_FOCUS for LCL_VIEW| ).
    "...
  ENDMETHOD.
  METHOD reset_focus.
    cl_demo_output=>write( |Called RESET_FOCUS for LCL_VIEW| ).
    "..
  ENDMETHOD.
ENDCLASS.


*& Concrete Class A - implements the primitive operations to carry out
*&   subclass-specific steps of the algorithm.
CLASS lcl_my_view DEFINITION FINAL INHERITING FROM lcl_view.
  PROTECTED SECTION.
    METHODS:
      do_display REDEFINITION.
ENDCLASS.

CLASS lcl_my_view IMPLEMENTATION.
  METHOD do_display.
    cl_demo_output=>write( |Called DO_DISPLAY for LCL_MY_VIEW| ).
    " render the view's contents
  ENDMETHOD.
ENDCLASS.


*& Concrete Class B - implements the primitive operations to carry out
*&   subclass-specific steps of the algorithm.
CLASS lcl_another_view DEFINITION FINAL INHERITING FROM lcl_view.
  PROTECTED SECTION.
    METHODS:
      do_display REDEFINITION.
ENDCLASS.

CLASS lcl_another_view IMPLEMENTATION.
  METHOD do_display.
    cl_demo_output=>write( |Called DO_DISPLAY for LCL_ANOTHER_VIEW| ).
    " render the view's contents
  ENDMETHOD.
ENDCLASS.


*& Collaboration:
*&  Concrete Class relies on Abstract Class to implement the invariant
*&   steps of the algorithm.
CLASS ltc_template_method_tester DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      teardown,
      dummy_create_my_view FOR TESTING,
      dummy_create_another_view FOR TESTING.
    DATA:
      mo_view TYPE REF TO lcl_view.
ENDCLASS.

CLASS ltc_template_method_tester IMPLEMENTATION.
  METHOD dummy_create_my_view.
    cl_demo_output=>next_section( |My View Example| ).

    mo_view = NEW lcl_my_view( ).
  ENDMETHOD.
  METHOD dummy_create_another_view.
    cl_demo_output=>next_section( |Another View Example| ).

    mo_view = NEW lcl_another_view( ).
  ENDMETHOD.
  METHOD teardown.
    mo_view->display( ).
  ENDMETHOD.
  METHOD class_teardown.
    cl_demo_output=>display( ).
  ENDMETHOD.
  METHOD class_setup.
    cl_demo_output=>begin_section(
                      |Design Pattern Demo for Template Method| ).
    cl_demo_output=>line( ).
  ENDMETHOD.
ENDCLASS.
