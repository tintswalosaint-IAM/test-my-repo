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
private class CMN_SOQL_Builder_TEST {
  @IsTest
  private static void testWithSecurityEnforced() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WITH SECURITY_ENFORCED LIMIT 1000 OFFSET 0',
      new CMN_SOQL_Builder()
        .selectX('Id')
        .fromX('Account')
        .withSecurityEnforced(true)
        .limitX(1000)
        .offsetX(0)
        .toSoql()
    );
  }

  @IsTest
  private static void testLimit() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account LIMIT 1000',
      new CMN_SOQL_Builder()
        .selectX('Id')
        .fromX('Account')
        .limitX(1000)
        .toSoql()
    );
  }

  @IsTest
  private static void testNoObjectName() {
    Boolean exceptionCaught = false;
    try {
      new CMN_SOQL_Builder().toSoql();
    } catch (CMN_UTIL_Exceptions.IllegalStateException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'CMN_UTIL_Exceptions.IllegalStateException not thrown'
    );
  }

  @IsTest
  private static void testBadField1() {
    Boolean exceptionCaught = false;
    try {
      String aNull = null;
      new CMN_SOQL_Builder().selectX(aNull);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testBadField2() {
    Boolean exceptionCaught = false;
    try {
      List<Object> anObjectList = new List<Object>{
        new CMN_UTIL_NumberRange.DecimalRange(0, 1)
      };
      new CMN_SOQL_Builder().selectX(anObjectList);
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testBasicSelect() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id,Name FROM Account WHERE Name like \'%acme%\'',
      new CMN_SOQL_Builder()
        .selectX(new List<String>{ 'Id', 'Name' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            '%acme%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testBasicSelectStringListSelectx() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id,Name FROM Account WHERE Name like \'%acme%\'',
      new CMN_SOQL_Builder()
        .selectX(new List<String>{ 'Id', 'Name' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            '%acme%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testOption_wildcardStringsInLikeOperators() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE Name like \'%acme%\'',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'acme'
          )
        )
        .toSoql(
          new CMN_SOQL_Query.SoqlOptions().wildcardStringsInLikeOperators()
        )
    );
  }

  @IsTest
  private static void testOption_wildcardStringsInLikeOperatorsAlreadyWildcarded() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE Name like \'%acme%\'',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            '%acme%'
          )
        )
        .toSoql(
          new CMN_SOQL_Query.SoqlOptions().wildcardStringsInLikeOperators()
        )
    );
  }

  @IsTest
  private static void testOption_doNotWildcardStringsInLikeOperators() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE Name like \'acme\'',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'acme'
          )
        )
        .toSoql(
          new CMN_SOQL_Query.SoqlOptions().doNotWildcardStringsInLikeOperators()
        )
    );
  }

  @IsTest
  private static void testOption_escapeSingleQuotes() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE Name like \'Bill\\\'s Chop Shop\'',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'Bill\'s Chop Shop'
          )
        )
        .toSoql(new CMN_SOQL_Query.SoqlOptions().escapeSingleQuotes())
    );
  }

  @IsTest
  private static void testOption_doNotEscapeSingleQuotes() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE Name like \'Bill\'s Chop Shop\'',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'Bill\'s Chop Shop'
          )
        )
        .toSoql(new CMN_SOQL_Query.SoqlOptions().doNotEscapeSingleQuotes())
    );
  }

  @IsTest
  private static void testNestedConditions() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id, Name FROM Account WHERE ((Name like \'%acme%\' OR Description = \'yo\') AND IsPartner = true) ORDER BY Name DESC LIMIT 500',
      new CMN_SOQL_Builder()
        .selectX(new List<String>{ 'Id', 'Name' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.AndCondition()
            .add(
              new CMN_SOQL_Query.OrCondition()
                .add(
                  new CMN_SOQL_Query.FieldCondition(
                    'Name',
                    CMN_SOQL_Query.Operator.LIKEX,
                    '%acme%'
                  )
                )
                .add(
                  new CMN_SOQL_Query.FieldCondition(
                    'Description',
                    CMN_SOQL_Query.Operator.EQUALS,
                    'yo'
                  )
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
        .orderByX(new CMN_SOQL_Query.OrderBy('Name').descending())
        .limitX(500)
        .toSoql()
    );
  }

  @IsTest
  private static void testOrderBy1() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account ORDER BY Name',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .orderByX(
          new List<CMN_SOQL_Query.OrderBy>{ new CMN_SOQL_Query.OrderBy('Name') }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testOrderBy2() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account ORDER BY Name ASC NULLS LAST, rating DESC, industry DESC NULLS FIRST',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .orderByX(
          new List<CMN_SOQL_Query.OrderBy>{
            new CMN_SOQL_Query.OrderBy('Name').ascending().nullsLast(),
            new CMN_SOQL_Query.OrderBy('rating').descending(),
            new CMN_SOQL_Query.OrderBy('industry').descending().nullsFirst()
          }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testANullOrderBy() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account ORDER BY Name',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .orderByX(
          new List<CMN_SOQL_Query.OrderBy>{
            new CMN_SOQL_Query.OrderBy('Name'),
            null
          }
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testGroupBy() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account GROUP BY Name',
      new CMN_SOQL_Builder().fromX('Account').groupByX('Name').toSoql()
    );
  }

  @IsTest
  private static void testParentToChildQuery1() {
    CMN_SOQL_String.assertEquals(
      'SELECT ID, Name, toLabel(Rating), (SELECT FirstName, LastName FROM Contacts) FROM Account',
      new CMN_SOQL_Builder()
        .selectX('ID')
        .selectX('Name')
        .selectX(new CMN_SOQL_Query.Field('Rating').toLabelX())
        .selectX(
          new CMN_SOQL_Builder()
            .selectX('FirstName')
            .selectX('LastName')
            .fromX('Contacts')
        )
        .fromX('Account')
        .toSoql()
    );
  }

  @IsTest
  private static void testParentToChildQuery2() {
    CMN_SOQL_String.assertEquals(
      'SELECT    ID, Name,    toLabel(Rating), (SELECT FirstName, LastName FROM Contacts) FROM Account',
      new CMN_SOQL_Builder()
        .selectX(
          new List<Object>{
            'ID',
            'Name',
            new CMN_SOQL_Query.Field('Rating').toLabelX(),
            new CMN_SOQL_Builder()
              .selectX('FirstName')
              .selectX('LastName')
              .fromX('Contacts')
          }
        )
        .fromX('Account')
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectCount1() {
    CMN_SOQL_String.assertEquals(
      'SELECT count() from Contact c, c.Account a WHERE a.Name = \'MyriadPubs\'',
      new CMN_SOQL_Builder()
        .selectCount()
        .fromX('Contact c, c.Account a')
        .whereX(new CMN_SOQL_Query.FieldCondition('a.Name', 'MyriadPubs'))
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectCount2() {
    CMN_SOQL_String.assertEquals(
      'SELECT count() FROM Account WHERE Name LIKE \'a%\'',
      new CMN_SOQL_Builder()
        .selectCount()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'a%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectCountWithArg() {
    CMN_SOQL_String.assertEquals(
      'SELECT count(Id) FROM Account WHERE Name LIKE \'a%\'',
      new CMN_SOQL_Builder()
        .selectCount('Id')
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'a%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectAverage() {
    CMN_SOQL_String.assertEquals(
      'SELECT AVG(Amount) FROM Account WHERE Name LIKE \'a%\'',
      new CMN_SOQL_Builder()
        .selectAverageX('Amount')
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'a%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectMax() {
    CMN_SOQL_String.assertEquals(
      'SELECT Max(Amount) FROM Account WHERE Name LIKE \'a%\'',
      new CMN_SOQL_Builder()
        .selectMaxX('Amount')
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'a%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectMin() {
    CMN_SOQL_String.assertEquals(
      'SELECT Min(Amount) FROM Account WHERE Name LIKE \'a%\'',
      new CMN_SOQL_Builder()
        .selectMinX('Amount')
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'a%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectSum() {
    CMN_SOQL_String.assertEquals(
      'SELECT Sum(Amount) FROM Account WHERE Name LIKE \'a%\'',
      new CMN_SOQL_Builder()
        .selectSumX('Amount')
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'Name',
            CMN_SOQL_Query.Operator.LIKEX,
            'a%'
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectNullCondition() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Case WHERE Contact.LastName = null',
      new CMN_SOQL_Builder()
        .fromX('Case')
        .whereX(new CMN_SOQL_Query.FieldCondition('Contact.LastName', null))
        .toSoql()
    );
  }

  @IsTest
  private static void testIncludes() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id, MSP1__c from CustObj__c WHERE MSP1__c INCLUDES (\'AAA;BBB\',\'CCC\')',
      new CMN_SOQL_Builder()
        .selectX(new List<String>{ 'Id', 'MSP1__c' })
        .fromX('CustObj__c')
        .whereX(
          new CMN_SOQL_Query.SetCondition('MSP1__c')
            .includes(new List<String>{ 'AAA;BBB', 'CCC' })
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testExcludes() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id, MSP1__c from CustObj__c WHERE MSP1__c EXCLUDES (\'AAA;BBB\',\'CCC\')',
      new CMN_SOQL_Builder()
        .selectX(new List<String>{ 'Id', 'MSP1__c' })
        .fromX('CustObj__c')
        .whereX(
          new CMN_SOQL_Query.SetCondition('MSP1__c')
            .excludes(new List<String>{ 'AAA;BBB', 'CCC' })
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testIn() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM ACCOUNT WHERE BillingState IN (\'California\',\'New York\')',
      new CMN_SOQL_Builder()
        .fromX('ACCOUNT')
        .whereX(
          new CMN_SOQL_Query.SetCondition('BillingState')
            .inX(new List<String>{ 'California', 'New York' })
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testNotIn() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM ACCOUNT WHERE BillingState NOT IN (\'California\',\'New York\')',
      new CMN_SOQL_Builder()
        .fromX('ACCOUNT')
        .whereX(
          new CMN_SOQL_Query.SetCondition('BillingState')
            .notIn(new List<String>{ 'California', 'New York' })
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testDateFormula_NEXT_N_FISCAL_QUARTERS() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE CreatedDate < NEXT_N_FISCAL_QUARTERS:6',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'CreatedDate',
            CMN_SOQL_Query.Operator.LESS_THAN,
            new CMN_SOQL_Query.DateFormula()
              .next(6, CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testDateFormula_TOMORROW() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Opportunity WHERE CloseDate = TOMORROW',
      new CMN_SOQL_Builder()
        .fromX('Opportunity')
        .whereX(
          new CMN_SOQL_Query.FieldCondition(
            'CloseDate',
            new CMN_SOQL_Query.DateFormula().tomorrowX()
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void test_EQUALS_1() {
    CMN_SOQL_String.assertEquals(
      'SELECT Name,employees FROM Account WHERE employees = 10',
      new CMN_SOQL_Builder()
        .selectX('Name')
        .selectX(new Set<Object>{ 'employees' })
        .fromX('Account')
        .whereX(new CMN_SOQL_Query.FieldCondition('employees', 10))
        .toSoql()
    );
  }

  @IsTest
  private static void test_EQUALS_1_SetString() {
    CMN_SOQL_String.assertEquals(
      'SELECT Name,employees FROM Account WHERE employees = 10',
      new CMN_SOQL_Builder()
        .selectX('Name')
        .selectX(new Set<String>{ 'employees' })
        .fromX('Account')
        .whereX(new CMN_SOQL_Query.FieldCondition('employees', 10))
        .toSoql()
    );
  }

  @IsTest
  private static void test_EQUALS_2() {
    CMN_SOQL_String.assertEquals(
      'SELECT Name,employees FROM Account WHERE employees = 10',
      new CMN_SOQL_Builder()
        .selectX('Name')
        .selectX('employees')
        .fromX('Account')
        .whereX(new CMN_SOQL_Query.FieldCondition('employees').equals(10))
        .toSoql()
    );
  }

  @IsTest
  private static void test_EQUALS_3() {
    CMN_SOQL_String.assertEquals(
      'SELECT Name,employees FROM Account WHERE employees = 10',
      new CMN_SOQL_Builder()
        .selectX(new Set<Object>{ 'Name', 'employees' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition().field('employees').equals(10)
        )
        .toSoql()
    );
  }

  @IsTest
  private static void test_EQUALS_3_SetString() {
    CMN_SOQL_String.assertEquals(
      'SELECT Name,employees FROM Account WHERE employees = 10',
      new CMN_SOQL_Builder()
        .selectX(new Set<String>{ 'Name', 'employees' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.FieldCondition().field('employees').equals(10)
        )
        .toSoql()
    );
  }

  @IsTest
  private static void test_INX_1() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id,industry FROM Account WHERE industry in (\'Agriculture\',\'Apparel\')',
      new CMN_SOQL_Builder()
        .selectX(new List<Object>{ 'industry', 'Id' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.SetCondition(
            'industry',
            CMN_SOQL_Query.Operator.INX,
            new List<Object>{ 'Agriculture', 'Apparel' }
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void test_INX_1_ListString() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id,industry FROM Account WHERE industry in (\'Agriculture\',\'Apparel\')',
      new CMN_SOQL_Builder()
        .selectX(new List<String>{ 'industry', 'Id' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.SetCondition(
            'industry',
            CMN_SOQL_Query.Operator.INX,
            new List<Object>{ 'Agriculture', 'Apparel' }
          )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void test_INX_2() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id,industry FROM Account WHERE industry in (\'Agriculture\',\'Apparel\')',
      new CMN_SOQL_Builder()
        .selectX(new List<Object>{ 'industry', 'Id' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.SetCondition('industry')
            .inX(new List<Object>{ 'Agriculture', 'Apparel' })
        )
        .toSoql()
    );
  }

  @IsTest
  private static void test_INX_3() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id,industry FROM Account WHERE industry in (\'Agriculture\',\'Apparel\')',
      new CMN_SOQL_Builder()
        .selectX(new List<Object>{ 'industry', 'Id' })
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.SetCondition()
            .field('industry')
            .inX(new List<Object>{ 'Agriculture', 'Apparel' })
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testBasicSemiJoin() {
    CMN_SOQL_String.assertEquals(
      'SELECT Id FROM Account WHERE ID IN ' +
      '(SELECT AccountId FROM Opportunity WHERE StageName = \'Closed Lost\')',
      new CMN_SOQL_Builder()
        .fromX('Account')
        .whereX(
          new CMN_SOQL_Query.SetCondition('ID')
            .inX(
              new CMN_SOQL_Builder()
                .selectX('AccountId')
                .fromX('Opportunity')
                .whereX(
                  new CMN_SOQL_Query.FieldCondition('StageName', 'Closed Lost')
                )
            )
        )
        .toSoql()
    );
  }

  @IsTest
  private static void testDuplicateFields() {
    CMN_SOQL_String.assertEquals(
      'SELECT Name FROM Account',
      new CMN_SOQL_Builder()
        .selectX('Name')
        .selectX(new CMN_SOQL_Query.Field('Name'))
        .fromX('Account')
        .toSoql()
    );
  }

  @IsTest
  private static void testSelectAll_ApexClass() {
    final String actualSoql = new CMN_SOQL_Builder()
      .selectAll()
      .fromX('ApexClass')
      .toSoql();
    Set<String> fieldsActual = CMN_UTIL_Set.listToSet(
      CMN_UTIL_Array.lowerCase(
        CMN_UTIL_Array.trim(
          CMN_UTIL_String.split(
            CMN_UTIL_String.substringAfter(
              CMN_UTIL_String.substringBefore(actualSoql, ' FROM'),
              'SELECT '
            ),
            ','
          )
        )
      )
    );

    System.assertNotEquals(null, fieldsActual);
    final Set<String> fieldsExpected = new Set<String>{
      'id',
      'createdbyid',
      'body',
      'name'
    };
    for (String fieldExpected : fieldsExpected) {
      System.assert(
        fieldsActual.contains(fieldExpected),
        'expected soql to contain column ' +
        fieldExpected +
        ': ' +
        actualSoql
      );
    }
    final String fromObjectNameActual = CMN_UTIL_String.substringAfter(
      actualSoql,
      'FROM '
    );
    System.assertEquals('ApexClass', fromObjectNameActual);
  }
}