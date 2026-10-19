/**
 * @description This code is part of the "apex-lang" open-source project release 1.18 available at:
 * <p/>
 * http://code.google.com/p/apex-lang/
 * <p/>
 * Copyright (2012) richard van hook
 * <p/>
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * <p/>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p/>
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * <p/>
 * This project code has been forked and to update the latest salesforce APIs.
 * <p/>
 * <p>VCCC-378</p>
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_StopWatch_TEST {
  @IsTest
  private static void testStopWatchSimple() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    watch.start();
    watch.stop();
    Long timex = watch.getTime();
    System.assertEquals(timex, watch.getTime());
    watch.reset();
    System.assertEquals(0, watch.getTime());
    watch.toStr();
  }

  @IsTest
  private static void testStopWatchSimpleGet() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    System.assertEquals(0, watch.getTime());
    watch.start();
    System.assert(watch.getTime() < 2000);
  }

  @IsTest
  private static void testStopWatchSplit() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    watch.start();
    watch.split();
    Long splitTime = watch.getSplitTime();
    watch.unsplit();
    watch.stop();
    Long totalTime = watch.getTime();

    System.assert(splitTime < 700);
    System.assert(totalTime < 700);
  }

  @IsTest
  private static void testStopWatchSuspend() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    watch.start();
    watch.suspend();
    Long suspendTime = watch.getTime();
    watch.resume();
    watch.stop();

    System.assert(suspendTime < 700);
  }

  @IsTest
  private static void testLang315() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    watch.start();
    watch.suspend();
    Long suspendTime = watch.getTime();
    watch.stop();
    Long totalTime = watch.getTime();
    System.assertEquals(suspendTime, totalTime);
  }

  @IsTest
  private static void testGetSplitString() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    watch.start();
    watch.split();
    System.assert(watch.toSplitString() != null);
    watch.stop();
  }

  @IsTest
  private static void testGetSplitStringIllegalStateException() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    try {
      watch.getSplitTime();
      System.assert(false);
    } catch (CMN_UTIL_Exceptions.IllegalStateException e) {
      System.assert(true);
    }
  }

  @IsTest
  private static void testBadStates() {
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    Boolean exceptionCaught = false;
    try {
      watch.stop();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling stop on an unstarted CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.stop();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling stop on an unstarted CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.suspend();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling suspend on an unstarted CMN_UTIL_StopWatch should throw an exception.'
    );

    exceptionCaught = false;
    try {
      watch.split();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling split on a non-running CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.unsplit();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling unsplit on an unsplit CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.resume();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling resume on an unsuspended CMN_UTIL_StopWatch should throw an exception. '
    );

    watch.start();

    exceptionCaught = false;
    try {
      watch.start();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling start on a started CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.unsplit();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling unsplit on an unsplit CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.getSplitTime();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling getSplitTime on an unsplit CMN_UTIL_StopWatch should throw an exception. '
    );

    exceptionCaught = false;
    try {
      watch.resume();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling resume on an unsuspended CMN_UTIL_StopWatch should throw an exception. '
    );

    watch.stop();

    exceptionCaught = false;
    try {
      watch.start();
    } catch (CMN_UTIL_Exceptions.IllegalStateException ise) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling start on a stopped CMN_UTIL_StopWatch should throw an exception as it needs to be reset. '
    );
  }

  @IsTest
  private static void testGetStartTime() {
    Long beforeStopWatch = System.currentTimeMillis();
    CMN_UTIL_StopWatch watch = new CMN_UTIL_StopWatch();
    Boolean exceptionCaught = false;
    try {
      watch.getStartTime();
    } catch (CMN_UTIL_Exceptions.IllegalStateException expected) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling getStartTime on an unstarted CMN_UTIL_StopWatch should throw an exception'
    );
    watch.start();
    exceptionCaught = true;
    String msg = null;
    try {
      watch.getStartTime();
      System.assert(watch.getStartTime() >= beforeStopWatch);
      exceptionCaught = false;
    } catch (CMN_UTIL_Exceptions.IllegalStateException ex) {
      msg = ex.getMessage();
    }
    System.assert(!exceptionCaught, 'Start time should be available: ' + msg);
    watch.reset();
    exceptionCaught = false;
    try {
      watch.getStartTime();
    } catch (CMN_UTIL_Exceptions.IllegalStateException expected) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught,
      'Calling getStartTime on a reset, but unstarted CMN_UTIL_StopWatch should throw an exception'
    );
  }
}