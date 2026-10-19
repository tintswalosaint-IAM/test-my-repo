@isTest
public with sharing class ICS_CTRL_FlowObjectFieldSet_Test {
    @TestSetup
    static void prepareMockupData() {
        Account account = new Account(Name = 'mockup');
        insert account;
        Application__c application = new Application__c(Account__c = account.id);
        insert application;
        Contact contact = new Contact(LastName = 'mockup');
        insert contact;
        ContactPointAddress address = new ContactPointAddress(Name = 'mockup', ParentId = account.Id);
        insert address;
    }

    @isTest
    static void getPicklistValuesTest() {
        Test.startTest();
        List<Map<String, Object>> result = ICS_CTRL_FlowObjectFieldSet.getPicklistValues('Account', 'Type');
        Test.stopTest();

        Assert.isTrue(result.size() > 0, 'Failed to get picklist values');
    }

    @isTest
    static void getFieldGroupTest() {
        Test.startTest();
        List<Map<String, Object>> result = ICS_CTRL_FlowObjectFieldSet.getFieldGroup('Account', 'other_business_interests');
        Test.stopTest();

        Assert.isTrue(result.size() > 0, 'Failed to get field group');
    }

    @isTest
    static void getFieldGroupExceptionTest() {
        Test.startTest();
        try {
            List<Map<String, Object>> result = ICS_CTRL_FlowObjectFieldSet.getFieldGroup('_Asdf', 'other_business_interests');
            Assert.isTrue(false, 'Methond should not work');
        } catch (Exception e) {
            Assert.isTrue(!String.isBlank(e.getMessage()), 'There should be an error message');
        }
        Test.stopTest();
    }

    @isTest
    static void getRecordTest() {
        ContactPointAddress testAddress = [SELECT Id, Name, ParentId FROM ContactPointAddress WHERE Name = 'mockup' LIMIT 1];
        Test.startTest();
        Sobject result = ICS_CTRL_FlowObjectFieldSet.getRecord('ContactPointAddress', testAddress.Id, 'Name,ParentId');
        Test.stopTest();

        Assert.areEqual(result.get('Id'), testAddress.Id, 'Failed to get record');
    }

    @isTest
    static void getRecordExceptionTest() {
        Test.startTest();
        try {
            Sobject result = ICS_CTRL_FlowObjectFieldSet.getRecord('_Asdf', 'asdf', 'Name,ParentId');
            Assert.isTrue(false, 'Methond should not work');
        } catch (Exception e) {
            Assert.isTrue(!String.isBlank(e.getMessage()), 'There should be an error message');
        }
        Test.stopTest();
    }

    @isTest
    static void createNewRecordTest() {
        Account account = [SELECT Id FROM Account WHERE Name = 'mockup' LIMIT 1];
        Test.startTest();
        Map<String, Object> result = ICS_CTRL_FlowObjectFieldSet.createNewRecord(
            'ContactPointAddress',
            'Record',
            account.Id,
            'ParentId',
            '',
            'AddressType',
            'Previous Residential'
        );
        Test.stopTest();
        Id id = (Id) result.get('Id');
        ContactPointAddress testAddress = [SELECT Id, ParentId FROM ContactPointAddress WHERE Id = :id];

        Assert.areEqual(testAddress.ParentId, account.Id, 'Failed to create record');
    }

    @isTest
    static void createNewRecordWithRecordTypeTest() {
        Account account = [SELECT Id FROM Account WHERE Name = 'mockup' LIMIT 1];
        Application__c application = [SELECT Id FROM Application__c WHERE Account__c = :account.id LIMIT 1];
        Schema.DescribeSObjectResult sobjectResult = Schema.getGlobalDescribe().get('Account').getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfo = sobjectResult.getRecordTypeInfos();
        Map<String,Id> mapofRecordTypeId = new Map<String,Id>();
        for(Schema.RecordTypeInfo info : recordTypeInfo){
            mapofRecordTypeId.put(info.getDeveloperName(),info.getRecordTypeId());
        }
        Id devRecordTypeId = mapofRecordTypeId.get('IndustriesBusiness');

        Test.startTest();
        Map<String, Object> result = ICS_CTRL_FlowObjectFieldSet.createNewRecord(
            'Account',
            'Record',
            application.Id,
            'Application_Other_Business_Interests__c',
            devRecordTypeId,
            '',
            ''
        );
        Test.stopTest();
        Id id = (Id) result.get('Id');
        Account testAccount = [SELECT Id, Application_Other_Business_Interests__c FROM Account WHERE Id = :id];

        Assert.areEqual(testAccount.Application_Other_Business_Interests__c, application.Id, 'Failed to create record');
    }

    @isTest
    static void removeRecordTest() {
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'mockup' LIMIT 1];
        Test.startTest();
        ICS_CTRL_FlowObjectFieldSet.removeRecord('Contact', contact.Id);
        Test.stopTest();

        Assert.areEqual(0, [SELECT Id FROM Contact WHERE LastName = 'mockup'].size(), 'Failed to remove record');
    }
}