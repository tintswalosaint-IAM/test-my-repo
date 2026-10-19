/**
 * @description Provides Query methods related to Account object
 *
 * @author Accenture
 *
 * @date Mar 2021
 */
public inherited sharing class SVC_DAL_Account
{
	public static final String OBJECT_NAME = Account.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_EXTERNAL_CIF_ID = Account.ExternalCIFId__c.getDescribe().getLocalName();
	public static final String FIELD_EXTERNAL_CF_UUID = Account.ExternalCIFUUID__c.getDescribe().getLocalName();
	/**
	 * @description The default fields to query from the Account Object
	 *
	 * @return A list of Account fields
	 */
	private static Set<String> getDefaultFields()
	{
		Set<String> fieldList = CMN_DAL_Account.getDefaultFields();

		fieldList.addAll(

				new Set<String>
				{
						Account.FinServ__MarketingSegment__c.getDescribe().getLocalName(),
						Account.Name.getDescribe().getLocalName(),
						Account.PersonContactId.getDescribe().getLocalName(),
                        Account.ExternalIdentifier__pc.getDescribe().getLocalName(),
                        Account.DR_Retain_Until_Date__pc.getDescribe().getLocalName(),
                        Account.CMN_IdentityNumber__pc.getDescribe().getLocalName(),
						FIELD_EXTERNAL_CIF_ID,
						FIELD_EXTERNAL_CF_UUID
				}

		);

		return fieldList;
	}

	/**
	 * @description Will retrieve a list of Accounts using their ID
	 *
	 * @param accountIds A list of Account Ids
	 *
	 * @return A list of Accounts
	 */
	public static List<Account> findById(Set<Id> accountIds)
	{
		return CMN_DAL_SObjectSelector.findById(CMN_DAL_Account.OBJECT_NAME, accountIds, getDefaultFields());
	}

	/**
	 * @description Method is return the Account Id
	 *
	 * @param accountId The id of the account to retrieve
	 *
	 * @return either Null or  account found
	 */
	public static Account findById(Id accountId)
	{
		List<Account> foundAccounts = findById(new Set<Id> {accountId});

		return foundAccounts.isEmpty() ? null : foundAccounts.iterator().next();
	}

	/**
	 * @description Returns account by externalCfId
	 *
	 * @param externalCfId The BPID of the account to retrieve
	 *
	 * @return either Null or unique account found
	 */
	public static Account findByExternalCfId(String externalCfId)
	{
		return (Account)CMN_DAL_SObjectSelector.findByField(CMN_DAL_Account.OBJECT_NAME, FIELD_EXTERNAL_CIF_ID, externalCfId, getDefaultFields(), false);
	}

	/**
	 * @description Returns account by identity number
	 *
	 * @param identityNumber The identity number of the account to retrieve
	 *
	 * @return either Null or unique account found
	 */
	public static Account findByIdentityNumber(String identityNumber)
	{
		List<IdentityDocument> foundDocuments = SVC_DAL_IdentityDocument.findByName(identityNumber);

		Account foundAccount;

		if(!foundDocuments.isEmpty())
		{
			List<Account> foundAccounts = findById(CMN_UTIL_System.extractListIds(foundDocuments, SVC_DAL_IdentityDocument.FIELD_RELATED_ENTITY_ID));
			foundAccount = foundAccounts.size() == 1 ? foundAccounts.iterator().next() : null;
		}

		return foundAccount;
	}

	/**
	 * @description Returns account by Phone
	 *
	 * @param phoneNumber The phone Number of the account to retrieve
	 *
	 * @return either Null or unique account found
	 */
	public static Account findByPhoneNumber(String phoneNumber)
	{
		return (Account)CMN_DAL_SObjectSelector.findByField(CMN_DAL_Account.OBJECT_NAME, CMN_DAL_Account.FIELD_PHONE_NUMBER, phoneNumber, getDefaultFields(), false);
	}
    
    /**
	 * @description Returns account by CustomerBPID
	 *
	 * @param CustomerBPID The phone Number of the account to retrieve
	 *
	 * @return either Null or unique account found
	 */
   // customerBPID
   // ExternalIdentifier__pc
   // FIELD_EXTERNAL_IDENTIFER
	public static Account findByCustomerBPID(String externalIdentifier)
	{
		return (Account)CMN_DAL_SObjectSelector.findByField(CMN_DAL_Account.OBJECT_NAME,CMN_DAL_Account.FIELD_EXTERNAL_IDENTIFER, externalIdentifier, getDefaultFields(), false);
	}
}