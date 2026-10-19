/**
 * @description selector class for INS_PremiumPayerPaymentMehodConfig__mdt.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @date August 27th 2024
 * 
 * @description : Add inherited sharing declaration as per AppOmni finding
 * @story       : SFP-60091
 * @modified    : Jaco de Lange
 * @date        : 16 September 2026 
 */
public inherited sharing class SEL_INSPremiumPayerPaymentMehodConfig extends sbgplatform.fflib_SObjectSelector  {
	private static Set<String> fields = new Set<String>{'Id','AddressLineLength__c','Address_Type__c','CityLength__c','CountryLength__c','CountryZipCodeLength__c','isAddressDisable__c','isAddressRequired__c','isBankDetailsDisable__c','isBankDetailsRequired__c','isAccountNumberDisable__c','isAccountNumberRequired__c','isBankNameDisable__c','isBankNameRequired__c','isBranchNameDisable__c','isBranchNameRequired__c','isSelectAccountDisable__c','isSelectAccountRequired__c','isBranchCodeDisable__c','isBranchCodeRequired__c','isAddressLineDisable__c','isAddressLineRequired__c','isAddressTypeDisable__c','isAddressTypeRequired__c','isCityDisable__c','isCityRequired__c','isCountryDisable__c','isCountryRequired__c','isPostalCodeDisable__c','isPostalCodeRequired__c','Branch_Code__c','Branch_Name__c','isBranchListRequired__c','Default_Address_Type__c'};
        
        public override Schema.SObjectType getSObjectType() {
            return INS_PremiumPayerPaymentMehodConfig__mdt.sObjectType;
        }
    
    /**
 * @description selector class for getSObjectFieldList.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @return Schema.SObjectField.
 * @date August 27th 2024
 */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            	INS_PremiumPayerPaymentMehodConfig__mdt.Id, 
                INS_PremiumPayerPaymentMehodConfig__mdt.AddressLineLength__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.Address_Type__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.CityLength__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.CountryLength__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.CountryZipCodeLength__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAddressDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAddressRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBankDetailsDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBankDetailsRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAccountNumberDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAccountNumberRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBankNameDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBankNameRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBranchNameDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBranchNameRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isSelectAccountDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isSelectAccountRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBranchCodeDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBranchCodeRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAddressLineDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAddressLineRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAddressTypeDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isAddressTypeRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isCityDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isCityRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isCountryDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isCountryRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isPostalCodeDisable__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isPostalCodeRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.Branch_Code__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.Branch_Name__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.isBranchListRequired__c,
                INS_PremiumPayerPaymentMehodConfig__mdt.Default_Address_Type__c
        };
    }
    
    /**
 * @description selector class for selectByPaymentMethod.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param paymentMethod.
 * @return List<INS_PremiumPayerPaymentMehodConfig__mdt>.
 * @date August 27th 2024
 */
    public List<INS_PremiumPayerPaymentMehodConfig__mdt> selectByPaymentMethod(String paymentMethod) {
        
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Payment_Method__c = : paymentMethod' );
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}