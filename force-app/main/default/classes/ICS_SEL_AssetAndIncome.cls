/**
*@description Selector class for AssetsAndIncomes__c object.
*This class provides methods to retrieve AssetsAndIncomes__c records.
* @author Ofentse Sacha
* @date May 2023
*/
public with sharing class ICS_SEL_AssetAndIncome extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_AssetAndIncome class.
     */
    public ICS_SEL_AssetAndIncome() {
        super();
    }
	/**
     * @description Retrieves the SObjectType for AssetsAndIncomes__c.
     * @return The SObjectType for AssetsAndIncomes__c
     */
    public override Schema.SObjectType getSObjectType() {
        return AssetsAndIncomes__c.SObjectType;
    }
	/**
     * @description Retrieves the list of SObjectFields for AssetsAndIncomes__c.
     * @return The list of SObjectFields for AssetsAndIncomes__c
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return AssetsAndIncomes__c.SObjectType.getDescribe().fields.getMap().values();
    }

    /**
     * @description Retrieves a list of AssetsAndIncomes__c records associated with a given Application ID and record type.
     * @param appID The ID of the Application
     * @param recordTypeName The name of the record type to query
     * @return List of AssetsAndIncomes__c objects associated with the Application and the record type
     */
    public List<AssetsAndIncomes__c> getAssetIncomeList(String appID, String recordTypeName) {
        return (List<AssetsAndIncomes__c>) Database.query('SELECT ' + getFieldListString() + ',RecordType.Name FROM AssetsAndIncomes__c WHERE Application__c = :appID AND RecordType.Name = :recordTypeName');
    }

    /**
     * @description Retrieves a list of AssetsAndIncomes__c records associated with a given Application ID.
     * @param appID The ID of the Application
     * @return List of AssetsAndIncomes__c objects associated with the Application
     */
    public List<AssetsAndIncomes__c> getAssetIncomeUsingAppIdList(String appID) {
        return (List<AssetsAndIncomes__c>) Database.query('SELECT ' + getFieldListString() + ',RecordType.Name FROM AssetsAndIncomes__c WHERE Application__c = :appID');
    }

    /**
     * @description Retrieves a list of AssetsAndIncomes__c records associated with a given Application ID, with some fields converted to the user's currency.
     * @param appID The ID of the Application
     * @return List of AssetsAndIncomes__c objects associated with the Application, with some fields converted to the user's currency
     */
    public List<AssetsAndIncomes__c> getAssetIncomeConvertedCurrencyList(String appID) {
        String soql = 'SELECT Account_Holder_Name__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Line_4__c, ';
        soql += 'convertCurrency(Amounts__c), Application__c, Asset_Property_Address__c, convertCurrency(Asset_Value__c), Bank_Name__c, ';
        soql += 'Client_s_share__c, Compensation_Payment_Reason__c, Country__c, CreatedById, CreatedDate, CurrencyIsoCode, Date__c, ';
        soql += 'Description__c, Details_of_Asset_Income__c, Details_of_Investment_Dividend__c, Details_of_Last_Employer__c, ';
        soql += 'Details_of_Purchaser__c, Details_of_the_Win__c, Investments_Stocks_Financial_Institution__c, Details_of_Turnover__c, Id, ';
        soql += 'Industry__c, Inheritance_Details__c, Investments_Stocks_Jurisdiction__c, Is_SBG_Account__c, IsDeleted, ';
        soql += 'Jurisdiction_Where_Investments_Were_Held__c, Length_of_time__c, Loan_Term__c, Locations__c, convertCurrency(Bonus_Amount__c), ';
        soql += 'Lottery_Betting_Organisation_Details__c, Maturity_Proceeds__c, Mortgage_Deductions__c, Name, Name_of_Business__c, ';
        soql += 'Name_of_employer__c, Name_of_Lender__c, Nature_of_Business__c, Is_listed_in_assets__c, Nature_of_Source__c, ';
        soql += 'Other_Income_Source__c, Other_Income_Type__c, Postcode__c, convertCurrency(Property_Value__c), RecordTypeId, ';
        soql += 'RecordType.Name, Is_future_fund__c, Redundancy_Pension_Employer_Name__c, Redundancy_Pension_Last_Salary__c, ';
        soql += 'Redundancy_Pension_Occupation__c, Relationship_between_donor_and_Client__c, Main_Account__c, Sub_Industry__c, ';
        soql += 'SystemModstamp, Type__c, What_the_Assets_are__c, convertCurrency(Expected_Annual_Yearly_Turnover_To__c) ';
        soql += 'FROM AssetsAndIncomes__c WHERE Application__c = :appID';

        return (List<AssetsAndIncomes__c>) Database.query(soql);
    }
}