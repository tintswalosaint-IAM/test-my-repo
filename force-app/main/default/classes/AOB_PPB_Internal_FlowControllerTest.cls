/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_PPB_Internal_FlowController
@ Description       :Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :07/08/2023.
@ Modification Description : SFP-31036
***************************************************************************************/

    /** 
     *@description class for AOB_PPB_Internal_FlowController
     */
    @isTest
    public class AOB_PPB_Internal_FlowControllerTest {
        /** 
         *@description TestMethod for createLeadRecordTest
         */
        @isTest static void createLeadRecordTest() {
            Lead ld = AOB_TestDataFactory.createLead();
            List<Lead> ldList = new List<Lead>{ld};
    
            Individual individualRecord = AOB_TestDataFactory.createIndividual();
            
            Test.startTest();
            String leadId = AOB_PPB_Internal_FlowController.createLeadRecord(ldList, new List<Individual>{individualRecord});
            Test.stopTest();
    
            List<Lead> insertedLeadList = [SELECT Id FROM Lead WHERE Id = :leadId];
            Assert.areEqual(1, insertedLeadList.size(), 'Instered Lead Size Check');
        }
    /** 
         *@description TestMethod for upsertApplicationRecordNationality
         */
        @isTest static void upsertApplicationRecordNationality() {
            
            List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
            insert appList; 
            String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"0","Description":"Successful"},"Resultz":{"CustomerReference":"256782793556","Area":"WALLET","StatusCode":"0","StatusDescription":"ACTIVE","CustomerName":"DENNIS  STANLEY MBOGO","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
            AOB_MobileNumberValidate.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_MobileNumberValidate.mockHttpStatus = 'OK';
            AOB_MobileNumberValidate.mockHttpbody = str;
            List<Product2> prodList = AOB_TestDataFactory.createProduct();
    
            Test.startTest();
            String resultList = AOB_PPB_Internal_FlowController.upsertApplicationRecord(appList, 'PPB_INT_Nationality and ID', prodList);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
            Test.stopTest();  
    
            Assert.areEqual((String)m.get('Description'),null,'Expected Description to be empty');
        }
        /** 
         *@description TestMethod for upsertApplicationRecordNationalityException
         */
        @isTest static void upsertApplicationRecordNationalityException() {
            
            List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
            insert appList; 
            String str = '{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"0","Description":"Successful","CustomerName":"Test Name"}}}}}}'; 
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = str;
            List<Product2> prodList = AOB_TestDataFactory.createProduct();
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.upsertApplicationRecord(appList, 'Nationality and ID', prodList);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
            
            Test.stopTest();  
        }
        /** 
         *@description TestMethod for upsertApplicationRecordNationalityFailure
         */
        @isTest static void upsertApplicationRecordNationalityFailure() {
            
            List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
            insert appList; 
            String str = '{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"10","Description":"Failed","CustomerName":"Test Name"}}}}}}'; 
            AOB_MobileNumberValidate.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_MobileNumberValidate.mockHttpStatus = 'OK';
            AOB_MobileNumberValidate.mockHttpbody = str;
            List<Product2> prodList = AOB_TestDataFactory.createProduct();
    
            Test.startTest();
            String resultList = AOB_PPB_Internal_FlowController.upsertApplicationRecord(appList, 'PPB_INT_Nationality and ID', prodList);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
            Test.stopTest();  
    
            Assert.areEqual((String)m.get('Description'), null, 'Status Check against the response');
        }

        /** 
         *@description TestMethod for upsertApplicationRecordPersonalDetailsException
         */
        @isTest static void upsertApplicationRecordPersonalDetailsException() {
            List<Application__c> applicationList = AOB_TestDataFactory.createApplication(1);
            insert applicationList;
            string mockResponse = '{"caseId":"5jb8f6g8q9zj1guky6czii2t7","name":"Leku Joel","providerTypes":["WATCHLIST"],"customFields":[],"secondaryFields":[],"groupId":"5jb75gv0cn6q1g4q4u0643299","entityType":"INDIVIDUAL","caseSystemId":"5jb8f6g8q9zj1guky6czii2t8","caseScreeningState":{"WATCHLIST":"INITIAL"},"lifecycleState":"UNARCHIVED","creator":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"modifier":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"assignee":null,"creationDate":"2022-07-22T07:00:45.917Z","modificationDate":"2022-07-22T07:00:49.020Z","nameTransposition":false,"outstandingActions":true,"results":[{"resultId":"5jb7ukkmdn291guky6iwoh1tz","referenceId":"e_tr_wci_6581204","matchScore":89.97,"matchStrength":"EXACT", "matchedTerm":"Joel LEKU","matchedTerms":[{"term":"Joel LEKU","type":"PRIMARY"}],"submittedTerm":"Leku Joel","matchedNameType":"PRIMARY","secondaryFieldResults":[],"sources":["b_trwc_PEP N"],"categories":["PEP","Regulatory Enforcement","Sanctions"],"creationDate":"2022-07-22T07:00:49.018Z","modificationDate":"2022-07-22T07:00:49.018Z","lastAlertDate":"2022-07-22T07:00:49.021Z","resolution":null,"resultReview":{"reviewRequired":false,"reviewRequiredDate":"2021-09-03T00:00:00.000Z","reviewRemark":null,"reviewDate":null},"primaryName":"Joel LEKU","events":[],"countryLinks":[{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"NATIONALITY"},{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"LOCATION"}],"identityDocuments":[],"category":"POLITICAL INDIVIDUAL","providerType":"WATCHLIST","gender":"MALE","entityCreationDate":"2021-08-02T00:00:00.000Z","entityModificationDate":"2021-09-03T00:00:00.000Z","pepStatus":"ACTIVE"}]}';
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = mockResponse;
            List<Product2> prodList = AOB_TestDataFactory.createProduct();
            
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.upsertApplicationRecord(applicationList, 'PPB_INT_Personal Details', prodList);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
            
            Test.stopTest();
        }
        /** 
         *@description TestMethod for upsertApplicationRecordEmploymentDetails
         */
        @isTest static void upsertApplicationRecordEmploymentDetails() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            
            String str = '{"RiskScoreStatus":"48.33","RiskScoreRating":"MEDIUM"}';
            AOB_CustomerRiskAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_CustomerRiskAssessment.mockHttpStatus = 'OK';
            AOB_CustomerRiskAssessment.mockHttpbody = str;
            List<Product2> prodList = AOB_TestDataFactory.createProduct();
    
            Test.startTest();
            string repStatus = AOB_PPB_Internal_FlowController.upsertApplicationRecord(lstApp, 'PPB_INT_Employment Details', prodList);
            Test.stopTest(); 
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), null, 'Status Check against the response');
        }
        /** 
         *@description TestMethod for upsertApplicationRecordEmploymentDetailsException
         */
        @isTest static void upsertApplicationRecordEmploymentDetailsException() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            
            String str = '{"RiskScoreStatus":"48.33","RiskScoreRating":"MEDIUM"}';
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = str;
            List<Product2> prodList = AOB_TestDataFactory.createProduct();
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.upsertApplicationRecord(lstApp, 'PPB_INT_Employment Details', prodList);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for verifyCustomerExistTest
         */
        @isTest static void verifyCustomerExistTest() {
            Lead ld = AOB_TestDataFactory.createLead();
            insert ld;
            List<Lead> ldList = new List<Lead>{ld};
            String str = '{"customers":[{"uuid":null,"accountNumber":"823565","status":"SUCCESS","prominentInfluentialPerson":{"relationType":{}},"personDetails":{"firstName":"DAVID","citizenshipCountry":{}},"addresses":[{"line1":"NYABUHIKYE TRADING CENTER","addressTypes":[{"addressType":"Mailing","startDate":"2007-10-12T00:00:00.000","endDate":"2099-12-31T00:00:00.000"}],"city":"NYABUHIKYE TRADING CENTER","countryCode":"NYABUHIKYE TRADING CENTER"}],"identifications":[{"issuingCountry":"UG","documentCode":"D0001"}]}]}';
            AOB_CustomerList.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_CustomerList.mockHttpStatus = 'OK';
            AOB_CustomerList.mockHttpbody = str;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.verifyCustomerExist(ldList);
            Test.stopTest();
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');
        }


    
         /** 
         *@description TestMethod for verifyThroughNIRATest
         */
        @isTest static void verifyThroughNIRATestInternal() {
            List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
            insert applicationList;
            String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
            AOB_NIRA.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_NIRA.mockHttpStatus = 'OK';
            AOB_NIRA.mockHttpbody = str;
    
            Test.startTest();
            String resultList = AOB_PPB_Internal_FlowController.verifyThroughNIRAInternal(applicationList);
            Test.stopTest();
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
            Assert.areEqual((String)m.get('matchingStatus'), 'true', 'Status Check against the response');
            List<Verification__c> verificationList=[SELECT Id FROM Verification__c];
            Assert.areEqual(1, verificationList.size(), 'Verification Record Size Check');
        }
          /** 
         *@description TestMethod for verifyThroughNIRATestException
         */
        @isTest static void verifyThroughNIRATestException() {
            List<Application__c> applicationList = AOB_TestDataFactory.createApplication(1);
            String str = '{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = str;
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.verifyThroughNIRAInternal(applicationList);
            } catch(Exception e) {
                Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for sendSMSTest
         */
        @isTest static void sendSMSTest() {
            Lead ld = AOB_TestDataFactory.createLead();
            List<Lead> idList = new List<Lead>{ld};
            AOB_SMSAlert.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_SMSAlert.mockHttpStatus = 'OK';
            AOB_SMSAlert.mockHttpbody = null;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.sendSMS(idList);        
            Test.stopTest(); 
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'NO_CONTENT', 'Status Check against the response');
        }
        /** 
         *@description TestMethod for sendSMSTestException
         */
        @isTest static void sendSMSTestException() {
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = '';
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.sendSMS(null);    
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
            Test.stopTest();
        }

        
        /** 
         *@description TestMethod for invokeCustomerCreationTest
         */
        @isTest static void invokeCustomerCreationTest() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            lstApp[0].AOB_Customer_Id__c= '';
            insert lstApp; 
            String str = '{"CustId":"10302196858","Status":"SUCCESS","Description":"Retail Customer successfully created with CIFID 10302196858"}';
            AOB_Customer.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_Customer.mockHttpStatus = 'OK';
            AOB_Customer.mockHttpbody = str;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeCustomerCreation(lstApp);        
            Test.stopTest(); 
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('Status'), 'SUCCESS', 'Status Check against the response');
        }
        /** 
         *@description TestMethod for invokeCustomerCreationTestException
         */
        @isTest static void invokeCustomerCreationTestException() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            lstApp[0].AOB_Customer_Id__c= '';
            insert lstApp; 
            String str = '{"CustId":"10302196858","Status":"SUCCESS","Description":"Retail Customer successfully created with CIFID 10302196858"}';
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = str;
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeCustomerCreation(null);  
            } catch(Exception e) {
              Assert.isNotNull(e,'will throw exception');
               
            }
        }
        /** 
         *@description TestMethod for invokeQuestionsAndAnswersTest
         */
        @isTest static void invokeQuestionsAndAnswersTest() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            String str = '{"customRegisterQNAResponse":{"userIdentity":"9030020359144","customerFirstName":"FAITHMIGI","Message":[{"Status":"306518","StatusCode":"306518","StatusType":"BC"},{"Status":"Password Set Successfully. Your user id is 9030020359144.","StatusCode":"107045","StatusType":"BC"},{"Status":"Registration for security questions successful.","StatusCode":"107034","StatusType":"BC"}]}}';
            AOB_CustomerRegister_QNA.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_CustomerRegister_QNA.mockHttpStatus = 'OK';
            AOB_CustomerRegister_QNA.mockHttpbody = str;
            String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
            
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeQuestionsAndAnswers(lstApp, sr);        
            Test.stopTest();
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');
        }
        /** 
         *@description TestMethod for invokeQuestionsAndAnswersTestException
         */
        @isTest static void invokeQuestionsAndAnswersTestException() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeQuestionsAndAnswers(null, null); 
            } catch(Exception e) {
              Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for invokeDSXCalloutTest
         */
        @isTest static void invokeDSXCalloutTest1() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            ContentVersion cv = AOB_TestDataFactory.createContentVersion();
            List<ContentVersion> documentList = new List<ContentVersion>{cv};
            insert documentList;
            ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
            List<Product2> productList = AOB_TestDataFactory.createProduct(); 
            insert productList; 
            ContentDocumentLink cDoc = AOB_TestDataFactory.createContentDocumentLink (productList[0].Id, contentVersion2.ContentDocumentId);
            insert cDoc;
            lstApp[0].AOB_Product__c = productList[0].Id; 
            String str = '{"documents":[{"reasonCode":"success","status":"queued","reasonDescription":"true"}]}';
            AOB_Internal_DSX.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_Internal_DSX.mockHttpStatus = 'OK';
            AOB_Internal_DSX.mockHttpbody = str;
            insert lstApp;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeDSXCalloutInternal(lstApp, productList);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();  
    
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');
        }
         /** 
         *@description TestMethod for invokeDSXCalloutTestException
         */
        @isTest static void invokeDSXCalloutTestException1() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            ContentVersion cv = AOB_TestDataFactory.createContentVersion();
            List<ContentVersion> documentList = new List<ContentVersion>{cv};
            insert documentList;
            ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
            List<Product2> productList = AOB_TestDataFactory.createProduct(); 
            insert productList; 
            ContentDocumentLink cDoc = AOB_TestDataFactory.createContentDocumentLink (productList[0].Id, contentVersion2.ContentDocumentId);
            insert cDoc;
            lstApp[0].AOB_Product__c = productList[0].Id; 
            String str='{"document":{"status":"queued"}}';
            AOB_API_Utils.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_API_Utils.mockHttpStatus = 'OK';
            AOB_API_Utils.mockHttpbody = str;
            insert lstApp;
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeDSXCalloutInternal(null, null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();  
        }
        /** 
         *@description TestMethod for fetchKeyFactDocLinkTest
         */
        
        @isTest static void fetchKeyFactDocLinkTest1() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            ContentVersion cv = AOB_TestDataFactory.createContentVersion();
            List<ContentVersion> documentList = new List<ContentVersion>{cv};
                insert documentList;
            ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
            List<Product2> productList = AOB_TestDataFactory.createProduct(); 
            insert productList; 
            lstApp[0].AOB_Product__c = productList[0].Id;
            update lstApp;
            ContentDocumentLink cDoc = AOB_TestDataFactory.createContentDocumentLink (productList[0].Id, contentVersion2.ContentDocumentId);
            insert cDoc;
            Lead ld = AOB_TestDataFactory.createLead();
            List<Lead> ldList = new List<Lead>();
            ldList.add(ld);
            insert ldList;
            Test.startTest();
            AOB_PPB_Internal_FlowController.fetchKeyFactDocLink(productList[0], lstApp[0]);
            AOB_PPB_Internal_FlowController.upsertApplicationRecord(lstApp, 'PPB_INT_Nationality and ID', new List<Product2>());
            List<Application__c> applicationList = AOB_PPB_Internal_FlowController.verifyApplicationStage(lstApp);
            AOB_PPB_Internal_FlowController.sendEmail(ldList);
            Test.stopTest();
            Assert.areEqual('PPB_INT_Nationality and ID', applicationList[0].AOB_Stage__c, 'Stage Verify Check');
        }
         /** 
         *@description TestMethod for invokeSignatureVerifyTest
         */
        @isTest static void invokeSignatureVerifyTest() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            lstApp[0].WI_ClientType__c = 'Staff Assist';
            insert lstApp;
            ContentVersion document = AOB_TestDataFactory.createContentVersion(); 
            List<ContentVersion> documentList = new List<ContentVersion>();
            document.Description = 'Signature File';
            documentList.add(document); 
            ContentVersion document1 = AOB_TestDataFactory.createContentVersion(); 
            document1.Title =  'Selfie image';
            document1.Description='Selfie image';
            insert document1;
            ContentVersion contentVersionId = [SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: document1.id];
        
            ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentVersionId.ContentDocumentId,
                LinkedEntityId = lstApp[0].Id,
                ShareType = 'V'
            );
            insert testContentDocumentLink;
            documentList.add(document1); 
            String str = '{"signatureAddResponse":{"signatureAddResponse":{},"accountCode":{},"customerNumber":"10000000111","employeeIdent":{},"bankCode":{},"signaturePowerNum":{},"signatureAddStatusCode":"true"}}';
            AOB_SignatureVerification.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_SignatureVerification.mockHttpStatus = 'OK';
            AOB_SignatureVerification.mockHttpbody = str;
            
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeSignatureVerify(lstApp, documentList);
            Test.stopTest(); 
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');
        }
         /** 
         *@description TestMethod for invokeSignatureVerifyTestException
         */
        @isTest static void invokeSignatureVerifyTestException() {
        
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeSignatureVerify(null, null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for getSelfRegistrationQuestionsTest
         */
        @isTest static void getSelfRegistrationQuestionsTest() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            String str = '{"status":"SUCCESS","customLoginQNAResponse":{"userIdentity":"215061","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}'; 
            AOB_SelfRegistration.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_SelfRegistration.mockHttpStatus = 'OK';
            AOB_SelfRegistration.mockHttpbody = str;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.getSelfRegistrationQuestions(lstApp);
            Test.stopTest(); 
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');
        }
        /** 
         *@description TestMethod for getSelfRegistrationQuestionsTestException
         */
        @isTest static void getSelfRegistrationQuestionsTestException() {
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.getSelfRegistrationQuestions(null);
            } catch(Exception e) {
              Assert.isNotNull(e,'will throw exception');
               
            }
            Test.stopTest(); 
        }
        /** 
         *@description TestMethod for invokeGETCustomerAccountNumberTest
         */
        @isTest static void invokeGETCustomerAccountNumberTest() {
            Lead ld = AOB_TestDataFactory.createLead();
            insert ld;
            List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
            appList[0].WI_ClientType__c = 'Staff Assist';
            appList[0].AOB_Account_Number__c =null;
            appList[0].AOB_Lead__c = ld.Id;
            insert appList;  
            string mockResponse = '{"ODAccountAddRes":{"ODaccountNumber":{"accountNumber":"9030020820453","accountType":{"schemaCode":{},"schemaType":{}},"accountCurrency":{},"bankInfo":{"bankId":{},"name":{},"branchId":{},"branchName":{},"postalAddress":{"line1":{},"line2":{},"line3":{},"city":{},"stateProvince":{},"postalCode":{},"country":{},"addressType":{}}}}}}';
            AOB_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_ODAccountCreation.mockHttpStatus = 'OK';
            AOB_ODAccountCreation.mockHttpbody = mockResponse;
            Test.startTest();
            String resultList =AOB_PPB_Internal_FlowController.invokeGETCustomerAccountNumber(appList);
            Test.stopTest();
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');
        }
        /** 
         *@description TestMethod for invokeGETCustomerAccountNumberTestException
         */
        @isTest static void invokeGETCustomerAccountNumberTestException() {
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeGETCustomerAccountNumber(null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');            }
            Test.stopTest();
        }
         /** 
         *@description TestMethod for invokeSubscriptionAlertCalloutTest
         */
        @isTest static void invokeSubscriptionAlertCalloutTest() {
            List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
            insert appList;  
            string mockResponse = '{"ErrorCode":"B000000051","ErrorDescription":"The user already subscribed for alerts","ErrorSource":" ","ErrorStatus" : " "}';
            AOB_CustomerAlertSubscription.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_CustomerAlertSubscription.mockHttpStatus = 'OK';
            AOB_CustomerAlertSubscription.mockHttpbody = mockResponse;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeSubscriptionAlertCallout(appList);
            Test.stopTest();
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('ErrorDescription'), 'The user already subscribed for alerts', 'Status Check against the response');
        }

         /** 
         *@description TestMethod for invokeProfileAlertCalloutTest
         */
        @isTest static void invokeProfileAlertCalloutTest() {
            List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
            insert appList;
    
            AOB_CustomerAlertsProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_CustomerAlertsProfile.mockHttpStatus = 'OK';
            AOB_CustomerAlertsProfile.mockHttpbody = null; 
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeProfileAlertCallout(appList);
            Test.stopTest();
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'FAILED', 'Status Check against the response');
        }

         /** 
         *@description TestMethod for invokeMobileWalletCalloutTest
         */
        @isTest static void invokeMobileWalletCalloutTest() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            String str = '{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';
            AOB_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_MobileWallet.mockHttpStatus = 'OK';
            AOB_MobileWallet.mockHttpbody = str;
    
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeMobileWalletCallout(lstApp);
            Test.stopTest();  
    
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            
            Assert.areEqual((Integer)m.get('status'),200, 'Status Check against the response');
        }
         /** 
         *@description TestMethod for invokeMobileWalletCalloutTestException
         */
        @isTest static void invokeMobileWalletCalloutTestException() {
    
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeMobileWalletCallout(null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
         /** 
         *@description TestMethod for updateVerificationStatusTest
         */
        @isTest static void updateVerificationStatusTest() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            String verificationRecordId = AOB_PPB_Internal_FlowController.createVerificationRecord(lstApp[0], 'NIRA', 'Success');
            try{
                AOB_PPB_Internal_FlowController.updateVerificationStatus('wertyuio', 'Success', '123566');
            } catch(Exception e) {
               Assert.isTrue(e.getMessage() != null, 'Exception Handling Check');
            }
            AOB_PPB_Internal_FlowController.updateVerificationStatus(verificationRecordId, 'Success', '123566');
    
            List<Verification__c> updatedVerification = [SELECT Id, Verification_Status__c FROM Verification__c WHERE Id = :verificationRecordId];
    
            Assert.areEqual('Success', updatedVerification[0].Verification_Status__c, 'Status Check against the response');
        }
          /** 
         *@description TestMethod for updateVerificationStatusTest to cover exception
         */
        @isTest static void updateVerificationStatusTestException() {
            
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.createVerificationRecord(null, 'Success', '123566');
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
          /** 
         *@description TestMethod for igetAllFlowScreenRecordsTest
         */
        @isTest static void getAllFlowScreenRecordsTest() {
            List<AOB_FlowScreen__c> flowScreenList = AOB_TestDataFactory.createFlowScreen(8);
            insert flowScreenList;
    
            Test.startTest();
            List<AOB_FlowScreen__c> queriedRecordList = AOB_PPB_Internal_FlowController.getAllFlowScreenRecords('UG');
            Test.stopTest();
    
            Assert.areEqual(queriedRecordList.size(), 0, 'Screen Record Size Check');
        }
    
        
         /** 
         *@description TestMethod for verifySelectedFileTest
         */
        @isTest static void verifySelectedFileTest() {
            List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
            insert appList; 
    
            ContentVersion cv = AOB_TestDataFactory.createContentVersion();
    
            String str1 = EncodingUtil.base64Encode(cv.VersionData);
            cv.Description = str1;
            cv.Title = 'testimage.jpg';
            String str = '{"status":"SUCCESS"}';
            AOB_ScanAndVerifyFiles.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_ScanAndVerifyFiles.mockHttpStatus = 'OK';
            AOB_ScanAndVerifyFiles.mockHttpbody = str;
    
            Test.startTest();
            String response = AOB_PPB_Internal_FlowController.verifySelectedFile(appList, new List<ContentVersion>{cv});
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
    
            cv.Title = 'testimage.pgm';
            AOB_PPB_Internal_FlowController.verifySelectedFile(appList, new List<ContentVersion>{cv});
    
            cv.Title = 'testimage.ppm';
            AOB_PPB_Internal_FlowController.verifySelectedFile(appList, new List<ContentVersion>{cv});
            Test.stopTest();
    
            Assert.areEqual((String) responseMap.get('status'), 'SUCCESS', 'Status Check');
        }
           /** 
         *@description TestMethod for verifySelectedFileTest
         */
        @isTest static void verifySelectedFileTest1() {
            List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
            insert appList; 
    
            ContentVersion cv = AOB_TestDataFactory.createContentVersion();
    
            String str1 = EncodingUtil.base64Encode(cv.VersionData);
            cv.Description = str1;
            cv.Title = 'testimage.jpg';
            String str = '{"status":"SUCCESS"}';
            AOB_ScanAndVerifyFiles.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
            AOB_ScanAndVerifyFiles.mockHttpStatus = 'OK';
            AOB_ScanAndVerifyFiles.mockHttpbody = str;
    
            Test.startTest();
            String response = AOB_PPB_Internal_FlowController.fileScreeningByDocumentList(new List<ContentVersion>{cv});
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
    
            cv.Title = 'testimage.pgm';
            AOB_PPB_Internal_FlowController.fileScreeningByDocumentList( new List<ContentVersion>{cv});
    
            cv.Title = 'testimage.ppm';
            AOB_PPB_Internal_FlowController.fileScreeningByDocumentList( new List<ContentVersion>{cv});
            Test.stopTest();
    
            Assert.areEqual((String) responseMap.get('status'), 'SUCCESS', 'Status Check');
        }
         /** 
         *@description TestMethod for verifySelectedFileTestFailure
         */
        @isTest static void verifySelectedFileTestFailure() {
            List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
            insert appList; 
    
            ContentVersion cv = AOB_TestDataFactory.createContentVersion();
    
            String str1 = EncodingUtil.base64Encode(cv.VersionData);
            cv.Description = str1;
            cv.Title = 'testimage.png';
            String str = '{"status":"SUCCESS"}';
            AOB_ScanAndVerifyFiles.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            AOB_ScanAndVerifyFiles.mockHttpStatus = 'OK';
            AOB_ScanAndVerifyFiles.mockHttpbody = str;
    
            Test.startTest();
            String response = AOB_PPB_Internal_FlowController.verifySelectedFile(appList, new List<ContentVersion>{cv});
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
            Test.stopTest();
    
            Assert.areEqual((String) responseMap.get('status'), 'FAILED', 'Status Check');
        }
         /** 
         *@description TestMethod for verifySelectedFileTestException
         */
        @isTest static void verifySelectedFileTestException() {
            
            Test.startTest();
            try{
                AOB_PPB_Internal_FlowController.verifySelectedFile(null, null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling Check');
            }
            Test.stopTest();
        }
          /** 
         *@description TestMethod for verifySelectedFileTestException
         */
        @isTest static void fileScreeningByDocumentListTestException() {
            
            Test.startTest();
            try{
                AOB_PPB_Internal_FlowController.fileScreeningByDocumentList(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling Check');
            }
            Test.stopTest();
        }
       /** 
         *@description TestMethod for FetchRecordTypeId
         */
        @isTest static void testFetchRecordTypeId() {
            Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Uganda_OnBoarding').getRecordTypeId();
            Test.startTest();
            Id resultRecordTypeId = AOB_PPB_Internal_FlowController.fetchRecordTypeId();
            Test.stopTest();
            Assert.areEqual(recordTypeId, resultRecordTypeId, 'The record type Ids should match');
        }
    /** 
         *@description TestMethod for InvokeSelfieUpload
         */
        @isTest static void testInvokeSelfieUpload() {
            List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
            insert appList; 
            ContentVersion cv = new ContentVersion();
            cv.Description = 'selfieFile';
            cv.Title = 'Test Selfie';
            cv.PathOnClient = 'Test_Selfie.jpg';
            cv.VersionData = EncodingUtil.base64Decode('Test Selfie Data');
            insert cv;
            Map<String, List<ContentVersion>> documentUploads = new Map<String, List<ContentVersion>>{
                'selfieFile' => new List<ContentVersion>{cv}
            };
            Test.startTest();
            AOB_PPB_Internal_FlowController.invokeSelfieUpload(appList, documentUploads);
            Test.stopTest();
            List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :appList[0].Id];
            Assert.areEqual(appList[0].Id, links[0].LinkedEntityId, 'The LinkedEntityId should be the Id of the Application__c record');
        }
        /** 
         *@description TestMethod for InvokeSelfieUploadException
         */
        @isTest static void testInvokeSelfieUploadException() {
            Test.startTest();
            try{
                AOB_PPB_Internal_FlowController.invokeSelfieUpload(null,null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
                
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for GetImages
         */
            @isTest static void testGetImages() {
                List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
                insert appList; 
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Image';
                cv.PathOnClient = 'Test_Image.jpg';
                cv.VersionData = EncodingUtil.base64Decode('Test Image Data');
                insert cv;
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = appList[0].Id;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                insert cdl;
                Test.startTest();
                List<AOB_PPB_Internal_FlowController.ImageWrapper> images = AOB_PPB_Internal_FlowController.getImages(appList);
                Test.stopTest();
              
               Assert.areEqual(cv.Id, images[0].Id, 'The Id of the ImageWrapper record should be the Id of the ContentVersion record');
            }
        /** 
         *@description TestMethod for invokeMobileWalletStatusCheckCallout
         */
            @istest static void invokeMobileWalletStatusCheckCalloutTest(){    
                List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
                insert lstApp;
                String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
                AOB_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
                AOB_MobileWalletStatus.mockHttpStatus='OK';
                AOB_MobileWalletStatus.mockHttpbody=str;
                Test.startTest();
                String repStatus = AOB_PPB_Internal_FlowController.invokeMobileWalletStatusCheckCallout(lstApp, str);
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
                Test.stopTest();
                Assert.areEqual((String)m.get('status'), 'SUCCESS','It should be success');
            }
        /** 
         *@description TestMethod for invokeMobileWalletStatusCheckCallout to cover exception
         */
        @istest static void invokeMobileWalletStatusCheckCalloutTestException(){    
           
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeMobileWalletCallout(null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod forinvokeMobileMoneyNumberValidate to cover exception
         */
        @istest static void invokeMobileMoneyNumberValidateTestException(){    
           
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeMobileMoneyNumberValidate(null);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for  AOB_PPB_Internal_FlowController.createApplicationDocument Exception
         */
        @isTest
        static void testCreateApplicationDocumentException() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            String applicationId = lstApp[0].id;
            String currencyType = 'USD';
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.createApplicationDocument(applicationId, null, null, currencyType);
            } catch(Exception e) {
               Assert.isNotNull(e,'will throw exception');
            }
            Test.stopTest();
        }
        /** 
         *@description TestMethod for  AOB_PPB_Internal_FlowController.createApplicationDocument
         */
        @isTest
        static void testCreateApplicationDocument() {
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            String applicationId = lstApp[0].id;
            String filename = 'testFile';
            String filedata = 'VGhpcyBpcyBhIHRlc3Qgc3RyaW5n'; 
            String currencyType = 'USD';
            Test.startTest();
            AOB_PPB_Internal_FlowController.createApplicationDocument(applicationId, filename, filedata, currencyType);
            Test.stopTest();
             List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: applicationId];
             Assert.areEqual(1, contentDocumentLinks.size(), 'ContentVersion record should be created');
        }

     /** 
* @description verificationInstanceException
*/

 /** 
         *@description TestMethod for testRelyComplyScreening
         */
        @isTest
        static void testRelyComplyScreening() {
            
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string response = '{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        AOB_RelyComply_Individual_Screening.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_Individual_Screening.mockHttpStatus='OK';
        AOB_RelyComply_Individual_Screening.mockHttpBody=response;
        Test.startTest();
        String repStatus = AOB_PPB_Internal_FlowController.handleEmploymentDetails(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will return status');
        } 
        /** 
         *@description TestMethod for testFetchAssessment
         */
        @isTest
        static void testFetchAssessment() {
            
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string response = '{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "Match","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        string assessmentId ='2361825';
        AOB_RelyComply_Individual_Screening.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_Individual_Screening.mockHttpStatus='OK';
        AOB_RelyComply_Individual_Screening.mockHttpBody=response;
        Test.startTest();
        String repStatus = AOB_PPB_Internal_FlowController.fetchAssessmentCallout(lstApp,assessmentId);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status');
        } 
        @istest static void testMethodPositiveResponse(){     
            List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
            insert lstApp;
            List<Product2> products = AOB_TestDataFactory.createProduct();
            String str='{"RiskScoreStatus":"48.33","RiskScoreRating":"MEDIUM"}';
            AOB_CustomerRiskAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            AOB_CustomerRiskAssessment.mockHttpStatus='OK';
            AOB_CustomerRiskAssessment.mockHttpBody=str;
            Test.startTest();
            String repStatus = AOB_PPB_Internal_FlowController.invokeRiskAssessmentCallout(lstApp,products);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest(); 
            Assert.areEqual((String)m.get('status'), 'Success', 'It will return status');
        }
        @istest static void invokeRiskAssessmentCalloutException(){     
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeRiskAssessmentCallout(null,null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
        }
        @isTest static void invokeIdentifiiCalloutTestException() {
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeIdentifiiCallout(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling Check');
            }        
            Test.stopTest();
        }
         /** 
         *@description TestMethod for invokeProfileAlertCalloutTestException
         */
        @isTest static void invokeProfileAlertCalloutTestException() {
       
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeProfileAlertCallout(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling Check');
            }
            Test.stopTest();
        }
        @isTest static void invokeSubscriptionAlertCalloutTestException() {
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.invokeSubscriptionAlertCallout(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling Check');
            }
            Test.stopTest();
        }
        @isTest static void sendEmailException() {
            
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.sendEmail(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
        }
        @isTest static void verifyCustomerExistTestException() {
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.verifyCustomerExist(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
        }
  
        @isTest static void testRelyComplyScreeningException() {
           
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.handleEmploymentDetails(null);
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
        }
        @isTest static void fetchKeyFactDocLinkException() {
            List<Product2> productList = AOB_TestDataFactory.createProduct(); 
            insert productList; 
            Test.startTest();
            try {
                AOB_PPB_Internal_FlowController.fetchKeyFactDocLink(productList[0], null);
                AOB_PPB_Internal_FlowController.upsertApplicationRecord(null, 'Nationality and ID', new List<Product2>());
            } catch(Exception e) {
               Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception Handling');
            }
        }
        @isTest
        public static void getActiveUgandaProductTest(){
            List<Product2> productList = AOB_TestDataFactory.createProduct(); 
            productList[0].AOB_Memo_Code__c = 'OD00999';
            productList[0].IsActive = true;
            productList[0].Country__c = 'UG';
            insert productList; 
            Test.startTest(); 
              List<Product2> productLst = AOB_PPB_Internal_FlowController.getActiveUgandaProduct();
              System.assertEquals(1, productLst.size(), 'Expected product list to contain exactly 1 active Uganda product.');
            Test.stopTest();
        }
    }