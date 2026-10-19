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
global class CMN_SOQL_String {
  /**
   * @description converts object to string literal
   *
   * @param value as input
   *
   * @return string literal
   */
  global static String toLiteral(final Object value) {
    return toLiteral(value, null);
  }

  /**
   * @description converts object to string literal
   *
   * @param value as input
   * @param options as input
   *
   * @return string literal
   */
  global static String toLiteral(
    final Object value,
    CMN_SOQL_Query.SoqlOptions options
  ) {
    if (options == null) {
      options = CMN_SOQL_Query.DEFAULT_OPTIONS;
    }
    String literal = '';
    if (value == null) {
      literal += 'null';
    } else if (value instanceof CMN_SOQL_Query.Soqlable) {
      return ((CMN_SOQL_Query.Soqlable) value).toSoql(options);
    } else if (value instanceof String || value instanceof Id) {
      String manipulated = (String) value;
      if (options.escapeSingleQuotes == true) {
        manipulated = String.escapeSingleQuotes(manipulated);
      }
      literal += '\'' + manipulated + '\'';
    } else if (
      value instanceof Boolean ||
      value instanceof Integer ||
      value instanceof Long ||
      value instanceof Double ||
      value instanceof Decimal
    ) {
      literal += value;
    } else if (value instanceof Date) {
      literal += Datetime.newInstance(
          ((Date) value).year(),
          ((Date) value).month(),
          ((Date) value).day()
        )
        .format('yyyy-MM-dd');
    } else if (value instanceof Datetime) {
      literal +=
        ((Datetime) value).format('yyyy-MM-dd') +
        'T' +
        ((Datetime) value).format('hh:mm:ss') +
        'Z';
    } else {
      throw new IllegalArgumentException(
        'invalid value; value must be null, a primitive type ' +
        '(String|ID|Boolean|Integer|Long|Double|Decimal|Date|Datetime), or implement CMN_SOQL_Soqlable interface'
      );
    }
    return literal;
  }

  /**
   * @description converts object to string literal
   *
   * @param values as input
   *
   * @return list of string literals
   */
  global static List<String> toLiteral(final List<Object> values) {
    return toLiteral(values, CMN_SOQL_Query.DEFAULT_OPTIONS);
  }

  /**
   * @description converts object to string literal
   *
   * @param values as input
   * @param options as input
   *
   * @return list of string literals
   */
  global static List<String> toLiteral(
    final List<Object> values,
    final CMN_SOQL_Query.SoqlOptions options
  ) {
    final List<String> literals = new List<String>();
    if (values != null && values.size() > 0) {
      for (Object obj : values) {
        literals.add(toLiteral(obj, options));
      }
    }
    return literals;
  }

  /**
   * @description assets if two sql strings are equal
   *
   * @param expected as input
   * @param actual as input
   */
  global static void assertEquals(String expected, String actual) {
    System.assert(
      equals(expected, actual),
      'Assertion failed, the following two SOQLs are not equal. Expected: ' +
      expected +
      ', Actual: ' +
      actual
    );
  }

  /**
   * @description This equals is fairly simplistic.  It will account for unordered columns,
   * lower vs upper case (SELECT vs select) but it won't take into account anything else.  Different
   * order of where conditions for example.
   *
   * @param soql1 as input
   * @param soql2 as input
   *
   * @return boolean is equals or not
   */
  global static Boolean equals(String soql1, String soql2) {
    if (soql1.contains('\n') != soql2.contains('\n')) {
      return false;
    }

    soql1 = CMN_UTIL_String.replace(
      CMN_UTIL_String.trim(CMN_UTIL_String.lowerCase(soql1)),
      '\n',
      ''
    );
    soql2 = CMN_UTIL_String.replace(
      CMN_UTIL_String.trim(CMN_UTIL_String.lowerCase(soql2)),
      '\n',
      ''
    );

    if (CMN_UTIL_String.equals(soql1, soql2)) {
      return true;
    }

    if (
      !CMN_UTIL_String.startsWith(soql1, 'select') ||
      !CMN_UTIL_String.startsWith(soql2, 'select')
    ) {
      return false;
    }

    String afterSelect1 = CMN_UTIL_String.trim(
      CMN_UTIL_String.substringAfter(soql1, 'select')
    );
    String afterSelect2 = CMN_UTIL_String.trim(
      CMN_UTIL_String.substringAfter(soql2, 'select')
    );

    Set<String> columns1 = CMN_UTIL_String.trimAll(
      CMN_UTIL_Set.listToSet(
        CMN_UTIL_String.split(
          CMN_UTIL_String.trim(
            CMN_UTIL_String.substringBeforeLast(afterSelect1, ' from ')
          ),
          ','
        )
      )
    );
    Set<String> columns2 = CMN_UTIL_String.trimAll(
      CMN_UTIL_Set.listToSet(
        CMN_UTIL_String.split(
          CMN_UTIL_String.trim(
            CMN_UTIL_String.substringBeforeLast(afterSelect2, ' from ')
          ),
          ','
        )
      )
    );

    if (!CMN_UTIL_Set.equals(columns1, columns2)) {
      return false;
    }

    String afterFrom1 = CMN_UTIL_String.trim(
      CMN_UTIL_String.substringAfterLast(soql1, ' from ')
    );
    String afterFrom2 = CMN_UTIL_String.trim(
      CMN_UTIL_String.substringAfterLast(soql2, ' from ')
    );
    return CMN_UTIL_String.equals(afterFrom1, afterFrom2);
  }
}