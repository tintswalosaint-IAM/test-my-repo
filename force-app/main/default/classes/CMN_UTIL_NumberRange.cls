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
global class CMN_UTIL_NumberRange {
  /**
   * @description interface for number range
   */
  global interface INumberRange {
    Object min();

    Object max();

    Integer compare(Object number1, Object number2);

    String toArrayString();
  }

  /**
   * @description abstract implementation for number range
   */
  global abstract class NumberRange implements INumberRange {
    private Object min;
    private Object max;

    global NumberRange(Object number1) {
      if (number1 == null) {
        throw new IllegalArgumentException('illegal argument: null number');
      }
      min = max = number1;
    }

    global NumberRange(Object number1, Object number2) {
      if (number1 == null || number2 == null) {
        throw new IllegalArgumentException('illegal argument: null number');
      }

      if (compare(number1, number2) < 0) {
        min = number1;
        max = number2;
      } else {
        min = number2;
        max = number1;
      }
    }

    global virtual Integer compare(Object number1, Object number2) {
      return 0; /* override this method */
    }

    global String toArrayString() {
      return '[' + min + ',' + max + ']';
    }
  }

  /**
   * @description integer range
   */
  global class IntegerRange extends NumberRange {
    global IntegerRange(Integer number1) {
      super(number1);
    }

    global IntegerRange(Integer number1, Integer number2) {
      super(number1, number2);
    }

    global virtual override Integer compare(Object number1, Object number2) {
      super.compare(number1, number2);
      return (Integer) number1 < (Integer) number2
        ? -1
        : (Integer) number1 > (Integer) number2 ? 1 : 0;
    }

    global Integer max() {
      return (Integer) max;
    }

    global Integer min() {
      return (Integer) min;
    }

    global Boolean contains(Integer value) {
      return min() <= value && value <= max();
    }

    global Boolean contains(IntegerRange value) {
      return min() <= value.min() && value.max() <= max();
    }

    global Boolean overlaps(IntegerRange value) {
      return min() <= value.max() && value.min() <= max();
    }
  }

  /**
   * @description long range
   */
  global class LongRange extends NumberRange {
    global LongRange(Long number1) {
      super(number1);
    }

    global LongRange(Long number1, Long number2) {
      super(number1, number2);
    }

    global virtual override Integer compare(Object number1, Object number2) {
      super.compare(number1, number2);
      return (Long) number1 < (Long) number2
        ? -1
        : (Long) number1 > (Long) number2 ? 1 : 0;
    }

    global Long max() {
      return (Long) max;
    }

    global Long min() {
      return (Long) min;
    }

    global Boolean contains(Long value) {
      return min() <= value && value <= max();
    }

    global Boolean contains(LongRange value) {
      return min() <= value.min() && value.max() <= max();
    }

    global Boolean overlaps(LongRange value) {
      return min() <= value.max() && value.min() <= max();
    }
  }

  /**
   * @description Double range
   */
  global class DoubleRange extends NumberRange {
    global DoubleRange(Double number1) {
      super(number1);
    }

    global DoubleRange(Double number1, Double number2) {
      super(number1, number2);
    }

    global virtual override Integer compare(Object number1, Object number2) {
      super.compare(number1, number2);
      return (Double) number1 < (Double) number2
        ? -1
        : (Double) number1 > (Double) number2 ? 1 : 0;
    }

    global Double max() {
      return (Double) max;
    }

    global Double min() {
      return (Double) min;
    }

    global Boolean contains(Double value) {
      return min() <= value && value <= max();
    }

    global Boolean contains(DoubleRange value) {
      return min() <= value.min() && value.max() <= max();
    }

    global Boolean overlaps(DoubleRange value) {
      return min() <= value.max() && value.min() <= max();
    }
  }

  /**
   * @description Decimal range
   */
  global class DecimalRange extends NumberRange {
    global DecimalRange(Decimal number1) {
      super(number1);
    }

    global DecimalRange(Decimal number1, Decimal number2) {
      super(number1, number2);
    }

    global virtual override Integer compare(Object number1, Object number2) {
      super.compare(number1, number2);
      return (Decimal) number1 < (Decimal) number2
        ? -1
        : (Decimal) number1 > (Decimal) number2 ? 1 : 0;
    }

    global Decimal max() {
      return (Decimal) max;
    }

    global Decimal min() {
      return (Decimal) min;
    }

    global Boolean contains(Decimal value) {
      return min() <= value && value <= max();
    }

    global Boolean contains(DecimalRange value) {
      return min() <= value.min() && value.max() <= max();
    }

    global Boolean overlaps(DecimalRange value) {
      return min() <= value.max() && value.min() <= max();
    }
  }
}