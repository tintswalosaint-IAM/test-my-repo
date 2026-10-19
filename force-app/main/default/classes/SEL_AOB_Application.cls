/**
 * @description Application Selector Layer
 * @author Yashwanth(Yaswanth.tikkisetty@standardbank.co.za)
 * @date May 2022
 */
public without sharing class SEL_AOB_Application extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{
        'Id', 
        'AOB_Lead__c',
        'AOB_Study_Year__c', 
        'AOB_Institution__c', 
        'AOB_Course_Name__c', 
        'AOB_FirstName__c', 
        'AOB_LastName__c',
            'AOB_Other_Name__c',
        'AOB_DOB__c', 
        'AOB_Gender__c',
        'AOB_Identifii_Expire_Date__c', 
        'AOB_Title__c', 
        'AOB_Nationality__c', 
        'AOB_Phone__c', 
        'AOB_NIN__c', 
        'AOB_Employer_Name__c',
        'AOB_Nature_Of_Employment__c', 
        'AOB_Occupation__c', 
        'AOB_Monthly_Income_in_UGX__c',  
        'AOB_State__c', 
        'AOB_Country__c', 
        'AOB_City__c',
        'AOB_Current_Address_City__c', 
        'AOB_Current_Address_Country__c', 
        'AOB_Current_Address_PostalCode__c', 
        'AOB_Current_Address_State__c',
        'AOB_Current_Address_Street__c', 
        'AOB_PostalCode__c', 
        'AOB_Marital_Status__c', 
        'AOB_Email__c', 
        'AOB_Street__c',
        'AOB_Accommodation_Type__c', 
        'AOB_Phone_Type__c', 
        'AOB_Email_Type__c', 
        'AOB_Employment_Type__c',
        'AOB_Selected_Currency__c', 
        'AOB_County__c', 
        'AOB_Current_Address_County__c', 
        'AOB_Consent_Status__c',
        'AOB_Preferred_Branch__c', 
        'AOB_Address_From_Date__c', 
        'AOB_Current_Address_From_Date__c',
        'AOB_Operator_Name__c',
        'AOB_Customer_Id__c',   
        'AOB_Schema_Code__c',
        'AOB_Pricing_Option__c', 
        'AOB_Mode_Of_Payment__c', 
        'AOB_Mobile_Money_Number__c', 
        'AOB_Name_Of_Bank__c', 
        'AOB_Alternative_Account_Name__c', 
        'AOB_Alternative_Account_Number__c',
        'AOB_Stage__c',
        'AOB_Current_Address_Same_As_Address__c',
        'AOB_Have_Referral_Code__c',
        'AOB_Address_Line3__c',
        'AOB_Current_Address_Line3__c',
        'AOB_Document_Number__c',
        'AOB_Referal_Code__c',
        'AOB_Product__c',
        'AOB_Liveness_Matched__c',
        'AOB_Risk_Score_Rating__c'
    };
	
    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Application__c.Id, 
            Application__c.AOB_Lead__c,
            Application__c.AOB_Study_Year__c, 
            Application__c.AOB_Institution__c, 
            Application__c.AOB_Course_Name__c, 
            Application__c.AOB_FirstName__c,
              Application__c.AOB_Other_Name__c,  
            Application__c.AOB_LastName__c,
            Application__c.AOB_Identifii_Expire_Date__c,
            Application__c.AOB_DOB__c, 
            Application__c.AOB_Gender__c, 
            Application__c.AOB_Title__c, 
            Application__c.AOB_Nationality__c, 
            Application__c.AOB_Phone__c, 
            Application__c.AOB_NIN__c, 
            Application__c.AOB_Employer_Name__c,
            Application__c.AOB_Nature_Of_Employment__c, 
            Application__c.AOB_Occupation__c, 
            Application__c.AOB_Monthly_Income_in_UGX__c,  
            Application__c.AOB_State__c, 
            Application__c.AOB_Country__c, 
            Application__c.AOB_City__c,
            Application__c.AOB_Current_Address_City__c, 
            Application__c.AOB_Current_Address_Country__c, 
            Application__c.AOB_Current_Address_PostalCode__c, 
            Application__c.AOB_Current_Address_State__c,
            Application__c.AOB_Current_Address_Street__c, 
            Application__c.AOB_PostalCode__c, 
            Application__c.AOB_Marital_Status__c, 
            Application__c.AOB_Email__c, 
            Application__c.AOB_Street__c,
            Application__c.AOB_Accommodation_Type__c, 
            Application__c.AOB_Phone_Type__c, 
            Application__c.AOB_Email_Type__c, 
            Application__c.AOB_Employment_Type__c,
            Application__c.AOB_Selected_Currency__c, 
            Application__c.AOB_County__c, 
            Application__c.AOB_Current_Address_County__c, 
            Application__c.AOB_Consent_Status__c,
            Application__c.AOB_Preferred_Branch__c, 
            Application__c.AOB_Address_From_Date__c, 
            Application__c.AOB_Current_Address_From_Date__c,
            Application__c.AOB_Operator_Name__c,
            Application__c.AOB_Customer_Id__c,   
            Application__c.AOB_Schema_Code__c,
            Application__c.AOB_Pricing_Option__c, 
            Application__c.AOB_Mode_Of_Payment__c, 
            Application__c.AOB_Mobile_Money_Number__c, 
            Application__c.AOB_Name_Of_Bank__c, 
            Application__c.AOB_Alternative_Account_Name__c, 
            Application__c.AOB_Alternative_Account_Number__c,
            Application__c.AOB_Stage__c,
            Application__c.AOB_Current_Address_Same_As_Address__c,
            Application__c.AOB_Have_Referral_Code__c,
            Application__c.AOB_Address_Line3__c,
            Application__c.AOB_Current_Address_Line3__c,
            Application__c.AOB_Document_Number__c,
            Application__c.AOB_Referal_Code__c,
            Application__c.AOB_Product__c,
            Application__c.AOB_Liveness_Matched__c,
            Application__c.AOB_Risk_Score_Rating__c
        };
    }

    /**
     * @description selectById
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return Application__c.sObjectType;
    }

    /**
     * @description Select by section
     * @param applicationId String
     * @return List<Application__c>
     */
    public List<Application__c> selectApplicationById(String applicationId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('Id = :applicationId');
		fieldQueryFactory.selectFields(fields);  

        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select by section
     * @param filterCondition String
     * @return List<Application__c>
     */
    public List<Application__c> getApplicationByFilter(String filterCondition) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition(filterCondition);
		fieldQueryFactory.selectFields(fields);  

        return Database.query(fieldQueryFactory.toSOQL());
    }
    
}