/**
 * @description       : test class for SEL_ServiceFulfillment
 * @author            : Mbuyiseni Mbhokane
 * @group             : 
 * @last modified on  : 08-05-2025
 * @last modified by  : Agisanang Shole
 * 						added test method for the getServiceFulfillmentsWithProcessInstanceAndSteps method
 * @last modified on            : 12-03-2026
 * @last modified by            : Vikash Beersye
 * @modification description    : [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
**/
@isTest 
public with sharing class SEL_ServiceFulfillment_Test {


    @TestSetup
    public static void setupTestData() {
        //create account
        Account acc = WI_DAL_DataFactory.createAccount(new Map<String, Object>{'WI_Title__c' => 'MR.'});
        insert acc;

        //create case
        Case caseRecord = WI_DAL_DataFactory.createCase(
                new Map<String, Object>{
                        'AccountId' => acc.Id,
                        'WI_Retro__c' => 'Yes'});
        insert caseRecord; 

        FinServ__FinancialAccount__c debitAccount = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, Name = 'debit account');
        insert debitAccount;
        
        //create service fulfillment
       ServiceFulfillment__c fulfillment = new ServiceFulfillment__c(
                Status__c = 'New',
                DebitAccount__c = debitAccount.Id,
                Case__c = caseRecord.Id,
                Amount__c = 28484,
                NarrativeDebitAccount__c = '24',
                BeneficiaryAccountName__c = 'test',
                BeneficiaryAccountBank__c = 'Discovery Bank',
                BeneficiaryAccountNumber__c = '1234',
                NarrativeCreditAccount__c = 'testNarrativeCredit'
        );
        insert fulfillment;
    }

    @isTest 
    private static void testGetSObjectType() {
        SEL_ServiceFulfillment selector = new SEL_ServiceFulfillment();
        System.assertEquals(selector.getSObjectType(), ServiceFulfillment__c.getSObjectType(),'Expected SEL_ServiceFulfillment to return ServiceFulfillment__c');
    }

    @isTest 
    private static void testGetSObjectFieldList() {
        SEL_ServiceFulfillment selector = new SEL_ServiceFulfillment();
        List<Schema.SObjectField>  expectedFieldList = selector.getSObjectFieldList();
        Map<String, Schema.SObjectField> fieldMap = ServiceFulfillment__c.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(true, !expectedFieldList.isEmpty(), 'Unexpected field count');
       for (Schema.SObjectField field : expectedFieldList) {
           Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
       }
       Assert.areEqual(true, !expectedFieldList.isEmpty(), 'Unexpected field count');
    }

    @isTest 
    private static void testGetServiceFulfillmentsByStatus() {
        SEL_ServiceFulfillment selector = new SEL_ServiceFulfillment();
        ServiceFulfillment__c sf = [SELECT Id,Status__c FROM ServiceFulfillment__c LIMIT 1];
        List<ServiceFulfillment__c> seriviceFulfillments = selector.getServiceFulfillmentsByStatus(sf.Status__c);
        Assert.areEqual(1, seriviceFulfillments.size(), 'Returns one record by status');
    }

    @isTest 
    private static void testGetServiceFulfillmentsWithProcessInstanceByStatus() {
        SEL_ServiceFulfillment selector = new SEL_ServiceFulfillment();
        ServiceFulfillment__c sf = [SELECT Id,Status__c FROM ServiceFulfillment__c LIMIT 1];
        List<ServiceFulfillment__c> seriviceFulfillments = selector.getServiceFulfillmentsWithProcessInstanceByStatus(sf.Status__c);
        Assert.areEqual(seriviceFulfillments.size(), seriviceFulfillments.size(), 'Returns one record with process instance by status');
    }

    @isTest 
    private static void testGetServiceFulfillmentsWithHistoriesById() {
        SEL_ServiceFulfillment selector = new SEL_ServiceFulfillment();
        ServiceFulfillment__c sf = [SELECT Id,Status__c FROM ServiceFulfillment__c LIMIT 1];
        List<ServiceFulfillment__c> seriviceFulfillments = selector.getServiceFulfillmentsWithHistoriesById(new Set<Id>{sf.Id});
        Assert.areEqual(seriviceFulfillments.size(), seriviceFulfillments.size(), 'Returns one record with histories by Id');
    }
    
    @isTest 
    private static void testGetServiceFulfillmentsWithProcessInstanceAndSteps() {
        SEL_ServiceFulfillment selector = new SEL_ServiceFulfillment();
        ServiceFulfillment__c sf = [SELECT Id,Status__c FROM ServiceFulfillment__c LIMIT 1];
		Set<Id> resultIds = new Set<Id>{sf.Id};
        List<ServiceFulfillment__c> seriviceFulfillments = selector.getServiceFulfillmentsWithProcessInstanceAndSteps(resultIds);
        Assert.areEqual(seriviceFulfillments.size(), seriviceFulfillments.size(), 'Returns one record with process instance and steps');
    }
}