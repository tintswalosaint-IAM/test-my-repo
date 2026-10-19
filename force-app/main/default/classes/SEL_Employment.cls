/**
 * @name of the class: SEL_Employment
* @description Selector Class for Employment Entity
* Story:SFP-30128
* @author Ikyatha Naidu
* @date 09/11/2023
***************************************************************
* @last modified on  : 14-02-2025
* @last modified by  : Tushar Walse
* @ Modification Description : updated to latest version
***************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 11-09-2025
 * @Modification description : SFP-52215 added Industry fields
 ***************************************************************************************
*/
public inherited sharing class SEL_Employment extends sbgplatform.fflib_SObjectSelector{

    private static Set<String> fields=new Set<String>{
        'id',
        'Name','RecordType.Name','Retired_Start_Date__c','Holds_Greater_Than_10_Percent__c', 'CMN_Industry__c', 
       'CMN_Industry__r.CMN_SubIndustry__c','CMN_Industry__r.CMN_MainIndustry__c','Unemployment_Start_Date__c','Employer_s_Sub_Region__c',
       'Employer_s_Province__c','Study_Start_Date__c','Previously_em__c','FinServ__EmployerAddress__c','Other_Status__c','FinServ__EndDate__c','Person_Account__c','Only_employment__c','Occupation__c','Name','In_home_Start_Date__c','In_Employment_Alongside_Studying__c','Industry__c','FinServ__StartDate__c','FinServ__Position__c','FinServ__Occupation__c','FinServ__EmploymentStatus__c','FinServ__AnnualIncome__c','Employer_s_Website__c','Employer_s_Postcode__c','Employer_s_Country__c','Employer_s_Address_Line_4__c','Employer_s_Address_Line_3__c','Employer_s_Address_Line_2__c','Employer_s_Address_Line_1__c','Bonuses_Commissions_received_per_annum__c','RecordTypeId','CurrencyIsoCode'

    };
    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public override Schema.SObjectType getSObjectType(){
        return FinServ__Employment__c.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            FinServ__Employment__c.Id,
            FinServ__Employment__c.Name

        };
    }
    /**
     * @description Select Employment based on parentId
     * @param parentId
     * @return FinServ__Employment__c
     */
    public List<FinServ__Employment__c> selectByParentIdAndSectionName(String parentId,string sectionName ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        string rcName='Current';
        
        string onlyEmp ='';
        if(sectionName == 'Dual Employment Details' && rcName=='Current'){
			onlyEmp='No';
            fieldQueryFactory.setCondition('Person_Account__c=:parentId  and recordtype.Name=:rcName and Only_employment__c=: onlyEmp');
        }
        else if(sectionName == 'Current Employment Details'  && rcName=='Current'){
			onlyEmp='Yes';
            fieldQueryFactory.setCondition('Person_Account__c=:parentId  and recordtype.Name=:rcName and (Only_employment__c =: onlyEmp or Only_employment__c = null)');
        }
        else if(sectionName == 'Previous Employment Details'  ){
           rcName='Previous';
            fieldQueryFactory.setCondition('Person_Account__c=:parentId  and recordtype.Name=:rcName');
        }
        if(onlyEmp == null || rcName == null  ){
            return null;
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
     * @description Select Employment based on accountid
     * @param parentId
     * @return FinServ__Employment__c
     */
    public List<FinServ__Employment__c> selectByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        
        fieldQueryFactory.setCondition('Person_Account__c in :accountIds');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}