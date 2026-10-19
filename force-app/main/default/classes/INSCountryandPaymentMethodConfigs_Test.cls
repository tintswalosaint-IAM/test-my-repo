/**
 * @description  test class for INSCountryandPaymentMethodConfigs_Test
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date August 27th 2024
 */
@isTest
public class INSCountryandPaymentMethodConfigs_Test {
    /**
 * @description  method for testGetSObjectType
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date August 27th 2024
 */
    @isTest
    static void testGetSObjectType() {
        SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        Schema.SObjectType sObjectType = metadataSelector.getSObjectType();
        
        Assert.areEqual(INS_Country_and_Payment_Method_Configs__mdt.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
 * @description  method for testGetSObjectFieldList
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date August 27th 2024
 */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        List<Schema.SObjectField> sObjectFieldList = metadataSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = INS_Country_and_Payment_Method_Configs__mdt.SObjectType.getDescribe().fields.getMap();
         Assert.areEqual(true, sObjectFieldList.size()>0, 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    
    /**
 * @description  method for testSelectByCountryAndProductId
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date August 27th 2024
 */
    @isTest
    static void testSelectByCountryAndProductId(){
    	SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        List<INS_Country_and_Payment_Method_Configs__mdt> mdtRecords = metadataSelector.selectByCountryAndProductId('UG', '7e919532-3c62-4013-aada-c5931c495de3');
        Assert.areEqual(1, mdtRecords.size(), 'records present');
    }

}