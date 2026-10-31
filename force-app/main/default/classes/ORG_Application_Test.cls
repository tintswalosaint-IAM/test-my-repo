/**
* @description      : SFP-53562: Test class to test the functionality of ORG_Application_Test.cls
* @last Modified 	: Jaco de Lange - 22-10-2025
* @modification		: SFP-53279 - create additional test data to cover code coverage
* 
*@description : SFP-54443 - Added testSetup Data to increase the code coverage
* @last Modified : Amlendu Bajpai - 10-07-2026

*@description : Removed the hardcoded Stage__c value on the test Lead - it was set to
*  'In Progress – Awaiting Signed Disclosure', which is no longer a valid picklist entry
*  for the SBFC_Lead record type, breaking @TestSetup (and therefore every test method in
*  this class) with INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST. The field is nillable and no
*  test asserts on it, so it's dropped rather than replaced with another value that can
*  go stale the same way when the picklist changes again.
* @last Modified : Raymond Magezi - 22-09-2026
*
*@description : SFP-51816 - Removed the Stage__c line from the test Lead. The change described
*  above (Raymond Magezi, 22-09-2026) was recorded in the header but the line was never
*  deleted, so @TestSetup still failed in SIT, where the picklist value does not exist.
* @last Modified : Given Khupai - 29-10-2026
*
**/
@IsTest
public class ORG_Application_Test { 
    
    @TestSetup
    static void setupTestData() {
        
        Contact con = new Contact (
        	LastName = 'Test LastName'
        );
        insert con;
        Schema.RecordTypeInfo rtInfo =
            Schema.SObjectType.Lead
                .getRecordTypeInfosByDeveloperName()
                .get('SBFC_Lead');
        
        // Create test records that might be needed for selector tests
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Lead',
            Status = 'Nurturing',
            RecordTypeId = rtInfo.getRecordTypeId(),
            FinServ__ReferredByContact__c = con.Id
        );
        insert testLead;
        
       
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        PartyProfile testPartyProfile = new PartyProfile(
            Name = 'Test Party Profile',
            AccountId = testAccount.Id
            // Add other required fields
        );
        insert testPartyProfile;
    }
    
    @IsTest
    static void testSelectorFactory() {
        Test.startTest();
        
        // Test Lead selector
        Object leadSelector = ORG_Application.selector.newInstance(Lead.SObjectType);
        Assert.isTrue(leadSelector instanceof sbgplatform.fflib_SObjectSelector, 'Lead selector should be an instance of fflib_SObjectSelector');
        
        // Test Application__c selector
        Object applicationSelector = ORG_Application.selector.newInstance(Application__c.SObjectType);
        Assert.isTrue(applicationSelector instanceof sbgplatform.fflib_SObjectSelector, 'Application__c selector should be an instance of fflib_SObjectSelector');
        
        // Test User selector
        Object userSelector = ORG_Application.selector.newInstance(User.SObjectType);
        Assert.isTrue(userSelector instanceof sbgplatform.fflib_SObjectSelector, 'User selector should be an instance of fflib_SObjectSelector');
        
        // Test Case selector
        Object caseSelector = ORG_Application.selector.newInstance(Case.SObjectType);
        Assert.isTrue(caseSelector instanceof sbgplatform.fflib_SObjectSelector, 'Case selector should be an instance of fflib_SObjectSelector');
         
        Test.stopTest();
        
        // Additional assertions to verify selector functionality
        if (leadSelector instanceof sbgplatform.fflib_SObjectSelector) {
            sbgplatform.fflib_SObjectSelector typedLeadSelector = (sbgplatform.fflib_SObjectSelector)leadSelector;
            Assert.areEqual(Lead.SObjectType, typedLeadSelector.getSObjectType(), 'Lead selector should return Lead SObjectType');
        }
        
        if (applicationSelector instanceof sbgplatform.fflib_SObjectSelector) {
            sbgplatform.fflib_SObjectSelector typedApplicationSelector = (sbgplatform.fflib_SObjectSelector)applicationSelector;
            Assert.areEqual(Application__c.SObjectType, typedApplicationSelector.getSObjectType(), 'Application__c selector should return Application__c SObjectType');
        }  
    }
    
    @IsTest
    static void testServiceFactory() {
        Test.startTest();
        Assert.isNotNull(ORG_Application.service, 'Service factory should be initialized');
        Test.stopTest();
    }
    
    @IsTest
    static void testUnitOfWorkFactory() {
        Test.startTest();
        Assert.isNotNull(ORG_Application.unitOfWork, 'UnitOfWork factory should be initialized');
        Assert.isNotNull(ORG_Application.unitOfWorkRegisteredTypes, 'UnitOfWork types should be initialized');
        Assert.isTrue(ORG_Application.unitOfWorkRegisteredTypes.size() > 0, 'UnitOfWork types should not be empty');
        Test.stopTest();
    }
}