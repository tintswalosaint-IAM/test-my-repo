/**
*   @description    SFP-36638 - test class for WI_API_ServiceFullfillment
*  @author Adam Redlinski
*  @date   2023/06/14
*  @last modified by Karabo Machubeni - SFP-38675 - updated the creation of the service fulfillment to be based on the Account Lookup field
*  @last modified date 2024/05/19
*  @last modified by Vikash Beersye - [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
*  @last modified date 2026/03/20
*/

@IsTest
public with sharing class WI_API_ServiceFullfillment_TEST {
    @TestSetup
    static void setupMethod() {
        User manager = WI_DAL_DataFactory.createUser('System Administrator');
        User approver = WI_DAL_DataFactory.createUser('System Administrator');
        approver.FirstName = 'John';
        approver.LastName = 'Johns';
        
        insert manager;
        
        approver.ManagerId = manager.Id;
        insert approver;
        List<ServiceFulfillment__c> fulfillments = new List<ServiceFulfillment__c>();
        system.runAs(approver) {
            Account acc = WI_DAL_DataFactory.createAccount(new Map<String, Object>{
                'WI_Title__c' => 'MR.'
            });
            insert acc;
            
            Case c = WI_DAL_DataFactory.createCase(
            new Map<String, Object>{
                'AccountId' => acc.Id,
                'WI_Retro__c' => 'Yes'
            }
            );
            insert c;
            
            fulfillments.add(new ServiceFulfillment__c(
            Status__c = 'New',
            Debit_Account_Number__c = '1234567890',
            Account__c = acc.Id,
            Case__c = c.Id,
            Amount__c = 28484,
            NarrativeDebitAccount__c = '24',
            BeneficiaryAccountName__c = 'test',
            BeneficiaryAccountBank__c = 'Discovery Bank',
            BeneficiaryAccountNumber__c = '1234',
            NarrativeCreditAccount__c = 'testNarrativeCredit'
            ));
            fulfillments.add(new ServiceFulfillment__c(
            Amount__c = 3000000,
            BeneficiaryAccountBank__c = 'Discovery Bank',
            Account__c = acc.Id,
            Case__c = c.Id,
            Debit_Account_Number__c = '1098745632',
            Status__c = 'New'));
            
            insert fulfillments;
            
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(fulfillments[0].Id);
            Approval.process(request);
            
            Approval.ProcessSubmitRequest requestOver3m = new Approval.ProcessSubmitRequest();
            requestOver3m.setObjectId(fulfillments[1].Id);
            Approval.process(requestOver3m);
        }
        List<ProcessInstanceWorkitem> workItems = [
        SELECT Id, ProcessInstanceId
        FROM ProcessInstanceWorkitem
        WHERE ProcessInstance.TargetObjectId IN :new Set<Id>{
            fulfillments[0].Id, fulfillments[1].Id
        }
        ];
        
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for (ProcessInstanceWorkitem workItem : workItems) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setAction('Approve');
            req.setComments('Your Comment.');
            requests.add(req);
        }
        Approval.process(requests);
    }
    
    @IsTest
    static void testGetRecordsByStatus() {
        Test.startTest();
        List<ServiceFulfillment__c> fulfillments = [SELECT Id, Status__c, (SELECT Id, StepStatus, ProcessInstanceId, CreatedDate, Actor.Name FROM ProcessSteps) FROM ServiceFulfillment__c ];
        
        Map<Id, Id> approvalInstanceIdByRecordId = WI_API_ServiceFullfillment.getApprovalInstanceIdByRecordId(fulfillments);
        List<ProcessInstanceNode> instanceNodes = WI_API_ServiceFullfillment.getInstanceNodes(approvalInstanceIdByRecordId);
        
        User us = [SELECT Id, WI_PersonnelNumber__c, Name FROM User WHERE LastName = 'Johns' LIMIT 1];
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1/ServiceFulfillment';
        request.addParameter('status', 'Approved');
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        WI_API_ServiceFullfillment.getRecordsByStatus();
        Test.stopTest();
        
        Assert.isNotNull(RestContext.response, 'Response is not empty');
        Assert.areEqual(CMN_API_HttpBase.HTTP_OK, RestContext.response.statusCode, 'Status code is 400' );
        Assert.isNotNull(RestContext.response.responseBody, 'Response body is not empty');
        
        WI_API_ServiceFullfillment.ResponseWrapper responseWrapper = (WI_API_ServiceFullfillment.ResponseWrapper) JSON.deserialize(
        RestContext.response.responseBody.toString(), WI_API_ServiceFullfillment.ResponseWrapper.class);
        Assert.isNotNull(responseWrapper, 'Response warraper is not empty');
        
        List<WI_API_ServiceFullfillment.WrapperItem> items = responseWrapper.records;
        WI_API_ServiceFullfillment.WrapperItem firstItem = items[0], secondItem = items[1];
        Assert.areEqual(2, items.size(), 'Number of fulfillments to process is correct');
        Assert.areEqual(fulfillments[0].Id, firstItem.id,'Service Fulfillment Ids match');
        Assert.areEqual('Approved', firstItem.status, 'Status is the same');
        Assert.areEqual(28484, firstItem.amount,'Provided amounts match');
        Assert.areEqual('1234567890', firstItem.debitAccount, 'Account number provided is valid');
        Assert.areEqual('24', firstItem.narrativeDebitAccount, 'Narrative for debit account is correct');
        Assert.areEqual('test', firstItem.beneficiaryAccountName, 'Beneficiary name is valid');
        Assert.areEqual('Discovery Bank', firstItem.beneficiaryAccountBank, 'Bank Name provided is valid');
        Assert.areEqual('1234', firstItem.beneficiaryAccountNumber, 'Beneficiary Account Number is valid');
        Assert.areEqual('testNarrativeCredit', firstItem.narrativeCreditAccount, 'Narrative for debit account is correct');
        Assert.areEqual('Yes', firstItem.retro , 'Retro option is valid');
        Assert.areEqual('John Snow', firstItem.debitName, 'Account to be debited Name matches');
        Assert.areEqual(us.Name, firstItem.serviceFulfilmentCreator, 'Service Fulfillment Creator is valid');
        
        for (ProcessInstanceNode node : instanceNodes) {
            if (node.ProcessInstanceId == approvalInstanceIdByRecordId.get(firstItem.Id)) {
                Assert.areEqual(node.CompletedDate, firstItem.dateOfApproval, 'Date of Approvals match');
            } else {
                Assert.areEqual(node.CompletedDate, secondItem.dateOfApproval, 'Date of Approvals match');
            }
        }
        
        Assert.areEqual(fulfillments[1].Id, secondItem.id, 'Service Fulfillment Ids match');
        Assert.areEqual('Approved', secondItem.status, 'Status is the same');
        Assert.areEqual(3000000.00, secondItem.amount,'Provided amounts match');
    }
    
    @IsTest
    static void testGetRecordsByStatusWrongParameter() {
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1/ServiceFulfillment';
        request.addParameter('status', 'Processed');
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        WI_API_ServiceFullfillment.getRecordsByStatus();
        Test.stopTest();
        
        Assert.isNotNull(RestContext.response, 'Response is not empty');
        Assert.areEqual(CMN_API_HttpBase.HTTP_BAD_REQUEST, RestContext.response.statusCode, 'Status code is 400 - Bad request');
        Assert.isNotNull(RestContext.response.responseBody, 'Response Body is not empty');
        Assert.areEqual('Provided status Processed doesn\'t exist', RestContext.response.responseBody.toString());
    }
    
    @IsTest
    static void testUpdateRecordsNoRecords() {
        WI_API_ServiceFullfillment.RequestWrapper reqWrapper = new WI_API_ServiceFullfillment.RequestWrapper();
        
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1/ServiceFulfillment';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        WI_API_ServiceFullfillment.updateRecords();
        Test.stopTest();
        
        Assert.isNotNull(RestContext.response, 'Response is not empty');
        Assert.areEqual(CMN_API_HttpBase.HTTP_BAD_REQUEST, RestContext.response.statusCode, 'Status code is 400 - Bad request');
        Assert.isNotNull(RestContext.response.responseBody, 'Response Body is not empty');
        String response = (String) JSON.deserializeUntyped(RestContext.response.responseBody.toString());
        Assert.isNotNull(response, 'Deserialized response is not empty');
        Assert.areEqual('For POST request records have to be provided', response, 'Response indicates that request records should be provided');
    }
    
    @IsTest
    static void testUpdateRecordsWrongData() {
        WI_API_ServiceFullfillment.RequestWrapper reqWrapper = new WI_API_ServiceFullfillment.RequestWrapper();
        List<WI_API_ServiceFullfillment.WrapperItem> items = new List<WI_API_ServiceFullfillment.WrapperItem>();
        
        for (ServiceFulfillment__c sf : [SELECT Id FROM ServiceFulfillment__c]) {
            items.add(new WI_API_ServiceFullfillment.WrapperItem(sf.Id, 'Processing Success'));
        }
        
        reqWrapper.records = items;
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1/ServiceFulfillment';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        WI_API_ServiceFullfillment.updateRecords();
        Test.stopTest();
        
        Assert.isNull(RestContext.response, 'Response is empty');
    }
    
    @IsTest
    static void testUpdateRecordsWrongJson() {
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1/ServiceFulfillment';
        request.requestBody = Blob.valueOf('{"records" : [{Id : a3M8E00000166sfUAA, Status : "Processing Successful"},{"Id" : "a3M8E00000166v5UAA", "Status" : "Processing Failed"}]}');
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        WI_API_ServiceFullfillment.updateRecords();
        Test.stopTest();
        
        Assert.isNotNull(RestContext.response, 'Response is not empty');
        Assert.areEqual(CMN_API_HttpBase.HTTP_BAD_REQUEST, RestContext.response.statusCode, 'Status code is 400 - Bad request');
        Assert.isNotNull(RestContext.response.responseBody, 'Response Body is not empty');
        Assert.areEqual('"Unexpected character (\'I\' (code 73)): was expecting double-quote to start field name at [line:1, column:17]"', RestContext.response.responseBody.toString());
    }
    
    @IsTest
    static void testUpdateRecordsPositive() {
        WI_API_ServiceFullfillment.RequestWrapper reqWrapper = new WI_API_ServiceFullfillment.RequestWrapper();
        List<WI_API_ServiceFullfillment.WrapperItem> items = new List<WI_API_ServiceFullfillment.WrapperItem>();
        
        for (ServiceFulfillment__c sf : [SELECT Id FROM ServiceFulfillment__c]) {
            items.add(new WI_API_ServiceFullfillment.WrapperItem(sf.Id, 'Processing Successful'));
        }
        reqWrapper.records = items;
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/v1/ServiceFulfillment';
        request.requestBody = Blob.valueOf(JSON.serialize(reqWrapper));
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        WI_API_ServiceFullfillment.updateRecords();
        Test.stopTest();
        
        Assert.isNull(RestContext.response, 'Response is empty');
    }
}