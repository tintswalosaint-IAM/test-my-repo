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
 * <p/>
 *    This is run time utility which can be used for timing running tasks.
 * </p>
 * <p>VCCC-378</p>
 */
global class CMN_UTIL_StopWatch {
  // running states
  private static final Integer STATE_UNSTARTED = 0;
  private static final Integer STATE_RUNNING = 1;
  private static final Integer STATE_STOPPED = 2;
  private static final Integer STATE_SUSPENDED = 3;

  // split state
  private static final Integer STATE_UNSPLIT = 10;
  private static final Integer STATE_SPLIT = 11;

  private Integer runningState = STATE_UNSTARTED;
  private Integer splitState = STATE_UNSPLIT;
  private Long startTime = -1;
  private Long stopTime = -1;

  /**
   * @description start the stop watch
   */
  global void start() {
    if (this.runningState == STATE_STOPPED) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch must be reset before being restarted. '
      );
    }
    if (this.runningState != STATE_UNSTARTED) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch already started. '
      );
    }
    this.stopTime = -1;
    this.startTime = System.currentTimeMillis();
    this.runningState = STATE_RUNNING;
  }

  /**
   * @description stop the stop watch
   */
  global void stop() {
    if (
      this.runningState != STATE_RUNNING &&
      this.runningState != STATE_SUSPENDED
    ) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch is not running. '
      );
    }
    if (this.runningState == STATE_RUNNING) {
      this.stopTime = System.currentTimeMillis();
    }
    this.runningState = STATE_STOPPED;
  }

  /**
   * @description reset the stop watch
   */
  global void reset() {
    this.runningState = STATE_UNSTARTED;
    this.splitState = STATE_UNSPLIT;
    this.startTime = -1;
    this.stopTime = -1;
  }

  /**
   * @description split the stop watch time
   */
  global void split() {
    if (this.runningState != STATE_RUNNING) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch is not running. '
      );
    }
    this.stopTime = System.currentTimeMillis();
    this.splitState = STATE_SPLIT;
  }

  /**
   * @description unsplit the stop watch time
   */
  global void unsplit() {
    if (this.splitState != STATE_SPLIT) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch has not been split. '
      );
    }
    this.stopTime = -1;
    this.splitState = STATE_UNSPLIT;
  }

  /**
   * @description suspend the stop watch
   */
  global void suspend() {
    if (this.runningState != STATE_RUNNING) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch must be running to suspend. '
      );
    }
    this.stopTime = System.currentTimeMillis();
    this.runningState = STATE_SUSPENDED;
  }

  /**
   * @description resume the stop watch
   */
  global void resume() {
    if (this.runningState != STATE_SUSPENDED) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch must be suspended to resume. '
      );
    }
    this.startTime += (System.currentTimeMillis() - this.stopTime);
    this.stopTime = -1;
    this.runningState = STATE_RUNNING;
  }

  /**
   * @description
   *
   * @return get the current run time
   */
  global Long getTime() {
    if (
      this.runningState == STATE_STOPPED ||
      this.runningState == STATE_SUSPENDED
    ) {
      return this.stopTime - this.startTime;
    } else if (this.runningState == STATE_RUNNING) {
      return System.currentTimeMillis() - this.startTime;
    }
    return 0;
  }

  /**
   * @description
   *
   * @return get the split time
   */
  global Long getSplitTime() {
    if (this.splitState != STATE_SPLIT) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch must be split to get the split time. '
      );
    }
    return this.stopTime - this.startTime;
  }

  /**
   * @description
   *
   * @return get the start time
   */
  global Long getStartTime() {
    if (this.runningState == STATE_UNSTARTED) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Stopwatch has not been started'
      );
    }
    return this.startTime;
  }

  /**
   * @description
   *
   * @return the run time to string
   */
  global String toStr() {
    return Datetime.newInstance(getTime()).format();
  }

  /**
   * @description
   *
   * @return the split time to string
   */
  global String toSplitString() {
    return Datetime.newInstance(getSplitTime()).format();
  }
}