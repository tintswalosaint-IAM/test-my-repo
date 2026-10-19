/**
 * @description  selctor class for INS_Country_and_Payment_Method_Configs__mdt SEL_INSCountryandPaymentMethodConfigs.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param
 * @return
 * @date August 27th 2024
 * 
 * @description : Add inherited sharing declaration as per AppOmni finding
 * @story       : SFP-60091
 * @modified    : Jaco de Lange
 * @date        : 16 September 2026
 */
public inherited sharing class SEL_INSCountryandPaymentMethodConfigs extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{'Id','Select_Account__c','Branch_Code__c','Branch_Name__c','isPaymentMethodDisable__c','Payment_Methods__c','Company_Name__c','isBranchListRequired__c','User_Country__c','Bank_Name__c','Default_Payment_Method__c','Default_Account__c','Country_Full_Name__c'};
        
          /**
 * @description  getSObjectType.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param
 * @return INS_Country_and_Payment_Method_Configs__mdt
 * @date August 27th 2024
 */
        public override Schema.SObjectType getSObjectType() {
            return INS_Country_and_Payment_Method_Configs__mdt.sObjectType;
        }
    
    /**
 * @description  method to return values getSObjectFieldList.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param
 * @return List<Schema.SObjectField>
 * @date August 27th 2024
 */
    
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            	INS_Country_and_Payment_Method_Configs__mdt.Id, 
                INS_Country_and_Payment_Method_Configs__mdt.Select_Account__c,
                INS_Country_and_Payment_Method_Configs__mdt.Branch_Code__c,
                INS_Country_and_Payment_Method_Configs__mdt.Branch_Name__c,
                INS_Country_and_Payment_Method_Configs__mdt.isPaymentMethodDisable__c,
                INS_Country_and_Payment_Method_Configs__mdt.Payment_Methods__c,
                INS_Country_and_Payment_Method_Configs__mdt.Company_Name__c,
                INS_Country_and_Payment_Method_Configs__mdt.isBranchListRequired__c,
                INS_Country_and_Payment_Method_Configs__mdt.User_Country__c,
                INS_Country_and_Payment_Method_Configs__mdt.Bank_Name__c,
                INS_Country_and_Payment_Method_Configs__mdt.Default_Payment_Method__c,
                INS_Country_and_Payment_Method_Configs__mdt.Default_Account__c,
                INS_Country_and_Payment_Method_Configs__mdt.Country_Full_Name__c
        };
    }
    
    /**
 * @description  queryRecords.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param country, productId
 * @return List<INS_Country_and_Payment_Method_Configs__mdt>
 * @date August 27th 2024
 */
    public List<INS_Country_and_Payment_Method_Configs__mdt> selectByCountryAndProductId(String country,String productId) {
        
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('User_Country__c = :country and Product_Id__c=:productId' );
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }    
}