/**
 * @description Provides Query methods related to Account object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date Mar 2021
 */
public inherited sharing class CMN_DAL_Account {
	private static final String FIELD_IS_PERSON_ACCOUNT = Account.IsPersonAccount.getDescribe().getLocalName();
	public static final String BUSINESS_RECORD_TYPE = 'CMN_Business';
	public static final String FIELD_PHONE_NUMBER = Account.Phone.getDescribe().getLocalName();
    public static final String FIELD_CUSTOMER_BPID = Account.CMN_CustomerBPID__pc.getDescribe().getLocalName();
    public static final String FIELD_EXTERNAL_IDENTIFER = Account.ExternalIdentifier__pc.getDescribe().getLocalName();
	public static final String OBJECT_NAME = Account.SObjectType.getDescribe().getLocalName();
	public static final String PERSON_RECORD_TYPE = 'PersonAccount';

	/**
	 * @description The default fields to query from the Account Object
	 *
	 * @return A list of Account fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Account.AccountNumber.getDescribe().getLocalName(),
				Account.AccountSource.getDescribe().getLocalName(),
				Account.AnnualRevenue.getDescribe().getLocalName(),
				Account.BillingCity.getDescribe().getLocalName(),
				Account.BillingCountry.getDescribe().getLocalName(),
				Account.BillingGeocodeAccuracy.getDescribe().getLocalName(),
				Account.BillingLatitude.getDescribe().getLocalName(),
				Account.BillingLongitude.getDescribe().getLocalName(),
				Account.BillingPostalCode.getDescribe().getLocalName(),
				Account.BillingState.getDescribe().getLocalName(),
				Account.BillingStreet.getDescribe().getLocalName(),
				Account.Description.getDescribe().getLocalName(),
				Account.FirstName.getDescribe().getLocalName(),
				Account.Id.getDescribe().getLocalName(),
				Account.Industry.getDescribe().getLocalName(),
				Account.IsDeleted.getDescribe().getLocalName(),
				Account.IsPersonAccount.getDescribe().getLocalName(),
				Account.LastName.getDescribe().getLocalName(),
				Account.MiddleName.getDescribe().getLocalName(),
				Account.Name.getDescribe().getLocalName(),
				Account.NumberOfEmployees.getDescribe().getLocalName(),
				Account.OwnerId.getDescribe().getLocalName(),
				Account.PersonAssistantName.getDescribe().getLocalName(),
				Account.PersonAssistantPhone.getDescribe().getLocalName(),
				Account.PersonBirthdate.getDescribe().getLocalName(),
				Account.PersonContactId.getDescribe().getLocalName(),
				Account.PersonDepartment.getDescribe().getLocalName(),
				Account.PersonDoNotCall.getDescribe().getLocalName(),
				Account.PersonEmail.getDescribe().getLocalName(),
				Account.PersonEmailBouncedDate.getDescribe().getLocalName(),
				Account.PersonEmailBouncedReason.getDescribe().getLocalName(),
				Account.PersonHasOptedOutOfEmail.getDescribe().getLocalName(),
				Account.PersonHasOptedOutOfFax.getDescribe().getLocalName(),
				Account.PersonHomePhone.getDescribe().getLocalName(),
				Account.PersonIndividualId.getDescribe().getLocalName(),
				Account.PersonLastCURequestDate.getDescribe().getLocalName(),
				Account.PersonLastCUUpdateDate.getDescribe().getLocalName(),
				Account.PersonLeadSource.getDescribe().getLocalName(),
				Account.PersonMailingCity.getDescribe().getLocalName(),
				Account.PersonMailingCountry.getDescribe().getLocalName(),
				Account.PersonMailingGeocodeAccuracy.getDescribe().getLocalName(),
				Account.PersonMailingLatitude.getDescribe().getLocalName(),
				Account.PersonMailingLongitude.getDescribe().getLocalName(),
				Account.PersonMailingPostalCode.getDescribe().getLocalName(),
				Account.PersonMailingState.getDescribe().getLocalName(),
				Account.PersonMailingStreet.getDescribe().getLocalName(),
				Account.PersonMobilePhone.getDescribe().getLocalName(),
				Account.PersonOtherCity.getDescribe().getLocalName(),
				Account.PersonOtherCountry.getDescribe().getLocalName(),
				Account.PersonOtherGeocodeAccuracy.getDescribe().getLocalName(),
				Account.PersonOtherLatitude.getDescribe().getLocalName(),
				Account.PersonOtherLongitude.getDescribe().getLocalName(),
				Account.PersonOtherPhone.getDescribe().getLocalName(),
				Account.PersonOtherPostalCode.getDescribe().getLocalName(),
				Account.PersonOtherState.getDescribe().getLocalName(),
				Account.PersonOtherStreet.getDescribe().getLocalName(),
				Account.PersonTitle.getDescribe().getLocalName(),
				Account.PhotoUrl.getDescribe().getLocalName(),
				Account.Rating.getDescribe().getLocalName(),
				Account.RecordTypeId.getDescribe().getLocalName(),
				Account.RelationshipMgrCode__c.getDescribe().getLocalName(),
				Account.Salutation.getDescribe().getLocalName(),
				Account.ShippingCity.getDescribe().getLocalName(),
				Account.ShippingCountry.getDescribe().getLocalName(),
				Account.ShippingGeocodeAccuracy.getDescribe().getLocalName(),
				Account.ShippingLatitude.getDescribe().getLocalName(),
				Account.ShippingLongitude.getDescribe().getLocalName(),
				Account.ShippingPostalCode.getDescribe().getLocalName(),
				Account.ShippingState.getDescribe().getLocalName(),
				Account.ShippingStreet.getDescribe().getLocalName(),
				Account.Sic.getDescribe().getLocalName(),
				Account.SicDesc.getDescribe().getLocalName(),
				Account.Site.getDescribe().getLocalName(),
				Account.Suffix.getDescribe().getLocalName(),
				Account.SystemModstamp.getDescribe().getLocalName(),
				Account.TickerSymbol.getDescribe().getLocalName(),
				Account.Type.getDescribe().getLocalName(),
				Account.Website.getDescribe().getLocalName(),
				Account.ExternalCIFId__c.getDescribe().getLocalName(),
				Account.ExternalCIFUUID__c.getDescribe().getLocalName(),
				FIELD_IS_PERSON_ACCOUNT,
				FIELD_PHONE_NUMBER,
				Account.ExternalCIFCountry__c.getDescribe().getLocalName(),
				Account.CMN_BPGUID__pc.getDescribe().getLocalName(),
				Account.CMN_CustomerBPID__pc.getDescribe().getLocalName()
		}; 
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
		return (Account)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, getDefaultFields());
	}

	/**
	 * @description Will get all accounts created in a unit test
	 *
	 * @return A list of accounts
	 */
	@TestVisible
	private static List<Account> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, CMN_DAL_Account.getDefaultFields());
	}

	/**
	 * @description Will get all person accounts created in a unit test
	 *
	 * @return A list of accounts
	 */
	@TestVisible
	private static List<Account> getAllPersonAccounts()
	{
		return CMN_DAL_Search.findAllByAnyValue(OBJECT_NAME, FIELD_IS_PERSON_ACCOUNT, true);
	}

    /**
     * @description Find account records by RM AE code and BP IDs partial match (opening characters ignored)
     *
	 * @param rmAeCodes Set<String> RM AE codes
	 * @param bpIdsQuery Set<String> BP IDs
	 *
     * @return List of accounts
     */
    public static List<Account> findAccountsForConversations(Set<String> rmAeCodes, Set<String> bpIdsQuery) {
        String query =
			'SELECT Id, RelationshipMgrCode__c, ExternalCIFId__c, CMN_CustomerBPID__pc FROM Account' +
			' WHERE RelationshipMgrCode__c IN :rmAeCodes AND ExternalCIFId__c LIKE :bpIdsQuery';
        List<Account> accounts = Database.query(query);
        return accounts;
    }
}