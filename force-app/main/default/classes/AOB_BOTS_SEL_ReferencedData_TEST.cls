/**
 * @description       : Test Class for AOB_BOTS_SEL_ReferencedData
 * @author            : Narendra Teja
* @last modified on  : 13-09-2024
 * @last modified by  : Narendra Teja
**/

@IsTest
public with sharing class AOB_BOTS_SEL_ReferencedData_TEST {

    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        list<Sobject> listRefData = new list<Sobject>();
        
        AOB_ReferencedData__c refData = new AOB_ReferencedData__c(Name='Yes', 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c='PER_CLASSIF', 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c='AOB_SAPField__c', 
                                                                  AOB_Language__c = 'en_US');
        
        AOB_ReferencedData__c refData2 = new AOB_ReferencedData__c(name='No', 
                                                                   AOB_Default__c=true, 
                                                                   AOB_SAPField__c='PER_CLASSIF', 
                                                                   AOB_isActive__c=true, 
                                                                   AOB_Code__c='AOB_SAPField__c', 
                                                                   AOB_Language__c = 'en_US');    
                Application__c apps = new Application__c();


        listRefData.add(apps);
        
        listRefData.add(refData);
        listRefData.add(refData2);
        insert listRefData;
    }
   
    /**
    * @description Test method for BOTS SEL.ReferencedData.getSObjectFieldList
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        AOB_BOTS_SEL_ReferencedData app = new AOB_BOTS_SEL_ReferencedData();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * @description Test method for BOTS SEL.ReferencedData.getSObjectType
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        Test.startTest();
        AOB_BOTS_SEL_ReferencedData app = new AOB_BOTS_SEL_ReferencedData();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(AOB_ReferencedData__c.sObjectType,typ,'checking the ReferencedData with type of object');
    }
    
    
    /**
    * @description Test method for BOTS SEL.ReferencedData.getReferencedDataName
    */
    @IsTest
    private static void getReferencedDataNameTest(){
        AOB_ReferencedData__c refData = [Select Id, AOB_SAPField__c,AOB_Code__c,Name from AOB_ReferencedData__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_ReferencedData app = new AOB_BOTS_SEL_ReferencedData();
            List<AOB_ReferencedData__c> lst = app.getReferencedDataName(refData.AOB_SAPField__c, refData.AOB_Code__c);
            Test.stopTest();
        Assert.areNotEqual(refData.id,lst[0].id,'Checking if the ReferencedData Id is not equal to any of the ReferenceData Ids in the list.');
    }
   
    /**
     * @description Test method for BOTS SEL.ReferencedData.getReferencedDataBySapField
     */
    @IsTest
    private static void getReferencedDataBySapFieldTest(){
         Test.startTest();
         AOB_ReferencedData__c refData = [Select Id, AOB_SAPField__c,AOB_Code__c,Name from AOB_ReferencedData__c Limit 1 ];
         List<AOB_ReferencedData__c> listData=new AOB_BOTS_SEL_ReferencedData().getReferencedDataBySapField(refData.AOB_SAPField__c,refData.AOB_Code__c,true);
         Test.stopTest();
         Assert.areEqual(listData[0].AOB_SAPField__c,'PER_CLASSIF','Check the AOB_SAPField__c field with the list of reference data');
    }
    
    /**
     * @description Test method for BOTS SEL.ReferencedData.getReferencedDataByCode
     */
    @IsTest
    private static void getReferencedDataByCodeTest(){
        Test.startTest();
        AOB_ReferencedData__c listData=new AOB_BOTS_SEL_ReferencedData().getReferencedDataByCode('AOB_SAPField__c');
        Test.stopTest();
        Assert.areEqual(listData.AOB_SAPField__c,'PER_CLASSIF','Check the AOB_SAPField__c field with the list of reference data');
    }
    
    
}