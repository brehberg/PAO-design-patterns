*&---------------------------------------------------------------------*
*&  Sample code for the Observer Design Pattern in ABAP
*&    based on Chapter 5 : Behavioral Patterns; Page 293
*&---------------------------------------------------------------------*
*& Purpose:
*&  Define a one-to-many dependency between objects so that when one
*&   object changes state, all its dependents are notified and updated
*&   automatically.
*&  Also known as a Dependent or Publish-Subscribe
*&---------------------------------------------------------------------*
*& Applications:
*&  When an abstraction has two aspects, one dependent on the other.
*&   Encapsulating these aspects in separate objects lets you vary and
*&   reuse them independently.
*&  When a change to one object requires changing others, and you don't
*&   know how many objects need to be changed.
*&  When an object should be able to notify other objects without making
*&   assumptions about who these objects are. In other words, you don't
*&   want these objects tightly coupled.
*&---------------------------------------------------------------------*
PROGRAM yy_pao_pattern_observer.


*& Observer - defines an updating interface for objects that should be
*&   notified of changes in a subject.
CLASS lcl_subject DEFINITION DEFERRED.

INTERFACE lif_observer.
  METHODS:
    update
      IMPORTING io_changed_subject TYPE REF TO lcl_subject.
ENDINTERFACE.


*& Subject - knows its observers. Any number of Observer objects may
*&   observe a subject. Also it provides an interface for attaching and
*&   detaching Observer objects.
CLASS lcl_subject DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      attach
        IMPORTING io_observer TYPE REF TO lif_observer,
      detach
        IMPORTING io_observer TYPE REF TO lif_observer,
      notify.
  PRIVATE SECTION.
    DATA:
      mt_observers TYPE STANDARD TABLE OF REF TO lif_observer
        WITH EMPTY KEY.
ENDCLASS.

CLASS lcl_subject IMPLEMENTATION.
  METHOD attach.
    APPEND io_observer TO mt_observers.
  ENDMETHOD.
  METHOD detach.
    DELETE mt_observers WHERE table_line = io_observer.
  ENDMETHOD.
  METHOD notify.
    LOOP AT mt_observers INTO DATA(lo_observer).
      lo_observer->update( me ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


*& Concrete Subject - stores state of interest to Concrete Observer
*&   objects. Also it sends a notification to its observers when its
*&   state changes.
CLASS lcl_clock_timer DEFINITION FINAL INHERITING FROM lcl_subject.
  PUBLIC SECTION.
    METHODS:
      hour
        RETURNING VALUE(rv_hour) TYPE numc2,
      minute
        RETURNING VALUE(rv_minute) TYPE numc2,
      second
        RETURNING VALUE(rv_second) TYPE numc2,
      tick.
  PRIVATE SECTION.
    DATA:
      mv_time TYPE t.
ENDCLASS.

CLASS lcl_clock_timer IMPLEMENTATION.
  METHOD tick.
    " update internal time-keeping state
    GET TIME FIELD mv_time.
    notify( ).
  ENDMETHOD.
  METHOD hour.
    rv_hour = mv_time+0(2).
  ENDMETHOD.
  METHOD minute.
    rv_minute = mv_time+2(2).
  ENDMETHOD.
  METHOD second.
    rv_second = mv_time+4(2).
  ENDMETHOD.
ENDCLASS.


*& Concrete Observer A - maintains a reference to a Concrete Subject
*&   object and stores state that should stay consistent with the
*&   subject's. Also it implements the Observer updating interface to
*&   keep its state consistent with the subject's.
CLASS lcl_widget DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS:
      draw ABSTRACT.       " defines how to draw the digital clock
    "...
ENDCLASS.

CLASS lcl_digital_clock DEFINITION FINAL INHERITING FROM lcl_widget.
  PUBLIC SECTION.
    INTERFACES:
      lif_observer.        " includes Observer method definition
    METHODS:
      constructor
        IMPORTING io_timer TYPE REF TO lcl_clock_timer,
      draw REDEFINITION.   " overrides Widget method implementation
  PRIVATE SECTION.
    DATA:
      mo_subject TYPE REF TO lcl_clock_timer.
ENDCLASS.

CLASS lcl_digital_clock IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mo_subject = io_timer.
  ENDMETHOD.
  METHOD lif_observer~update.
    IF io_changed_subject = mo_subject.
      draw( ).
    ENDIF.
  ENDMETHOD.
  METHOD draw.
    " get the new values from the subject
    DATA(lv_hour) = mo_subject->hour( ).
    DATA(lv_minute) = mo_subject->minute( ).
    DATA(lv_second) = mo_subject->second( ).
    " draw the digital clock
    cl_demo_output=>write( |Drawing LCL_DIGITAL_CLOCK with time | &&
                           |{ lv_hour }:{ lv_minute }:{ lv_second }| ).
  ENDMETHOD.
ENDCLASS.


*& Concrete Observer B - maintains a reference to a Concrete Subject
*&   object and stores state that should stay consistent with the
*&   subject's. Also it implements the Observer updating interface to
*&   keep its state consistent with the subject's.
CLASS lcl_analog_clock DEFINITION FINAL INHERITING FROM lcl_widget.
  PUBLIC SECTION.
    INTERFACES:
      lif_observer.
    METHODS:
      constructor
        IMPORTING io_timer TYPE REF TO lcl_clock_timer,
      draw REDEFINITION.
  PRIVATE SECTION.
    DATA:
      mo_timer TYPE REF TO lcl_clock_timer.
ENDCLASS.

CLASS lcl_analog_clock IMPLEMENTATION.
  METHOD constructor.
    super->constructor( ).
    mo_timer = io_timer.
  ENDMETHOD.
  METHOD lif_observer~update.
    IF io_changed_subject = mo_timer.
      draw( ).
    ENDIF.
  ENDMETHOD.
  METHOD draw.
    DATA(lv_hour) = mo_timer->hour( ).
    DATA(lv_minute) = mo_timer->minute( ).
    DATA(lv_second) = mo_timer->second( ).
    cl_demo_output=>write( |Drawing LCL_ANALOG_CLOCK with time | &&
                           |{ lv_hour }:{ lv_minute }:{ lv_second }| ).
  ENDMETHOD.
ENDCLASS.


*& Collaboration:
*&  Concrete Subject notifies its observers whenever a change occurs
*&   that could make its observers' state inconsistent with its own.
*&  After being informed of a change in the concrete subject, a
*&   Concrete Observer object may query the subject for information.
*&   Concrete Observer uses this information to reconcile its state with
*&   that of the subject.
CLASS ltc_clock_timer_tester DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION LONG.

  PRIVATE SECTION.
    CLASS-METHODS:
      class_setup,
      class_teardown.
    METHODS:
      setup,
      teardown,
      example_with_two_observers FOR TESTING,
      example_with_one_observer FOR TESTING.
    DATA:
      mo_timer TYPE REF TO lcl_clock_timer.
ENDCLASS.

CLASS ltc_clock_timer_tester IMPLEMENTATION.
  METHOD example_with_two_observers.
    cl_demo_output=>next_section( |With both clocks attached| ).

    " configure Observer pattern objects
    DATA(lo_analog)  = NEW lcl_analog_clock( mo_timer ).
    mo_timer->attach( lo_analog ).
    DATA(lo_digital) = NEW lcl_digital_clock( mo_timer ).
    mo_timer->attach( lo_digital ).
  ENDMETHOD.
  METHOD example_with_one_observer.
    cl_demo_output=>next_section( |With only one clock attached| ).

    DATA(lo_analog)  = NEW lcl_analog_clock( mo_timer ).
    mo_timer->attach( lo_analog ).
    DATA(lo_digital) = NEW lcl_digital_clock( mo_timer ).
    mo_timer->attach( lo_digital ).
    mo_timer->detach( lo_analog ).
  ENDMETHOD.
  METHOD teardown.
    " change subject to notify observers
    mo_timer->tick( ).
    WAIT UP TO 1 SECONDS.
    mo_timer->tick( ).
  ENDMETHOD.
  METHOD setup.
    mo_timer = NEW #( ).
  ENDMETHOD.
  METHOD class_teardown.
    cl_demo_output=>display( ).
  ENDMETHOD.
  METHOD class_setup.
    cl_demo_output=>begin_section( |Design Pattern Demo for Observer| ).
    cl_demo_output=>line( ).
  ENDMETHOD.
ENDCLASS.
