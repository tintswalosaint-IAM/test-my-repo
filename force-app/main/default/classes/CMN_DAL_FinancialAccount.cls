/**
* @description Data Access Layer SOQL and DML updates related to the Financial Account Object, this is common class to be used across applications
*
* @author Eduardo Salia
*
* @date July 2021
*/
public with sharing class CMN_DAL_FinancialAccount {
  public static final String OBJECT_NAME = FinServ__FinancialAccount__c.SObjectType.getDescribe().getLocalName();
    
	/**
	 * @description The default fields to query from the Financial Account Object
	 *
	 * @return A list of Financial Account fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
            FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c.getDescribe().getLocalName(),
            FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c.getDescribe().getLocalName()
		}; 
	}

	/**
	 * @description Method will return the Financial Account based on the Id
	 *
	 * @param accountId The id of the Financial Account to retrieve
	 *
	 * @return either Null or Financial Account found
	 */
	public static FinServ__FinancialAccount__c findById(Id accountId)
	{
		return (FinServ__FinancialAccount__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, getDefaultFields());
	}

    /**
* @description Will return all the Financial Accounts based on the Set of Account Numbers
*
* @param accountNumbers These are the Financial Account Numbers
*
* @return A list of Financial Accounts
*/
    public static List<FinServ__FinancialAccount__c> getByAccountNumbers(Set<String> accountNumbers) {
        return
            [
                SELECT Id, FinServ__FinancialAccountNumber__c, FinServ__Balance__c
                FROM FinServ__FinancialAccount__c
                WHERE FinServ__FinancialAccountNumber__c IN: accountNumbers
            ];
    }
    
    /**
* @description Will return all the Financial Accounts based on the Set of Account Ids
*
* @param accountIds These are the Person Account Ids
*
* @return A list of Financial Accounts
*/
    public static List<FinServ__FinancialAccount__c> getByAccountIds(Set<Id> accountIds) {
        return
            [
                SELECT Id, FinServ__FinancialAccountNumber__c
                FROM FinServ__FinancialAccount__c
                WHERE FinServ__PrimaryOwner__c != null
                AND FinServ__PrimaryOwner__c IN: accountIds
            ];
    }
}