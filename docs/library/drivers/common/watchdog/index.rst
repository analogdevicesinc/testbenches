.. _watchdog:

Watchdog
================================================================================

Overview
-------------------------------------------------------------------------------

The purpose of this class is to provide an object that can stop a simulation
run, most importantly to prevent system hangs, never ending simulation runs.
The designer of the test stimulus needs to have a good understanding of the
design under test to be able to configure the watchdog module properly. The
watchdog object can be used on the entire test stimulus or on smaller test
cases, where there is a moderate chance that the system may hang, and to
prevent such instances to happen.

Variables
-------------------------------------------------------------------------------

None are available for direct external access.

Functions
-------------------------------------------------------------------------------

function new(bit [31:0] timer, string message);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creates the watchdog object. The timer variable is used to set the default
timer value after which the watchdog is triggered. This value must be set in
nanoseconds. The message value sets the default output message when the
watchdog is triggered.

function void update_message(string message);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to update the timer value. The timer variable is used to set the new timer
value after which the watchdog is triggered.

function void update_timer(bit [31:0] timer);
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Used to update the watchdog message. The message value sets the watchdog output
message when this is triggered. This value must be set in nanoseconds.

task start();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Starts the watchdog timer in a separate thread. This allows other code to be
run in parallel with it. When the watchdog timer reaches the wait time that was
set prior to starting of the watchdog, either with a default value or an
updated value, it is triggered, prints out the watchdog message and then the
simulation is halted. If the watchdog receives a stop event, the thread is
killed and the counting stops. This means that the watchdog will not trigger in
this instance and the simulation will not be halted.

task stop();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Stops the watchdog timer when called. Used when the designer wants to stop the
watchdog timer.

task reset();
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Stops and then starts again the watchdog timer using the start and stop
functions.

Usage and recommendations
-------------------------------------------------------------------------------

Basic usage of the watchdog timer:

* Declare the watchdog timer, give an initial value for the timer and the
  message. These can be changed later
* Update the watchdog timer value and message if needed
* Start the watchdog timer
* Add test stimulus that needs to be timed by the watchdog timer
* Stop the watchdog timer if the stimulus finished the process

.. important::

  * The watchdog timer value must be set higher than the time the stimulus needs
    to finish the execution of the process. At the initial development of the
    test stimulus, this value should be oversized by a couple times the estimated
    value, to ensure that the test case has enough time to complete the process
    in case the original execution time is well underestimated. After a couple of
    iterations when the process execution time bounds are known, the watchdog
    timer should be reduced to the value that is: highest execution time for the
    process +20-30% of this time to ensure that the process can terminate
    properly.
  * Multiple instances of the same watchdog timer object should not be started,
    before the previous one is stopped. This will cause multiple instances of the
    same watchdog to be started in separate threads. When the stop function is
    called for this watchdog timer object, it will stop all currently active
    watchdog timers. To use multiple watchdog timers all at the same  time,
    multiple watchdog timer objects need to be created, each with its own message
    and timer value. This will allow each one of these to be controlled
    independently.

Other use-cases for the watchdog timer:

* Repetitive test stimulus that takes a long time to finish and may cause
  system hanging. In this case it is more advisable have a watchdog timer
  stopped and started or reset each time a repetitive task is completed. This
  allows for a stricter watchdog timer value, which may stop a hanging
  simulation sooner without waiting for the whole process to finish. 

.. include:: ../../../../common/support.rst
