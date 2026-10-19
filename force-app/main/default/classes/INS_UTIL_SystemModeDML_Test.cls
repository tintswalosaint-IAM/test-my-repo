/**
 * @description Test class for INS_UTIL_SystemModeDML
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-21
 **/
@isTest
private class INS_UTIL_SystemModeDML_Test {
    
    @isTest
    static void testDmlInsert() {
        INS_UTIL_SystemModeDML dml = new INS_UTIL_SystemModeDML();
        
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'Test1', Company = 'TestCo'),
            new Lead(LastName = 'Test2', Company = 'TestCo')
        };
        
        Test.startTest();
        dml.dmlInsert(leads);
        Test.stopTest();
        
        List<Lead> inserted = [SELECT Id FROM Lead WHERE LastName LIKE 'Test%'];
        Assert.areEqual(2, inserted.size(), 'Two leads should be inserted');
    }
    
    @isTest
    static void testDmlUpdate() {
        Lead lead = new Lead(LastName = 'TestUpdate', Company = 'TestCo');
        insert lead;
        
        lead.Company = 'UpdatedCo';
        
        Test.startTest();
        INS_UTIL_SystemModeDML dml = new INS_UTIL_SystemModeDML();
        dml.dmlUpdate(new List<Lead>{lead});
        Test.stopTest();
        
        Lead updated = [SELECT Company FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual('UpdatedCo', updated.Company, 'Company should be updated');
    }
    
    @isTest
    static void testDmlDelete() {
        Lead lead = new Lead(LastName = 'TestDelete', Company = 'TestCo');
        insert lead;
        
        Test.startTest();
        INS_UTIL_SystemModeDML dml = new INS_UTIL_SystemModeDML();
        dml.dmlDelete(new List<Lead>{lead});
        Test.stopTest();
        
        List<Lead> deleted = [SELECT Id FROM Lead WHERE Id = :lead.Id];
        Assert.areEqual(0, deleted.size(), 'Lead should be deleted');
    }
    
    @isTest
    static void testEmptyListHandling() {
        INS_UTIL_SystemModeDML dml = new INS_UTIL_SystemModeDML();
        
        Test.startTest();
        dml.dmlInsert(new List<Lead>());
        dml.dmlUpdate(new List<Lead>());
        dml.dmlDelete(new List<Lead>());
        dml.eventPublish(new List<SObject>());
        dml.emptyRecycleBin(new List<SObject>());
        Test.stopTest();
        
        Assert.isTrue(true, 'Empty lists should be handled gracefully');
    }
}