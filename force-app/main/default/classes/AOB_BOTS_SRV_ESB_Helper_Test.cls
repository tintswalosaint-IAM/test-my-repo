/**
 * @description       : Test Class for AOB_BOTS_SRV_ESB_Helper
 * @author            : Nagendraprasad Mylavarapu
 * @last modified on  : 03-08-2023
* @last modified by  : Nagendraprasad Mylavarapu
**/
@istest
public class AOB_BOTS_SRV_ESB_Helper_Test {
    
     /*
     *@description  Test method for AOB_BOTS_SRV_ESB.createCustomer
     */
    @isTest
    static void createCustomerTest(){
        
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_PrimaryRelationshipManagerID__c='Kabelo Modimoosi';
        app.AOB_IDIssuedOrganization__c='001';
         app.AOB_Preferred_Branch__c='031087';
        update app;
        Application_Participant__c ap = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.ID);
        ap.AOB_MaritalStatus__c='SINGLE';
        ap.AOB_Role__c='CEO';
        ap.AOB_Signatory__c=true;
        ap.AOB_External_GUID__c='test';
        ap.AOB_Director__c=true;
        ap.AOB_GrossAnnualIncome__c=2000;
        ap.AOB_PrimaryNationality__c='BW';
        ap.AOB_Title__c='41';
        ap.AOB_Gender__c='Male';
        ap.AOB_City__c='ABIM';
        ap.AOB_State__c='GaboroneCity';
        ap.AOB_PostalCode__c='1234';
        ap.AOB_Street__c='test';
        
         Date today = Date.today();
        Date eighteenYearsAgo = today.addYears(-18);
        ap.AOB_DateofBirth__c=eighteenYearsAgo;
        ap.AOB_AddressValidFrom__c=Date.newInstance(2023,05,09);
        update ap;
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(ap.Id);
        ap.AOB_AddressValidFrom__c = Date.today();
        Test.startTest();
        Integer statusCode=AOB_BOTS_SRV_ESB_Helper.createCustomer(ap.Application__c);
        Test.stopTest();
        Assert.areEqual(200,statusCode,'Comparing the status code returned by the createCustomer API');
    }

}