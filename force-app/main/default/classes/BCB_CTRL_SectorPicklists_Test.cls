/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :August 2023
@ Name of the Class :BCB_CTRL_SectorPicklists_Test
@description       :Test Class for BCB_CTRL_SectorPicklists to cover the main class methods.
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :06-08-2023
@ Modification Description : SFP-
***************************************************************************************/
@isTest
public class BCB_CTRL_SectorPicklists_Test {
    @isTest
    public static void fetchTertiorySectorCodes_Test(){
      list<AOB_ReferencedData__c> referencedData =  BCB_DAL_TestFactory.createRefData();
        Test.startTest();
        	List<AOB_ReferencedData__c> refData = BCB_CTRL_SectorPicklists.fetchTertiorySectorCodes('k662');
    
        Assert.areNotEqual(null, refData);
        Test.stopTest();
    }
}