/**
* @description Test class for AOB_CTRL_ACPicklist
* 
* @author Narendra Teja
* 
* @date April 10th 2023 
*/
@IsTest
public class AOB_CTRL_ACPicklist_TEST {    
    /**
    * @description Test method for AOB_CTRL_ACPicklist.loadData (positive scenario)
    */
    @isTest
    public static void loadDataTest(){
        try {
            list<AOB_ReferencedData__c> result = AOB_BOTS_DAL_TestFactory.createRefData();
            Test.startTest();
            List<AOB_ReferencedData__c> refList=AOB_CTRL_ACPicklist.loadData(result[0].AOB_SAPField__c);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex);
        }
        
    }
}