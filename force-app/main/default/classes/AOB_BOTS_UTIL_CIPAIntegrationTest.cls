/**
* @description Test class for AOB_BOTS_UTIL_CIPAIntegration
* @author dayakar
* @date Jan 25th 2023 
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/

@isTest
public class AOB_BOTS_UTIL_CIPAIntegrationTest {
    
    /**
    * @description Test method for AOB_BOTS_UTIL_CIPAIntegration.makeCallout
    */
    
    @isTest
    static void makeCalloutTest() {
        
        Application__c app=AOB_BOTS_DAL_TestFactory.createTest();
        Test.startTest();
        Map<String, String> result = AOB_BOTS_UTIL_CIPAIntegration.makeCallout(app.Id);
        Test.stopTest();
    }
    
    /**
    * @description Test method for AOB_BOTS_UTIL_CIPAIntegration.validate
    */
    
    @isTest
    static void validateCompanyStatusCancelledTest() {
        AOB_BOTS_UTIL_CIPAIntegration.mockCompanyStatus='cancelled';
        Application__c app=AOB_BOTS_DAL_TestFactory.createTest();        
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (currentUser) {
            Group g1 = new Group(Name='AOB_Bots_BCC_ACQ', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
        } 
        Map<String, Object> response = new Map<String, Object>();
        response.put('CompanyUIN', 'BW00001881348');
        Map<String, Object> domTree = new Map<String, Object>();
        List<Map<String, Object>> directors = new List<Map<String, Object>>();
        Map<String, Object> dirRec = new Map<String, Object>();
        List<Map<String, Object>> names = new List<Map<String, Object>>();
        Map<String, Object> nameRec = new Map<String, Object>();
        nameRec.put('attributes', new Map<String, Object>{'FullName' => 'test test'});
        names.add(nameRec);
        dirRec.put('names', names);
        directors.add(dirRec);
        domTree.put('directors', directors);
        Map<String, Object> attributes = new Map<String, Object>{'Status' => 'cancelled'};
       
        domTree.put('attributes', attributes);
        response.put('domainTree', domTree);
        Test.startTest();
        Map<String, String> result = AOB_BOTS_UTIL_CIPAIntegration.validate(response, app.Id);
        Test.stopTest();
        Assert.areEqual('cancelled', result.get('status'),'Test Meassage');
        
    }
    
    /**
    * @description Test method for AOB_BOTS_UTIL_CIPAIntegration.validate
    */
    
    @isTest
    static void testValidateRemoved() {
        AOB_BOTS_UTIL_CIPAIntegration.mockCompanyStatus='removed';
        Application__c app=AOB_BOTS_DAL_TestFactory.createTest();
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Group g1 = new Group(Name='AOB_Bots_BCC_ACQ', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
           
        }
        Map<String, Object> response = new Map<String, Object>();
        response.put('CompanyUIN', 'BW00001881348');
        Map<String, Object> domTree = new Map<String, Object>();
        List<Map<String, Object>> directors = new List<Map<String, Object>>();
        Map<String, Object> dirRec = new Map<String, Object>();
        List<Map<String, Object>> names = new List<Map<String, Object>>();
        Map<String, Object> nameRec = new Map<String, Object>();
        nameRec.put('attributes', new Map<String, Object>{'FullName' => 'test test'});
        names.add(nameRec);
        dirRec.put('names', names);
        directors.add(dirRec);
        domTree.put('directors', directors);
        Map<String, Object> attributes = new Map<String, Object>{'Status' => 'removed'};
        domTree.put('attributes', attributes);
        response.put('domainTree', domTree);
        Test.startTest();
        Map<String, String> result = AOB_BOTS_UTIL_CIPAIntegration.validate(response, app.Id);
        Test.stopTest();
        Assert.areEqual('removed', result.get('status'),'Test Meassage');
    }
     /**
    * @description Test method for AOB_BOTS_UTIL_CIPAIntegration.validate
    */
    
    @isTest
    static void testValidateRegistered() {
        AOB_BOTS_UTIL_CIPAIntegration.mockCompanyStatus='registered';
        Application__c app=AOB_BOTS_DAL_TestFactory.createTest();
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            Group g1 = new Group(Name='AOB_Bots_BCC_ACQ', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Lead');
            insert q1;
          
        }
        Map<String, Object> response = new Map<String, Object>();
        response.put('CompanyUIN', 'BW00001881348');
        Map<String, Object> domTree = new Map<String, Object>();
        List<Map<String, Object>> directors = new List<Map<String, Object>>();
        Map<String, Object> dirRec = new Map<String, Object>();
        List<Map<String, Object>> names = new List<Map<String, Object>>();
        Map<String, Object> nameRec = new Map<String, Object>();
        nameRec.put('attributes', new Map<String, Object>{'FullName' => 'test test'});
        names.add(nameRec);
        dirRec.put('names', names);
        directors.add(dirRec);
        domTree.put('directors', directors);
        Map<String, Object> attributes = new Map<String, Object>{'Status' => 'registered'};
        domTree.put('attributes', attributes);
        response.put('domainTree', domTree);
        Test.startTest();
        Map<String, String> result = AOB_BOTS_UTIL_CIPAIntegration.validate(response, app.Id);
        Test.stopTest();
        Assert.areEqual('registered', result.get('status'),'Test Meassage');
    }
}