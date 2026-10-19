/**
 * @description SFP-32986 Class used as test class for ICS_CTRL_ViewCRAData
 * @author Ikyatha Naidu
 * @date 22/04/2024
 ***************************************************** 
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: Initital Version
 */
@IsTest
private class ICS_CTRL_ViewCRAData_Test {
    
    @TestSetup
    static void makeData(){
        // Create test data
        PartyProfileRisk testRisk = new PartyProfileRisk(Name='test',
            Full_CRA_Result__c = '{"test": "data"}'
        );
        insert testRisk;
    }
   
    @IsTest
    static void testGetJSONString() {
        // Get the test PartyProfileRisk record
        PartyProfileRisk testRisk = [SELECT Id FROM PartyProfileRisk LIMIT 1];
        
        Test.startTest();
        String result = ICS_CTRL_ViewCRAData.getJSONString(testRisk.Id);
        Test.stopTest();
        
        // Verify the result
        Assert.isNotNull(result, 'OrEqual: Expected non-null result');
        Assert.areEqual('{"test": "data"}', result, 'OrEqual: Expected unescaped JSON string');
    }
    
   
    
    
     @IsTest
    static void testEmptyFullCRAResult() {
        // Get the test PartyProfileRisk record
        PartyProfileRisk testRisk = [SELECT Id FROM PartyProfileRisk LIMIT 1];
        testRisk.Full_CRA_Result__c='';
        
        update testRisk;
        Test.startTest();
        String result = ICS_CTRL_ViewCRAData.getJSONString(testRisk.Id);
        Test.stopTest();
        
        // Verify the result
        Assert.isNotNull(result, 'OrEqual: Expected non-null result');
        Assert.areEqual('{}', result, 'OrEqual: Expected empty JSON Object');
    }
     @IsTest
    static void testnullRecordID() {
        try{
        Test.startTest();
        ICS_CTRL_ViewCRAData.getJSONString('');
        Test.stopTest();
        }catch(exception ex){
        // Verify the result
        	Assert.areEqual(true, ex.getmessage() != null, 'OrEqual: Expected an exception as blank recordId');
        
        }
    }
}