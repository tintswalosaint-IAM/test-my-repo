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
 *
 * @author Accenture
 *
 * @date 2020 - Updated to new apex API
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_StringBuffer_TEST {
  @IsTest
  private static void testDecimal() {
    Decimal value = 3.14159;
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testDouble() {
    Double value = 3.14159;
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testInteger() {
    Integer value = 792392;
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testLong() {
    Long value = 792392;
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testId() {
    CMN_Foobar__c foo = new CMN_Foobar__c(
      Id = CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType),
      Name = 'test'
    );
    //insert foo;
    Id value = foo.Id;
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testBoolean() {
    Boolean value = true;
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(!value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      (!value)
    );
  }

  @IsTest
  private static void testString() {
    String value = 'rwkrfkdekf';
    System.assertEquals(
      (new CMN_UTIL_StringBuffer()).append(value).toStr(),
      '' + value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer()).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testDate() {
    Date value = Date.newInstance(1960, 2, 17);
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testDatetime() {
    Datetime value = Datetime.newInstance(2008, 12, 1);
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testTime() {
    Time value = Time.newInstance(18, 30, 2, 20);
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }

  @IsTest
  private static void testBlob() {
    Blob value = Blob.valueOf('test123');
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).toStr(),
      '' +
      value +
      '' +
      value
    );
    System.assertEquals(
      (new CMN_UTIL_StringBuffer(value)).append(value).append(value).toStr(),
      '' +
      value +
      '' +
      value +
      '' +
      value
    );
  }
}