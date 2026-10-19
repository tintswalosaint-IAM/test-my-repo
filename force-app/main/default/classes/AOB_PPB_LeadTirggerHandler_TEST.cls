/********************************************************************************************
* @Date              : 03-06-2025
* @Name              : AOB_PPB_LeadTirggerHandler_TEST
* @author            : Narendra Gorrela
* @Description       : This test class verifies the correct behavior of the lead status update logic handled in AOB_PPB_LeadTirggerHandler.
*
********************************************************************************************/
@isTest
private class AOB_PPB_LeadTirggerHandler_TEST {
    
    /**
* Inserts a test Lead with 'New' status.
*/
    @testSetup
    static void setupData() {
        // Insert a Lead with initial 'New' status
        Lead oldlead = AOB_TestDataFactory.createLead();
        insert oldlead;
    }
    
    /**
* Tests status updates: 'New' → 'Working' → 'Qualified'.
* Verifies time fields and status updates.
*/
    @isTest
    static void testWorkingStatusUpdate() {
        Lead oldLead = [SELECT Status, Completed_Date__c, AOB_Status__c, New_Duration_Hours__c, Working_Start_Date__c, Working_Duration_Hours__c 
                        FROM Lead WHERE LastName =: 'testLead'];
        
        //Start Executing Test
        Test.startTest();
        oldlead.Status = 'Working';
        oldlead.Working_Start_Date__c = System.now().addHours(-3); // 3 hours ago
        update oldlead;
        Test.stopTest();
        
        oldlead.Status = 'Waiting for Customer';
        update oldlead;
        
        oldlead.Status = 'Qualified';
        update oldlead;
        
        // Fetch updated Lead to validate results
        Lead updatedLead = [SELECT Status, Completed_Date__c, AOB_Status__c, Working_Start_Date__c, New_Duration_Hours__c, Working_Duration_Hours__c 
                            FROM Lead WHERE LastName =: 'testLead'];
        
        // Assertions
        Assert.areEqual('Qualified', updatedLead.Status, 'Status should be Working');
        Assert.areEqual('Closed', updatedLead.AOB_Status__c, 'AOB_Status__c should be Closed');
         Assert.areNotEqual(null, updatedLead.Completed_Date__c, 'Completed_Date__c should be set');
         Assert.areNotEqual(null, updatedLead.Working_Start_Date__c, 'Working_Start_Date__c should be set');
    }
}