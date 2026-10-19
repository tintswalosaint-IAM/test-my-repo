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
global class CMN_SOQL_Builder implements CMN_SOQL_Query.Soqlable {
  private Boolean selectAll = false;
  private Boolean selectAvg = false;
  private Boolean selectCount = false;
  private Boolean selectMax = false;
  private Boolean selectMin = false;
  private Boolean selectSum = false;
  private Boolean withSecurityEnforced = false;
  private CMN_SOQL_Query.Condition whereX = null;
  private Integer limitX = null;
  private Integer offsetX = null;
  private List<CMN_SOQL_Query.OrderBy> orderByX = null;
  private Set<Object> selectSet = null;
  private String aggregateX = null;
  private String fromX = null;
  private String groupByX = null;

  global CMN_SOQL_Builder() {
  }

  global CMN_SOQL_Builder selectAll() {
    selectAll = true;
    return this;
  }

  global CMN_SOQL_Builder selectX(String field) {
    return addToSelect(field);
  }

  global CMN_SOQL_Builder selectX(CMN_SOQL_Query.Field field) {
    return addToSelect(field);
  }

  global CMN_SOQL_Builder selectX(CMN_SOQL_Builder field) {
    return addToSelect(field);
  }

  global CMN_SOQL_Builder selectX(List<Object> fields) {
    return selectX(CMN_UTIL_Set.listToSet(fields));
  }

  global CMN_SOQL_Builder selectX(Set<Object> fields) {
    if ((fields != null) && !fields.isEmpty()) {
      for (Object field : fields) {
        addToSelect(field);
      }
    }
    return this;
  }

  global CMN_SOQL_Builder selectX(List<String> fields) {
    return selectX(CMN_UTIL_Set.listToSet(fields));
  }

  global CMN_SOQL_Builder selectX(Set<String> fields) {
    if ((fields != null) && !fields.isEmpty()) {
      for (String field : fields) {
        addToSelect(field);
      }
    }

    return this;
  }

  private CMN_SOQL_Builder addToSelect(Object field) {
    if (field == null) {
      throw new IllegalArgumentException('Null field');
    }

    if (
      (field instanceof String) ||
      (field instanceof CMN_SOQL_Query.Field) ||
      (field instanceof CMN_SOQL_Builder)
    ) {
      if (selectSet == null) {
        selectSet = new Set<Object>();
      }
      selectSet.add(field);
    } else {
      throw new IllegalArgumentException(
        'Invalid field type. A field must be either a String, CMN_SOQL_Query.Field, or CMN_SOQL_Builder.'
      );
    }

    this.selectCount = false;

    return this;
  }

  global CMN_SOQL_Builder selectCount() {
    return selectCountX();
  }

  global CMN_SOQL_Builder selectCountX() {
    this.selectCount = true;
    return this;
  }

  global CMN_SOQL_Builder selectCount(String aggregateX) {
    this.aggregateX = aggregateX;
    return selectCountX();
  }

  global CMN_SOQL_Builder selectAverageX(String aggregateX) {
    this.selectAvg = true;
    this.aggregateX = aggregateX;
    return this;
  }

  global CMN_SOQL_Builder selectSumX(String aggregateX) {
    this.selectSum = true;
    this.aggregateX = aggregateX;
    return this;
  }

  global CMN_SOQL_Builder selectMinX(String aggregateX) {
    this.selectMin = true;
    this.aggregateX = aggregateX;
    return this;
  }

  global CMN_SOQL_Builder selectMaxX(String aggregateX) {
    this.selectMax = true;
    this.aggregateX = aggregateX;
    return this;
  }

  global CMN_SOQL_Builder fromX(String fromX) {
    this.fromX = fromX;
    return this;
  }

  global CMN_SOQL_Builder whereX(CMN_SOQL_Query.Condition whereX) {
    this.whereX = whereX;
    return this;
  }

  global CMN_SOQL_Builder withSecurityEnforced(Boolean withSecurityEnforced) {
    this.withSecurityEnforced = withSecurityEnforced;
    return this;
  }

  global CMN_SOQL_Builder orderByX(CMN_SOQL_Query.OrderBy orderByX) {
    if (this.orderByX == null) {
      this.orderByX = new List<CMN_SOQL_Query.OrderBy>();
    }

    this.orderByX.add(orderByX);
    return this;
  }

  global CMN_SOQL_Builder orderByX(List<CMN_SOQL_Query.OrderBy> orderByX) {
    if ((orderByX != null) && !orderByX.isEmpty()) {
      for (CMN_SOQL_Query.OrderBy field : orderByX) {
        orderByX(field);
      }
    }

    return this;
  }

  global CMN_SOQL_Builder groupByX(String groupByX) {
    this.groupByX = groupByX;
    return this;
  }

  global CMN_SOQL_Builder limitX(Integer limitX) {
    this.limitX = limitX;
    return this;
  }

  global CMN_SOQL_Builder offsetX(Integer offsetX) {
    this.offsetX = offsetX;
    return this;
  }

  global String toSoql() {
    return this.toSoql(null);
  }

  global String toSoql(CMN_SOQL_Query.SoqlOptions options) {
    if (options == null) {
      options = CMN_SOQL_Query.DEFAULT_OPTIONS;
    }

    if (CMN_UTIL_String.isBlank(fromX)) {
      throw new CMN_UTIL_Exceptions.IllegalStateException(
        'Illegal state! You must invoke fromX() with valid object name before invoking toSoql().'
      );
    }

    String separator = ' ' + (options.breakLineBetweenClauses ? '\n' : '');
    Boolean isFirst = true;
    String soql = 'SELECT ';

    if (selectSet == null) {
      selectSet = new Set<Object>();
    }

    if (
      (this.selectCount != null) &&
      this.selectCount &&
      (aggregateX == null)
    ) {
      soql += 'COUNT()';
    } else if (this.selectCount != null && this.selectCount) {
      soql += 'COUNT(' + aggregateX + ')';
    } else if (this.selectAvg != null && this.selectAvg) {
      soql += 'AVG(' + aggregateX + ')';
    } else if (this.selectSum != null && this.selectSum) {
      soql += 'SUM(' + aggregateX + ')';
    } else if (this.selectMin != null && this.selectMin) {
      soql += 'MIN(' + aggregateX + ')';
    } else if (this.selectMax != null && this.selectMax) {
      soql += 'MAX(' + aggregateX + ')';
    } else {
      if (this.selectAll) {
        selectSet.addAll(getAllFieldNames(fromX));
      }

      if (selectSet.isEmpty()) {
        selectSet.add('Id');
      }

      String distinctField = null;

      Map<String, String> distinctFields = new Map<String, String>();

      for (Object value : selectSet) {
        if (value instanceof CMN_SOQL_Query.Field) {
          distinctField = ((CMN_SOQL_Query.Field) value).toSoql(options);
        } else if (value instanceof CMN_SOQL_Builder) {
          distinctField =
            '(' +
            ((CMN_SOQL_Builder) value).toSoql(options) +
            ')';
        } else {
          distinctField = '' + value;
        }
        distinctField = CMN_UTIL_String.trim(distinctField);
        distinctFields.put(
          CMN_UTIL_String.lowerCase(distinctField),
          distinctField
        );
      }
      //soql += CMN_UTIL_String.joinStrings(distinctFields.values(), separator + ',');
      soql += CMN_UTIL_String.joinStrings(distinctFields.values(), ', ');
    }

    soql += separator + 'FROM ' + fromX;

    if (whereX != null) {
      final String whereXs = whereX.toSoql(options);

      if (CMN_UTIL_String.isNotBlank(whereXs)) {
        soql += separator + 'WHERE ' + whereXs;
      }
    }

    if (withSecurityEnforced) {
      soql += separator + 'WITH SECURITY_ENFORCED';
    }

    if ((groupByX != null) && (groupByX != '')) {
      soql += separator + 'GROUP BY ' + groupByX + ' ';
    }

    if ((orderByX != null) && !orderByX.isEmpty()) {
      isFirst = true;

      for (CMN_SOQL_Query.OrderBy orderBy : orderByX) {
        if (orderBy == null) {
          continue;
        }

        if (isFirst) {
          isFirst = false;
          soql += separator + 'ORDER BY ';
        } else {
          soql += ', ';
        }
        soql += orderBy.toSoql(options);
      }
    }

    if (limitX != null) {
      soql += separator + 'LIMIT ' + limitX;
    }

    if (offsetX != null) {
      soql += separator + 'OFFSET ' + offsetX;
    }

    return soql;
  }

  /**
   * @description
   *
   * @param sobjectTypeName as input
   *
   * @return set of api fields
   */
  private static Set<Object> getAllFieldNames(String sobjectTypeName) {
    final Set<Object> returnValue = new Set<Object>();

    sobjectTypeName = CMN_UTIL_String.lowerCase(
      CMN_UTIL_String.trim(sobjectTypeName)
    );

    final Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

    if (
      (globalDescribe != null) && globalDescribe.containsKey(sobjectTypeName)
    ) {
      final Schema.SObjectType objectToken = globalDescribe.get(
        sobjectTypeName
      );

      if (objectToken != null) {
        final Map<String, Schema.SObjectField> fieldNameToFieldIndex = objectToken.getDescribe()
          .fields.getMap();

        if (
          (fieldNameToFieldIndex != null) && !fieldNameToFieldIndex.isEmpty()
        ) {
          for (String fieldName : fieldNameToFieldIndex.keySet()) {
            returnValue.add(
              fieldNameToFieldIndex.get(fieldName).getDescribe().getName()
            );
          }
        }
      }
    }
    return returnValue;
  }
}