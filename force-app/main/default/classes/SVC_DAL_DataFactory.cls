/**
 * @description Class containing re-usable methods for initialising test data
 *
 * @author Accenture 
 *
 * @date January 2021
 */
@SuppressWarnings('PMD.ApexCrudViolation, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class SVC_DAL_DataFactory
{
	private static final String ENTITLEMENT_TYPE = 'Web Support';
	private static final Boolean ACTIVE_TRUE = true;

	public static final String TYPE_GENERAL_RESPONSE = 'General Response';

	/**
	 * @description Will generate service types and insert them
	 *
	 * @param numberOfItems Number of items to generate
	 *
	 * @return A list of the inserted items
	 */
	@TestVisible
	private static List<SVC_ServiceType__c> generateServiceTypes(Integer numberOfItems)
	{
		List<SVC_ServiceType__c> newServiceTypes = new List<SVC_ServiceType__c>();

		for(Integer i = 0; i < numberOfItems; i++)
		{
			String authenticationLevel = String.valueOf
					(
							CMN_DAL_SObjectDomain.generateRandomInteger
									(
											SVC_DAL_AuthenticationCombination.MIN_AUTHENTICATION_LEVEL,
											SVC_DAL_AuthenticationCombination.MAX_AUTHENTICATION_LEVEL
									)
					);
			SVC_ServiceType__c newServiceType = generateServiceType(authenticationLevel);
			newServiceTypes.add(newServiceType);
		}

		insert newServiceTypes;

		return newServiceTypes;
	}

	/**
	 * @description Will generate service type with corresponding authentication level
	 *
	 * @param authenticationLevel The service type's authentication level
	 *
	 * @return An unsaved service type
	 */
	@TestVisible
	private static SVC_ServiceType__c generateServiceType(String authenticationLevel)
	{
		SVC_ServiceType__c newServiceType = new SVC_ServiceType__c();

		newServiceType.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newServiceType.SVC_ExternalId__c = CMN_DAL_SObjectDomain.generateRandomName();
		newServiceType.SVC_AuthenticationLevel__c = authenticationLevel;

		return newServiceType;
	}

	/**
	 * @description Will generate interaction response records
	 *
	 * @param numberOfRecords - the number of sample records to create
	 *
	 * @return The inserted list of SVC_InteractionResponse__c
	 */
	@TestVisible
	private static List<SVC_InteractionResponse__c> generateInteractionResponses(Integer numberOfRecords)
	{
		List<SVC_InteractionResponse__c> recordsToInsert = new List<SVC_InteractionResponse__c>();

		for(Integer interactionResponseIndex = 0; interactionResponseIndex < numberOfRecords; interactionResponseIndex++)
		{
			SVC_InteractionResponse__c interactionResponse = new SVC_InteractionResponse__c();

			interactionResponse.SVC_QuestionText__c = CMN_UTIL_String.generateRandomString(50);
			interactionResponse.SVC_ResponseTextLong__c = CMN_UTIL_String.generateRandomString(250);
			interactionResponse.SVC_ResponseText__c = CMN_UTIL_String.generateRandomString(50);
			interactionResponse.SVC_Type__c = TYPE_GENERAL_RESPONSE;

			recordsToInsert.add(interactionResponse);
		}
		insert recordsToInsert;
		return recordsToInsert;
	}

	/**
	 * @description Will generate interaction response records with specific questionText and linkage to a case
	 * <p/>
	 * @note Overload
	 *
	 * @param numberOfRecords - the number of sample records to create
	 * @param caseId - the Id of the case to link to the interaction response
	 * @param questionText - the text to insert into SVC_QuestionText__c
	 *
	 * @return The inserted list of SVC_InteractionResponse__c
	 *
	 * @see generateInteractionResponses (Integer numberOfRecords)
	 */
	@TestVisible
	private static List<SVC_InteractionResponse__c> generateInteractionResponses(Integer numberOfRecords, String caseId, String questionText)
	{
		List<SVC_InteractionResponse__c> recordsToInsert = new List<SVC_InteractionResponse__c>();

		for(Integer interactionResponseIndex = 0; interactionResponseIndex < numberOfRecords; interactionResponseIndex++)
		{
			SVC_InteractionResponse__c interactionResponse = new SVC_InteractionResponse__c();

			interactionResponse.SVC_Case__c = caseId;
			interactionResponse.SVC_QuestionText__c = questionText;
			interactionResponse.SVC_ResponseTextLong__c = CMN_UTIL_String.generateRandomString(250);
			interactionResponse.SVC_ResponseText__c = CMN_UTIL_String.generateRandomString(50);
			interactionResponse.SVC_Type__c = TYPE_GENERAL_RESPONSE;

			recordsToInsert.add(interactionResponse);
		}
		insert recordsToInsert;
		return recordsToInsert;
	}

	/**
	 * @description Will generate authentication combinations and insert them
	 *
	 * @return A list of the inserted items
	 */
	@TestVisible
	private static List<SVC_AuthenticationCombination__c> generateAuthenticationCombinations()
	{
		List<SVC_AuthenticationCombination__c> authenticationCombinations = new List<SVC_AuthenticationCombination__c>();

		// Set level 3 authentication
		SVC_AuthenticationCombination__c lvl3Auth = new SVC_AuthenticationCombination__c();
		lvl3Auth.SVC_AuthenticationMethod__c = CMN_UTIL_String.joinStrings(
				new List<String>
				{
						SVC_DAL_AuthenticationCombination.VOICE_BIOMETRICS,
						SVC_DAL_AuthenticationCombination.STRONG_AUTH,
						SVC_DAL_AuthenticationCombination.NIUSSD
				},
				';'
		);
		lvl3Auth.Authentication_Level__c = CMN_UTIL_String.joinStrings(
				new List<String>
				{
						SVC_DAL_AuthenticationCombination.AUTH_LEVEL1,
						SVC_DAL_AuthenticationCombination.AUTH_LEVEL2,
						SVC_DAL_AuthenticationCombination.AUTH_LEVEL3
				},
				';'
		);
		authenticationCombinations.add(lvl3Auth);

		// Set level 2 authentication
		SVC_AuthenticationCombination__c lvl2Auth = new SVC_AuthenticationCombination__c();
		lvl2Auth.SVC_AuthenticationMethod__c = CMN_UTIL_String.joinStrings(
				new List<String>
				{
						SVC_DAL_AuthenticationCombination.OTP,
						SVC_DAL_AuthenticationCombination.XDS
				},
				';'
		);
		lvl2Auth.Authentication_Level__c = CMN_UTIL_String.joinStrings(
				new List<String>
				{
						SVC_DAL_AuthenticationCombination.AUTH_LEVEL1,
						SVC_DAL_AuthenticationCombination.AUTH_LEVEL2
				},
				';'
		);
		authenticationCombinations.add(lvl2Auth);

		// Set level 1 authentication
		SVC_AuthenticationCombination__c lvl1Auth = new SVC_AuthenticationCombination__c();
		lvl1Auth.SVC_AuthenticationMethod__c = CMN_UTIL_String.joinStrings(
				new List<String>
				{
						SVC_DAL_AuthenticationCombination.FIVE_POINT_SECURITY_QUESTIONS
				},
				';'
		);
		lvl1Auth.Authentication_Level__c = CMN_UTIL_String.joinStrings(
				new List<String>
				{
						SVC_DAL_AuthenticationCombination.AUTH_LEVEL1
				},
				';'
		);
		authenticationCombinations.add(lvl1Auth);

		insert authenticationCombinations;
		return authenticationCombinations;
	}

	/**
	 * @description Will insert a list of cases
	 *
	 * @param contactId Contact to which the case should be linked
	 * @param numberOfCases Number of Items to Create
	 *
	 * @return List of inserted Cases
	 */
	@TestVisible
	private static List<Case> generateCases(Id contactId, Integer numberOfCases)
	{
		List<Case> newCases = new List<Case>();

		for(Integer i = 0; i < numberOfCases; i++)
		{
			newCases.add(newCase(contactId));
		}

		insert newCases;

		return newCases;
	}

	/**
	 * @description Will insert a list of cases with Entitlement Id
	 *
	 * @param contactId Contact to which the case should be linked
	 * @param entitlementId Entitlement to which the case should be linked
	 * @param numberOfCases Number of Items to Create
	 *
	 * @return List of inserted Cases
	 */
	@TestVisible
	private static List<Case> generateCases(Id contactId, Id entitlementId, Integer numberOfCases)
	{
		List<Case> newCases = new List<Case>();

		for(Integer i = 0; i < numberOfCases; i++)
		{
			newCases.add(newCase(contactId, entitlementId));
		}

		insert newCases;

		return newCases;
	}

	/**
	 * @description Will instantiate a new case with relevant fields filled
	 *
	 * @param contactId The Contact to which this case should be related, can be null
	 *
	 * @return A completed case, note this case is not saved to the database
	 */
	public static Case newCase(Id contactId)
	{
		Case newCase = CMN_DAL_DataFactory.newCase(contactId);

		newCase.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SVC_DAL_Case.RT_SERVICE_REQUEST);
		newCase.amazonconnect__AC_Contact_Id__c = CMN_DAL_SObjectDomain.generateRandomNumber();

		return newCase;
	}

	/**
	 * @description Will instantiate a new case with relevant fields filled and entitlement id
	 *
	 * @param contactId The Contact to which this case should be related, can be null
	 * @param entitlementId The Entitlement to which this case should be related, can be null
	 *
	 * @return A completed case, note this case is not saved to the database
	 */
	public static Case newCase(Id contactId, Id entitlementId)
	{
		Case newCase = CMN_DAL_DataFactory.newCase(contactId);

		newCase.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Case.SObjectType, SVC_DAL_Case.RT_SERVICE_REQUEST);
		newCase.amazonconnect__AC_Contact_Id__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newCase.EntitlementId = entitlementId;
		newCase.SlaStartDate = System.now();

		return newCase;
	}

	/**
	 * @description Method is use return the a new Contact
	 *
	 * @return newly created Contact, not committed yet
	 */
	@TestVisible
	private static Contact newContact()
	{
		Contact newContact = CMN_DAL_DataFactory.newContact();

		return newContact;
	}

	/**
	 * @description Will generate a list of Accounts
	 *
	 * @param numberOfAccounts Number of Accounts to generate
	 * @param isPerson Indicate if the account to be generated is a person account
	 *
	 * @return A list of Accounts
	 */
	@TestVisible
	private static List<Account> generateAccounts(Integer numberOfAccounts, Boolean isPerson)
	{
		List<Account> newAccounts = new List<Account>();

		for(Integer i = 0; i < numberOfAccounts; i++)
		{
			Account newAccount = newAccount(isPerson);
			newAccounts.add(newAccount);
		}

		return newAccounts;
	}

	/**
	 * @description Will generate a list of Accounts
	 *
	 * @param unitOfWork unit of work to manage committing changes in single transaction
	 * @param numberOfAccounts Number of Accounts to generate
	 * @param isPerson Indicate if the account to be generated is a person account
	 *
	 * @return A list of Accounts
	 */
	@TestVisible
	private static List<Account> generateAccounts(CMN_DAL_SObjectUnitOfWork unitOfWork, Integer numberOfAccounts, Boolean isPerson)
	{
		List<Account> newAccounts = generateAccounts(numberOfAccounts, isPerson);
		unitOfWork.registerNew(newAccounts);
		return newAccounts;
	}

	/**
	 * @description Will generate a list of Business Accounts
	 *
	 * @param unitOfWork unit of work to manage committing changes in single transaction
	 * @param numberOfAccounts Number of Accounts to generate
	 *
	 * @return A list of Accounts
	 */
	private static List<Account> generateBusinessAccounts(CMN_DAL_SObjectUnitOfWork unitOfWork, Integer numberOfAccounts)
	{
		return generateAccounts(unitOfWork, numberOfAccounts, false);
	}

	/**
	 * @description Will generate a list of Business Accounts
	 *
	 * @param numberOfAccounts Number of Accounts to generate
	 *
	 * @return A list of Accounts
	 */
	@TestVisible
	private static List<Account> generatePersonAccounts(Integer numberOfAccounts)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>
		{
				Account.SObjectType, IdentityDocument.SObjectType
		});

		List<Account> newAccounts = generateAccounts(unitOfWork, numberOfAccounts, true);

		for(Account newAccount : newAccounts)
		{
			IdentityDocument newIdentityDocument = newIdentityDocument();
			unitOfWork.registerNew(newIdentityDocument, IdentityDocument.RelatedLegalEntityId, newAccount);
		}

		unitOfWork.commitWork();

		return newAccounts;
	}

	/**
	 * @description Will create a new Account
	 *
	 * @param isPerson Set flag to true to create a person account
	 *
	 * @return A new account (uncommitted)
	 */
	private static Account newAccount(Boolean isPerson)
	{
		Account newAccount = isPerson ? CMN_DAL_DataFactory.newPersonAccount() : CMN_DAL_DataFactory.newBusinessAccount();

		newAccount.ExternalCIFId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newAccount.ExternalCIFUUID__c = CMN_UTIL_Random.randomUUID();

		return newAccount;
	}

	/**
	 * @description Will generate a list of Contacts
	 *
	 * @param unitOfWork unit of work to manage committing changes in single transaction
	 * @param parentAccount The Account to which contacts belong
	 * @param numberOfContacts Number of Contacts to generate
	 *
	 * @return A list of Contacts
	 */
	private static List<Contact> generateContacts(CMN_DAL_SObjectUnitOfWork unitOfWork, Account parentAccount, Integer numberOfContacts)
	{
		List<Contact> newContacts = new List<Contact>();

		for(Integer j = 0; j < numberOfContacts; j++)
		{
			Contact newContact = newContact();

			unitOfWork.registerNew(newContact, Contact.AccountId, parentAccount);

			newContacts.add(newContact);
		}

		return newContacts;
	}

	/**
	 * @description Will generate a list of contacts and related accounts
	 *
	 * @param unitOfWork Unit of work to manage committing changes in single transaction
	 * @param numberOfAccounts Number of Accounts to generate
	 * @param numberOfContacts Number of Contacts to generate
	 *
	 * @return A list of Contacts
	 */
	@TestVisible
	private static List<Contact> generateContacts(CMN_DAL_SObjectUnitOfWork unitOfWork, Integer numberOfAccounts, Integer numberOfContacts)
	{
		List<Account> newAccounts = generateBusinessAccounts(unitOfWork, numberOfAccounts);

		List<Contact> newContacts = new List<Contact>();

		for(Account newAccount : newAccounts)
		{
			newContacts.addAll(generateContacts(unitOfWork, newAccount, numberOfContacts));
		}

		return newContacts;
	}

	/**
	 * @description Will generate a list of contacts and related accounts
	 *
	 * @param numberOfAccounts Number of Accounts to generate
	 * @param numberOfContacts Number of Contacts to generate
	 *
	 * @return Returns a list of contacts associated to accounts created
	 */
	@TestVisible
	private static List<Contact> generateContacts(Integer numberOfAccounts, Integer numberOfContacts)
	{
		CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>
		{
				Account.SObjectType, Contact.SObjectType
		});

		List<Contact> newContacts = generateContacts(unitOfWork, numberOfAccounts, numberOfContacts);

		unitOfWork.commitWork();

		return newContacts;
	}

	/**
	 * @description Will insert a list of LiveChatVisitor
	 *
	 * @param numberOfChatVisitor Number of Items to Create
	 *
	 * @return List of inserted LiveChatVisitor
	 */
	@TestVisible
	private static List<LiveChatVisitor> generateChatVisitors(Integer numberOfChatVisitor)
	{
		List<LiveChatVisitor> newChatVisitors = new List<LiveChatVisitor>();

		for(Integer i = 0; i < numberOfChatVisitor; i++)
		{
			newChatVisitors.add(CMN_DAL_DataFactory.newChatVisitor());
		}

		insert newChatVisitors;

		return newChatVisitors;
	}

	/**
	 * @description Will insert a list of LiveChatTranscript
	 *
	 * @param caseId Case to which the LiveChatTranscript should be linked
	 * @param contactId Contact to which the LiveChatTranscript should be linked
	 * @param visitorId LiveChatVisitor to which the LiveChatTranscript should be linked
	 * @param numberOfChatTranscripts Number of Items to Create
	 *
	 * @return List of inserted LiveChatTranscript
	 */
	@TestVisible
	private static List<LiveChatTranscript> generateChatTranscripts(Id caseId, Id contactId, Id visitorId, Integer numberOfChatTranscripts)
	{
		List<LiveChatTranscript> newChatTranscripts = new List<LiveChatTranscript>();

		for(Integer i = 0; i < numberOfChatTranscripts; i++)
		{
			newChatTranscripts.add(newChatTranscript(caseId, contactId, visitorId));
		}

		insert newChatTranscripts;

		return newChatTranscripts;
	}

	/**
	 * @description Will generate a new LiveChatTranscript
	 *
	 * @param caseId The case to which the chat transcript should be linked
	 * @param contactId The contact to which the chat transcript should be linked
	 * @param visitorId The visitor Id of the chat transcript
	 *
	 * @return A new uncommitted LiveChatTranscript
	 */
	private static LiveChatTranscript newChatTranscript(Id caseId, Id contactId, Id visitorId)
	{
		LiveChatTranscript newChatTranscript = CMN_DAL_DataFactory.newChatTranscript(visitorId);

		newChatTranscript.CaseId = caseId;
		newChatTranscript.ContactId = contactId;

		return newChatTranscript;
	}

	/**
	 * @description Will generate a new uncommitted contact channel object
	 *
	 * @return A contact channel object
	 */
	private static amazonconnect__AC_ContactChannels__c newContactChannel()
	{
		amazonconnect__AC_ContactChannels__c contactChannel = new amazonconnect__AC_ContactChannels__c();
		contactChannel.amazonconnect__ContactId__c = CMN_DAL_SObjectDomain.generateRandomName();
		return contactChannel;
	}

	/**
	 * @description Will insert a new contact channel object
	 *
	 * @return A contact channel object
	 */
	@TestVisible
	private static amazonconnect__AC_ContactChannels__c insertContactChannel()
	{
		amazonconnect__AC_ContactChannels__c contactChannel = newContactChannel();
		insert contactChannel;
		return contactChannel;
	}

	/**
	 * @description Will generate a new Identity Document Object
	 *
	 * @return A new uncommitted Identity Document
	 */
	private static IdentityDocument newIdentityDocument()
	{
		IdentityDocument newIdentityDocument = new IdentityDocument();

		newIdentityDocument.Name = CMN_DAL_SObjectDomain.generateRandomNumber();

		return newIdentityDocument;
	}

	/**
	 * @description Will generate a new Entitlement
	 *
	 * @param accountId
	 *
	 * @return A new Entitlement
	 */
	@TestVisible
	private static Entitlement generateEntitlement(Id accountId)
	{
		Entitlement newEntitlement = new Entitlement();

		newEntitlement.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newEntitlement.AccountId = accountId;
		newEntitlement.Type = ENTITLEMENT_TYPE;
		newEntitlement.StartDate = Date.valueOf(System.now().addDays(-2));
		newEntitlement.EndDate = Date.valueOf(System.now().addYears(2));

		insert newEntitlement;
		return newEntitlement;
	}

	/**
	 * @description Will generate a new Teams
	 *
	 * @param numberOfItems Number of items to generate
	 * @param active
	 *
	 * @return List of Teams
	 */
	@TestVisible
	private static List<CMN_Team__c> generateTeams(Integer numberOfItems, Boolean active)
	{
		List<CMN_Team__c> newTeams = new List<CMN_Team__c>();

		for(Integer i = 0; i < numberOfItems; i++)
		{
			CMN_Team__c team = createNewTeam(active);
			newTeams.add(team);
		}

		insert newTeams;

		return newTeams;
	}

	/**
	 * @description Will creat new team
	 *
	 * @param active
	 *
	 * @return An unsaved team
	 */
	@TestVisible
	private static CMN_Team__c createNewTeam(Boolean active)
	{
		CMN_Team__c team = new CMN_Team__c();

		team.Name = CMN_DAL_SObjectDomain.generateRandomName();
		team.CMN_Active__c = active;
		team.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomEmail();

		return team;
	}

	/**
	 * @description Will generate service team
	 *
	 * @param serviceTypeId The service type id
	 * @param teamId The team Id
	 *
	 * @return An unsaved service team
	 */
	@TestVisible
	private static SVC_ServiceTeam__c newServiceTeam(Id serviceTypeId, Id teamId)
	{
		SVC_ServiceTeam__c newServiceTeam = new SVC_ServiceTeam__c();
		newServiceTeam.SVC_ServiceType__c = serviceTypeId;
		newServiceTeam.CMN_Team__c = teamId;
		newServiceTeam.SVC_Active__c = ACTIVE_TRUE;

		return newServiceTeam;
	}

	/**
	 * @description Will generate team members
	 *
	 * @param type
	 * @param teamId
	 * @param numberOfItems
	 *
	 * @return List of Team Members
	 */
	@TestVisible
	private static List<CMN_TeamMember__c> generateTeamMembers(String type, Id teamId, Integer numberOfItems)
	{
		List<CMN_TeamMember__c> newTeamMembers = new List<CMN_TeamMember__c>();

		for(Integer i = 0; i < numberOfItems; i++)
		{
			CMN_TeamMember__c teamMember = new CMN_TeamMember__c();

			teamMember.CMN_Type__c = type;
			teamMember.CMN_Team__c = teamId;

			newTeamMembers.add(teamMember);
		}

		insert newTeamMembers;
		return newTeamMembers;
	}

}