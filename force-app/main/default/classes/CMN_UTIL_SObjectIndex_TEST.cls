/**
 * @description Test class for CMN_UTIL_SObjectIndex
 * <p/>
 * MIT License
 * <p/>
 * Copyright (c) 2018 Aidan Harding, Nebula Consulting
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author aidan@nebulaconsulting.co.uk
 *
 * @date 09/11/2018
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_SObjectIndex_TEST {
  private final static String TEST_LAST_NAME = 'Doe';
  private static Account newAccount = CMN_DAL_DataFactory.insertAccount();
  private static String FIELD_ACCOUNT_ID = Contact.AccountId.getDescribe()
    .getLocalName();
  private static String FIELD_LAST_NAME = Contact.LastName.getDescribe()
    .getLocalName();

  @IsTest
  private static void emptyIndex() {
    Test.startTest();

    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
    );

    Test.stopTest();

    System.assertEquals(null, theIndex.get(new Contact()));
    System.assert(theIndex.isEmpty());
  }

  @IsTest
  private static void setCaseInsensitiveWithData() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .put(new Contact());

    Test.startTest();

    try {
      theIndex.setIsCaseInsensitive(true);
      System.assert(false, 'Should have thrown IllegalStateException');
    } catch (CMN_UTIL_SObjectIndex.IllegalStateException e) {
      System.assertEquals(
        CMN_UTIL_SObjectIndex.ERROR_CASE_INSENSITIVE,
        e.getMessage()
      );
    }

    Test.stopTest();
  }

  @IsTest
  private static void setCaseSensitiveWithData() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .put(new Contact());

    Test.startTest();

    try {
      theIndex.setIsCaseInsensitive(false);
      System.assert(false, 'Should have thrown IllegalStateException');
    } catch (CMN_UTIL_SObjectIndex.IllegalStateException e) {
      System.assertEquals(
        CMN_UTIL_SObjectIndex.ERROR_CASE_INSENSITIVE,
        e.getMessage()
      );
    }

    Test.stopTest();
  }

  @IsTest
  private static void nullValueOnIndexField() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        Account.ParentId.getDescribe().getName()
      )
      .put(newAccount);

    Test.startTest();

    Account indexAccount = (Account) theIndex.get((Id) null);

    Test.stopTest();

    System.assertEquals(newAccount.Id, indexAccount.Id);
  }

  @IsTest
  private static void singleHit() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
    );

    Contact togContact = new Contact(
      AccountId = newAccount.Id,
      LastName = TEST_LAST_NAME
    );
    theIndex.put(togContact);

    System.assertEquals(
      1,
      theIndex.getAll(
          new Contact(AccountId = newAccount.Id, LastName = TEST_LAST_NAME)
        )
        .size()
    );
    System.assert(!theIndex.isEmpty());

    Set<String> accountIdKeySet = theIndex.keySet(FIELD_ACCOUNT_ID);
    System.assertEquals(1, accountIdKeySet.size());
    System.assert(accountIdKeySet.contains(newAccount.Id));

    Set<String> lastNameKeySet = theIndex.keySet(FIELD_LAST_NAME);
    System.assertEquals(1, lastNameKeySet.size());
    System.assert(lastNameKeySet.contains(TEST_LAST_NAME));

    List<Contact> values = (List<Contact>) theIndex.values();
    System.assertEquals(1, values.size());
    System.assertEquals(togContact, values[0]);
  }

  @IsTest
  private static void caseInsensitive() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .setIsCaseInsensitive(true);

    Test.startTest();

    Contact togContact = new Contact(
      AccountId = newAccount.Id,
      LastName = TEST_LAST_NAME
    );
    theIndex.put(togContact);

    Test.stopTest();

    System.assertEquals(
      1,
      theIndex.getAll(
          new Contact(
            AccountId = newAccount.Id,
            LastName = TEST_LAST_NAME.toLowerCase()
          )
        )
        .size()
    );
    System.assert(!theIndex.isEmpty());
  }

  @IsTest
  private static void caseInsensitiveMap() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .setIsCaseInsensitive(true);

    Test.startTest();

    Contact togContact = new Contact(
      AccountId = newAccount.Id,
      LastName = TEST_LAST_NAME
    );
    theIndex.put(togContact);

    Test.stopTest();

    System.assertEquals(
      1,
      theIndex.getAll(
          new Map<String, String>{
            FIELD_ACCOUNT_ID => newAccount.Id,
            FIELD_LAST_NAME => TEST_LAST_NAME.toLowerCase()
          }
        )
        .size()
    );

    System.assert(!theIndex.isEmpty());
  }

  @IsTest
  private static void caseSensitiveMap() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .setIsCaseInsensitive(false);

    Test.startTest();

    Contact togContact = new Contact(
      AccountId = newAccount.Id,
      LastName = TEST_LAST_NAME
    );
    theIndex.put(togContact);

    Test.stopTest();

    System.assertEquals(
      0,
      theIndex.getAll(
          new Map<String, String>{
            FIELD_ACCOUNT_ID => newAccount.Id,
            FIELD_LAST_NAME => TEST_LAST_NAME.toLowerCase()
          }
        )
        .size()
    );

    System.assertEquals(
      1,
      theIndex.getAll(
          new Map<String, String>{
            FIELD_ACCOUNT_ID => newAccount.Id,
            FIELD_LAST_NAME => TEST_LAST_NAME
          }
        )
        .size()
    );

    System.assert(!theIndex.isEmpty());
  }

  @IsTest
  private static void caseInsensitiveReverse() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(FIELD_LAST_NAME)
      .setIsCaseInsensitive(true);

    Test.startTest();

    Contact togContact = new Contact(
      AccountId = newAccount.Id,
      LastName = TEST_LAST_NAME.toLowerCase()
    );
    theIndex.put(togContact);

    Test.stopTest();

    System.assertEquals(1, theIndex.getAll(TEST_LAST_NAME).size());
    System.assert(!theIndex.isEmpty());
  }

  private static CMN_UTIL_SObjectIndex getTwoHitsIndex() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
    );

    theIndex.putAll(
      new List<Contact>{
        new Contact(
          AccountId = newAccount.Id,
          FirstName = 'John',
          LastName = TEST_LAST_NAME
        ),
        new Contact(
          AccountId = newAccount.Id,
          FirstName = 'Jane',
          LastName = TEST_LAST_NAME
        ),
        new Contact(
          AccountId = newAccount.Id,
          FirstName = 'Fred',
          LastName = 'Deer'
        )
      }
    );

    return theIndex;
  }

  @IsTest
  private static void twoHits() {
    CMN_UTIL_SObjectIndex theIndex = getTwoHitsIndex();

    System.assertEquals(
      2,
      theIndex.getAll(
          new Contact(AccountId = newAccount.Id, LastName = TEST_LAST_NAME)
        )
        .size()
    );
    System.assert(!theIndex.isEmpty());
    Set<String> accountKeySet = theIndex.keySet(FIELD_ACCOUNT_ID);
    System.assertEquals(1, accountKeySet.size());
    System.assert(accountKeySet.contains(newAccount.Id));
    Set<String> nameKeySet = theIndex.keySet('LastName');
    System.assertEquals(2, nameKeySet.size());
    System.assert(nameKeySet.contains(TEST_LAST_NAME));
    System.assert(nameKeySet.contains('Deer'));
  }

  @IsTest
  private static void nearHit() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
    );

    Test.startTest();

    theIndex.put(
      new Contact(
        AccountId = newAccount.Id,
        FirstName = 'John',
        LastName = TEST_LAST_NAME
      )
    );
    theIndex.put(
      new Contact(
        AccountId = newAccount.Id,
        FirstName = 'Jane',
        LastName = TEST_LAST_NAME + 2
      )
    );

    Test.stopTest();

    System.assertEquals(
      1,
      theIndex.getAll(
          new Contact(AccountId = newAccount.Id, LastName = TEST_LAST_NAME)
        )
        .size()
    );
  }

  @IsTest
  private static void simpleIndex() {
    List<Contact> data = new List<Contact>{
      new Contact(
        AccountId = newAccount.Id,
        FirstName = 'John',
        LastName = TEST_LAST_NAME
      ),
      new Contact(
        AccountId = newAccount.Id,
        FirstName = 'Jane',
        LastName = TEST_LAST_NAME + 2
      )
    };

    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(FIELD_ACCOUNT_ID)
      .putAll(data);

    System.assertEquals(2, theIndex.getAll(newAccount.Id).size());

    Set<String> ks2 = theIndex.keySet();
    System.assertEquals(1, ks2.size());
    System.assert(ks2.contains(newAccount.Id));

    theIndex.get(newAccount.Id);
    System.assertEquals(null, theIndex.get('null'));
    System.assert(theIndex.getAll('null').isEmpty());
  }

  @IsTest
  private static void crossObjectField() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{ 'Account.Name', FIELD_LAST_NAME }
    );

    Contact togContact = new Contact(
      AccountId = newAccount.Id,
      LastName = TEST_LAST_NAME
    );
    insert togContact;
    togContact = [
      SELECT Id, Account.Name, LastName
      FROM Contact
      WHERE Id = :togContact.Id
    ];
    theIndex.put(togContact);

    System.assertEquals(
      1,
      theIndex.getAll(
          new Contact(
            Account = new Account(Name = newAccount.Name),
            LastName = TEST_LAST_NAME
          )
        )
        .size()
    );
    System.assert(!theIndex.isEmpty());

    List<Contact> values = (List<Contact>) theIndex.values();
    System.assertEquals(1, values.size());
    System.assertEquals(togContact, values[0]);
  }

  @IsTest
  private static void exactHitMap() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
    );

    theIndex.put(
      new Contact(AccountId = newAccount.Id, LastName = TEST_LAST_NAME)
    );

    System.assertEquals(
      1,
      theIndex.getAll(
          new Map<String, Object>{
            FIELD_ACCOUNT_ID => newAccount.Id,
            FIELD_LAST_NAME => TEST_LAST_NAME
          }
        )
        .size()
    );
    System.assert(!theIndex.isEmpty());
  }

  @IsTest
  private static void twoHitsMap() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .putAll(
        new List<Contact>{
          new Contact(AccountId = null, FirstName = 'John', LastName = 'Doe'),
          new Contact(
            AccountId = newAccount.Id,
            FirstName = 'Jane',
            LastName = 'Doe'
          ),
          new Contact(
            AccountId = newAccount.Id,
            FirstName = 'Fred',
            LastName = 'Deer'
          )
        }
      );

    List<Contact> fetchedContacts = theIndex.getAll(
      new Map<String, Object>{ FIELD_LAST_NAME => TEST_LAST_NAME }
    );

    System.assertEquals(2, fetchedContacts.size());
    System.assert(fetchedContacts[0].AccountId == null);
    System.assert(fetchedContacts[1].AccountId == newAccount.Id);
    System.assert(fetchedContacts[0].FirstName == 'John');
    System.assert(fetchedContacts[1].FirstName == 'Jane');
    System.assertEquals(TEST_LAST_NAME, fetchedContacts[0].LastName);
    System.assertEquals(TEST_LAST_NAME, fetchedContacts[1].LastName);
  }

  @IsTest
  private static void twoHitsSubIndex() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
        new List<String>{ FIELD_ACCOUNT_ID, FIELD_LAST_NAME }
      )
      .putAll(
        new List<Contact>{
          new Contact(AccountId = null, FirstName = 'John', LastName = 'Doe'),
          new Contact(
            AccountId = newAccount.Id,
            FirstName = 'Jane',
            LastName = 'Doe'
          ),
          new Contact(
            AccountId = newAccount.Id,
            FirstName = 'Fred',
            LastName = 'Deer'
          )
        }
      );

    CMN_UTIL_SObjectIndex subIndex = theIndex.getSubIndex(newAccount.Id);
    List<Contact> fetchedContacts = subIndex.getAll(
      new Map<String, Object>{ FIELD_LAST_NAME => TEST_LAST_NAME }
    );
    System.assertEquals(1, fetchedContacts.size());
    System.assert(fetchedContacts[0].AccountId == newAccount.Id);
    System.assert(fetchedContacts[0].FirstName == 'Jane');
    System.assertEquals(TEST_LAST_NAME, fetchedContacts[0].LastName);
  }

  @IsTest
  private static void remove() {
    CMN_UTIL_SObjectIndex theIndex = getTwoHitsIndex();

    theIndex.remove(
      new Contact(
        AccountId = newAccount.Id,
        FirstName = 'John',
        LastName = TEST_LAST_NAME
      )
    );
    System.assertEquals(
      0,
      theIndex.getAll(
          new Contact(AccountId = newAccount.Id, LastName = TEST_LAST_NAME)
        )
        .size()
    );
    Set<String> keySetName = theIndex.keySet(FIELD_LAST_NAME);
    System.assertEquals(2, keySetName.size());
    System.assert(keySetName.contains('Deer'));
    System.assert(keySetName.contains(TEST_LAST_NAME));

    System.assert(theIndex.remove(new Contact()).isEmpty());
  }

  @IsTest
  private static void removeMap() {
    CMN_UTIL_SObjectIndex theIndex = new CMN_UTIL_SObjectIndex(
      new List<String>{
        FIELD_ACCOUNT_ID,
        FIELD_LAST_NAME,
        Contact.FirstName.getDescribe().getName()
      }
    );

    theIndex.putAll(
      new List<Contact>{
        new Contact(
          AccountId = newAccount.Id,
          FirstName = 'John',
          LastName = TEST_LAST_NAME
        ),
        new Contact(
          AccountId = newAccount.Id,
          FirstName = 'Jane',
          LastName = TEST_LAST_NAME
        ),
        new Contact(
          AccountId = newAccount.Id,
          FirstName = 'Fred',
          LastName = 'Deer'
        )
      }
    );
    theIndex.remove(new Map<String, Object>{ 'FirstName' => 'John' });
    System.assertEquals(
      1,
      theIndex.getAll(
          new Map<String, Object>{
            FIELD_ACCOUNT_ID => newAccount.Id,
            FIELD_LAST_NAME => TEST_LAST_NAME
          }
        )
        .size()
    );
    Set<String> keySetName = theIndex.keySet(FIELD_LAST_NAME);
    System.assertEquals(2, keySetName.size());
    System.assert(keySetName.contains(TEST_LAST_NAME));
    System.assert(keySetName.contains('Deer'));
  }

  @IsTest
  private static void forCodeCoverageOfLeaf() {
    CMN_UTIL_SObjectIndex.SObjectIndexLeaf indexLeaf = new CMN_UTIL_SObjectIndex.SObjectIndexLeaf();

    Test.startTest();

    Set<String> keys = indexLeaf.keySet(TEST_LAST_NAME);

    System.assert(indexLeaf.getAll(1).isEmpty());

    System.assert(indexLeaf.getAll(new Map<String, Object>()).isEmpty());

    System.assert(indexLeaf.getAll(new CMN_Foobar__c()).isEmpty());

    Test.stopTest();

    System.assertNotEquals(null, keys);
  }
}