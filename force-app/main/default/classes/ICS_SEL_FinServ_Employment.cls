/**
*@description Selector class for FinServ__Employment__c object.
*This class provides methods to retrieve FinServ__Employment__c records.
* @author Ofentse Sacha
* @date May 2023
*/
public with sharing class ICS_SEL_FinServ_Employment extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_FinServ_Employment class.
     */
    public ICS_SEL_FinServ_Employment() {
        super();
    }

    /**
     * @description Retrieves the SObjectType for FinServ__Employment__c.
     * @return The SObjectType for FinServ__Employment__c
     */
    public override Schema.SObjectType getSObjectType() {
        return FinServ__Employment__c.SObjectType;
    }

    /**
     * @description Retrieves the list of SObjectFields for FinServ__Employment__c.
     * @return The list of SObjectFields for FinServ__Employment__c
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return FinServ__Employment__c.SObjectType.getDescribe().fields.getMap().values();
    }

    /**
     * @description Retrieves a list of FinServ__Employment__c objects based on the Account ID and record type name.
     * @param accID The ID of the Account
     * @param recordTypeName The name of the record type
     * @return List of FinServ__Employment__c objects associated with the Account and record type
     */
    public List<FinServ__Employment__c> getEmployment(String accID, String recordTypeName) {
        if (recordTypeName == 'Current') {
        	return (List<FinServ__Employment__c>) Database.query('SELECT ' + getFieldListString() + ', RecordType.Name, Person_Account__r.Id, Person_Account__r.Has_Previous_Employment__c FROM FinServ__Employment__c WHERE Person_Account__c = :accID AND RecordType.Name = :recordTypeName ORDER BY FinServ__StartDate__c ASC');
        } else if (recordTypeName == 'Previous') {
            return (List<FinServ__Employment__c>) Database.query('SELECT ' + getFieldListString() + ', RecordType.Name, Person_Account__r.Id, Person_Account__r.Has_Previous_Employment__c, Person_Account__r.Previous_Employment_Status__c, Person_Account__r.Previous_Employment_Status_Other__c FROM FinServ__Employment__c WHERE Person_Account__c = :accID AND RecordType.Name = :recordTypeName ORDER BY FinServ__EndDate__c DESC');		
        }
        return new List<FinServ__Employment__c>();
    }
    
    
    /**
     * @description Retrieves a list of FinServ__Employment__c objects based on the Account ID and record type name, with some fields converted to the user's currency.
     * @param accID The ID of the Account
     * @param recordTypeName The name of the record type
     * @return List of FinServ__Employment__c objects associated with the Account and record type
     */
    public List<FinServ__Employment__c> getEmploymentConvertedCurrencyList(String accID, String recordTypeName) {
        if (recordTypeName == 'Current') {
             String soql = 'SELECT convertCurrency(FinServ__AnnualIncome__c), convertCurrency(Bonuses_Commissions_received_per_annum__c), FinServ__Contact__c,   ';
					soql += 'FinServ__EmployerAddress__c, Name, FinServ__EmployerPhoneNumber__c, Employer_s_Address_Line_1__c, Employer_s_Address_Line_4__c,  ';
					soql += 'Employer_s_Address_Line_2__c, Employer_s_Address_Line_3__c, Employer_s_Website__c, In_Employment_Alongside_Studying__c,  ';
					soql += 'Employer_s_Country__c, Employer_s_Postcode__c, FinServ__StartDate__c, Sub_Industry__c, RecordType.Name,  ';
					soql += 'FinServ__EmploymentStatus__c, FinServ__EndDate__c, Previously_em__c, RecordTypeId, Retired_Start_Date__c,  ';
					soql += 'In_home_Start_Date__c, Industry__c, Is_Future_Fund__c, FinServ__LengthOfEmployment__c, CreatedById,  ';
					soql += 'Occupation__c, FinServ__Occupation__c, Only_employment__c, Other_Status__c, OwnerId, FinServ__Position__c,  ';
					soql += 'Person_Account__c, FinServ__SourceSystemId__c, CurrencyIsoCode, Unemployment_Start_Date__c  ';
					soql += 'FROM FinServ__Employment__c WHERE Person_Account__c = :accID AND RecordType.Name = :recordTypeName ORDER BY FinServ__StartDate__c ASC';
        	return  Database.query(soql);        
        } 
        else if (recordTypeName == 'Previous') {
             String soql = 'SELECT convertCurrency(FinServ__AnnualIncome__c), convertCurrency(Bonuses_Commissions_received_per_annum__c), FinServ__Contact__c,   ';
					soql += 'FinServ__EmployerAddress__c, Name, FinServ__EmployerPhoneNumber__c, Employer_s_Address_Line_1__c, Employer_s_Address_Line_4__c,  ';
					soql += 'Employer_s_Address_Line_2__c, Employer_s_Address_Line_3__c, Employer_s_Website__c, In_Employment_Alongside_Studying__c,  ';
					soql += 'Employer_s_Country__c, Employer_s_Postcode__c, FinServ__StartDate__c, Sub_Industry__c, RecordType.Name,  ';
					soql += 'FinServ__EmploymentStatus__c, FinServ__EndDate__c, Previously_em__c, RecordTypeId, Retired_Start_Date__c,  ';
					soql += 'In_home_Start_Date__c, Industry__c, Is_Future_Fund__c, FinServ__LengthOfEmployment__c, CreatedById,  ';
					soql += 'Occupation__c, FinServ__Occupation__c, Only_employment__c, Other_Status__c, OwnerId, FinServ__Position__c,  ';
					soql += 'Person_Account__c, FinServ__SourceSystemId__c, CurrencyIsoCode, Unemployment_Start_Date__c  ';
					soql += 'FROM FinServ__Employment__c WHERE Person_Account__c = :accID AND RecordType.Name = :recordTypeName ORDER BY FinServ__EndDate__c DESC ';
        	return  Database.query(soql);        
        }
        return new List<FinServ__Employment__c>();
    }
   
}