/**
 * @description selector class INSPremiumPayerPaymentMehodConfig_Test for SEL_INSPremiumPayerPaymentMehodConfig.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param.
 * @return.
 * @date August 28th 2024
 */
@isTest
public class INSPremiumPayerPaymentMehodConfig_Test {
    
    /**
 * @description selector class testGetSObjectType for GetSObjectType.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param.
 * @return.
 * @date August 28th 2024
 */
	@isTest
    static void testGetSObjectType() {
        SEL_INSPremiumPayerPaymentMehodConfig metadataSelector = new SEL_INSPremiumPayerPaymentMehodConfig();
        Schema.SObjectType sObjectType = metadataSelector.getSObjectType();
        
        Assert.areEqual(INS_PremiumPayerPaymentMehodConfig__mdt.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
     /**
 * @description selector class testGetSObjectFieldList for GetSObjectFieldList.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param.
 * @return.
 * @date August 28th 2024
 */
     @IsTest
    static void testGetSObjectFieldList() {
        SEL_INSPremiumPayerPaymentMehodConfig metadataSelector = new SEL_INSPremiumPayerPaymentMehodConfig();
        List<Schema.SObjectField> sObjectFieldList = metadataSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = INS_PremiumPayerPaymentMehodConfig__mdt.SObjectType.getDescribe().fields.getMap();
         Assert.areEqual(true, sObjectFieldList.size()>0, 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    
     /**
 * @description selector class testSelectByPaymentMethod for selectByPaymentMethod.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param.
 * @return.
 * @date August 28th 2024
 */
    @isTest
    static void testSelectByPaymentMethod(){
    	SEL_INSPremiumPayerPaymentMehodConfig metadataSelector = new SEL_INSPremiumPayerPaymentMehodConfig();
        List<INS_PremiumPayerPaymentMehodConfig__mdt> mdtRecords = metadataSelector.selectByPaymentMethod('Card Payment');
        Assert.areEqual(1, mdtRecords.size(), 'Records present');
    }

}