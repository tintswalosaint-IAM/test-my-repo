/**
 * @description Data Access Layer SOQL and DML updates related to the Contact Object, this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class CMN_DAL_Contact {
  public static final String OBJECT_NAME = Contact.SObjectType.getDescribe()
    .getLocalName();

  /**
   * @description A list of the common contact fields to query
   *
   * @return A set of fields
   */
  @TestVisible
  private static Set<String> getDefaultFields() {
    return new Set<String>{
      'AccountId',
      'AssistantName',
      'AssistantPhone',
      'Birthdate',
      'CMN_BPGUID__c',
      'CMN_CustomerBPID__c',
      'CMN_IdentityNumber__c',
      'Department',
      'Description',
      'Email',
      'EmailBouncedDate',
      'FirstName',
      'HomePhone',
      'Id',
      'LastName',
      'MobilePhone',
      'Name',
      'OwnerId',
      'Phone',
      'RecordTypeId',
      'Salutation',
      'Title'
    };
  }

  /**
   * @description Will query contact object with given ids
   *
   * @param contactIds A list of Contact ids
   *
   * @return A List of found contacts
   */
  public static List<Contact> findById(Set<Id> contactIds) {
    return CMN_DAL_SObjectSelector.findById(
      Contact.SObjectType,
      contactIds,
      getDefaultFields()
    );
  }

  /**
   * @description Will query contact using their Id
   *
   * @param contactId Salesforce Id of the contact
   *
   * @return either Null or a Contact
   */
  public static Contact findById(Id contactId) {
    List<Contact> contacts = findById(new Set<Id>{ contactId });

    return contacts.isEmpty() ? null : contacts[0];
  }

  /**
   * @description Will return all the contacts in the system using default fields
   *
   * @return A list of contacts
   */
  @TestVisible
  private static List<Contact> getAll() {
    CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(
      OBJECT_NAME
    );

    searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;

    searchParameters.searchFields.clear();
    searchParameters.selectFields = getDefaultFields();

    return CMN_DAL_Search.getObjects(searchParameters);
  }
}