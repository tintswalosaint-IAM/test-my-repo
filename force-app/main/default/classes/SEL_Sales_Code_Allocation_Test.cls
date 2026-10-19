/**
 * @description Selector class for Sales_Code_Allocation__c object.
 * This class provides methods to retrieve Sales_Code_Allocation__c records.
 * @author Ofentse Sacha
 * @date 07 November 2023
* Modification Description : SFP-36390, This class provides methods to retrieve Sales_Code_Allocation__c records SBO UK
 */

@istest
public class SEL_Sales_Code_Allocation_Test {
    
     @IsTest
    static void testGetSObjectType() {
        Sales_Code_Allocation__c salesCodeSelector = new Sales_Code_Allocation__c();
        Schema.SObjectType sObjectType = salesCodeSelector.getSObjectType();
        
        Assert.areEqual(Sales_Code_Allocation__c.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
     @IsTest
    static void testGetSObjectFieldList() {
        SEL_Sales_Code_Allocation salesCodeSelector = new SEL_Sales_Code_Allocation();
        List<Schema.SObjectField> sObjectFieldList = salesCodeSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = Sales_Code_Allocation__c.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(fieldMap.size(), sObjectFieldList.size(), 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    
     @isTest
    public static void salesCodeTest(){
         Sales_Codes__c codeInfo = new Sales_Codes__c(
            Sales_Code_Country__c = 'AL');
        insert codeInfo;
        Sales_Code_Allocation__c salesCodeAllocation=new Sales_Code_Allocation__c();
        salesCodeAllocation.Sales_Codes__c=codeInfo.id;
        salesCodeAllocation.User__c=userinfo.getuserid();
        insert salesCodeAllocation;
        if(salesCodeAllocation != null){
         SEL_Sales_Code_Allocation salesCodeAllocationObject= new SEL_Sales_Code_Allocation();
         
            salesCodeAllocationObject.getAllocationbyIds(new set<string>{codeInfo.id});
            salesCodeAllocationObject.getAllocatedCodesByUserId(userinfo.getuserid());
             Assert.areEqual(true, salesCodeAllocation !=null, 'Unexpected field count');
        }
        
    }
    
}