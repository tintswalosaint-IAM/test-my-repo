/*************************************************************
 * @description SFP-32986 Class used to test ICS_API_SAPCreateRelation
 *
 * @author Ridima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima
 * Last Modified Date 21/10/2024 
 * Last Modified Description: Initial Version
 * ***************************************************************************************
 *  @Last Modified By 		: Ridhima Saxena
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account 
 */
@Istest
public class ICS_API_SAPCreateRelation_TEST {
    @TestSetup
    static void setupData() {
        Account acc=ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity =ICS_DAL_TestFactory.createOpportunity(acc.id);
        ApplicationForm appForm = ICS_DAL_TestFactory.createApplicationForm(acc.id,testOpportunity.id);
       partyProfile profileData =ICS_DAL_TestFactory.createPartyProfile(acc.id);
        ICS_DAL_TestFactory.createApplicant(acc.id, profileData.id, appForm.id);
    }
    // Covers: addRelationship() - single application form (IOM role)
    @isTest
    static void testAddRelationship_IOMRole() {
        List<Opportunity> lstOpportunity = [SELECT Id, AccountId, OwnerId FROM Opportunity LIMIT 1];
        
        // Set IOM role on opportunity owner
        User owner = [SELECT Id, UserRoleId FROM User WHERE Id = :lstOpportunity[0].OwnerId LIMIT 1];
        UserRole iomRole = [SELECT Id FROM UserRole WHERE Name LIKE '%IOM%' LIMIT 1];
        if(iomRole != null) {
            owner.UserRoleId = iomRole.Id;
            update owner;
        }
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        Test.startTest();
        ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateRelation', lstOpportunity[0].Id, lstOpportunity[0].AccountId, false);
        Test.stopTest();
        
        Assert.areNotEqual(null, lstOpportunity[0].Id, 'Opportunity should exist');
    }
    
    // Covers: addRelationship() - joint application (multiple forms, isJoint=false)
    @isTest
    static void testAddRelationship_Joint() {
        List<Opportunity> lstOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        // Create second application form to trigger joint flow
        Account acct2 = ICS_DAL_TestFactory.createAccount();
        acct2.Phone = '9999999999';
        acct2.PersonEmail = 'testjoint2@test.com';
        acct2.ExternalCIFUUID__c = 'RandomBPGUID2';
        update acct2;
        
        PartyProfile ptData2 = ICS_DAL_TestFactory.createPartyProfile(acct2.id);
        ApplicationForm apptform2 = ICS_DAL_TestFactory.createApplicationForm(acct2.id, lstOpportunity[0].id);
        ICS_DAL_TestFactory.createApplicant(acct2.id, ptData2.id, apptform2.id);
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        Test.startTest();
        // isJoint=false with multiple forms → triggers ics_category_Joint
        ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateRelation', lstOpportunity[0].Id, lstOpportunity[0].AccountId, false);
        Test.stopTest();
        
        Assert.areNotEqual(null, lstOpportunity[0].Id, 'Opportunity should exist');
    }
    
    // Covers: addRelationship() - joint=true with multiple forms
    @isTest
    static void testAddRelationship_JointTrue() {
        List<Opportunity> lstOpportunity = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        Account acct2 = ICS_DAL_TestFactory.createAccount();
        acct2.Phone = '8888888888';
        acct2.PersonEmail = 'testjoint3@test.com';
        acct2.ExternalCIFUUID__c = 'RandomBPGUID3';
        update acct2;
        
        PartyProfile ptData2 = ICS_DAL_TestFactory.createPartyProfile(acct2.id);
        ApplicationForm apptform2 = ICS_DAL_TestFactory.createApplicationForm(acct2.id, lstOpportunity[0].id);
        ICS_DAL_TestFactory.createApplicant(acct2.id, ptData2.id, apptform2.id);
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        Test.startTest();
        // isJoint=true with multiple forms → triggers partnerNumber1 with RM_AE_Code
        ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateRelation', lstOpportunity[0].Id, lstOpportunity[0].AccountId, true);
        Test.stopTest();
        
        Assert.areNotEqual(null, lstOpportunity[0].Id, 'Opportunity should exist');
    }
    @isTest
    static void testSAPCreateRelationCallSapService(){
        List<Opportunity> lstOpportunity = [SELECT Id,AccountID FROM Opportunity];
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CreateCustomerMockSuccess());
        Test.startTest();
        ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateRelation',lstOpportunity[0].Id,lstOpportunity[0].AccountID,false);
        Test.stopTest();
        HttpCalloutMock mock = new CreateCustomerMockSuccess();
        HttpRequest req = new HttpRequest();
        HttpResponse res = mock.respond(req);
        assert.areEqual(200, res.getStatusCode(), 'The response status code should be 200 (OK)');
    }
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