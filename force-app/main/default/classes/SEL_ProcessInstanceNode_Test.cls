/**
 * @description       : test class for SEL_ProcessInstanceNode
 * @author            : Mbuyiseni Mbhokane
 * @group             : 
 * @last modified on  : 08-05-2025
 * @last modified by  : Agisanang Shole
 						added data setup method and test methods for the getInstanceNodesBySingleInstanceId and getInstanceNodesByInstanceIds methods
 
 * @last modified on            : 12-03-2026
 * @last modified by            : Vikash Beersye
 * @modification description    : [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
**/
@isTest 
public with sharing class SEL_ProcessInstanceNode_Test {
    
    @TestSetup
    private static void dataSetup() {

        User testUser = AOB_DAL_TestFactory.createUser('System Administrator', true);

        system.runAs(testUser) {
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

            FinServ__FinancialAccount__c debitAccount = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, Name = 'debit account');
            insert debitAccount;

            List<ServiceFulfillment__c> fulfillments = new List<ServiceFulfillment__c>();
            fulfillments.add(new ServiceFulfillment__c(
                    Status__c = 'New',
                    DebitAccount__c = debitAccount.Id,
                    Case__c = c.Id,
                    Amount__c = 28484,
                    NarrativeDebitAccount__c = '24',
                    BeneficiaryAccountName__c = 'test',
                    BeneficiaryAccountBank__c = 'Discovery Bank',
                    BeneficiaryAccountNumber__c = '1234',
                    NarrativeCreditAccount__c = 'testNarrativeCredit'
            ));

            insert fulfillments;
        }
    }

    @isTest 
    private static void testGetSObjectType() {
        SEL_ProcessInstanceNode selector = new SEL_ProcessInstanceNode();
        System.assertEquals(selector.getSObjectType(), ProcessInstanceNode.getSObjectType(),'Expected SEL_ProcessInstanceNode to return ProcessInstanceNode');
    }

    @isTest 
    private static void testGetSObjectFieldList() {
        SEL_ProcessInstanceNode selector = new SEL_ProcessInstanceNode();
        List<Schema.SObjectField>  expectedFieldList = selector.getSObjectFieldList();
        Map<String, Schema.SObjectField> fieldMap = ProcessInstanceNode.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(true, !expectedFieldList.isEmpty(), 'Unexpected field count');
       for (Schema.SObjectField field : expectedFieldList) {
           Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
       }
       Assert.areEqual(true, !expectedFieldList.isEmpty(), 'Unexpected field count');
    }
    
    @isTest
    static void testGetInstanceNodesBySingleInstanceId() {
        ServiceFulfillment__c sf = [SELECT Id FROM ServiceFulfillment__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Alias = 'aob'];

        System.runAs(testUser) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(sf.Id);
            Approval.process(request);

            ProcessInstance pi = [
                    SELECT Id
                    FROM ProcessInstance
                    WHERE TargetObjectId =: sf.Id
                	LIMIT 1
            ];
            	
            SEL_ProcessInstanceNode processInstanceNodeSelector = new SEL_ProcessInstanceNode();
            List<ProcessInstanceNode> nodes = processInstanceNodeSelector.getInstanceNodesBySingleInstanceId(pi.Id);
            Assert.areNotEqual(0, nodes.size(), 'There is at least 1 ProcessInstanceNode');
        }
    }
    
    @isTest
    static void testGetInstanceNodesByInstanceIds() {
        ServiceFulfillment__c sf = [SELECT Id FROM ServiceFulfillment__c LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Alias = 'aob'];

        System.runAs(testUser) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(sf.Id);
            Approval.process(request);

            ProcessInstance pi = [
                    SELECT Id
                    FROM ProcessInstance
                    WHERE TargetObjectId =: sf.Id
                	LIMIT 1
            ];

            Set<Id> resultIds = new Set<Id>{pi.Id};               	
            SEL_ProcessInstanceNode processInstanceNodeSelector = new SEL_ProcessInstanceNode();
            List<ProcessInstanceNode> nodes = processInstanceNodeSelector.getInstanceNodesByInstanceIds(resultIds);
            Assert.areNotEqual(0, nodes.size(), 'There is at least 1 ProcessInstanceNode');
        }
    }
}