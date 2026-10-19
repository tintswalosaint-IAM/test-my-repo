/**
 * @description Copyright (c), FinancialForce.com, inc
 * All rights reserved.
 * <p/>
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 * <p/>
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 * <p/>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 *  This class adapted from https://github.com/capeterson/Apex-Util
 * Used under a BSD license: https://github.com/capeterson/Apex-Util/blob/master/LICENSE
 * <p/>
 * <p>VCCC-378</p>
 **/
@IsTest(SeeAllData=false)
private class CMN_UTIL_SObjectDescribe_TEST {
  /**
   * @description Verify that the different ways of getting your hands on an CMN_UTIL_SObjectDescribe instance all handle null inputs
   * 				(and blank/empty strings, why not?) by returning null - since there's no possible way to resolve it.
   */
  @IsTest
  private static void getDescribe_badInput() {
    String nullStr = null; //having it as a String var makes for unambiguous selection of overloads
    Schema.SObjectType nullType = null;
    Schema.DescribeSObjectResult nullDescribe = null;
    SObject nullSObject = null;
    System.assertEquals(null, CMN_UTIL_SObjectDescribe.getDescribe(nullStr));
    System.assertEquals(null, CMN_UTIL_SObjectDescribe.getDescribe(''));
    System.assertEquals(null, CMN_UTIL_SObjectDescribe.getDescribe(' '));
    System.assertEquals(null, CMN_UTIL_SObjectDescribe.getDescribe(nullType));
    System.assertEquals(
      null,
      CMN_UTIL_SObjectDescribe.getDescribe(nullDescribe)
    );
    System.assertEquals(
      null,
      CMN_UTIL_SObjectDescribe.getDescribe(nullSObject)
    );
  }

  @IsTest
  private static void namespaceAttributeMap() {
    CMN_UTIL_SObjectDescribe.GlobalDescribeMap gdm = CMN_UTIL_SObjectDescribe.getGlobalDescribe();

    Map<String, SObjectType> testGDM = Schema.getGlobalDescribe();

    System.assertEquals(testGDM.size(), gdm.size());

    Schema.SObjectType accountObjType = gdm.get('AccOunT');
    System.assertEquals(accountObjType, Account.SObjectType);
    System.assertEquals(Schema.getGlobalDescribe().size(), gdm.size());

    CMN_UTIL_SObjectDescribe accountDescribe = CMN_UTIL_SObjectDescribe.getDescribe(
      accountObjType
    );
    CMN_UTIL_SObjectDescribe.FieldsMap fields = accountDescribe.getFields();
    System.assert(
      fields.keySet().containsAll(accountDescribe.getFieldsMap().keySet())
    );

    System.assertEquals(fields.get('name'), Account.SObjectType.fields.Name); //behavior of FieldsMap is tested in another method
    System.assertEquals(
      Schema.SObjectType.Account.fields.getMap().size(),
      fields.size()
    );

    System.assertEquals(
      null,
      fields.get(null),
      'Null input should result in null ouput.'
    );
    System.assertEquals(
      null,
      fields.get(''),
      'Invalid fieldname input should result in null ouput.'
    );
  }

  @IsTest
  private static void fieldMap() {
    String fakeNamespace = 'fflib_test';
    Map<String, Schema.SObjectField> fakeFieldData = new Map<String, Schema.SObjectField>{
      'name__c' => Contact.SObjectType.fields.Name, //re-use standard field types since we can't mock them
      fakeNamespace + '__name__c' => Account.SObjectType.fields.Name,
      fakeNamespace + '__otherField__c' => Account.SObjectType.fields.Name,
      'createddate' => Contact.SObjectType.fields.CreatedDate
    };
    CMN_UTIL_SObjectDescribe.FieldsMap fields = new CMN_UTIL_SObjectDescribe.FieldsMap(
      fakeFieldData
    );
    fields.currentNamespace = fakeNamespace;
    System.assertEquals(true, fields.containsKey('name__c'));
    System.assertEquals(
      true,
      fields.containsKey(fakeNamespace.toUpperCase() + '__nAMe__c')
    );
    System.assert(
      fields.get('NAme__c') === fields.get(fakeNamespace + '__namE__c')
    );

    System.assert(!fields.keySet(false).contains('otherField__c'));
    System.assert(
      fields.keySet(false).contains(fakeNamespace + '__otherField__c')
    );

    System.assert(fields.keySet(true).contains('otherField__c'));
    System.assert(
      !fields.keySet(true).contains(fakeNamespace + '__otherField__c')
    );

    fields.currentNamespace = 'someOtherNamespace';
    System.assertNotEquals(
      fields.get('name__C'),
      fields.get(fakeNamespace.capitalize() + '__nAme__c')
    );
  }

  @IsTest
  private static void globalDescribeMap() {
    String fakeNamespace = 'fflib_test';
    Map<String, Schema.SObjectType> fakeFieldData = new Map<String, Schema.SObjectType>{
      'name__c' => Contact.SObjectType, //re-use stndard object types since we can't mock them
      fakeNamespace + '__name__c' => Account.SObjectType,
      'createddate' => Lead.SObjectType
    };
    CMN_UTIL_SObjectDescribe.GlobalDescribeMap gdm = new CMN_UTIL_SObjectDescribe.GlobalDescribeMap(
      fakeFieldData
    );
    gdm.currentNamespace = fakeNamespace;
    System.assertEquals(true, gdm.containsKey('name__c'));
    System.assertEquals(true, gdm.containsKey(fakeNamespace + '__name__c'));
    System.assert(gdm.get('name__c') === gdm.get(fakeNamespace + '__name__c'));

    gdm.currentNamespace = 'someOtherNamespace';
    System.assertNotEquals(
      gdm.get('name__c'),
      gdm.get(fakeNamespace + '__name__c')
    );
  }

  //Tests all forms of the getDescribe static
  @IsTest
  private static void getAccountDescribes() {
    CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(
      'Account'
    );
    CMN_UTIL_SObjectDescribe d2 = CMN_UTIL_SObjectDescribe.getDescribe(
      Account.SObjectType
    );
    CMN_UTIL_SObjectDescribe d3 = CMN_UTIL_SObjectDescribe.getDescribe(
      Schema.SObjectType.Account
    );
    System.assertEquals('Account', d.getDescribe().getName());
    System.assert(
      (d === d2 &&
      d2 === d3),
      'All three getDescribe calls should return the same cached instance.'
    );
  }

  @IsTest
  private static void simpleAccountFieldDescribe() {
    CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(
      Account.SObjectType
    );
    Map<String, Schema.SObjectField> fields;
    for (Integer i = 0; i < 10; i++) {
      fields = d.getFieldsMap();
    }

    System.assertEquals(false, fields.isEmpty());
    System.assertEquals(Account.SObjectType, d.getSObjectType());
  }

  @IsTest
  private static void simpleAccountFieldSetDescribe() {
    CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(
      Account.SObjectType
    );
    Map<String, Schema.FieldSet> fields;
    for (Integer i = 0; i < 10; i++) {
      fields = d.getFieldSetsMap();
    }
  }

  @IsTest
  private static void simpleAccountGetNameField() {
    CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(
      Account.SObjectType
    );
    Schema.SObjectField nameField = d.getNameField();
    System.assertEquals('Name', nameField.getDescribe().getName());
  }

  @IsTest
  private static void flushCache() {
    CMN_UTIL_SObjectDescribe d = CMN_UTIL_SObjectDescribe.getDescribe(
      'Account'
    );
    CMN_UTIL_SObjectDescribe.flushCache();
    CMN_UTIL_SObjectDescribe d2 = CMN_UTIL_SObjectDescribe.getDescribe(
      'Account'
    );
    System.assert(
      d !== d2,
      'Second object should be a fresh instance after a cache flush.'
    );
  }

  @IsTest
  private static void rawGlobalDescribeCheck() {
    Map<String, Schema.SObjectType> systemGd = Schema.getGlobalDescribe();
    CMN_UTIL_SObjectDescribe.flushCache();
    Map<String, Schema.SObjectType> cachedGd = CMN_UTIL_SObjectDescribe.getRawGlobalDescribe();
    System.assertEquals(systemGd.size(), cachedGd.size());
  }
}