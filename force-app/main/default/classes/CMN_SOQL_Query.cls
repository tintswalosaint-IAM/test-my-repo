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
global class CMN_SOQL_Query {
  // Field = Value
  global static Condition equalsX(String field, Object value) {
    return new FieldCondition(field, EQUALS, value);
  }

  // Field != Value
  global static Condition notEquals(String field, Object value) {
    return new FieldCondition(field, NOT_EQUALS, value);
  }

  // Field < Value
  global static Condition lessThan(String field, Object value) {
    return new FieldCondition(field, LESS_THAN, value);
  }

  // Field <= Value
  global static Condition lessThanOrEqualTo(String field, Object value) {
    return new FieldCondition(field, LESS_THAN_OR_EQUAL_TO, value);
  }

  // Field > Value
  global static Condition greaterThan(String field, Object value) {
    return new FieldCondition(field, GREATER_THAN, value);
  }

  // Field >= Value
  global static Condition greaterThanOrEqualTo(String field, Object value) {
    return new FieldCondition(field, GREATER_THAN_OR_EQUAL_TO, value);
  }

  // Field LIKE Value
  global static Condition likeX(String field, Object value) {
    return new FieldCondition(field, LIKEX, value);
  }

  // FIELD IN (Values)
  global static Condition inX(String field, Set<Object> values) {
    return new SetCondition(field, INX, values);
  }

  // FIELD IN (Values)
  global static Condition inX(String field, List<Object> values) {
    return new SetCondition(field, INX, values);
  }

  // FIELD NOT IN (Values)
  global static Condition notIn(String field, Set<Object> values) {
    return new SetCondition(field, NOT_IN, values);
  }

  // FIELD NOT IN (Values)
  global static Condition notIn(String field, List<Object> values) {
    return new SetCondition(field, NOT_IN, values);
  }

  // FIELD INCLUDES(Values) e.g. for picklists
  global static Condition includes(String field, Set<Object> values) {
    return new SetCondition(field, INCLUDES, values);
  }

  // FIELD INCLUDES(Values) e.g. for picklists
  global static Condition includes(String field, List<Object> values) {
    return new SetCondition(field, INCLUDES, values);
  }

  // FIELD EXCLUDES(Values) e.g. for picklists
  global static Condition excludes(String field, Set<Object> values) {
    return new SetCondition(field, EXCLUDES, values);
  }

  // FIELD EXCLUDES(Values) e.g. for picklists
  global static Condition excludes(String field, List<Object> values) {
    return new SetCondition(field, EXCLUDES, values);
  }

  global static SoqlOptions DEFAULT_OPTIONS = new SoqlOptions();

  /**
   * @description field condition operators
   */
  global static final Operator EQUALS = Operator.EQUALS;
  global static final Operator NOT_EQUALS = Operator.NOT_EQUALS;
  global static final Operator LESS_THAN = Operator.LESS_THAN;
  global static final Operator LESS_THAN_OR_EQUAL_TO = Operator.LESS_THAN_OR_EQUAL_TO;
  global static final Operator GREATER_THAN = Operator.GREATER_THAN;
  global static final Operator GREATER_THAN_OR_EQUAL_TO = Operator.GREATER_THAN_OR_EQUAL_TO;
  global static final Operator LIKEX = Operator.LIKEX;

  /**
   * @description collection (set) operators
   */
  global static final Operator INCLUDES = Operator.INCLUDES;
  global static final Operator EXCLUDES = Operator.EXCLUDES;
  global static final Operator INX = Operator.INX;
  global static final Operator NOT_IN = Operator.NOT_IN;

  /**
   * @description default if not specified =
   */
  private static final Operator DEFAULT_OPERATOR = EQUALS;

  /**
   * @description Soqlable interface
   */
  global virtual interface Soqlable {
    String toSoql();

    String toSoql(SoqlOptions options);
  }

  /**
   * @description Condition interface extends Soqlable
   */
  global virtual interface Condition extends Soqlable {
  }

  /**
   * @description NestableCondition interface extends Condition <Soqlable>
   */
  global interface NestableCondition extends Condition {
    NestableCondition add(Condition c);

    NestableCondition equalsX(String field, Object value);

    NestableCondition notEquals(String field, Object value);

    NestableCondition lessThan(String field, Object value);

    NestableCondition lessThanOrEqualTo(String field, Object value);

    NestableCondition greaterThan(String field, Object value);

    NestableCondition greaterThanOrEqualTo(String field, Object value);

    NestableCondition likeX(String field, Object value);

    NestableCondition inX(String field, Set<Object> values);

    NestableCondition inX(String field, List<Object> values);

    NestableCondition notIn(String field, Set<Object> values);

    NestableCondition notIn(String field, List<Object> values);

    NestableCondition includes(String field, Set<Object> values);

    NestableCondition includes(String field, List<Object> values);

    NestableCondition excludes(String field, Set<Object> values);

    NestableCondition excludes(String field, List<Object> values);
  }

  /**
   * @description abstract nestable with wrapped nestable condition methods
   */
  global abstract class AbstractNestableCondition implements NestableCondition {
    global List<Condition> conditions { get; private set; }

    private String separator { get; set; }

    public AbstractNestableCondition(String separator) {
      this.separator = separator;
      this.conditions = new List<Condition>();
    }

    global virtual NestableCondition add(Condition c) {
      if (c != null) {
        this.conditions.add(c);
      }
      return this;
    }

    global NestableCondition equalsX(String field, Object value) {
      return add(new FieldCondition(field, EQUALS, value));
    }

    global NestableCondition notEquals(String field, Object value) {
      return add(new FieldCondition(field, NOT_EQUALS, value));
    }

    global NestableCondition lessThan(String field, Object value) {
      return add(new FieldCondition(field, LESS_THAN, value));
    }

    global NestableCondition lessThanOrEqualTo(String field, Object value) {
      return add(new FieldCondition(field, LESS_THAN_OR_EQUAL_TO, value));
    }

    global NestableCondition greaterThan(String field, Object value) {
      return add(new FieldCondition(field, GREATER_THAN, value));
    }

    global NestableCondition greaterThanOrEqualTo(String field, Object value) {
      return add(new FieldCondition(field, GREATER_THAN_OR_EQUAL_TO, value));
    }

    global NestableCondition likeX(String field, Object value) {
      return add(new FieldCondition(field, LIKEX, value));
    }

    global NestableCondition inX(String field, Set<Object> values) {
      return add(new SetCondition(field, INX, values));
    }

    global NestableCondition inX(String field, List<Object> values) {
      return add(new SetCondition(field, INX, values));
    }

    global NestableCondition notIn(String field, Set<Object> values) {
      return add(new SetCondition(field, NOT_IN, values));
    }

    global NestableCondition notIn(String field, List<Object> values) {
      return add(new SetCondition(field, NOT_IN, values));
    }

    global NestableCondition includes(String field, Set<Object> values) {
      return add(new SetCondition(field, INCLUDES, values));
    }

    global NestableCondition includes(String field, List<Object> values) {
      return add(new SetCondition(field, INCLUDES, values));
    }

    global NestableCondition excludes(String field, Set<Object> values) {
      return add(new SetCondition(field, EXCLUDES, values));
    }

    global NestableCondition excludes(String field, List<Object> values) {
      return add(new SetCondition(field, EXCLUDES, values));
    }
  }

  /**
   * @description ConditionGroup implements interface NestableCondition
   */
  global abstract class ConditionGroup extends AbstractNestableCondition {
    public ConditionGroup(String separator) {
      super(separator);
    }

    global String toSoql() {
      return this.toSoql(null);
    }

    global String toSoql(SoqlOptions options) {
      if (options == null) {
        options = DEFAULT_OPTIONS;
      }

      String soql = '';

      if (conditions.size() == 1) {
        return conditions.get(0).toSoql(options);
      } else if (conditions.size() > 1) {
        Boolean hasOpenParenBeenAdded = false;
        String additionalSoql = null;

        for (Condition condition : conditions) {
          additionalSoql = condition.toSoql(options);

          if (CMN_UTIL_String.isBlank(additionalSoql)) {
            continue;
          }

          if (hasOpenParenBeenAdded) {
            soql += ' ' + separator + ' ';
          } else {
            soql = '(';
            hasOpenParenBeenAdded = true;
          }
          soql += additionalSoql;
        }

        if (hasOpenParenBeenAdded) {
          soql += ')';
        }
      }
      return soql;
    }
  }

  /**
   * @description static wrapper method for developer productivity
   *
   * @return new andCondition
   */
  global static AndCondition andX() {
    return new AndCondition();
  }

  /**
   * @description AND
   */
  global class AndCondition extends ConditionGroup {
    global AndCondition() {
      super('AND');
    }
  }

  /**
   * @description static wrapper method for developer productivity
   *
   * @return new OrCondition
   */
  global static OrCondition orX() {
    return new OrCondition();
  }

  /**
   * @description OR
   */
  global class OrCondition extends ConditionGroup {
    global OrCondition() {
      super('OR');
    }
  }

  /**
   * @description static wrapper method for developer productivity
   *
   * @return new NotCondition
   */
  global static NotCondition notX() {
    return new NotCondition();
  }

  /**
   * @description NOT
   */
  global class NotCondition extends AbstractNestableCondition {
    global Condition condition { get; private set; }

    global NotCondition() {
      this(null);
    }

    global NotCondition(Condition c) {
      super(null);
      add(c);
    }

    global virtual override NestableCondition add(Condition c) {
      this.condition = c;
      return this;
    }

    global String toSoql() {
      return this.toSoql(null);
    }

    global String toSoql(SoqlOptions options) {
      if (options == null) {
        options = DEFAULT_OPTIONS;
      }

      String soql = '';

      if (condition != null) {
        soql += '(NOT ' + condition.toSoql(options) + ')';
      }

      return soql;
    }
  }

  /**
   * @description single field condition
   */
  global class FieldCondition implements Condition {
    global String field { get; private set; }
    global Operator operator { get; private set; }
    global Object value { get; private set; }

    global FieldCondition() {
    }

    global FieldCondition(String field) {
      this.field(field);
    }

    global FieldCondition(String field, Object value) {
      this(field, DEFAULT_OPERATOR, value);
    }

    global FieldCondition(String field, Operator operator, Object value) {
      this.field(field);

      if (operator != null) {
        this.setOperation(operator, value);
      }
    }

    global FieldCondition field(String field) {
      if (CMN_UTIL_String.isBlank(field)) {
        throw new IllegalArgumentException('Illegal argument: field is empty');
      }
      this.field = CMN_UTIL_String.trim(field);
      return this;
    }

    global FieldCondition equals(Object value) {
      return setOperation(EQUALS, value);
    }

    global FieldCondition notEquals(Object value) {
      return setOperation(NOT_EQUALS, value);
    }

    global FieldCondition lessThan(Object value) {
      return setOperation(LESS_THAN, value);
    }

    global FieldCondition lessThanOrEqualTo(Object value) {
      return setOperation(LESS_THAN_OR_EQUAL_TO, value);
    }

    global FieldCondition greaterThan(Object value) {
      return setOperation(GREATER_THAN, value);
    }

    global FieldCondition greaterThanOrEqualTo(Object value) {
      return setOperation(GREATER_THAN_OR_EQUAL_TO, value);
    }

    global FieldCondition likex(Object value) {
      return setOperation(LIKEX, value);
    }

    private FieldCondition setOperation(Operator operator, Object value) {
      if (operatorToString(operator) == null) {
        throw new IllegalArgumentException('illegal operator: ' + operator);
      }

      this.operator = operator;
      this.value = value;

      return this;
    }

    global String toSoql() {
      return this.toSoql(null);
    }

    global String toSoql(SoqlOptions options) {
      if (options == null) {
        options = DEFAULT_OPTIONS;
      }

      Object manipulated = value;

      if (
        (manipulated != null) &&
        (manipulated instanceof String) &&
        (operator == LIKEX) &&
        options.wildcardStringsInLikeOperators
      ) {
        manipulated = CMN_UTIL_String.ensureStringStartsEndsWithChar(
          ((String) manipulated),
          '%'
        );
      }

      return field +
        ' ' +
        operatorToString(operator) +
        ' ' +
        CMN_SOQL_String.toLiteral(manipulated, options);
    }

    /**
     * @description
     *
     * @param op operator as input
     *
     * @return string from enum
     */
    public String operatorToString(Operator op) {
      String returnValue = null;

      if (op == EQUALS) {
        returnValue = '=';
      } else if (op == NOT_EQUALS) {
        returnValue = '!=';
      } else if (op == LESS_THAN) {
        returnValue = '<';
      } else if (op == LESS_THAN_OR_EQUAL_TO) {
        returnValue = '<=';
      } else if (op == GREATER_THAN) {
        returnValue = '>';
      } else if (op == GREATER_THAN_OR_EQUAL_TO) {
        returnValue = '>=';
      } else if (op == LIKEX) {
        returnValue = 'LIKE';
      }
      return returnValue;
    }
  }

  /**
   * @description set of conditions
   */
  global class SetCondition implements Condition {
    global String field { get; private set; }
    global Operator operator { get; private set; }
    global List<Object> values { get; private set; }
    global CMN_SOQL_Builder builder { get; private set; }

    global SetCondition() {
    }

    global SetCondition(String field) {
      this.field(field);
    }

    global SetCondition(String field, Operator operator, List<Object> values) {
      this.field(field);
      this.setOperation(operator, values);
    }

    global SetCondition(String field, Operator operator, Set<Object> values) {
      this.field(field);
      this.setOperation(operator, new List<Object>(values));
    }

    global SetCondition(
      String field,
      Operator operator,
      CMN_SOQL_Builder builder
    ) {
      this.field(field);
      this.setOperation(operator, builder);
    }

    global SetCondition field(String field) {
      if (CMN_UTIL_String.isBlank(field)) {
        throw new IllegalArgumentException('Illegal argument: field is empty');
      }
      this.field = CMN_UTIL_String.trim(field);
      return this;
    }

    global SetCondition includes(List<Object> values) {
      return setOperation(INCLUDES, values);
    }

    global SetCondition excludes(List<Object> values) {
      return setOperation(EXCLUDES, values);
    }

    global SetCondition inX(List<Object> values) {
      return setOperation(INX, values);
    }

    global SetCondition notIn(List<Object> values) {
      return setOperation(NOT_IN, values);
    }

    global SetCondition includes(CMN_SOQL_Builder builder) {
      return setOperation(INCLUDES, builder);
    }

    global SetCondition excludes(CMN_SOQL_Builder builder) {
      return setOperation(EXCLUDES, builder);
    }

    global SetCondition inX(CMN_SOQL_Builder builder) {
      return setOperation(INX, builder);
    }

    global SetCondition notIn(CMN_SOQL_Builder builder) {
      return setOperation(NOT_IN, builder);
    }

    private SetCondition setOperation(Operator operator, List<Object> values) {
      if (values == null || values.size() <= 0) {
        throw new IllegalArgumentException(
          'illegal argument:  values is empty'
        );
      }
      this.values = values;
      return setOperator(operator);
    }

    private SetCondition setOperation(
      Operator operator,
      CMN_SOQL_Builder builder
    ) {
      if (builder == null) {
        throw new IllegalArgumentException(
          'illegal argument:  builder is null'
        );
      }
      this.builder = builder;
      return setOperator(operator);
    }

    private SetCondition setOperator(Operator operator) {
      if (operatorToString(operator) == null) {
        throw new IllegalArgumentException('illegal operator: ' + operator);
      }
      this.operator = operator;
      return this;
    }

    global String toSoql() {
      return this.toSoql(null);
    }

    global String toSoql(SoqlOptions options) {
      if (options == null) {
        options = DEFAULT_OPTIONS;
      }
      if (this.operator == null) {
        throw new CMN_UTIL_Exceptions.IllegalStateException(
          'Illegal state! One of the following operations must be invoked on SetCondition prior to invoke toSoql(): (includes|excludes|in|notIn)'
        );
      }
      String insideParams = null;
      if (builder == null) {
        insideParams = CMN_UTIL_String.joinArray(
          CMN_SOQL_String.toLiteral(this.values),
          ','
        );
      } else {
        insideParams = builder.toSoql(options);
      }
      return field +
        ' ' +
        operatorToString(operator) +
        ' (' +
        insideParams +
        ')';
    }

    /**
     * @description
     *
     * @param op operator as input
     *
     * @return string from enum
     */
    public String operatorToString(Operator op) {
      String returnValue = null;

      if (op == INCLUDES) {
        returnValue = 'INCLUDES';
      } else if (op == EXCLUDES) {
        returnValue = 'EXCLUDES';
      } else if (op == INX) {
        returnValue = 'IN';
      } else if (op == NOT_IN) {
        returnValue = 'NOT IN';
      }
      return returnValue;
    }
  }

  /**
   * @description field query field
   */
  global class Field implements Soqlable {
    private String name;
    private Boolean toLabelX;

    global Field(String name) {
      this.name = name;
      this.toLabelX = false;
    }

    global Field toLabelX() {
      this.toLabelX = true;
      return this;
    }

    global String toSoql() {
      return this.toSoql(null);
    }

    global String toSoql(SoqlOptions options) {
      if (options == null) {
        options = DEFAULT_OPTIONS;
      }
      return (toLabelX ? 'toLabel(' : '') + name + (toLabelX ? ')' : '');
    }
  }

  /**
   * @description SoqlOptions
   */
  global class SoqlOptions {
    global Boolean escapeSingleQuotes { get; set; }
    global Boolean wildcardStringsInLikeOperators { get; set; }
    global Boolean breakLineBetweenClauses { get; set; }

    global SoqlOptions() {
      escapeSingleQuotes();
      doNotWildcardStringsInLikeOperators();
      doNotBreakLineBetweenClauses();
    }

    global SoqlOptions wildcardStringsInLikeOperators() {
      this.wildcardStringsInLikeOperators = true;
      return this;
    }

    global SoqlOptions doNotWildcardStringsInLikeOperators() {
      this.wildcardStringsInLikeOperators = false;
      return this;
    }

    global SoqlOptions escapeSingleQuotes() {
      this.escapeSingleQuotes = true;
      return this;
    }

    global SoqlOptions doNotEscapeSingleQuotes() {
      this.escapeSingleQuotes = false;
      return this;
    }

    global SoqlOptions breakLineBetweenClauses() {
      this.breakLineBetweenClauses = true;
      return this;
    }

    global SoqlOptions doNotBreakLineBetweenClauses() {
      this.breakLineBetweenClauses = false;
      return this;
    }
  }

  /**
   * @description OrderBy
   */
  global class OrderBy implements Soqlable {
    global String field { get; set; }
    global Boolean ascending { get; set; }
    global Boolean descending {
      get {
        return !ascending;
      }
    }
    global Boolean nullsFirst { get; set; }
    global Boolean nullsLast {
      get {
        return !nullsFirst;
      }
    }
    private Boolean sortSet = false;
    private Boolean nullsSet = false;

    global OrderBy(String field) {
      if (CMN_UTIL_String.isBlank(field)) {
        throw new IllegalArgumentException('field is empty');
      }
      this.field = field;
      this.ascending();
      this.sortSet = false;
    }

    global OrderBy ascending() {
      return setAscending(true);
    }
    global OrderBy descending() {
      return setAscending(false);
    }
    global OrderBy nullsFirst() {
      return setNullsFirst(true);
    }
    global OrderBy nullsLast() {
      return setNullsFirst(false);
    }

    private OrderBy setAscending(Boolean ascending) {
      this.ascending = ascending;
      this.sortSet = true;

      if (!this.nullsSet) {
        this.nullsFirst = this.descending;
      }

      return this;
    }

    private OrderBy setNullsFirst(Boolean nullsFirst) {
      this.nullsFirst = nullsFirst;
      this.nullsSet = true;
      return this;
    }

    global String toSoql() {
      return this.toSoql(null);
    }

    global String toSoql(SoqlOptions options) {
      if (options == null) {
        options = DEFAULT_OPTIONS;
      }

      String returnValue = this.field;

      if (sortSet) {
        if (ascending) {
          returnValue += ' ASC';
        } else {
          returnValue += ' DESC';
        }
      }

      if (nullsSet) {
        if (nullsFirst) {
          returnValue += ' NULLS FIRST';
        } else {
          returnValue += ' NULLS LAST';
        }
      }
      return returnValue;
    }
  }

  /**
   * @description Field and Set SQOL Operations
   */
  global enum Operator {
    EQUALS, // =
    NOT_EQUALS, // !=
    LESS_THAN, // <
    LESS_THAN_OR_EQUAL_TO, // <=
    GREATER_THAN, // >
    GREATER_THAN_OR_EQUAL_TO, // >=
    LIKEX, // LIKE
    INCLUDES, // INCLUDED
    EXCLUDES, // EXCLUDES
    INX, // IN
    NOT_IN // NOT IN
  }

  global enum UnitOfTime {
    Day,
    Week,
    Month,
    Quarter,
    Year,
    FiscalQuarter,
    FiscalYear
  }

  global static String unitToLabel(UnitOfTime unit) {
    String label = '';
    if (unit == UnitOfTime.Day) {
      label = 'DAY';
    } else if (unit == UnitOfTime.Week) {
      label = 'WEEK';
    } else if (unit == UnitOfTime.Month) {
      label = 'MONTH';
    } else if (unit == UnitOfTime.Quarter) {
      label = 'QUARTER';
    } else if (unit == UnitOfTime.FiscalQuarter) {
      label = 'FISCAL_QUARTER';
    } else if (unit == UnitOfTime.Year) {
      label = 'YEAR';
    } else if (unit == UnitOfTime.FiscalYear) {
      label = 'FISCAL_YEAR';
    }
    return label;
  }

  global class DateFormula implements Soqlable {
    private String literal = null;

    global String toSoql() {
      return this.toSoql(CMN_SOQL_Query.DEFAULT_OPTIONS);
    }

    global String toSoql(final CMN_SOQL_Query.SoqlOptions options) {
      if (CMN_UTIL_String.isBlank(literal)) {
        throw new CMN_UTIL_Exceptions.IllegalStateException();
      }
      return literal;
    }

    global DateFormula yesterdayX() {
      this.literal = 'YESTERDAY';
      return this;
    }
    global DateFormula todayX() {
      this.literal = 'TODAY';
      return this;
    }
    global DateFormula tomorrowX() {
      this.literal = 'TOMORROW';
      return this;
    }
    global DateFormula thisX(UnitOfTime unit) {
      if (unit == UnitOfTime.Day) {
        return todayX();
      }
      this.literal = 'THIS_' + unitToLabel(unit);
      return this;
    }

    global DateFormula last90Days() {
      return last(90, UnitOfTime.Day);
    }
    global DateFormula next90Days() {
      return next(90, UnitOfTime.Day);
    }

    global DateFormula last(UnitOfTime unit) {
      return last(1, unit);
    }
    global DateFormula next(UnitOfTime unit) {
      return next(1, unit);
    }

    global DateFormula last(Integer n, UnitOfTime unit) {
      this.literal = 'LAST_' + toUnitAndAmount(n, unit);
      return this;
    }
    global DateFormula next(Integer n, UnitOfTime unit) {
      this.literal = 'NEXT_' + toUnitAndAmount(n, unit);
      return this;
    }

    private String toUnitAndAmount(Integer n, UnitOfTime unit) {
      String unitAndAmount = '';
      if (n < 0) {
        throw new IllegalArgumentException('n cannot be negative');
      } else if (n == 90 && unit == UnitOfTime.Day) {
        unitAndAmount += '90_' + unitToLabel(UnitOfTime.Day) + 'S';
      } else if (n == 1 && unit != UnitOfTime.Day) {
        unitAndAmount += unitToLabel(unit);
      } else if (unit == UnitOfTime.Week || unit == UnitOfTime.Month) {
        throw new IllegalArgumentException(
          'N_WEEKS and N_MONTHS are not supported'
        );
      } else {
        unitAndAmount += 'N_' + unitToLabel(unit) + 'S:' + n;
      }
      return unitAndAmount;
    }
  }
}