/***************************************************************************************

@Name of the Component : InsuranceClientOffersController_Test
@Description : Test class for retrieving top 3 list of recommended actions.
@Author : Kenneth Dlamini
@Created Date : 2024-09-19
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-36986, SFP-36989
***************************************************************************************/
@isTest
public class InsuranceClientOffersController_Test {
    @testSetup
    static void setupData(){

        User testUser = LoadSalesforceOffersTestDataFactory.createTestUser(1);
        LoadSalesforceOffersTestDataFactory.createTestUser(2);   
        Account testAccount = LoadSalesforceOffersTestDataFactory.createTestAccount(testUser);
        LoadSalesforceOffersTestDataFactory.createTestCase(testUser, testAccount);
        LoadSalesforceOffersTestDataFactory.loadClientOffers(testUser, testAccount);
    }

    @isTest
    static void verifyTestCaseCreationRecord(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1];  
        //assign user to permission set.     
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);

        System.runAs(adminUser)
        {
            Test.startTest();
            List<Case> retrieveTestCases = [SELECT Id FROM Case WHERE Subject = 'Client with Salesforce Offers'];
            Test.stopTest(); 
            Assert.areEqual(1, retrieveTestCases.size(), 'Successful.');
        }
    }

    @isTest
    static void verifyClientHasSalesforceOffers(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1];       

        System.runAs(adminUser)
        {
            //Get case details
            Case retrieveTestCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
            
            Test.startTest();
            //Get client Salesforce offers
            List<sbgpers__Recommended_Action__c> sfOffersList = [SELECT Id 
                FROM sbgpers__Recommended_Action__c 
                WHERE sbgpers__Account__c =: retrieveTestCase.AccountId];
            Test.stopTest(); 
            Assert.areEqual(4, sfOffersList.size(), 'Successful.');
        }
    }

    @isTest
    static void fetchPendingTop3ClientSalesforceOffers(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            //Get case details
            Case retrieveTestCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
            Test.startTest();
            //Get client Salesforce offers
            List<sbgpers__Recommended_Action__c> sfOffersList = InsuranceClientOffersController.fetchRecommendedActionsByCaseId(retrieveTestCase.Id);
            Test.stopTest(); 
            Assert.areEqual(3, sfOffersList.size(), 'Successful.');
        }
    }

    @isTest
    static void fetchPendingClientSalesforceOffersByAccountId(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            //Get caseaccount Id details
            Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com'];           
            Test.startTest();
            //Get client Salesforce offers
            List<sbgpers__Recommended_Action__c> sfOffersList = InsuranceClientOffersController.fetchTop3RecommendedActionsByAccountId(accInfo.Id);
            Test.stopTest(); 
            Assert.areEqual(3, sfOffersList.size(), 'Successful.');
        }
    }

    @isTest
    static void fetchClientSalesforceOffersTriggerAnError(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchRecommendedActionsByCaseId('006000000000000AAA');
                Test.stopTest(); 
            }
            catch(Exception ex){
                exceptionThrown = true;
            }
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown');
            }
            
        }
    }

    @isTest
    static void fetchClientSalesforceOffersHistoryByAccountId(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            //Get caseaccount Id details
            Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com'];           
            Test.startTest();
            //Get client Salesforce offers
            List<sbgpers__Recommended_Action__c> sfOffersList = InsuranceClientOffersController.fetchRecommendedActionsByAccountId(accInfo.Id);
            Test.stopTest(); 
            Assert.areEqual(0, sfOffersList.size(), 'Successful.');
        }
    }

    @isTest
    static void fetchClientOfferDetailsTriggerAnError(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchRecommendedActionById('001000000000000AAA');
                Test.stopTest(); 
            }
            catch(Exception ex){
                exceptionThrown = true;
            }
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown');
            }
            
        }
    }

    @isTest
    static void fetchTop3ClientOffersByAccIdTriggerAnError(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchTop3RecommendedActionsByAccountId('00A1000000000000A');
                Test.stopTest(); 
            }
            catch(Exception ex){
                exceptionThrown = true;
            }
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown');
            }
            
        }
    }

    @isTest
    static void fetchSingleClientSalesforceOfferRecordById(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1]; 
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);      
        System.runAs(adminUser)
        {
            //Get caseaccount Id details
            Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com'];    
            sbgpers__Recommended_Action__c offerRecord = [SELECT Id FROM sbgpers__Recommended_Action__c
                WHERE sbgpers__Account__c =: accInfo.Id LIMIT 1];       
            Test.startTest();
            //Get client Salesforce offers
            sbgpers__Recommended_Action__c sfOffersRecordDetails = InsuranceClientOffersController.fetchRecommendedActionById(offerRecord.Id);
            Test.stopTest(); 
            Assert.areEqual(offerRecord.Id, sfOffersRecordDetails.Id, 'Successful.');
        }
    }

    @isTest
    static void updateClientSalesforceOffer(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '1salesforceoffers@test.com' and isactive= True limit 1];       
        LoadSalesforceOffersTestDataFactory.assignUserPermissionSet(adminUser);
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Case retrieveTestCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
                //Get client offer
                sbgpers__Recommended_Action__c clientOffer = [SELECT Id 
                    FROM sbgpers__Recommended_Action__c
                    WHERE sbgpers__Category__c = 'KYC Outstanding.' 
                    AND sbgpers__Account__c = : retrieveTestCase.AccountId];
                //Update/Action Client Offer
                sbgpers__Recommended_Action__c  updateClientoffer = new sbgpers__Recommended_Action__c ();
                updateClientoffer.Id = clientoffer.Id;
                updateClientoffer.sbgpers__Response__c = 'Conversation Actioned';
                updateClientoffer.sbgpers__Reason__c = 'Actioned';
                updateClientoffer.sbgpers__Status__c = 'Actioned';
                updateClientoffer.sbgpers__Notes__c = 'Client happy with updating KYC status.';            
                Test.startTest();
                //update client Salesforce offer
                InsuranceClientOffersController.updateClientOfferRecord(updateClientoffer);
                Test.stopTest(); 
            }
            Catch (Exception e){
                exceptionThrown = true;
            }  
            finally{
                Assert.areEqual(false, exceptionThrown, 'Update was successful.'); 
            }
        }
    }  

    /**
     * This method attempts to access the record and object without the Permission Set
     */
    @isTest
    static void fetchClientTop3OffersWithoutPermSet(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '2salesforceoffers@test.com' and isactive= True limit 1];     
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Case retrieveTestCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchRecommendedActionsByCaseId(retrieveTestCase.Id);
                Test.stopTest(); 
            }
            Catch (Exception e){
                exceptionThrown = true;
            }  
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown'); 
            }        
        }
    }

    @isTest
    static void fetchClientTop3OffersByAccIdWithoutPermSet(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '2salesforceoffers@test.com' and isactive= True limit 1];     
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Case retrieveTestCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchTop3RecommendedActionsByAccountId(retrieveTestCase.Id);
                Test.stopTest(); 
            }
            Catch (Exception e){
                exceptionThrown = true;
            }  
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown'); 
            }        
        }
    }

    @isTest
    static void fetchClientAllOffersWithoutPermSet(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '2salesforceoffers@test.com' and isactive= True limit 1];     
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get caseaccount Id details
                Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com'];           
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchRecommendedActionsByAccountId(accInfo.Id);
                Test.stopTest(); 
            }
            Catch (Exception e){
                exceptionThrown = true;
            }  
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown'); 
            }        
        }
    }

    @isTest
    static void fetchClientDetailsRecordWithoutPermSet(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '2salesforceoffers@test.com' and isactive= True limit 1];     
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get caseaccount Id details
                Account accInfo = [SELECT Id FROM Account WHERE PersonEmail = 'salesforcetestaccount100@test.com'];    
                sbgpers__Recommended_Action__c offerRecord = [SELECT Id FROM sbgpers__Recommended_Action__c
                    WHERE sbgpers__Account__c =: accInfo.Id LIMIT 1];       
                Test.startTest();
                //Get client Salesforce offers
                InsuranceClientOffersController.fetchRecommendedActionById(offerRecord.Id);
                Test.stopTest(); 
            }
            Catch (Exception e){
                exceptionThrown = true;
            }  
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown'); 
            }        
        }
    }

    @isTest
    static void updateClientOfferRecordWithoutPermSet(){
        User adminUser = [SELECT Id,Name FROM User WHERE Email = '2salesforceoffers@test.com' and isactive= True limit 1];     
        System.runAs(adminUser)
        {
            Boolean exceptionThrown = false;
            try {
                //Get case details
                Case retrieveTestCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Client with Salesforce Offers'];
                //Get client offer
                sbgpers__Recommended_Action__c clientOffer = [SELECT Id 
                    FROM sbgpers__Recommended_Action__c
                    WHERE sbgpers__Category__c = 'KYC Outstanding.' 
                    AND sbgpers__Account__c = : retrieveTestCase.AccountId];
                //Update/Action Client Offer
                sbgpers__Recommended_Action__c  updateClientoffer = new sbgpers__Recommended_Action__c ();
                updateClientoffer.Id = clientoffer.Id;
                updateClientoffer.sbgpers__Response__c = 'Conversation Actioned';
                updateClientoffer.sbgpers__Reason__c = 'Actioned';
                updateClientoffer.sbgpers__Status__c = 'Actioned';
                updateClientoffer.sbgpers__Notes__c = 'Client happy with updating KYC status.';
            
                Test.startTest();
                //update client Salesforce offer
                InsuranceClientOffersController.updateClientOfferRecord(updateClientoffer);
                Test.stopTest(); 
            }
            Catch (Exception e){
                exceptionThrown = true;
            }  
            finally{
                Assert.areEqual(true, exceptionThrown, 'Expected exception was thrown'); 
            }        
        }
    }
}