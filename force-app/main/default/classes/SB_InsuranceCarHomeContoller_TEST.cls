/**
* @description Test class
* @author Alexandr Goryachko
* @date 2024/08/16
*/
@isTest
public class SB_InsuranceCarHomeContoller_TEST {
    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;
        
        Lead lead = WI_DAL_DataFactory.createLead(
            new Map<String, Object>{
                Schema.Lead.ID_Number__c.getDescribe().getName() => '4410285050180',
                    Schema.Lead.FinServ__RelatedAccount__c.getDescribe().getName() => acc.Id,
                    Schema.Lead.IsConverted.getDescribe().getName() => false,
                    Schema.Lead.RecordTypeId.getDescribe().getName() =>Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId()
                    }
        );
        insert lead;
        
        Lead lead2 = WI_DAL_DataFactory.createLead(
            new Map<String, Object>{
                Schema.Lead.ID_Number__c.getDescribe().getName() => '450545678',
                    Schema.Lead.IsConverted.getDescribe().getName() => false,
                    Schema.Lead.Description.getDescribe().getName() => 'Car and home',
                    Schema.Lead.RecordTypeId.getDescribe().getName() =>Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId()
                    }
        );
        insert lead2;
        
        //Connverted Lead
        Lead convertedLead = WI_DAL_DataFactory.createLead(
            new Map<String, Object>{
                Schema.Lead.ID_Number__c.getDescribe().getName() => '450545678',
                    Schema.Lead.FinServ__RelatedAccount__c.getDescribe().getName() => acc.Id,
                    Schema.Lead.IsConverted.getDescribe().getName() => true,
                    Schema.Lead.ConvertedAccountId.getDescribe().getName() =>acc.Id,
                    Schema.Lead.Description.getDescribe().getName() => 'Car and home',
                    Schema.Lead.RecordTypeId.getDescribe().getName() =>Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId()
                    }
        );
        insert convertedLead;
        
        
        PartyProfile ppAcc = WI_DAL_DataFactory.createPartyProfile(null, acc.Id, null);
        insert ppAcc;
        
        // Create PartyProfile for Lead
        PartyProfile ppLead = WI_DAL_DataFactory.createPartyProfile(null, null, lead.Id);
        insert ppLead;
        
        SB_InsuranceCarHomeHelper.createOpportunityLead(lead,UserInfo.getUserId(),'Car and Home Omniscript');
        
    }
    
    /**
* @description To check positive retrieve data for Lead Id
*/
    @isTest
    private static void convertLeadUseLeadId() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        
        String methodName = 'convertLead';
        Map<String, Object> inputMap = new Map<String, Object>{
            'recordId' => lead.Id
                };
                    Map<String, Object> options = new Map<String, Object>{};
                        Map<String, Object> outMap = new Map<String, Object>();
        
        Test.startTest();
        SB_InsuranceCarHomeContoller ctrl = new SB_InsuranceCarHomeContoller();
        Boolean result = ctrl.invokeMethod(methodName, inputMap, outMap, options);
        
        Assert.isTrue(result, 'Error in the convertLead method');
        Test.stopTest();
    }
    
    /**
* @description To check positive retrieve data for Account Id
*/
    @isTest
    private static void convertLeadUseAccountId() {
        Lead lead = [SELECT Id, FinServ__RelatedAccount__c FROM Lead LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        lead.FinServ__RelatedAccount__c = acc.Id;
        update lead;
        
        String methodName = 'convertLead';
        Map<String, Object> inputMap = new Map<String, Object>{
            'recordId' => acc.Id
                };
                    Map<String, Object> options = new Map<String, Object>{};
                        Map<String, Object> outMap = new Map<String, Object>();
        
        Test.startTest();
        SB_InsuranceCarHomeContoller ctrl = new SB_InsuranceCarHomeContoller();
        Boolean result = ctrl.invokeMethod(methodName, inputMap, outMap, options);
        
        Assert.isTrue(result, 'Error in the convertLead method');
        Test.stopTest();
    }
        
    /**
* @description Verify the checkOpportunity  with Lead, referrerId, leadSource
*/
    @isTest
    private static void testcheckOpportunity(){
        Lead lead = [SELECT Id, Title,
                     AOB_Date_of_Birth__c,
                     MobilePhone,
                     LastName,
                     FirstName,
                     ID_Number__c,
                     GenderIdentity,
                     Marital_Status__c,
                     Street,
                     City, 
                     State, 
                     PostalCode, 
                     Country, 
                     FinServ__RelatedAccount__c,
                     CurrencyIsoCode,
                     FinServ__ReferredByUser__c FROM Lead WHERE Status = 'New' LIMIT 1];
        String leadSource='Car and Home Omniscript';
        String referrerId= userInfo.getUserId();
        Test.startTest();
        String OppId =SB_InsuranceCarHomeContoller.checkOpportunity(lead,referrerId,leadSource);
        Opportunity opp= [Select Id From Opportunity WHERE Id=:OppId lIMIT 1];
        Assert.areEqual(OppId,opp.Id,'Returned Opportunity should match queried opportunity');
        Test.stopTest();
    }
    
    /**
* @description Verify the convertLead with a unconverted Lead Id
*/
    @isTest
    private static void testconvertLead(){
        list<Lead> myLead = [SELECT Id, 
                             FirstName, 
                             LastName, 
                             Email, 
                             MobilePhone, 
                             ID_Number__c, 
                             Description, 
                             CurrencyIsoCode, 
                             FinServ__RelatedAccount__c
                             From Lead 
                             WHERE ID_Number__c = '450545678'
                             LIMIT 1];
        
        Map<String, Object> inputMap = new Map<String, Object>{};
            Map<String, Object> outMap = new Map<String, Object>();
        
        Test.startTest();
        Map<String, Object> isLeadContext = SB_InsuranceCarHomeContoller.convertLead(myLead[0].Id,inputMap,outMap);
        Id accId= (Id)isLeadContext.get('AccountRecId');
        Id oppId= (Id)isLeadContext.get('OpportunityRecId');
        Id createdAccount =[SELECT Id from Account WHERE Id=:accId LIMIT 1].Id; 
        Id createdOpp=[SELECT Id From Opportunity WHERE Id=:oppId LIMIT 1].Id;
        Assert.areEqual(accId,createdAccount, 'Account was not created');
        Assert.areEqual(oppId,createdOpp, 'opportunity was not created');
        Test.stopTest();
    }
    /**
* @description Verify the convertLead  with a converted Lead Id
*/
    @isTest
    private static void testconvertLead2(){
        Lead myLead = [SELECT Id From Lead WHERE IsConverted = true LIMIT 1];
        Map<String, Object> inputMap = new Map<String, Object>{};
            Map<String, Object> outMap = new Map<String, Object>();
        Test.startTest();
        Map<String, Object> isLeadContext = SB_InsuranceCarHomeContoller.convertLead(myLead.Id,inputMap,outMap);  
        Id accId= (Id)isLeadContext.get('AccountRecId');
        Id createdAccount =[SELECT Id from Account WHERE Id=:accId LIMIT 1].Id; 
        Assert.areEqual(accId,createdAccount, 'Account was not created');
        Test.stopTest();
    }
    
    
}