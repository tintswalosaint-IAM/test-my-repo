/**
 * @description Provides Query methods related to Case object
 *
 * @author Accenture
 * @date January 2021
 * @last modified on  : 03-30-2026
 * @last modified by  : Aliaksei Koval
 * SFP-35988 FIELD_ENTITLEMENT_NAME was added to standard fields
 * SFP-56611 SVC_FraudReferenceNumber__c was added to standard fields
 */
public inherited sharing class SVC_DAL_Case
{
	private static final String FIELD_ACCOUNT_ID = Case.AccountId.getDescribe().getLocalName();
	private static final String FIELD_AWS_CONTACT_ID = Case.amazonconnect__AC_Contact_Id__c.getDescribe().getLocalName();
	private static final String FIELD_CASE_NUMBER = Case.CaseNumber.getDescribe().getLocalName();
	private static final String FIELD_FINANCIAL_ACCOUNT = 'FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c';
	private static final String FIELD_OWNER_EMAIL = 'Owner.Email';
	private static final String FIELD_OWNER_NAME = 'Owner.Name';
	private static final String FIELD_SERVICE_TYPE_AUTH_LEVEL = 'SVC_ServiceType__r.SVC_AuthenticationLevel__c';
	private static final String FIELD_SERVICE_TYPE_ID = Case.SVC_ServiceTeam__c.getDescribe().getRelationshipName() + CMN_UTIL_String.DOT + SVC_DAL_ServiceTeam.FIELD_SERVICE_TYPE;
	private static final String FIELD_SERVICE_TYPE_NAME = 'SVC_ServiceType__r.Name';
	private static final String FIELD_SERVICE_TEAM_NAME = 'SVC_ServiceTeam__r.CMN_Team__r.Name';
	private static final String FIELD_SERVICE_TEAM_TYPE_NAME = 'SVC_ServiceTeam__r.SVC_ServiceType__r.Name';
	private static final String FIELD_ENTITLEMENT_NAME = 'Entitlement.Name';

	public static final String OBJECT_NAME = Case.SObjectType.getDescribe().getLocalName();
	public static final String ORIGIN_WEB_CHAT = 'Web Chat';
	public static final String RT_SERVICE_REQUEST = 'SVC_ServiceRequest';

	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Case fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
                                Case.SVC_AuthenticationMethod__c.getDescribe().getLocalName(),
				Case.SVC_CustomerIdNumber__c.getDescribe().getLocalName(),
                                Case.SVC_CustomerInformedAboutSurvey__c.getDescribe().getLocalName(),
                                Case.SVC_IsAuthenticated__c.getDescribe().getLocalName(),
				Case.SVC_PotentialSpam__c.getDescribe().getLocalName(),
                                Case.SVC_PreferredEmailAddress__c.getDescribe().getLocalName(),
                                Case.SVC_QueueId__c.getDescribe().getLocalName(),
				Case.SVC_SentimentIndicator__c.getDescribe().getLocalName(),
				Case.SVC_SentimentScore__c.getDescribe().getLocalName(),
				Case.SVC_Sentiment__c.getDescribe().getLocalName(),
				Case.SVC_ServiceRequestNumber__c.getDescribe().getLocalName(),
				Case.SVC_ServiceTeam__c.getDescribe().getLocalName(),
				Case.SVC_ServiceType__c.getDescribe().getLocalName(),
				Case.SVC_ProductCategory__c.getDescribe().getLocalName(),
				Case.SVC_FraudReferenceNumber__c.getDescribe().getLocalName(),
                                Case.Service_Type_Name__c.getDescribe().getLocalName(),
				Case.SVC_CaseOwnerTeam__c.getDescribe().getLocalName(),
				Case.Comments.getDescribe().getLocalName(),
				Case.ContactEmail.getDescribe().getLocalName(),
				Case.ContactId.getDescribe().getLocalName(),
				Case.CreatedDate.getDescribe().getLocalName(),
				Case.Description.getDescribe().getLocalName(),
				Case.Id.getDescribe().getLocalName(),
				Case.IsEscalated.getDescribe().getLocalName(),
				Case.Origin.getDescribe().getLocalName(),
				Case.Priority.getDescribe().getLocalName(),
				Case.Reason.getDescribe().getLocalName(),
				Case.SourceId.getDescribe().getLocalName(),
				Case.Status.getDescribe().getLocalName(),
				Case.Subject.getDescribe().getLocalName(),
				Case.SuppliedCompany.getDescribe().getLocalName(),
				Case.SuppliedEmail.getDescribe().getLocalName(),
				Case.SuppliedName.getDescribe().getLocalName(),
				Case.SuppliedPhone.getDescribe().getLocalName(),
				Case.Type.getDescribe().getLocalName(),
				FIELD_ACCOUNT_ID,
				FIELD_AWS_CONTACT_ID,
				FIELD_CASE_NUMBER,
				FIELD_FINANCIAL_ACCOUNT,
				FIELD_OWNER_EMAIL,
				FIELD_OWNER_NAME,
				FIELD_SERVICE_TYPE_AUTH_LEVEL,
				FIELD_SERVICE_TYPE_ID,
				FIELD_SERVICE_TYPE_NAME,
				FIELD_SERVICE_TEAM_NAME,
				FIELD_SERVICE_TEAM_TYPE_NAME,
				FIELD_ENTITLEMENT_NAME
		};

	}

	/**
	 * @description Will return a case based on Id given return base case fields
	 *
	 * @param caseId The id of the case
	 *
	 * @return either null or the case that was found
	 */
	@AuraEnabled
	public static Case findById(Id caseId)
	{
		try{
			return (Case)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, caseId, getDefaultFields());
		} catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Will return all the Cases in the system
	 *
	 * @return A list of Cases
	 */
	@TestVisible
	public static List<Case> getAll()
	{
		return CMN_DAL_Search.getAll(Case.SObjectType, getDefaultFields());
	}

	/**
	 * @description Will find all open cases related to a given Amazon Connect Contact Id
	 *
	 * @param contactId The Id of the contact that should be matched on the Amazon Connect Contact Id field
	 *
	 * @return Unique Case, will raise an exception if case is not unique
	 *
	 * @see Case.amazonconnect__AC_Contact_Id__c
	 */
	public static Case findByAmazonConnectContactId(String contactId)
	{
		return (Case)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_AWS_CONTACT_ID, contactId, getDefaultFields(), true);
	}

	/**
	 * @description Will find all cases related to a given Account Id
	 *
	 * @param accountId The Id of the Account
	 *
	 * @return List of cases
	 */
	public static List<Case> findByAccountId(String accountId)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<String> {accountId}, getDefaultFields());
	}

	/**
	 * @description Will find all cases related to a given Account Id in descending order (based on CaseNumber)
	 *
	 * @param accountId The Id of the Account
	 *
	 * @return List of cases
	 */
	public static Case findLatestByAccountId(String accountId)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = CMN_DAL_SObjectSelector.initialiseParameters(OBJECT_NAME, FIELD_ACCOUNT_ID, new Set<String> {accountId}, getDefaultFields());
		searchParameters.pageSize = 1;
		searchParameters.addOrderByField(FIELD_CASE_NUMBER, true);
		List<Case> foundCases = CMN_DAL_Search.getObjects(searchParameters);
		return foundCases.isEmpty() ? null : foundCases.iterator().next();
	}

}