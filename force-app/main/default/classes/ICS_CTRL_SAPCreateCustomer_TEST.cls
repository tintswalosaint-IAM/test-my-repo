/*************************************************************
 * @description SFP-43424 Test Class used to ICS_CTRL_SAPCreateCustomer
 *
 * @autor Ruchi Agarwal
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima 
 * Last Modified Date 05/05/2025
 * Last Modified Description: Initial Version
 * ***************************************************************************************
 *  @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 01-11-2025
 * @Modification description : SFP-52787 Added security questions updated logic 
 * 
***************************************************************************************
 * * @Last Modified By 		: Ridhima Saxena
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account 
 */
@isTest
public class ICS_CTRL_SAPCreateCustomer_TEST {
    @TestSetup
    static void setupData() {    
        
        Account acct=ICS_DAL_TestFactory.createAccount();
        
        Opportunity testOpty = ICS_DAL_TestFactory.createOpportunity(acct.id);
        
        testOpty =[select id,recordtype.Name from opportunity where id=:testOpty.id];
        
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
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = testOpty.Id, Quantity = 1, PricebookEntryId = pbe1.Id, TotalPrice = 100);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = testOpty.Id, Quantity = 1, PricebookEntryId = pbe2.Id, TotalPrice = 200);
        insert new List<OpportunityLineItem>{oli1, oli2};
            
        PartyProfile ptData = ICS_DAL_TestFactory.createPartyProfile(acct.id);
        ptData.Country_of_Residence__c = 'IN';
        ptData.Country_of_Nationality__c = 'IN';
        ptData.WI_CountryOfCitizenship__c = 'IN';
        ptData.CountryofBirth = 'IN';
        ptData.PrimaryIdentifier = 'ASD123';
        ptData.PrimaryIdentifierType = 'Passport Number';
        update ptData;
        
        PartyProfileAddress addr = ICS_DAL_TestFactory.createPartyProfileAddress(ptData.id, 'Residential Address', date.today(), null);
        addr.Street = 'Test Street';
        addr.City = 'Test City';
        addr.State = 'Test State';
        addr.PostalCode = '500001';
        addr.Country = 'India';
        update addr;
        ICS_DAL_TestFactory.createPartyProfileAddress(ptData.id, 'Residential Address', date.today(), null);
        
        Applicationform apptform = ICS_DAL_TestFactory.createApplicationForm(acct.id,testOpty.id);
        
        ICS_DAL_TestFactory.createApplicant(acct.id,ptData.id,apptform.id);
         
        
      
    }
    @isTest
    static void testJointApplication() {
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Account acct2 = ICS_DAL_TestFactory.createAccount();
        acct2.Phone = '9999999999';
        acct2.PersonEmail = 'testunique2@test.com';
        acct2.ExternalCIFUUID__c = 'RandomBPGUID2';  // ← add this
        update acct2;
        
        PartyProfile ptData2 = ICS_DAL_TestFactory.createPartyProfile(acct2.id);
        ptData2.Country_of_Residence__c = 'IN';
        ptData2.Country_of_Nationality__c = 'IN';
        ptData2.WI_CountryOfCitizenship__c = 'IN';
        ptData2.CountryofBirth = 'IN';
        ptData2.PrimaryIdentifier = 'XYZ456';
        ptData2.PrimaryIdentifierType = 'Passport Number';
        update ptData2;
        
        PartyProfileAddress addr2 = ICS_DAL_TestFactory.createPartyProfileAddress(ptData2.id, 'Residential Address', date.today(), null);
        addr2.Street = 'Test Street 2';
        addr2.City = 'Test City 2';
        addr2.State = 'Test State 2';
        addr2.PostalCode = '500002';
        addr2.Country = 'India';
        update addr2;
        
        ApplicationForm apptform2 = ICS_DAL_TestFactory.createApplicationForm(acct2.id, lstOpp[0].id);
        ICS_DAL_TestFactory.createApplicant(acct2.id, ptData2.id, apptform2.id);
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CustomerMockResponse('S'));
        
        Test.startTest();
        System.enqueueJob(new ICS_CTRL_SAPCreateCustomer(new List<String>{lstOpp[0].Id}));
        Test.stopTest();
        
        List<CMN_WebserviceCallQueue__c> queues = [SELECT Id FROM CMN_WebserviceCallQueue__c];
        Assert.areNotEqual(0, queues.size(), 'Should create webservice queue for joint application');
    }
    @isTest
    static void testSingleApplication() {
        List<Opportunity> lstOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CustomerMockResponse('S'));
        
        Test.startTest();
        System.enqueueJob(new ICS_CTRL_SAPCreateCustomer(new List<String>{lstOpp[0].Id}));
        Test.stopTest();
        
        List<CMN_WebserviceCallQueue__c> queues = [SELECT Id FROM CMN_WebserviceCallQueue__c];
        Assert.areNotEqual(0, queues.size(), 'Should create webservice queue');
    }
   
    @isTest
    static void testSapCreateCustomer_Success() {
        
        List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity WHERE Name = 'tesstopp'];
        
        if (lstOpportunity.isEmpty()) {
            Assert.areEqual(false, 'Opportunity with name "tesstopp" should exist');
        }
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CustomerMockResponse('S'));
        
        Test.startTest();
        System.enqueueJob(new ICS_CTRL_SAPCreateCustomer(new List<String>{lstOpportunity[0].Id}));
        Test.stopTest();
        
        
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
         Assert.areNotEqual(jobs.size(), 0, 'Queueable job should be created for success scenario');
    }
    
    @isTest
    static void testSapCreateCustomer_Error() {
        List<Opportunity> lstOpportunity = [SELECT Id,Name FROM Opportunity WHERE Name = 'tesstopp' ];
        
        if (lstOpportunity.isEmpty()) {
            Assert.areEqual(false, 'Opportunities should exist in the test org.');
        }
        
        List<String> oppIds = new List<String>();
        for (Opportunity opp : lstOpportunity) {
            oppIds.add(opp.Id);
        }
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CustomerMockResponse('E'));
        
        Test.startTest();
        System.enqueueJob(new ICS_CTRL_SAPCreateCustomer(oppIds));
        Test.stopTest();
        
        // Verify error handling queue record was created
        List<CMN_WebserviceCallQueue__c> errorQueues = [
            SELECT Id, Name, CMN_Response__c 
            FROM CMN_WebserviceCallQueue__c 
            LIMIT 1
        ];
        Assert.areNotEqual(errorQueues.size(), 0, 'Error queue record should be created for error scenario');
    }
    
   public class CustomerMockResponse implements HttpCalloutMock {
    private final String statusCode;
    private Integer callCount = 0;
    
    public CustomerMockResponse(String statusCode) {
        this.statusCode = statusCode;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        callCount++;
        HttpResponse response = new HttpResponse();
        String statusMessage = (statusCode == 'S') ? 'Your request was successfully processed' : 'Error processing your request';
        
        String uniqueCifId = '00010052' + callCount;
        
        // ← String body declaration was missing, add it back
        String body = '{"Party":[{"PartyReference":{"PartyIdentification":[' +
            '{"PartyIdentificationType":"identificationNumber","PartyIdentification":{"IdentifierValue":{"Value":"' + uniqueCifId + '"}}},' +
            '{"PartyIdentificationType":"Type","PartyIdentification":{"IdentifierValue":{"Value":"BusinessPartnerID"}}}' +
            ']},"AdditionalData":{"CategoryInformation":{"Category":[' +
            '{"CategoryItem":"header","CategoryDetails":[' +
            '{"CategoryType":"correlationID","CategoryIdentifierValue":"8044329e-331f-daab-3c52-5a4ebe826f15"},' +
            '{"CategoryType":"channelID","CategoryIdentifierValue":"SB678656760621A"},' +
            '{"CategoryType":"UserID","CategoryIdentifierValue":"MCA_USR"}' +
            ']},' +
            '{"CategoryItem":"providerStatus","CategoryDetails":[' +
            '{"CategoryType":"statusMessage","CategoryIdentifierValue":"' + statusMessage + '"},' +
            '{"CategoryType":"statusCode","CategoryIdentifierValue":"' + statusCode + '"},' +
            '{"CategoryType":"VerificationStatus","CategoryIdentifierValue":"057"}' +
            ']}]}}}]}';
        
        response.setStatusCode(200);
        response.setBody(body);
        return response;
    }
    }
}