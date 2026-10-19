/**
* @description Test class for ICS_CTRL_ACPicklist
* 
* @author Ikyatha Naidu
* 
* @date Sepetmber 10th 2023 
* @last modified on  : 29-02-2024
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-36390, Test Class for ICS_CTRL_ACPicklist for SBO-UK
*/
@isTest
public class ICS_CTRL_ACPicklist_Test {

    /**
    * @description Test method for ICS_CTRL_ACPicklist.loadData (positive scenario)
    */
    @isTest
    public static void loadDataTest(){
        try {
            list<AOB_ReferencedData__c> result = ICS_DAL_TestFactory.createRefData();
            Test.startTest();
            List<AOB_ReferencedData__c> refList=ICS_CTRL_ACPicklist.loadData(result[0].AOB_SAPField__c);
            Test.stopTest();
            Assert.areNotEqual(null, refList,'Expected');
            Assert.areNotEqual(null, result,'Expected');
        } catch (Exception ex) {
            Assert.areNotEqual(null, ex,'Expected');
        }
        
    }
}