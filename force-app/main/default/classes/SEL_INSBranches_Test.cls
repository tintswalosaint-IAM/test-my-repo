/**
 * @description  test class SEL_INSBranches_Test for SEL_INSBranches.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param.
 * @return.
 * @date Nov 28th 2024
 */
@isTest
public class SEL_INSBranches_Test {
    
        /**
     * @description  method testGetSObjectType for GetSObjectType.
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param.
     * @return.
     * @date Nov 28th 2024
     */
	@isTest
    static void testGetSObjectType() {
        SEL_INSBranches metadataSelector = new SEL_INSBranches();
        Schema.SObjectType sObjectType = metadataSelector.getSObjectType();
        
        Assert.areEqual(INS_Branches__mdt.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
     * @description  method testGetSObjectFieldList for GetSObjectFieldList.
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param.
     * @return.
     * @date Nov 28th 2024
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_INSBranches metadataSelector = new SEL_INSBranches();
        List<Schema.SObjectField> sObjectFieldList = metadataSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = INS_Branches__mdt.SObjectType.getDescribe().fields.getMap();
         Assert.areEqual(true, sObjectFieldList.size()>0, 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    
    /**
     * @description  method testSelectByCountry for selectByCountry.
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param.
     * @return.
     * @date Nov 28th 2024
     */
    @isTest
    static void testSelectByCountry(){
    	SEL_INSBranches metadataSelector = new SEL_INSBranches();
        List<INS_Branches__mdt> mdtRecords = metadataSelector.selectByCountry('UG');
        Assert.areEqual(true, mdtRecords.size()>0, 'Records present');
    }
}