/**
* @author Gomolemo Mpyana
* @description Test class 
* @date 2024/10/31
*/
@isTest
public class SB_InsuranceCarHomeHelperTest {
    
    @TestSetup
    private static void setup(){
        
        // Create a test User
        User testUser = WI_DAL_DataFactory.createUser('SVC Agent Banker');
        insert testUser;
        
        // create account
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;
        
        //create lead
        Lead newLead = WI_DAL_DataFactory.createLead(
            new Map<String, Object>{
                Schema.Lead.ID_Number__c.getDescribe().getName() => '4410285050180',
                    Schema.Lead.FinServ__RelatedAccount__c.getDescribe().getName() => acc.Id,
                    Schema.Lead.IsConverted.getDescribe().getName() => false,
                    Schema.Lead.RecordTypeId.getDescribe().getName() =>Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId()
                    }
        );
        insert newLead; 
        
    }
    
    /**
* @description Verify CreateAccount
*/ 
    @isTest
    static void testCreateAccount(){
        Lead testLead=[SELECT Id, Title,AOB_Date_of_Birth__c,MobilePhone,LastName, FirstName,ID_Number__c,GenderIdentity, Marital_Status__c,Street,City, State, PostalCode, Country FROM Lead WHERE Status='New' LIMIT 1];
        String accountId = SB_InsuranceCarHomeHelper.createAccount(testLead, new Map<String, Object>());
        Assert.areNotEqual(null,accountId,'Account creation failed'); 
    }
    
    /**
* @description Verify GetLead
*/    
    @isTest
    Static void testGetLead(){
        Lead testLead = [SELECT Id FROM Lead WHERE Status = 'New' LIMIT 1];
        Lead retrievedLead = new SEL_Lead().selectById(testLead.Id);
        Assert.areNotEqual(null, retrievedLead, 'Retrieved lead should not be null');
        Assert.areEqual(testLead.Id, retrievedLead.Id, 'Retrieved lead ID does not match the original lead ID');
    }
    
    /**
* @description Verify the ConvertLead with a qualified Lead
*/   
    @isTest
    static void testConvertLead(){
        Lead testLead=[SELECT Id, Title,AOB_Date_of_Birth__c,MobilePhone,LastName, FirstName,ID_Number__c,GenderIdentity, Marital_Status__c,Street,City, State, PostalCode, Country FROM Lead WHERE Status='New' LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        testLead.FinServ__RelatedAccount__c = acc.Id;
        update testLead;
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(testLead.Id);
        leadConvert.setAccountId(acc.Id);
        leadConvert.setDoNotCreateOpportunity(false); 
        leadConvert.setConvertedStatus('Qualified');         
        Database.LeadConvertResult conversionResult = SB_InsuranceCarHomeHelper.convertLead(leadConvert);
        Assert.isTrue(conversionResult.isSuccess(), 'Lead was not converted successfully');
    }
    
    /**
* @description Verify the createOpportunity with Lead
*/
    @isTest
    static void testcreateOpportunity(){
        Lead testLead = [SELECT Id, Title,AOB_Date_of_Birth__c,MobilePhone,LastName, FirstName,ID_Number__c,GenderIdentity, Marital_Status__c,Street,City, State, PostalCode, Country, FinServ__RelatedAccount__c, CurrencyIsoCode FROM Lead WHERE Status='New' LIMIT 1];
        Account acc = [SELECT Id,FirstName,LastName,CurrencyIsoCode FROM Account LIMIT 1];
        testLead.FinServ__RelatedAccount__c = acc.Id;
        update testLead;
        String leadsource='Car and Home Omniscript';
        
        string opportunityId = SB_InsuranceCarHomeHelper.createOpportunityLead(testLead, null, leadsource);
        Map<String, Object> outMap = SB_InsuranceCarHomeHelper.createOpportunityFromAccount(acc.Id,new Map<String, Object>());
        
        string opportunityAccountId = SB_InsuranceCarHomeHelper.createOpportunityAccount(acc);
        
        Assert.isNotNull(outMap);
        Assert.areNotEqual(opportunityId, null, 'opportunity was not returned');
        Assert.areNotEqual(opportunityAccountId, null, 'opportunity was not created from Account');
    }
    
    /**
* @description Verify the createApplicationForm with AccountId, LeadId and OpportunityId
*/
    @IsTest
    static void testcreateApplicationForm(){
        Lead testLead = [SELECT Id, Title,
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
        Account acc = [SELECT Id FROM Account LIMIT 1];
        testLead.FinServ__RelatedAccount__c = acc.Id;
        update testLead;
        string oppId = SB_InsuranceCarHomeHelper.createOpportunityLead(testLead, null, 'Car and Home Omniscript');
        SB_InsuranceCarHomeHelper.createApplicationForm(acc.Id, testLead.Id, oppId);
        List<ApplicationForm> applicationForm = [Select Id from ApplicationForm Limit 1];
        Assert.areNotEqual(0,applicationForm.size(),'Application Form was not created succesfully');
    }
}