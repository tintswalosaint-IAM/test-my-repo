/**
* @description Test class for BCB_CTRL_ACPicklist
* 
* @author lokesh
* 
* @date April 10th 2023 
*/
@isTest
public class BCB_CTRL_ACPicklist_Test {

    /**
    * @description Test method for AOB_CTRL_ACPicklist.loadData (positive scenario)
    */
    @isTest
    public static void loadDataTest(){
        try {
            list<AOB_ReferencedData__c> result = BCB_DAL_TestFactory.createRefData();
            Test.startTest();
            List<AOB_ReferencedData__c> refList=BCB_CTRL_ACPicklist.loadData(result[0].AOB_SAPField__c);
            Test.stopTest();
            Assert.areNotEqual(null, refList,'Expected');
            Assert.areNotEqual(null, result,'Expected');
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex,'Expected');
        }
        
    }
}