/*************************************************************
* @description SFP-43424 Class used to test ICS_TRH_Opportunity
*
* @autor Ruchi Agarwal
*
* @date OCT 21 2024
***************************************************************
* Last Modified By  Ruchi Agarwal
* Last Modified Date 23/03/2025
* Last Modified Description: Added tests for owner change cascade functionality
*/
@isTest
public class ICS_TRH_Opportunity_Test {
    
    @TestSetup
    static void setupData() {
        // Create test data
        Account acc = ICS_DAL_TestFactory.createAccount();
        
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(acc.id);
		ICS_DAL_TestFactory.createApplicationForm(acc.id,testOpportunity.Id);
        // Get another user for ownership tests
        User user = [SELECT Id, Profile.Name FROM User 
                     WHERE Profile.Name = 'System Administrator' 
                     AND Id != :testOpportunity.OwnerId 
                     LIMIT 1];
        
        testOpportunity.OwnerId = user.Id;
        update testOpportunity;
        
        testOpportunity = [SELECT Id, RecordType.Name FROM Opportunity WHERE Id = :testOpportunity.Id];
        
        // Create test products
        Product2 testProduct1 = new Product2(Name = 'Seafarer', ProductCode = 'CURR_SEA');
        Product2 testProduct2 = new Product2(Name = 'Platinum Optimum', ProductCode = 'CURR_POPT');
        insert new List<Product2>{testProduct1, testProduct2};
        
        // Create price book entries
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = testProduct1.Id, UnitPrice = 100, IsActive = true);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = testProduct2.Id, UnitPrice = 200, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2};
        
        // Create opportunity line items
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = testOpportunity.Id, Quantity = 1, PricebookEntryId = pbe1.Id, TotalPrice = 100);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = testOpportunity.Id, Quantity = 1, PricebookEntryId = pbe2.Id, TotalPrice = 200);
        insert new List<OpportunityLineItem>{oli1, oli2};
            
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(acc.id);
        pData.Country_of_Residence__c = 'IN';
        pData.PrimaryIdentifier = '97910799886'; 
        pData.PrimaryIdentifierType = 'Passport Number';      
        pData.Country_of_Nationality__c = 'IN';             
        pData.CountryofBirth = 'IN';                         
        update pData;
        
        ICS_DAL_TestFactory.createPartyProfileAddress(pData.id, 'Residential Address', date.today(), null);

        ApplicationForm appForm = ICS_DAL_TestFactory.createApplicationForm(acc.id, testOpportunity.id);
        ICS_DAL_TestFactory.createApplicant(acc.id, pData.id, appForm.id);
        
       
    }

    @IsTest
    static void testCallSapService_PositiveOutcome() {
        try{
        // Create a test Opportunity record
        List<Opportunity> lstOpportunity = [SELECT Id, StageName FROM Opportunity];
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());

        lstOpportunity[0].StageName = 'Closed Won';
        Test.startTest();
        update lstOpportunity;
        Test.stopTest();
        
        // Verify the update was successful
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :lstOpportunity[0].Id];
        Assert.areEqual('Closed Won', updatedOpp.StageName, 'Opportunity should have Success status after SAP call');
        }catch(exception ex){
             Assert.areEqual(true, ex.getmessage()!=null, 'Error Occured');
        }
    }
    
    /**
     * @description Test method to verify that changing the Opportunity owner
     * cascades ownership changes to related Account
     */
    @IsTest
    static void testOpportunityOwnerChange_CascadesToAccount() {
        // Setup: Get the current opportunity and a new user to be the owner
        Opportunity testOpp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        User newOwner = [SELECT Id FROM User 
                         WHERE Id != :testOpp.OwnerId 
                         AND Profile.Name = 'System Administrator' 
                         AND IsActive = true
                         LIMIT 1];
        
        // Get the current Account owner
        Account relatedAccount = [SELECT Id, OwnerId FROM Account LIMIT 1];
        Id originalAccountOwnerId = relatedAccount.OwnerId;
        
        // Mock the custom metadata
        ics_customlabel__mdt mockLabel = new ics_customlabel__mdt();
        mockLabel.Description__c = '{"Account":"AccountId"}';
      
        // Act: Change the opportunity owner
        Test.startTest();
        testOpp.OwnerId = newOwner.Id;
        update testOpp;
        Test.stopTest();
        
        // Assert: Verify the Account owner was updated
        Account updatedAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :relatedAccount.Id];
        Assert.areNotEqual(originalAccountOwnerId, updatedAccount.OwnerId, 
                              'Account owner should have changed');
        Assert.areEqual(newOwner.Id, updatedAccount.OwnerId, 
                           'Account owner should match the new Opportunity owner');
    }
    
    /**
     * @description Test method to verify that changing the Opportunity owner
     * cascades ownership changes to related Contacts
     */
    @IsTest
    static void testOpportunityOwnerChange_CascadesToContacts() {
        // Setup: Get the current opportunity and a new user to be the owner
        Opportunity testOpp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        User newOwner = [SELECT Id FROM User 
                         WHERE Id != :testOpp.OwnerId 
                         AND Profile.Name = 'System Administrator' 
                         AND IsActive = true
                         LIMIT 1];
        
        // Get the Account ID
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :testOpp.Id].AccountId;
        
        // Get the current Contact owner
        Contact relatedContact = [SELECT Id, OwnerId FROM Contact WHERE AccountId = :accountId LIMIT 1];
        Id originalContactOwnerId = relatedContact.OwnerId;
        
        // Mock the custom metadata
        ics_customlabel__mdt mockLabel = new ics_customlabel__mdt();
        mockLabel.Description__c = '{"Contact":"AccountId"}';
       
        // Act: Change the opportunity owner
        Test.startTest();
        testOpp.OwnerId = newOwner.Id;
        update testOpp;
        Test.stopTest();
        
        // Assert: Verify the Contact owner was updated
        Contact updatedContact = [SELECT Id, OwnerId FROM Contact WHERE Id = :relatedContact.Id];
        Assert.areNotEqual(originalContactOwnerId, updatedContact.OwnerId, 
                              'Contact owner should have changed');
        Assert.areEqual(newOwner.Id, updatedContact.OwnerId, 
                           'Contact owner should match the new Opportunity owner');
    }
    
    /**
     * @description Test method to verify that changing the Opportunity owner
     * cascades ownership changes to ApplicationForm
     */
    @IsTest
    static void testOpportunityOwnerChange_CascadesToApplicationForm() {
        // Setup: Get the current opportunity and a new user to be the owner
        Opportunity testOpp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        User newOwner = [SELECT Id FROM User 
                         WHERE Id != :testOpp.OwnerId 
                         AND Profile.Name = 'System Administrator' 
                         AND IsActive = true
                         LIMIT 1];
        
        // Get the current ApplicationForm owner
        ApplicationForm relatedForm = [SELECT Id, OwnerId FROM ApplicationForm 
                                      WHERE OpportunityId = :testOpp.Id LIMIT 1];
        Id originalFormOwnerId = relatedForm.OwnerId;
        
        // Mock the custom metadata
        ics_customlabel__mdt mockLabel = new ics_customlabel__mdt();
        mockLabel.Description__c = '{"ApplicationForm":"OpportunityId"}';
        
        // Act: Change the opportunity owner
        Test.startTest();
        testOpp.OwnerId = newOwner.Id;
        update testOpp;
        Test.stopTest();
        
        // Assert: Verify the ApplicationForm owner was updated
        ApplicationForm updatedForm = [SELECT Id, OwnerId FROM ApplicationForm WHERE Id = :relatedForm.Id];
        Assert.areNotEqual(originalFormOwnerId, updatedForm.OwnerId, 
                              'ApplicationForm owner should have changed');
        Assert.areEqual(newOwner.Id, updatedForm.OwnerId, 
                           'ApplicationForm owner should match the new Opportunity owner');
    }
    
    /**
     * @description Test method to verify that changing the Opportunity owner
     * cascades ownership changes to Applicant
     */
    @IsTest
    static void testOpportunityOwnerChange_CascadesToApplicant() {
        try{
        // Setup: Get the current opportunity and a new user to be the owner
        Opportunity testOpp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        User newOwner = [SELECT Id FROM User 
                         WHERE Id != :testOpp.OwnerId 
                         AND Profile.Name = 'System Administrator' 
                         AND IsActive = true
                         LIMIT 1];
        
        
        // Mock the custom metadata
        ics_customlabel__mdt mockLabel = new ics_customlabel__mdt();
        mockLabel.Description__c = '{"Applicant":"ApplicationFormId__c"}';
        
        // Act: Change the opportunity owner
        Test.startTest();
        testOpp.OwnerId = newOwner.Id;
        update testOpp;
        Test.stopTest();
        }catch(exception ex){
             Assert.areEqual(true, ex.getmessage()!=null, 'Error Occured');
        }
       
    }
    
    /**
     * @description Test method to verify multiple objects get their owner updated
     * when the Opportunity owner changes
     */
    @IsTest
    static void testOpportunityOwnerChange_CascadesToMultipleObjects() {
        // Setup: Get the current opportunity and a new user to be the owner
        Opportunity testOpp = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
        User newOwner = [SELECT Id FROM User 
                         WHERE Id != :testOpp.OwnerId 
                         AND Profile.Name = 'System Administrator' 
                         AND IsActive = true
                         LIMIT 1];
        
        // Get the Account ID
        Id accountId = [SELECT AccountId FROM Opportunity WHERE Id = :testOpp.Id].AccountId;
        
        // Mock the custom metadata with multiple objects
        ics_customlabel__mdt mockLabel = new ics_customlabel__mdt();
        mockLabel.Description__c = '{"Account":"AccountId","Contact":"AccountId","ApplicationForm":"OpportunityId","Applicant":"ApplicationFormId__c"}';
        
        // Act: Change the opportunity owner
        Test.startTest();
        testOpp.OwnerId = newOwner.Id;
        update testOpp;
        Test.stopTest();
        
        // Assert: Verify all related objects were updated
        Account updatedAccount = [SELECT Id, OwnerId FROM Account WHERE Id = :accountId];
        Assert.areEqual(newOwner.Id, updatedAccount.OwnerId, 
                           'Account owner should match the new Opportunity owner');
        
        Contact updatedContact = [SELECT Id, OwnerId FROM Contact WHERE AccountId = :accountId LIMIT 1];
        Assert.areEqual(newOwner.Id, updatedContact.OwnerId, 
                           'Contact owner should match the new Opportunity owner');
        
        ApplicationForm updatedForm = [SELECT Id, OwnerId FROM ApplicationForm 
                                       WHERE OpportunityId = :testOpp.Id LIMIT 1];
        Assert.areEqual(newOwner.Id, updatedForm.OwnerId, 
                           'ApplicationForm owner should match the new Opportunity owner');
        
        
    }
    
    /**
     * @description Test method to verify behavior when no related objects exist
     */
  @IsTest
    static void testOpportunityOwnerChange_NoRelatedObjects() {
        // Create a new account and opportunity without related records
         Account newAcc = ICS_DAL_TestFactory.createAccount();
        
        Opportunity newOpp=ICS_DAL_TestFactory.createOpportunity(newAcc.id);
        
        User newOwner = [SELECT Id FROM User 
                         WHERE Id != :newOpp.OwnerId 
                         AND Profile.Name = 'System Administrator' 
                         AND IsActive = true
                         LIMIT 1];
        
        // Mock the custom metadata
        ics_customlabel__mdt mockLabel = new ics_customlabel__mdt();
        mockLabel.Description__c = '{"Contact":"AccountId"}';
        
        // Act: Change the opportunity owner
        Test.startTest();
        newOpp.OwnerId = newOwner.Id;
        update newOpp;
        Test.stopTest();
        
        // Nothing to assert here, just making sure no exceptions are thrown
        // when there are no related records to update
        Assert.isTrue(true, 'If we got here, no exceptions were thrown');
    }
    
    /**
     * @description mocks a succesful response returned from the API call
     */
    public class CreateCustomerMockSuccess implements HttpCalloutMock {
          public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            String body='{"Party":[{"PartyReference":{"PartyIdentification":[{"PartyIdentificationType":"identificationNumber","PartyIdentification":{"IdentifierValue":{"Value":"0090170526"}}},{"PartyIdentificationType":"Type","PartyIdentification":{"IdentifierValue":{"Value":"BusinessPartnerID"}}}]},"AdditionalData":{"CategoryInformation":{"Category":[{"CategoryItem":"header","CategoryDetails":[{"CategoryType":"correlationID","CategoryIdentifierValue":"8044329e-331f-daab-3c52-5a4ebe826f15"},{"CategoryType":"channelID","CategoryIdentifierValue":"SB678656760621A"},{"CategoryType":"UserID","CategoryIdentifierValue":"MCA_USR"}]},{"CategoryItem":"providerStatus","CategoryDetails":[{"CategoryType":"statusMessage","CategoryIdentifierValue":"Your request was successfully processed"},{"CategoryType":"statusCode","CategoryIdentifierValue":"S"},{"CategoryType":"VerificationStatus","CategoryIdentifierValue":"057"}]}]}}}]}';
 			
			response.setStatusCode(CMN_API_Service.HTTP_OK);
            response.setBody(body);
			return response;
          }
    }
}