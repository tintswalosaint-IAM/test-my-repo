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
@IsTest(SeeAllData=false)
private class CMN_SOQL_String_TEST {
  @IsTest
  private static void testInvalidValue() {
    Boolean exceptionCaught = false;
    try {
      CMN_SOQL_String.toLiteral(new CMN_UTIL_NumberRange.DecimalRange(0, 1));
    } catch (IllegalArgumentException e) {
      exceptionCaught = true;
    }
    System.assert(
      exceptionCaught == true,
      'IllegalArgumentException not thrown'
    );
  }

  @IsTest
  private static void testSoqlableValue() {
    System.assertEquals(
      'NEXT_N_FISCAL_QUARTERS:2',
      CMN_SOQL_String.toLiteral(
        new CMN_SOQL_Query.DateFormula()
          .next(2, CMN_SOQL_Query.UnitOfTime.FiscalQuarter)
      )
    );
  }

  @IsTest
  private static void testNullValue() {
    Object value = null;
    System.assertEquals('null', CMN_SOQL_String.toLiteral(value));
  }

  @IsTest
  private static void testStringValue() {
    System.assertEquals('\'acme\'', CMN_SOQL_String.toLiteral('acme'));
  }

  @IsTest
  private static void testBooleanValue() {
    System.assertEquals('true', CMN_SOQL_String.toLiteral(true));
    System.assertEquals('false', CMN_SOQL_String.toLiteral(false));
  }

  @IsTest
  private static void testIntegerValue() {
    Integer i = 1;
    System.assertEquals('1', CMN_SOQL_String.toLiteral(i));
  }

  @IsTest
  private static void testLongValue() {
    Long l = 1;
    System.assertEquals('1', CMN_SOQL_String.toLiteral(l));
  }

  @IsTest
  private static void testDoubleValue() {
    Double d = 1.1;
    System.assertEquals('1.1', CMN_SOQL_String.toLiteral(d));
  }

  @IsTest
  private static void testDecimalValue() {
    Decimal d = 1.1;
    System.assertEquals('1.1', CMN_SOQL_String.toLiteral(d));
  }

  @IsTest
  private static void testDateValue() {
    System.assertEquals(
      '1960-02-17',
      CMN_SOQL_String.toLiteral(Date.newInstance(1960, 2, 17))
    );
  }

  @IsTest
  private static void testDatetimeValue() {
    System.assertEquals(
      '2008-12-01T12:00:00Z',
      CMN_SOQL_String.toLiteral(Datetime.newInstance(2008, 12, 1))
    );
  }

  @IsTest
  private static void testPrimitivesToSoqlLiterals() {
    final List<Object> values = new List<Object>{
      1,
      'test123',
      1.1,
      true,
      null
    };
    final List<String> literals = CMN_SOQL_String.toLiteral(values);
    System.assertEquals('1', literals.get(0));
    System.assertEquals('\'test123\'', literals.get(1));
    System.assertEquals('1.1', literals.get(2));
    System.assertEquals('true', literals.get(3));
    System.assertEquals('null', literals.get(4));
  }

  @IsTest
  private static void testEquals_1() {
    System.assertEquals(
      false,
      CMN_SOQL_String.equals('select id from account', 'SELECT id FROM contact')
    );
  }

  @IsTest
  private static void testEquals_2() {
    System.assertEquals(
      true,
      CMN_SOQL_String.equals('select id from account', 'SELECT id FROM account')
    );
  }

  @IsTest
  private static void testEquals_3() {
    System.assertEquals(
      false,
      CMN_SOQL_String.equals(
        'select id,name from account',
        'SELECT id FROM account'
      )
    );
  }

  @IsTest
  private static void testEquals_4() {
    System.assertEquals(
      true,
      CMN_SOQL_String.equals(
        '  select    ispartner,rating,id, name    from   account  ',
        ' SELECT  name,rating,  ispartner,id  FROM   account   '
      )
    );
  }

  @IsTest
  private static void testEquals_5() {
    System.assertEquals(
      false,
      CMN_SOQL_String.equals(
        'xxx',
        ' SELECT  name,rating,  ispartner,id  FROM   account   '
      )
    );
  }

  @IsTest
  private static void testEquals_newlinesInconsistent() {
    System.assertEquals(
      false,
      CMN_SOQL_String.equals(
        '  select    ispartner,\nrating,\nid,\n name    from   account  ',
        ' SELECT  name,rating,  ispartner,id  FROM   account   '
      )
    );
  }

  @IsTest
  private static void testEquals_newlinesConsistent() {
    System.assertEquals(
      true,
      CMN_SOQL_String.equals(
        '  select    ispartner,\nrating,id, name    from   account  ',
        ' SELECT  name,rating, \n ispartner,id  FROM   account   '
      )
    );
  }

  @IsTest
  private static void testAssertEquals() {
    CMN_SOQL_String.assertEquals(
      'select id,name from account',
      'SELECT id,name FROM account'
    );
  }
}