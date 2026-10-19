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
 * <p>VCCC-378</p>
 * This project code has been forked and to update the latest salesforce APIs.
 */
global class CMN_UTIL_Comparators {
  /**
   * @description comparator to compare two objects used for sorting objects e.g. integers
   */
  global interface Comparator {
    Integer compare(Object object1, Object object2);
  }

  /**
   * @description comparator to compare two sobjects used for sorting objects e.g. Accounts
   */
  global interface SObjectComparator {
    Integer compare(SObject record1, SObject record2);
  }

  /**
   * @description should be used to compare primative object collections
   */
  global class PrimitiveComparator implements Comparator {
    global Integer compare(Object object1, Object object2) {
      if (object1 == null && object2 == null) {
        return 0;
      } else if (object1 == null) {
        return -1;
      } else if (object2 == null) {
        return 1;
      } else if (object1 instanceof Boolean && object2 instanceof Boolean) {
        return compare((Boolean) object1, (Boolean) object2);
      } else if (object1 instanceof Date && object2 instanceof Date) {
        return compare((Date) object1, (Date) object2);
      } else if (object1 instanceof Datetime && object2 instanceof Datetime) {
        return compare((Datetime) object1, (Datetime) object2);
      } else if (object1 instanceof Integer && object2 instanceof Integer) {
        return compare((Integer) object1, (Integer) object2);
      } else if (object1 instanceof Long && object2 instanceof Long) {
        return compare((Long) object1, (Long) object2);
      } else if (object1 instanceof Double && object2 instanceof Double) {
        return compare((Double) object1, (Double) object2);
      } else if (object1 instanceof Time && object2 instanceof Time) {
        return compare((Time) object1, (Time) object2);
      } else if (object1 instanceof String && object2 instanceof String) {
        return compare((String) object1, (String) object2);
      } else {
        throw new IllegalArgumentException(
          'Both arguments must be type Boolean, Date, Datetime, Decimal, Double, Id, Integer, Long, Time, or String'
        );
      }
    }

    global Integer compare(Boolean b1, Boolean b2) {
      if (!b1 && b2) {
        return -1;
      } else if (b1 == b2) {
        return 0;
      } else {
        return 1;
      }
    }

    global Integer compare(Date d1, Date d2) {
      if (d1 < d2) {
        return -1;
      } else if (d1 == d2) {
        return 0;
      } else {
        return 1;
      }
    }

    global Integer compare(Datetime d1, Datetime d2) {
      if (d1 < d2) {
        return -1;
      } else if (d1 == d2) {
        return 0;
      } else {
        return 1;
      }
    }

    global Integer compare(Double d1, Double d2) {
      if (d1 < d2) {
        return -1;
      } else if (d1 == d2) {
        return 0;
      }
      return 1;
    }

    global Integer compare(Integer i1, Integer i2) {
      if (i1 < i2) {
        return -1;
      } else if (i1 == i2) {
        return 0;
      }
      return 1;
    }

    global Integer compare(Long l1, Long l2) {
      if (l1 < l2) {
        return -1;
      } else if (l1 == l2) {
        return 0;
      }
      return 1;
    }

    global Integer compare(String s1, String s2) {
      if (s1 < s2) {
        return -1;
      } else if (s1 == s2) {
        return 0;
      }
      return 1;
    }

    global Integer compare(Time t1, Time t2) {
      return compare('' + t1, '' + t2);
    }
  }

  /**
   * @description should be used to compare decimal object collections
   */
  global class DecimalRangeComparator implements Comparator {
    global Integer compare(Object object1, Object object2) {
      if (
        (object1 == null) ||
        !(object1 instanceof CMN_UTIL_NumberRange.DecimalRange) ||
        (object2 == null) ||
        !(object2 instanceof CMN_UTIL_NumberRange.DecimalRange)
      ) {
        throw new IllegalArgumentException('Illegal Number or NumberRange');
      }

      Decimal decimal1 = ((CMN_UTIL_NumberRange.DecimalRange) object1).min();
      Decimal decimal2 = ((CMN_UTIL_NumberRange.DecimalRange) object2).min();

      if (decimal1 < decimal2) {
        return -1;
      } else if (decimal1 == decimal2) {
        return 0;
      } else {
        return 1;
      }
    }
  }

  /**
   * @description can be used to sort sobjects in-memory By Name Field Sobject Comparator
   */
  global class SObjectNameComparator implements SObjectComparator {
    global Integer compare(SObject record1, SObject record2) {
      if ((record1 == null) || record1.get('Name') == null) {
        if ((record2 == null) || record2.get('Name') == null) {
          return 0;
        } else {
          return -1;
        }
      }
      if ((record2 == null) || record2.get('Name') == null) {
        return 1;
      }
      return ('' + record1.get('Name')).compareTo('' + record2.get('Name'));
    }
  }

  /**
   * @description to sort SObject by sortBy Specific Field Sobject Comparator
   */
  global class SObjectSortByFieldComparator implements SObjectComparator {
    private final PrimitiveComparator primitiveComparator = new PrimitiveComparator();

    global String sortBy { get; set; }
    global Boolean sortAscending { get; set; }

    global SObjectSortByFieldComparator() {
      this(null, null);
    }

    global SObjectSortByFieldComparator(String sortBy) {
      this(sortBy, null);
    }

    global SObjectSortByFieldComparator(String sortBy, Boolean sortAscending) {
      this.sortBy = sortBy;
      this.sortAscending = sortAscending;
    }

    global Integer compare(SObject object1, SObject object2) {
      if (object1 == null && object2 == null) {
        return 0;
      } else if (object1 == null) {
        return -1;
      } else if (object2 == null) {
        return 1;
      }
      if (CMN_UTIL_String.isBlank(sortBy)) {
        throw new CMN_UTIL_Exceptions.IllegalStateException(
          'sortBy cannot be blank'
        );
      }

      Integer returnValue = primitiveComparator.compare(
        object1.get(sortBy),
        object2.get(sortBy)
      );

      if (sortAscending != null && !sortAscending) {
        if (returnValue == -1) {
          returnValue = 1;
        } else if (returnValue == 1) {
          returnValue = -1;
        }
      }
      return returnValue;
    }

    global List<SObject> sortSObjects(List<SObject> objects) {
      return sortSObjects(objects, null, null);
    }

    global List<SObject> sortSObjects(List<SObject> objects, String sortBy) {
      return sortSObjects(objects, sortBy, null);
    }

    global List<SObject> sortSObjects(
      List<SObject> objects,
      Boolean sortAscending
    ) {
      return sortSObjects(objects, null, sortAscending);
    }

    global List<SObject> sortSObjects(
      List<SObject> objects,
      String sortBy,
      Boolean sortAscending
    ) {
      if (CMN_UTIL_String.isBlank(sortBy))
        sortBy = 'Name';

      if (sortAscending == null)
        sortAscending = true;

      return sortSObjects(
        objects,
        new SObjectSortByFieldComparator(sortBy, sortAscending)
      );
    }

    global List<SObject> sortSObjects(
      List<SObject> objects,
      SObjectSortByFieldComparator comparator
    ) {
      return CMN_UTIL_Array.sortSObjects(objects, comparator);
    }
  }
}