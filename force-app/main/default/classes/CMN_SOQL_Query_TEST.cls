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
private class CMN_SOQL_Query_TEST {
  @IsTest
  private static void testQueryWrapperNestedConditions() {
    // AND, OR, NOT
    System.assertEquals(
      'Name = \'foo\'',
      CMN_SOQL_Query.andX().equalsX('Name', 'foo').toSoql(),
      'Expected: Name = \'foo\''
    );

    System.assertEquals(
      'Name = \'foo\'',
      CMN_SOQL_Query.orX().equalsX('Name', 'foo').toSoql(),
      'Expected: Name = \'foo\''
    );

    System.assertEquals(
      '(NOT Name = \'foo\')',
      CMN_SOQL_Query.notX().equalsX('Name', 'foo').toSoql(),
      'Expected: (NOT Name = \'foo\')'
    );

    CMN_SOQL_Query.NestableCondition oldNestedAnd = CMN_SOQL_Query.andX()
      .add(
        new CMN_SOQL_Query.FieldCondition('Name', CMN_SOQL_Query.EQUALS, 'foo')
      )
      .add(
        new CMN_SOQL_Query.FieldCondition(
          'CMN_NumberInteger__c',
          CMN_SOQL_Query.NOT_EQUALS,
          100
        )
      );

    CMN_SOQL_Query.NestableCondition newNestedAnd = CMN_SOQL_Query.andX()
      .equalsX('Name', 'foo')
      .notEquals('CMN_NumberInteger__c', 100);

    System.assertEquals(
      oldNestedAnd.toSoql(),
      newNestedAnd.toSoql(),
      'Expected: (Name = \'foo\' AND CMN_NumberInteger__c != 100)'
    );

    CMN_SOQL_Query.NestableCondition newNestedOr = CMN_SOQL_Query.orX()
      .equalsX('Name', 'foo')
      .equalsX('CMN_NumberInteger__c', 100);

    System.assertEquals(
      '(Name = \'foo\' OR CMN_NumberInteger__c = 100)',
      newNestedOr.toSoql(),
      'Expected: (Name = \'foo\' OR CMN_NumberInteger__c = 100)'
    );

    CMN_SOQL_Query.NestableCondition allNested = CMN_SOQL_Query.orX()
      .equalsX('Name', 'foo')
      .notEquals('CMN_NumberInteger__c', 100)
      .lessThan('CMN_NumberInteger__c', 999)
      .lessThanOrEqualTo('CMN_NumberInteger__c', 998)
      .greaterThan('CMN_NumberInteger__c', 0)
      .greaterThanOrEqualTo('CMN_NumberInteger__c', 1)
      .likeX('Name', 'foo%')
      .inX('CMN_NumberInteger__c', new Set<Object>{ 100 })
      .inX('CMN_NumberInteger__c', new List<Object>{ 200 })
      .notIn('CMN_NumberInteger__c', new Set<Object>{ 300 })
      .notIn('CMN_NumberInteger__c', new List<Object>{ 300 })
      .includes('CMN_PicklistMultiSelect__c', new Set<Object>{ 'One' })
      .includes('CMN_PicklistMultiSelect__c', new List<Object>{ 'Two' })
      .excludes('CMN_PicklistMultiSelect__c', new Set<Object>{ 'Three' })
      .excludes('CMN_PicklistMultiSelect__c', new List<Object>{ 'Four' });
    System.assertEquals(
      '(Name = \'foo\' OR CMN_NumberInteger__c != 100 OR CMN_NumberInteger__c < 999 ' +
      'OR CMN_NumberInteger__c <= 998 OR CMN_NumberInteger__c > 0 ' +
      'OR CMN_NumberInteger__c >= 1 OR Name LIKE \'foo%\' ' +
      'OR CMN_NumberInteger__c IN (100) OR CMN_NumberInteger__c IN (200) ' +
      'OR CMN_NumberInteger__c NOT IN (300) OR CMN_NumberInteger__c NOT IN (300) ' +
      'OR CMN_PicklistMultiSelect__c INCLUDES (\'One\') OR CMN_PicklistMultiSelect__c INCLUDES (\'Two\') ' +
      'OR CMN_PicklistMultiSelect__c EXCLUDES (\'Three\') OR CMN_PicklistMultiSelect__c EXCLUDES (\'Four\'))',
      allNested.toSoql()
    );
  }

  @IsTest
  private static void testQueryWrapperConditions() {
    // EQUAL AND NOT EQUAL Conditions
    System.assertEquals(
      'Name = \'foo\'',
      CMN_SOQL_Query.equalsX('Name', 'foo').toSoql(),
      'Expected: Name = \'foo\''
    );

    System.assertEquals(
      'Name != \'foo\'',
      CMN_SOQL_Query.notEquals('Name', 'foo').toSoql(),
      'Expected: Name != \'foo\''
    );

    // LTE AND GTE Conditions
    System.assertEquals(
      'CMN_NumberInteger__c < 100',
      CMN_SOQL_Query.lessThan('CMN_NumberInteger__c', 100).toSoql(),
      'Expected: CMN_NumberInteger__c < 100'
    );

    System.assertEquals(
      'CMN_NumberInteger__c <= 100',
      CMN_SOQL_Query.lessThanOrEqualTo('CMN_NumberInteger__c', 100).toSoql(),
      'Expected: CMN_NumberInteger__c <= 100'
    );

    System.assertEquals(
      'CMN_NumberInteger__c > 100',
      CMN_SOQL_Query.greaterThan('CMN_NumberInteger__c', 100).toSoql(),
      'Expected: CMN_NumberInteger__c > 100'
    );

    System.assertEquals(
      'CMN_NumberInteger__c >= 100',
      CMN_SOQL_Query.greaterThanOrEqualTo('CMN_NumberInteger__c', 100).toSoql(),
      'Expected: CMN_NumberInteger__c >= 100'
    );

    // LIKE CONDITION
    System.assertEquals(
      'Name LIKE \'foo%\'',
      CMN_SOQL_Query.likeX('Name', 'foo%').toSoql(),
      'Expected: Name LIKE \'foo%\''
    );

    // IN CONDITIONS
    System.assertEquals(
      'CMN_NumberInteger__c IN (100,200)',
      CMN_SOQL_Query.inX('CMN_NumberInteger__c', new Set<Object>{ 100, 200 })
        .toSoql(),
      'Expected: CMN_NumberInteger__c IN (100,200)'
    );

    System.assertEquals(
      'CMN_NumberInteger__c IN (100,200)',
      CMN_SOQL_Query.inX('CMN_NumberInteger__c', new List<Object>{ 100, 200 })
        .toSoql(),
      'Expected: CMN_NumberInteger__c IN (100,200)'
    );

    // NOT IN CONDITIONS
    System.assertEquals(
      'CMN_NumberInteger__c NOT IN (100,200)',
      CMN_SOQL_Query.notIn('CMN_NumberInteger__c', new Set<Object>{ 100, 200 })
        .toSoql(),
      'Expected: CMN_NumberInteger__c NOT IN (100,200)'
    );

    System.assertEquals(
      'CMN_NumberInteger__c NOT IN (100,200)',
      CMN_SOQL_Query.notIn('CMN_NumberInteger__c', new List<Object>{ 100, 200 })
        .toSoql(),
      'Expected: CMN_NumberInteger__c NOT IN (100,200)'
    );

    //INCLUDES AND EXCLUDES
    System.assertEquals(
      'CMN_PicklistMultiSelect__c INCLUDES (\'One\')',
      CMN_SOQL_Query.includes(
          'CMN_PicklistMultiSelect__c',
          new Set<Object>{ 'One' }
        )
        .toSoql(),
      'Expected: CMN_PicklistMultiSelect__c INCLUDES (\'One\')'
    );

    System.assertEquals(
      'CMN_PicklistMultiSelect__c INCLUDES (\'One\')',
      CMN_SOQL_Query.includes(
          'CMN_PicklistMultiSelect__c',
          new List<Object>{ 'One' }
        )
        .toSoql(),
      'Expected: CMN_PicklistMultiSelect__c INCLUDES (\'One\')'
    );

    System.assertEquals(
      'CMN_PicklistMultiSelect__c EXCLUDES (\'One\')',
      CMN_SOQL_Query.excludes(
          'CMN_PicklistMultiSelect__c',
          new Set<Object>{ 'One' }
        )
        .toSoql(),
      'Expected: CMN_PicklistMultiSelect__c INCLUDES (\'One\')'
    );

    System.assertEquals(
      'CMN_PicklistMultiSelect__c EXCLUDES (\'One\')',
      CMN_SOQL_Query.excludes(
          'CMN_PicklistMultiSelect__c',
          new List<Object>{ 'One' }
        )
        .toSoql(),
      'Expected: CMN_PicklistMultiSelect__c EXCLUDES (\'One\')'
    );
  }

  @IsTest
  private static void testAndConditionEmpty() {
    System.assertEquals('', new CMN_SOQL_Query.AndCondition().toSoql());
  }

  @IsTest
  private static void testAndConditionNestedAndConditionEmpty() {
    System.assertEquals(
      '',
      new CMN_SOQL_Query.AndCondition()
        .add(new CMN_SOQL_Query.AndCondition())
        .add(new CMN_SOQL_Query.AndCondition())
        .toSoql()
    );
  }

  @IsTest
  private static void testAndConditionNotOneCondition() {
    System.assertEquals(
      '(NOT ((Name = \'acme\' AND IsPartner = true) OR Rating = \'Hot\'))',
      new CMN_SOQL_Query.NotCondition()
        .add(
          new CMN_SOQL_Query.OrCondition()
            .add(
              new CMN_SOQL_Query.AndCondition()
                .add(
                  new CMN_SOQL_Query.FieldCondition(
                    'Name',
                    CMN_SOQL_Query.Operator.EQUALS,
                    'acme'
                  )
                )
                .add(
                  new CMN_SOQL_Query.FieldCondition(
                    'IsPartner',
                    CMN_SOQL_Query.Operator.EQUALS,
                    true
                  )
                )
            )
            .add(
              new CMN_SOQL_Query.FieldCondition(
                'Rating',
                CMN_SOQL_Query.Operator.EQUALS,
                'Hot'
              )
            )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testAndConditionNotTwoConditions() {
    System.assertEquals(
      '((NOT (Name = \'acme\' AND IsPartner = true)) OR Rating = \'Hot\')',
      new CMN_SOQL_Query.OrCondition()
        .add(
          new CMN_SOQL_Query.NotCondition()
            .add(
              new CMN_SOQL_Query.AndCondition()
                .add(
                  new CMN_SOQL_Query.FieldCondition(
                    'Name',
                    CMN_SOQL_Query.Operator.EQUALS,
                    'acme'
                  )
                )
                .add(
                  new CMN_SOQL_Query.FieldCondition(
                    'IsPartner',
                    CMN_SOQL_Query.Operator.EQUALS,
                    true
                  )
                )
            )
        )
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'Rating',
            CMN_SOQL_Query.Operator.EQUALS,
            'Hot'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testAndConditionWithOneConditionOnly() {
    System.assertEquals(
      'Name = \'acme\'',
      new CMN_SOQL_Query.AndCondition()
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'Name ',
            CMN_SOQL_Query.Operator.EQUALS,
            'acme'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testAndConditionWithTwoFieldConditions() {
    System.assertEquals(
      '(Name = \'acme\' AND IsPartner = true)',
      new CMN_SOQL_Query.AndCondition()
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'Name ',
            CMN_SOQL_Query.Operator.EQUALS,
            'acme'
          )
        )
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'IsPartner',
            CMN_SOQL_Query.Operator.EQUALS,
            true
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testOrConditionEmpty() {
    System.assertEquals('', new CMN_SOQL_Query.OrCondition().toSoql());
  }

  @IsTest
  private static void testOrConditionNestedOrConditionEmpty() {
    System.assertEquals(
      '',
      new CMN_SOQL_Query.OrCondition()
        .add(new CMN_SOQL_Query.OrCondition())
        .add(new CMN_SOQL_Query.OrCondition())
        .toSoql()
    );
  }

  @IsTest
  private static void testOrConditionWithOneConditionOnly() {
    System.assertEquals(
      'Name = \'acme\'',
      new CMN_SOQL_Query.OrCondition()
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.EQUALS,
            'acme'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testOrConditionWithTwoFieldConditions() {
    System.assertEquals(
      '(Name = \'acme\' OR IsPartner = true)',
      new CMN_SOQL_Query.OrCondition()
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.EQUALS,
            'acme'
          )
        )
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'IsPartner',
            CMN_SOQL_Query.EQUALS,
            true
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testNestedConditionGroup() {
    System.assertEquals(
      '((Name = \'acme\' AND IsPartner = true) OR Rating = \'Hot\')',
      new CMN_SOQL_Query.OrCondition()
        .add(
          new CMN_SOQL_Query.AndCondition()
            .add(
              new CMN_SOQL_Query.FieldCondition(
                'Name ',
                CMN_SOQL_Query.EQUALS,
                'acme'
              )
            )
            .add(
              new CMN_SOQL_Query.FieldCondition(
                'IsPartner',
                CMN_SOQL_Query.EQUALS,
                true
              )
            )
        )
        .add(
          new CMN_SOQL_Query.FieldCondition(
            'Rating',
            CMN_SOQL_Query.EQUALS,
            'Hot'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldName() {
    CMN_SOQL_Query.Field field = new CMN_SOQL_Query.Field('test');
    System.assertNotEquals(null, field);
    System.assertEquals('test', field.toSoql());
  }

  @IsTest
  private static void testFieldToLabel() {
    CMN_SOQL_Query.Field field = new CMN_SOQL_Query.Field('test').toLabelX();
    System.assertNotEquals(null, field);
    System.assertEquals('toLabel(test)', field.toSoql());
  }

  @IsTest
  private static void testFieldConditionInvalidField() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.FieldCondition(' ', null, null);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'Empty field param to CMN_SOQL_Query.FieldCondition constructor did not throw IllegalArgumentException'
    );
  }

  @IsTest
  private static void testFieldConditionInvalidOperatorIncludes() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.FieldCondition(
        'x',
        CMN_SOQL_Query.Operator.INCLUDES,
        null
      );
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testFieldConditionInvalidOperatorExcludes() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.FieldCondition(
        'x',
        CMN_SOQL_Query.Operator.EXCLUDES,
        null
      );
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testFieldConditionInvalidOperatorIn() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.FieldCondition('x', CMN_SOQL_Query.Operator.INX, null);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testFieldConditionInvalidOperatorNotIn() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.FieldCondition(
        'x',
        CMN_SOQL_Query.Operator.NOT_IN,
        null
      );
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testFieldConditionInvalidValue() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.FieldCondition(
          'x',
          new CMN_UTIL_NumberRange.DecimalRange(0, 1)
        )
        .toSoql();
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testFieldConditionNullValue() {
    System.assertEquals(
      'Name = null',
      new CMN_SOQL_Query.FieldCondition(
          'Name',
          CMN_SOQL_Query.Operator.EQUALS,
          null
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionStringValue() {
    System.assertEquals(
      'Name = \'acme\'',
      new CMN_SOQL_Query.FieldCondition().field('Name').equals('acme').toSoql()
    );
    System.assertEquals(
      'Name = \'acme\'',
      new CMN_SOQL_Query.FieldCondition('Name').equals('acme').toSoql()
    );
    System.assertEquals(
      'Name = \'acme\'',
      new CMN_SOQL_Query.FieldCondition(
          'Name',
          CMN_SOQL_Query.Operator.EQUALS,
          'acme'
        )
        .toSoql()
    );
    System.assertEquals(
      'Name LIKE \'%acme%\'',
      new CMN_SOQL_Query.FieldCondition().field('Name').likex('%acme%').toSoql()
    );
    System.assertEquals(
      'Name LIKE \'%acme%\'',
      new CMN_SOQL_Query.FieldCondition('Name').likex('%acme%').toSoql()
    );
    System.assertEquals(
      'Name LIKE \'%acme%\'',
      new CMN_SOQL_Query.FieldCondition(
          'Name',
          CMN_SOQL_Query.Operator.LIKEX,
          '%acme%'
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionBooleanValue() {
    System.assertEquals(
      'IsPartner = true',
      new CMN_SOQL_Query.FieldCondition(
          'IsPartner',
          CMN_SOQL_Query.Operator.EQUALS,
          true
        )
        .toSoql()
    );
    System.assertEquals(
      'IsPartner = false',
      new CMN_SOQL_Query.FieldCondition(
          'IsPartner',
          CMN_SOQL_Query.Operator.EQUALS,
          false
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionIntegerValue() {
    System.assertEquals(
      'employees = 1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.EQUALS,
          1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees != 1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.NOT_EQUALS,
          1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees < 1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.LESS_THAN,
          1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees > 1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.GREATER_THAN,
          1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees <= 1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.LESS_THAN_OR_EQUAL_TO,
          1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees >= 1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.GREATER_THAN_OR_EQUAL_TO,
          1
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionDoubleValue() {
    System.assertEquals(
      'employees = 1.1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.EQUALS,
          1.1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees != 1.1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.NOT_EQUALS,
          1.1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees < 1.1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.LESS_THAN,
          1.1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees > 1.1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.GREATER_THAN,
          1.1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees <= 1.1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.LESS_THAN_OR_EQUAL_TO,
          1.1
        )
        .toSoql()
    );
    System.assertEquals(
      'employees >= 1.1',
      new CMN_SOQL_Query.FieldCondition(
          'employees',
          CMN_SOQL_Query.Operator.GREATER_THAN_OR_EQUAL_TO,
          1.1
        )
        .toSoql()
    );
  }
  @IsTest
  private static void testFieldConditionDateValue() {
    System.assertEquals(
      'CreatedDate < 1960-02-17',
      new CMN_SOQL_Query.FieldCondition(
          'CreatedDate',
          CMN_SOQL_Query.Operator.LESS_THAN,
          Date.newInstance(1960, 2, 17)
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionDatetimeValue() {
    System.assertEquals(
      'CreatedDate >= 2008-12-01T12:00:00Z',
      new CMN_SOQL_Query.FieldCondition(
          'CreatedDate',
          CMN_SOQL_Query.Operator.GREATER_THAN_OR_EQUAL_TO,
          Datetime.newInstance(2008, 12, 1)
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodEquals() {
    System.assertEquals(
      'x = 1',
      new CMN_SOQL_Query.FieldCondition().field('x').equals(1).toSoql()
    );
    System.assertEquals(
      'x = 1',
      new CMN_SOQL_Query.FieldCondition('x').equals(1).toSoql()
    );
    System.assertEquals(
      'x = 1',
      new CMN_SOQL_Query.FieldCondition('x', CMN_SOQL_Query.Operator.EQUALS, 1)
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodNotEquals() {
    System.assertEquals(
      'x != 1',
      new CMN_SOQL_Query.FieldCondition().field('x').notEquals(1).toSoql()
    );
    System.assertEquals(
      'x != 1',
      new CMN_SOQL_Query.FieldCondition('x').notEquals(1).toSoql()
    );
    System.assertEquals(
      'x != 1',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.NOT_EQUALS,
          1
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodLessThan() {
    System.assertEquals(
      'x < 1',
      new CMN_SOQL_Query.FieldCondition().field('x').lessThan(1).toSoql()
    );
    System.assertEquals(
      'x < 1',
      new CMN_SOQL_Query.FieldCondition('x').lessThan(1).toSoql()
    );
    System.assertEquals(
      'x < 1',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.LESS_THAN,
          1
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodLessThanOrEqualTo() {
    System.assertEquals(
      'x <= 1',
      new CMN_SOQL_Query.FieldCondition()
        .field('x')
        .lessThanOrEqualTo(1)
        .toSoql()
    );
    System.assertEquals(
      'x <= 1',
      new CMN_SOQL_Query.FieldCondition('x').lessThanOrEqualTo(1).toSoql()
    );
    System.assertEquals(
      'x <= 1',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.LESS_THAN_OR_EQUAL_TO,
          1
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodGreaterThan() {
    System.assertEquals(
      'x > 1',
      new CMN_SOQL_Query.FieldCondition().field('x').greaterThan(1).toSoql()
    );
    System.assertEquals(
      'x > 1',
      new CMN_SOQL_Query.FieldCondition('x').greaterThan(1).toSoql()
    );
    System.assertEquals(
      'x > 1',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.GREATER_THAN,
          1
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodGreaterThanOrEqualTo() {
    System.assertEquals(
      'x >= 1',
      new CMN_SOQL_Query.FieldCondition()
        .field('x')
        .greaterThanOrEqualTo(1)
        .toSoql()
    );
    System.assertEquals(
      'x >= 1',
      new CMN_SOQL_Query.FieldCondition('x').greaterThanOrEqualTo(1).toSoql()
    );
    System.assertEquals(
      'x >= 1',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.GREATER_THAN_OR_EQUAL_TO,
          1
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testFieldConditionOperatorMethodLike() {
    System.assertEquals(
      'x LIKE \'acme\'',
      new CMN_SOQL_Query.FieldCondition().field('x').likex('acme').toSoql()
    );
    System.assertEquals(
      'x LIKE \'acme\'',
      new CMN_SOQL_Query.FieldCondition('x').likex('acme').toSoql()
    );
    System.assertEquals(
      'x LIKE \'acme\'',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.LIKEX,
          'acme'
        )
        .toSoql()
    );

    System.assertEquals(
      'x LIKE \'%acme%\'',
      new CMN_SOQL_Query.FieldCondition()
        .field('x')
        .likex('acme')
        .toSoql(
          new CMN_SOQL_Query.SoqlOptions().wildcardStringsInLikeOperators()
        )
    );
    System.assertEquals(
      'x LIKE \'%acme%\'',
      new CMN_SOQL_Query.FieldCondition('x')
        .likex('acme')
        .toSoql(
          new CMN_SOQL_Query.SoqlOptions().wildcardStringsInLikeOperators()
        )
    );
    System.assertEquals(
      'x LIKE \'%acme%\'',
      new CMN_SOQL_Query.FieldCondition(
          'x',
          CMN_SOQL_Query.Operator.LIKEX,
          'acme'
        )
        .toSoql(
          new CMN_SOQL_Query.SoqlOptions().wildcardStringsInLikeOperators()
        )
    );
  }

  @IsTest
  private static void testSetConditionInvalidField() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition(' ');
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'empty field param to CMN_SOQL_Query.FieldCondition constructor did not throw IllegalArgumentException'
    );
  }

  @IsTest
  private static void testSetConditionInvalidOperatorEquals() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.SetCondition(
        'x',
        CMN_SOQL_Query.EQUALS,
        new List<Object>{ 1, 2 }
      );
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionNullValueList() {
    Boolean exceptionCaught = false;
    List<Object> value = null;
    try {
      new CMN_SOQL_Query.SetCondition('x', CMN_SOQL_Query.INCLUDES, value);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionNullValueSoqlBuilder() {
    Boolean exceptionCaught = false;
    CMN_SOQL_Builder value = null;

    try {
      new CMN_SOQL_Query.SetCondition('x', CMN_SOQL_Query.NOT_IN, value);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionEmptyListValue() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition(
        'x',
        CMN_SOQL_Query.INCLUDES,
        new List<Object>{}
      );
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionEmptySetValue() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition(
        'x',
        CMN_SOQL_Query.INCLUDES,
        new Set<Object>{}
      );
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionNameNotDefined() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition().toSoql();
    } catch (CMN_UTIL_Exceptions.IllegalStateException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'CMN_UTIL_Exceptions.IllegalStateException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionOperationNotDefined() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition('name').toSoql();
    } catch (CMN_UTIL_Exceptions.IllegalStateException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'CMN_UTIL_Exceptions.IllegalStateException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionInvalidValue() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition('name')
        .includes(
          new List<Object>{ new CMN_UTIL_NumberRange.DecimalRange(0, 1) }
        )
        .toSoql();
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionNullValuesList() {
    Boolean exceptionCaught = false;

    List<Object> value = null;

    try {
      new CMN_SOQL_Query.SetCondition('name').includes(value);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionEmptyValuesList() {
    Boolean exceptionCaught = false;

    try {
      new CMN_SOQL_Query.SetCondition('name').includes(new List<Object>());
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }

    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSetConditionIncludes() {
    assertEqualsAfterRemovingNewLines(
      'name INCLUDES (\'test\',123)',
      new CMN_SOQL_Query.SetCondition('name')
        .includes(new List<Object>{ 'test', 123 })
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionExcludes() {
    assertEqualsAfterRemovingNewLines(
      'name EXCLUDES (\'test\',123)',
      new CMN_SOQL_Query.SetCondition('name')
        .excludes(new List<Object>{ 'test', 123 })
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionIn() {
    assertEqualsAfterRemovingNewLines(
      'name IN (\'test\',123)',
      new CMN_SOQL_Query.SetCondition('name')
        .inX(new List<Object>{ 'test', 123 })
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionNotIn() {
    assertEqualsAfterRemovingNewLines(
      'name NOT IN (\'test\',123)',
      new CMN_SOQL_Query.SetCondition('name')
        .notIn(new List<Object>{ 'test', 123 })
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionOperatorMethodIncludes() {
    assertEqualsAfterRemovingNewLines(
      'x INCLUDES (1,2)',
      new CMN_SOQL_Query.SetCondition()
        .field('x')
        .includes(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x INCLUDES (1,2)',
      new CMN_SOQL_Query.SetCondition('x')
        .includes(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x INCLUDES (1,2)',
      new CMN_SOQL_Query.SetCondition(
          'x',
          CMN_SOQL_Query.INCLUDES,
          new List<Object>{ 1, 2 }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionOperatorMethodExcludes() {
    assertEqualsAfterRemovingNewLines(
      'x EXCLUDES (1,2)',
      new CMN_SOQL_Query.SetCondition()
        .field('x')
        .excludes(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x EXCLUDES (1,2)',
      new CMN_SOQL_Query.SetCondition('x')
        .excludes(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x EXCLUDES (1,2)',
      new CMN_SOQL_Query.SetCondition(
          'x',
          CMN_SOQL_Query.EXCLUDES,
          new List<Object>{ 1, 2 }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionOperatorMethodIn() {
    assertEqualsAfterRemovingNewLines(
      'x IN (1,2)',
      new CMN_SOQL_Query.SetCondition()
        .field('x')
        .inX(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x IN (1,2)',
      new CMN_SOQL_Query.SetCondition('x')
        .inX(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x IN (1,2)',
      new CMN_SOQL_Query.SetCondition(
          'x',
          CMN_SOQL_Query.INX,
          new List<Object>{ 1, 2 }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionOperatorMethodNotIn() {
    assertEqualsAfterRemovingNewLines(
      'x NOT IN (1,2)',
      new CMN_SOQL_Query.SetCondition()
        .field('x')
        .notIn(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x NOT IN (1,2)',
      new CMN_SOQL_Query.SetCondition('x')
        .notIn(new List<Object>{ 1, 2 })
        .toSoql()
    );
    assertEqualsAfterRemovingNewLines(
      'x NOT IN (1,2)',
      new CMN_SOQL_Query.SetCondition(
          'x',
          CMN_SOQL_Query.NOT_IN,
          new List<Object>{ 1, 2 }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionBasicSemiJoinConstructor() {
    assertEqualsAfterRemovingNewLines(
      'ID IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
      new CMN_SOQL_Query.SetCondition(
          'ID',
          CMN_SOQL_Query.INX,
          new CMN_SOQL_Builder()
            .selectX('AccountId')
            .fromX('Opportunity')
            .whereX(
              new CMN_SOQL_Query.FieldCondition('StageName', 'Closed Lost')
            )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionBasicSemiJoinOne() {
    assertEqualsAfterRemovingNewLines(
      'ID IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
      new CMN_SOQL_Query.SetCondition('ID')
        .inX(
          new CMN_SOQL_Builder()
            .selectX('AccountId')
            .fromX('Opportunity')
            .whereX(
              new CMN_SOQL_Query.FieldCondition('StageName', 'Closed Lost')
            )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionBasicSemiJoinTwo() {
    assertEqualsAfterRemovingNewLines(
      'ID NOT IN (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
      new CMN_SOQL_Query.SetCondition('ID')
        .notIn(
          new CMN_SOQL_Builder()
            .selectX('AccountId')
            .fromX('Opportunity')
            .whereX(
              new CMN_SOQL_Query.FieldCondition('StageName', 'Closed Lost')
            )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionBasicSemiJoinThree() {
    assertEqualsAfterRemovingNewLines(
      'ID INCLUDES (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
      new CMN_SOQL_Query.SetCondition('ID')
        .includes(
          new CMN_SOQL_Builder()
            .selectX('AccountId')
            .fromX('Opportunity')
            .whereX(
              new CMN_SOQL_Query.FieldCondition('StageName', 'Closed Lost')
            )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSetConditionBasicSemiJoinFour() {
    assertEqualsAfterRemovingNewLines(
      'ID EXCLUDES (SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
      new CMN_SOQL_Query.SetCondition('ID')
        .excludes(
          new CMN_SOQL_Builder()
            .selectX('AccountId')
            .fromX('Opportunity')
            .whereX(
              new CMN_SOQL_Query.FieldCondition('StageName', 'Closed Lost')
            )
        )
        .toSoql()
    );
  }

  @TestVisible
  private static void assertEqualsAfterRemovingNewLines(
    String expected,
    String actual
  ) {
    System.assertEquals(
      CMN_UTIL_String.replace(expected, '\n', ''),
      CMN_UTIL_String.replace(actual, '\n', '')
    );
  }

  @IsTest
  private static void testOrderByNullFieldName() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.OrderBy(null);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testOrderByBlankFieldName() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.OrderBy(' ');
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testOrderByNameOnly() {
    final CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name');
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals('Name', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByAscendingNullsLast() {
    CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .ascending()
      .nullsLast();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals('Name ASC NULLS LAST', orderBy.toSoql());

    orderBy = new CMN_SOQL_Query.OrderBy('Name').nullsLast().ascending();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals('Name ASC NULLS LAST', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByDescendingNullsFirst() {
    CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .descending()
      .nullsFirst();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.descending);
    System.assertEquals(true, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.ascending);
    System.assertEquals(false, orderBy.nullsLast);
    System.assertEquals('Name DESC NULLS FIRST', orderBy.toSoql());

    orderBy = new CMN_SOQL_Query.OrderBy('Name').nullsFirst().descending();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.descending);
    System.assertEquals(true, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.ascending);
    System.assertEquals(false, orderBy.nullsLast);
    System.assertEquals('Name DESC NULLS FIRST', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByAscendingNullsFirst() {
    CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .ascending()
      .nullsFirst();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(false, orderBy.nullsLast);
    System.assertEquals(true, orderBy.nullsFirst);
    System.assertEquals('Name ASC NULLS FIRST', orderBy.toSoql());

    orderBy = new CMN_SOQL_Query.OrderBy('Name').nullsFirst().ascending();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(false, orderBy.nullsLast);
    System.assertEquals(true, orderBy.nullsFirst);
    System.assertEquals('Name ASC NULLS FIRST', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByDescendingNullsLast() {
    CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .descending()
      .nullsLast();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.descending);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.ascending);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals('Name DESC NULLS LAST', orderBy.toSoql());

    orderBy = new CMN_SOQL_Query.OrderBy('Name').nullsLast().descending();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.descending);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.ascending);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals('Name DESC NULLS LAST', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByAscending() {
    CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .ascending();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals('Name ASC', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByDescending() {
    final CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .descending();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.descending);
    System.assertEquals(true, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.ascending);
    System.assertEquals(false, orderBy.nullsLast);
    System.assertEquals('Name DESC', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByNullsFirst() {
    final CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .nullsFirst();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(true, orderBy.nullsFirst);
    System.assertEquals(false, orderBy.nullsLast);
    System.assertEquals('Name NULLS FIRST', orderBy.toSoql());
  }

  @IsTest
  private static void testOrderByNullsLast() {
    final CMN_SOQL_Query.OrderBy orderBy = new CMN_SOQL_Query.OrderBy('Name')
      .nullsLast();
    System.assertNotEquals(null, orderBy);
    System.assertEquals(true, orderBy.ascending);
    System.assertEquals(false, orderBy.descending);
    System.assertEquals(false, orderBy.nullsFirst);
    System.assertEquals(true, orderBy.nullsLast);
    System.assertEquals('Name NULLS LAST', orderBy.toSoql());
  }

  @IsTest
  private static void testSoqlOptionsDefault() {
    System.assertEquals(
      true,
      CMN_SOQL_Query.DEFAULT_OPTIONS.escapeSingleQuotes
    );
    System.assertEquals(
      false,
      CMN_SOQL_Query.DEFAULT_OPTIONS.wildcardStringsInLikeOperators
    );
    System.assertEquals(
      false,
      CMN_SOQL_Query.DEFAULT_OPTIONS.breakLineBetweenClauses
    );
  }

  @IsTest
  private static void testSoqlOptionsEscapeSingleQuotes() {
    final CMN_SOQL_Query.SoqlOptions options = new CMN_SOQL_Query.SoqlOptions();
    System.assertEquals(true, options.escapeSingleQuotes);
    System.assertEquals(options, options.doNotEscapeSingleQuotes());
    System.assertEquals(false, options.escapeSingleQuotes);
    System.assertEquals(options, options.escapeSingleQuotes());
    System.assertEquals(true, options.escapeSingleQuotes);
  }

  @IsTest
  private static void testSoqlOptionsWildcardStringsInLikeOperators() {
    final CMN_SOQL_Query.SoqlOptions options = new CMN_SOQL_Query.SoqlOptions();
    System.assertEquals(false, options.wildcardStringsInLikeOperators);
    System.assertEquals(options, options.wildcardStringsInLikeOperators());
    System.assertEquals(true, options.wildcardStringsInLikeOperators);
    System.assertEquals(options, options.doNotWildcardStringsInLikeOperators());
    System.assertEquals(false, options.wildcardStringsInLikeOperators);
  }

  @IsTest
  private static void testSoqlOptionsBreakLineBetweenClauses() {
    final CMN_SOQL_Query.SoqlOptions options = new CMN_SOQL_Query.SoqlOptions();
    System.assertEquals(false, options.breakLineBetweenClauses);
    System.assertEquals(options, options.breakLineBetweenClauses());
    System.assertEquals(true, options.breakLineBetweenClauses);
    System.assertEquals(options, options.doNotBreakLineBetweenClauses());
    System.assertEquals(false, options.breakLineBetweenClauses);
  }

  @IsTest
  private static void test_ILLEGAL_STATE() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.DateFormula().toSoql();
    } catch (CMN_UTIL_Exceptions.IllegalStateException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'CMN_UTIL_Exceptions.IllegalStateException not thrown'
    );
  }

  @IsTest
  private static void test_INVALID_N() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.DateFormula()
        .next(-1, CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql();
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void test_YESTERDAY() {
    System.assertEquals(
      'YESTERDAY',
      new CMN_SOQL_Query.DateFormula().yesterdayX().toSoql()
    );
  }

  @IsTest
  private static void test_TODAY() {
    System.assertEquals(
      'TODAY',
      new CMN_SOQL_Query.DateFormula().todayX().toSoql()
    );
  }

  @IsTest
  private static void test_TOMORROW() {
    System.assertEquals(
      'TOMORROW',
      new CMN_SOQL_Query.DateFormula().tomorrowX().toSoql()
    );
  }

  @IsTest
  private static void test_LAST_90_DAYS() {
    System.assertEquals(
      'LAST_90_DAYS',
      new CMN_SOQL_Query.DateFormula().last90Days().toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_90_DAYS() {
    System.assertEquals(
      'NEXT_90_DAYS',
      new CMN_SOQL_Query.DateFormula().next90Days().toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_DAY() {
    System.assertEquals(
      'NEXT_N_DAYS:1',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_N_DAYS:1',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_WEEK() {
    System.assertEquals(
      'NEXT_WEEK',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.Week)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_WEEK',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.Week)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_MONTH() {
    System.assertEquals(
      'NEXT_MONTH',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.Month)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_MONTH',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.Month)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_QUARTER() {
    System.assertEquals(
      'NEXT_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_YEAR() {
    System.assertEquals(
      'NEXT_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_FISCAL_QUARTER() {
    System.assertEquals(
      'NEXT_FISCAL_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_FISCAL_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_FISCAL_YEAR() {
    System.assertEquals(
      'NEXT_FISCAL_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .next(CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_FISCAL_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_DAY() {
    System.assertEquals(
      'LAST_N_DAYS:1',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
    System.assertEquals(
      'LAST_N_DAYS:1',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_WEEK() {
    System.assertEquals(
      'LAST_WEEK',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.Week)
        .toSoql()
    );
    System.assertEquals(
      'LAST_WEEK',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.Week)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_MONTH() {
    System.assertEquals(
      'LAST_MONTH',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.Month)
        .toSoql()
    );
    System.assertEquals(
      'LAST_MONTH',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.Month)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_QUARTER() {
    System.assertEquals(
      'LAST_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
    System.assertEquals(
      'LAST_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_YEAR() {
    System.assertEquals(
      'LAST_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
    System.assertEquals(
      'LAST_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_FISCAL_QUARTER() {
    System.assertEquals(
      'LAST_FISCAL_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
    System.assertEquals(
      'LAST_FISCAL_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_FISCAL_YEAR() {
    System.assertEquals(
      'LAST_FISCAL_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .last(CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
    System.assertEquals(
      'LAST_FISCAL_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_DAY() {
    System.assertEquals(
      'TODAY',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_WEEK() {
    System.assertEquals(
      'THIS_WEEK',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.Week)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_MONTH() {
    System.assertEquals(
      'THIS_MONTH',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.Month)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_QUARTER() {
    System.assertEquals(
      'THIS_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_YEAR() {
    System.assertEquals(
      'THIS_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_FISCAL_QUARTER() {
    System.assertEquals(
      'THIS_FISCAL_QUARTER',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_THIS_FISCAL_YEAR() {
    System.assertEquals(
      'THIS_FISCAL_YEAR',
      new CMN_SOQL_Query.DateFormula()
        .thisX(CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_N_DAYS() {
    System.assertEquals(
      'NEXT_N_DAYS:0',
      new CMN_SOQL_Query.DateFormula()
        .next(0, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_N_DAYS:1',
      new CMN_SOQL_Query.DateFormula()
        .next(1, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
    System.assertEquals(
      'NEXT_N_DAYS:2',
      new CMN_SOQL_Query.DateFormula()
        .next(2, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_N_WEEKS() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.DateFormula().next(2, CMN_SOQL_Query.UnitOfTime.Week);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void test_NEXT_N_MONTHS() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.DateFormula().next(2, CMN_SOQL_Query.UnitOfTime.Month);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void test_NEXT_N_QUARTERS() {
    System.assertEquals(
      'NEXT_N_QUARTERS:2',
      new CMN_SOQL_Query.DateFormula()
        .next(2, CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_N_YEARS() {
    System.assertEquals(
      'NEXT_N_YEARS:2',
      new CMN_SOQL_Query.DateFormula()
        .next(2, CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_N_FISCAL_QUARTERS() {
    System.assertEquals(
      'NEXT_N_FISCAL_QUARTERS:2',
      new CMN_SOQL_Query.DateFormula()
        .next(2, CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_NEXT_N_FISCAL_YEARS() {
    System.assertEquals(
      'NEXT_N_FISCAL_YEARS:2',
      new CMN_SOQL_Query.DateFormula()
        .next(2, CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_N_DAYS() {
    System.assertEquals(
      'LAST_N_DAYS:0',
      new CMN_SOQL_Query.DateFormula()
        .last(0, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
    System.assertEquals(
      'LAST_N_DAYS:1',
      new CMN_SOQL_Query.DateFormula()
        .last(1, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
    System.assertEquals(
      'LAST_N_DAYS:2',
      new CMN_SOQL_Query.DateFormula()
        .last(2, CMN_SOQL_Query.UnitOfTime.Day)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_N_WEEKS() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.DateFormula().last(2, CMN_SOQL_Query.UnitOfTime.Week);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void test_LAST_N_MONTHS() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Query.DateFormula().last(2, CMN_SOQL_Query.UnitOfTime.Month);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void test_LAST_N_QUARTERS() {
    System.assertEquals(
      'LAST_N_QUARTERS:2',
      new CMN_SOQL_Query.DateFormula()
        .last(2, CMN_SOQL_Query.UnitOfTime.Quarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_N_YEARS() {
    System.assertEquals(
      'LAST_N_YEARS:2',
      new CMN_SOQL_Query.DateFormula()
        .last(2, CMN_SOQL_Query.UnitOfTime.Year)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_N_FISCAL_QUARTERS() {
    System.assertEquals(
      'LAST_N_FISCAL_QUARTERS:2',
      new CMN_SOQL_Query.DateFormula()
        .last(2, CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
        .toSoql()
    );
  }

  @IsTest
  private static void test_LAST_N_FISCAL_YEARS() {
    System.assertEquals(
      'LAST_N_FISCAL_YEARS:2',
      new CMN_SOQL_Query.DateFormula()
        .last(2, CMN_SOQL_Query.UnitOfTime.FiscalYear)
        .toSoql()
    );
  }
}