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
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p/>
 * <p>VCCC-378</p>
 **/
@IsTest(SeeAllData=false)
public class CMN_MOCK_ApexMocksUtils_TEST {
  public static Schema.FieldSet findAnyFieldSet() {
    for (Schema.SObjectType objectType : Schema.getGlobalDescribe().values()) {
      for (
        Schema.FieldSet fs : objectType.getDescribe()
          .fieldSets.getMap()
          .values()
      ) {
        return fs;
      }
    }

    return null;
  }

  @IsTest
  private static void makeRelationship_returnsObjectsWithRelationFieldSet() {
    //Given
    Account acc = new Account(
      Id = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType),
      Name = 'AccName',
      NumberOfEmployees = 7
    );

    Contact contact1 = new Contact(
      Id = CMN_DAL_SObjectDomain.generateIncrementalId(Contact.SObjectType),
      DoNotCall = true
    );

    Contact contact2 = new Contact(
      Id = CMN_DAL_SObjectDomain.generateIncrementalId(Contact.SObjectType),
      DoNotCall = false
    );

    //When
    Account accWithRelationships = ((List<Account>) CMN_MOCK_ApexMocksUtils.makeRelationship(
      List<Account>.class,
      new List<Account>{ acc },
      Contact.AccountId,
      new List<List<Contact>>{ new List<Contact>{ contact1, contact2 } }
    ))[0];

    //Then
    System.assertEquals(acc.Id, accWithRelationships.Id);
    System.assertEquals(acc.Name, accWithRelationships.Name);
    System.assertEquals(
      acc.NumberOfEmployees,
      accWithRelationships.NumberOfEmployees
    );

    //Assert relationship fields
    List<Contact> contacts = accWithRelationships.Contacts;
    System.assertNotEquals(null, contacts);
    System.assertEquals(2, contacts.size());

    System.assertEquals(contact1.Id, contacts[0].Id);
    System.assertEquals(contact1.DoNotCall, contacts[0].DoNotCall);

    System.assertEquals(contact2.Id, contacts[1].Id);
    System.assertEquals(contact2.DoNotCall, contacts[1].DoNotCall);
  }

  @IsTest
  private static void makeRelationship_GenericOverload_ReturnsObjectsWithRelationFieldSet() {
    //Given
    SObject acc = Schema.getGlobalDescribe().get('Account').newSObject();
    acc.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(acc.getSObjectType())
    );
    acc.put('Name', 'AccName');
    acc.put('NumberOfEmployees', 7);

    SObject contact1 = Schema.getGlobalDescribe().get('Contact').newSObject();
    contact1.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(contact1.getSObjectType())
    );
    contact1.put('DoNotCall', true);

    SObject contact2 = Schema.getGlobalDescribe().get('Contact').newSObject();
    contact2.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(contact2.getSObjectType())
    );
    contact2.put('DoNotCall', false);

    //When
    SObject accWithRelationships = ((List<SObject>) CMN_MOCK_ApexMocksUtils.makeRelationship(
      'Account',
      'Contact',
      new List<SObject>{ acc },
      'AccountId',
      new List<List<SObject>>{ new List<SObject>{ contact1, contact2 } }
    ))[0];

    //Then
    System.assertEquals(acc.Id, accWithRelationships.Id);
    System.assertEquals(acc.get('Name'), accWithRelationships.get('Name'));
    System.assertEquals(
      acc.get('NumberOfEmployees'),
      accWithRelationships.get('NumberOfEmployees')
    );

    //Assert relationship fields
    List<SObject> contacts = accWithRelationships.getSObjects('Contacts');
    System.assertNotEquals(null, contacts);
    System.assertEquals(2, contacts.size());

    System.assertEquals(contact1.Id, contacts[0].Id);
    System.assertEquals(
      (Boolean) contact1.get('DoNotCall'),
      (Boolean) contacts[0].get('DoNotCall')
    );

    System.assertEquals(contact2.Id, contacts[1].Id);
    System.assertEquals(
      (Boolean) contact2.get('DoNotCall'),
      (Boolean) contacts[1].get('DoNotCall')
    );
  }

  @IsTest
  private static void makeRelationship_GenericOverload_ThrowsErrorOnInvalidParentType() {
    // Setup parent object
    SObject acc = Schema.getGlobalDescribe().get('Account').newSObject();
    acc.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(acc.getSObjectType())
    );

    // Setup child object
    SObject cont = Schema.getGlobalDescribe().get('Contact').newSObject();
    cont.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(cont.getSObjectType())
    );

    String errorMessage = '';
    try {
      // Call method under test
      CMN_MOCK_ApexMocksUtils.makeRelationship(
        'MyInvalidParentType',
        'Contact',
        new List<SObject>{ acc },
        'AccountId',
        new List<List<SObject>>{ new List<SObject>{ cont } }
      );
    } catch (Exception exc) {
      errorMessage = exc.getMessage();
    }
    System.assertEquals(
      'SObject type not found: MyInvalidParentType',
      errorMessage
    );
  }

  @IsTest
  private static void makeRelationship_GenericOverload_ThrowsErrorOnInvalidChildType() {
    // Setup parent object
    SObject acc = Schema.getGlobalDescribe().get('Account').newSObject();
    acc.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(acc.getSObjectType())
    );

    // Setup child object
    SObject cont = Schema.getGlobalDescribe().get('Contact').newSObject();
    cont.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(cont.getSObjectType())
    );

    String errorMessage = '';
    try {
      // Call method under test
      CMN_MOCK_ApexMocksUtils.makeRelationship(
        'Account',
        'MyInvalidChildType',
        new List<SObject>{ acc },
        'AccountId',
        new List<List<SObject>>{ new List<SObject>{ cont } }
      );
    } catch (Exception exc) {
      errorMessage = exc.getMessage();
    }
    System.assertEquals(
      'SObject type not found: MyInvalidChildType',
      errorMessage
    );
  }

  @IsTest
  private static void makeRelationship_GenericOverload_ThrowsErrorOnInvalidFieldName() {
    // Setup parent object
    SObject acc = Schema.getGlobalDescribe().get('Account').newSObject();
    acc.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(acc.getSObjectType())
    );

    // Setup child object
    SObject cont = Schema.getGlobalDescribe().get('Contact').newSObject();
    cont.put(
      'Id',
      CMN_DAL_SObjectDomain.generateIncrementalId(cont.getSObjectType())
    );

    String errorMessage = '';
    try {
      // Call method under test
      CMN_MOCK_ApexMocksUtils.makeRelationship(
        'Account',
        'Contact',
        new List<SObject>{ acc },
        'MyInvalidField',
        new List<List<SObject>>{ new List<SObject>{ cont } }
      );
    } catch (Exception exc) {
      errorMessage = exc.getMessage();
    }
    System.assertEquals(
      'SObject field not found: MyInvalidField',
      errorMessage
    );
  }

  @IsTest
  private static void setReadOnlyFields_CreatedByIdSetToCurrentUserId_IdFieldSetSuccessfully() {
    Account acc = new Account();
    Id userId = CMN_DAL_SObjectDomain.generateIncrementalId(
      (new User()).getSObjectType()
    );

    Test.startTest();
    acc = (Account) CMN_MOCK_ApexMocksUtils.setReadOnlyFields(
      acc,
      Account.class,
      new Map<SObjectField, Object>{ Account.CreatedById => userId }
    );
    Test.stopTest();

    System.assertEquals(userId, acc.CreatedById);
  }

  @IsTest
  private static void setReadOnlyFields_LastReferencedDateSetOnAccount_DateTimeFieldSetSuccessfully() {
    Account acc = new Account();
    Datetime lastRefDate = Datetime.newInstanceGmt(2020, 1, 7, 23, 30, 0);

    Test.startTest();
    acc = (Account) CMN_MOCK_ApexMocksUtils.setReadOnlyFields(
      acc,
      Account.class,
      new Map<SObjectField, Object>{ Account.LastReferencedDate => lastRefDate }
    );
    Test.stopTest();

    System.assertEquals(lastRefDate, acc.LastReferencedDate);
  }

  @IsTest
  private static void setReadOnlyFields_IsDeletedSetOnAccount_BooleanFieldSetSuccessfully() {
    Account acc = new Account();
    Boolean isDeleted = true;

    Test.startTest();
    acc = (Account) CMN_MOCK_ApexMocksUtils.setReadOnlyFields(
      acc,
      Account.class,
      new Map<SObjectField, Object>{ Account.IsDeleted => isDeleted }
    );
    Test.stopTest();

    System.assertEquals(isDeleted, acc.IsDeleted);
  }
}