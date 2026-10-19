/**
 * @description Used to create Data, mostly for unit tests
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 /**
* @description SFP-54443 - Creates an inbound Webservice Call Queue record and safely populates
 *              the request payload. The method retrieves the current REST request body,
 *              defaults to an empty string when no request is available, and truncates
 *              the payload to the maximum length supported by the CMN_Request__c field
 *              to prevent DML exceptions caused by exceeding the field length.
*@LastModified by : Amlendu Bajpai
*Group : SBFC
*Last Modified Date : 08-07-2026
 */

@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class CMN_DAL_DataFactory
{
	private static final String DEFAULT_CHRON_EXPRESSION = '0 0 * * * ?';
	private static final String FULL_MONTH_DATE_FORMAT = 'MMMMM';

	/**
	 * @description Will create feature switch that indicates a particular API should be disabled for the running user
	 *
	 * @param apiName The class name of the API to disable
	 */
	@TestVisible
	private static void disableAPI(String apiName)
	{
		CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();
		newSwitch.CMN_APIsToDisableList1__c = apiName;

		upsert newSwitch;
	}
      
	      /**
	   * @description Method is use return the new Account with record type
	   *
	   * @return newAccount
	   */
	  public static Account newAccount() {
	    Account newAccount = new Account();

	    newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
	    newAccount.AnnualRevenue = CMN_DAL_SObjectDomain.generateRandomDecimal();
	    newAccount.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

	    return newAccount;
	  }

	  /**
	   * @description Method is use insert a new Account (Can Use this method in Test class)
	   *
	   * @return newAccount
	   */
	  @TestVisible
	  private static Account insertAccount() {
	    Account newAccount = newAccount();
	    insert newAccount;

	    return newAccount;
	  }

	/**
	 * @description Will create feature switch that indicates a particular API should be mocked for the running user
	 *
	 * @param apiName The class name of the API to Mock
	 */
	@TestVisible
	private static void mockAPI(String apiName)
	{
		CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();
		newSwitch.CMN_APIsToMockList1__c = apiName;

		upsert newSwitch;
	}

	/**
	 * @description Will Create feature custom setting and upsert it
	 *
	 * @param setupOwnerId The owner of the custom setting
	 */
	@TestVisible
	private static void createFeatureSwitch(Id setupOwnerId)
	{
		CMN_FeatureSwitches__c newSwitch = CMN_FeatureSwitches__c.getInstance();

		newSwitch.SetupOwnerId = setupOwnerId;

		newSwitch.CMN_DisableAllOutboundAPICalls__c = false;
		newSwitch.CMN_MockAllOutboundAPICalls__c = false;

		upsert newSwitch;
	}

	/**
	 * @description This method is use to create new record in Custom Setting newSpcUsersToEnable
	 *
	 * @param name Setting Name
	 * @param profileName Profile Name for Setting
	 * @param userName User Name for Setting
	 *
	 * @return A new Custom Setting Row
	 */
	@TestVisible
	private static CMN_SPC_UsersToEnable__c newSpcUsersToEnable(String name, String profileName, String userName)
	{
		CMN_SPC_UsersToEnable__c newUsersToEnable = new CMN_SPC_UsersToEnable__c();

		newUsersToEnable.Name = name;

		newUsersToEnable.CMN_SPC_EnableProfileName__c = profileName;
		newUsersToEnable.CMN_SPC_EnableUsername__c = userName;

		return newUsersToEnable;
	}

	/**
	 * @description Will create a row in the custom setting CMN_TriggersToDisable__c, thereby disabling said trigger
	 *
	 * @param triggerName The name of the trigger to disable
	 */
	@TestVisible
	private static void disableTrigger(String triggerName)
	{
		CMN_TriggersToDisable__c newTriggersToDisable = new CMN_TriggersToDisable__c();

		newTriggersToDisable.Name = triggerName;
		newTriggersToDisable.CMN_ClassName__c = triggerName;

		insert newTriggersToDisable;
	}

	/**
	 * @description This method is use to get the user with profile
	 *
	 * @param profileName The profile that should be linked to the new user
	 *
	 * @return A user that's not inserted
	 */
	public static User newUser(String profileName)
	{
		User newUser = new User();

		newUser.ProfileId = CMN_DAL_Profile.findByName(profileName).Id;

		newUser.Username = CMN_DAL_SObjectDomain.generateRandomEmail();
		newUser.Email = newUser.Username.toLowerCase();
		newUser.FederationIdentifier = newUser.Email;
		newUser.LastName = CMN_DAL_SObjectDomain.generateRandomName();
		newUser.FirstName = CMN_DAL_SObjectDomain.generateRandomName();
		newUser.Alias = CMN_DAL_SObjectDomain.generateRandomName().substring(0, 7);
		newUser.CommunityNickname = CMN_DAL_SObjectDomain.generateRandomName();

		User currentUser = CMN_DAL_User.getCurrentUser();

		newUser.TimeZoneSidKey = currentUser.TimeZoneSidKey;
		newUser.LocaleSidKey = currentUser.LocaleSidKey;
		newUser.EmailEncodingKey = currentUser.EmailEncodingKey;
		newUser.LanguageLocaleKey = currentUser.LanguageLocaleKey;

		newUser.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

		newUser.IsActive = true;

		return newUser;
	}

	/**
	 * @description Will create an account and set's it record type based on developer name
	 *
	 * @param recordTypeDeveloperName Record Type developer name
	 *
	 * @return A new account (uncommitted)
	 */
	public static Account newAccount(String recordTypeDeveloperName)
	{
		Account newAccount = new Account();

		newAccount.AnnualRevenue = CMN_DAL_SObjectDomain.generateRandomDecimal();
		newAccount.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();

		RecordTypeInfo recordTypeInfo = CMN_DAL_SObjectDomain.getRecordTypeInfo(Account.SObjectType, recordTypeDeveloperName);
		newAccount.RecordTypeId = recordTypeInfo?.recordTypeId;

		Boolean isBusiness = true;

		if(newAccount.RecordTypeId != null)
		{
			RecordType accountRecordType = CMN_DAL_RecordType.findById(newAccount.RecordTypeId);
			isBusiness = !accountRecordType.IsPersonType;
		}

		if(isBusiness)
		{
			//This is a business Account
			newAccount.Name = CMN_DAL_SObjectDomain.generateRandomName();
		}
		else
		{
			//This is a person account
			newAccount.LastName = CMN_DAL_SObjectDomain.generateRandomName();
			newAccount.PersonMobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
			newAccount.PersonHomePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
			newAccount.PersonEmail = CMN_DAL_SObjectDomain.generateRandomEmail();
			newAccount.PersonBirthdate = CMN_DAL_SObjectDomain.generateRandomDate();
			newAccount.PersonHasOptedOutOfFax = true;
		}

		return newAccount;
	}

	/**
	 * @description Method is use return the new Person Account
	 *
	 * @return A new account (uncommitted)
	 */
	public static Account newPersonAccount()
	{
		Account newAccount = newAccount(CMN_DAL_Account.PERSON_RECORD_TYPE);
		return newAccount;
	}
	  /**
	   * @description Method is use insert a new Application (Can Use this method in Test class)
	   * @input accountId
	   * @return new Application
	   */
	  @TestVisible
	  private static AOB_Application__c insertApplication(Id accountId) {
	    AOB_Application__c app = new AOB_Application__c(
	      AOB_Customer__c = accountId
	    );
	    insert app;

	    return app;
	  }

	  /**
	   * @description Method is use return the a new Contact
	   *
	   * @return newly created Contact, not committed yet
	   */
	  public static Contact newContact() {
	    Contact newContact = new Contact();

	    newContact.LastName = CMN_DAL_SObjectDomain.generateRandomName();
	    newContact.MobilePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
	    newContact.Phone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
	    newContact.HomePhone = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
	    newContact.Email = CMN_DAL_SObjectDomain.generateRandomEmail();
	    newContact.Birthdate = CMN_DAL_SObjectDomain.generateRandomDate();
	    newContact.HasOptedOutOfFax = true;
	    newContact.CMN_CustomerBPID__c = CMN_DAL_SObjectDomain.generateRandomNumber();
	    newContact.CMN_BPGUID__c = CMN_UTIL_Random.randomUUID();
	    newContact.CMN_IdentityNumber__c = CMN_DAL_SObjectDomain.generateRandomNumber();

	    return newContact;
	  }
	/**
	 * @description Method is use return the new Business Account
	 *
	 * @return A new account (uncommitted)
	 */
	public static Account newBusinessAccount()
	{
		Account newAccount = newAccount(CMN_DAL_Account.BUSINESS_RECORD_TYPE);
		return newAccount;
	}

	/**
	 * @description Method is use insert a new Business Account (Can Use this method in Test class)
	 *
	 * @return a new account (committed)
	 */
	@TestVisible
	private static Account insertBusinessAccount()
	{
		Account newAccount = newBusinessAccount();

		insert newAccount;

		return newAccount;
	}
	/**
	 * @description Will save email binary attachments as content associated with an Object
	 *
	 * @param linkToObjectId The object against which the attachments should be saved
	 * @param binaryAttachments The binary attachments of an email
	 *
	 * @return Newly created ContentVersion, not inserted
	 */
	public static List<ContentVersion> newContentVersionsFromBinaryAttachments(Id linkToObjectId, List<Messaging.InboundEmail.BinaryAttachment> binaryAttachments)
	{
		List<ContentVersion> newContentVersions = new List<ContentVersion>();

		if(binaryAttachments != null)
		{
			for(Messaging.InboundEmail.BinaryAttachment binaryAttachment : binaryAttachments)
			{
				newContentVersions.add(newContentVersion(linkToObjectId, binaryAttachment.fileName, binaryAttachment.body));
			}
		}

		return newContentVersions;
	}

	/**
	 * @description Will save email text attachments as content associated with an Object
	 *
	 * @param linkToObjectId The object against which the attachments should be saved
	 * @param textAttachments The text attachments of an email
	 *
	 * @return Newly created ContentVersion, not inserted
	 */
	public static List<ContentVersion> newContentVersionsFromTextAttachments(Id linkToObjectId, List<Messaging.InboundEmail.TextAttachment> textAttachments)
	{
		List<ContentVersion> newContentVersions = new List<ContentVersion>();

		if(textAttachments != null)
		{
			for(Messaging.InboundEmail.TextAttachment textAttachment : textAttachments)
			{
				newContentVersions.add(newContentVersion(linkToObjectId, textAttachment.fileName, Blob.valueOf(textAttachment.body)));
			}
		}

		return newContentVersions;
	}

	/**
	 * @description Will create a new Content Version
	 *
	 * @param linkToObjectId To which object should this Content be linked
	 * @param fileName The file name of the Content
	 * @param body The binary body of the content
	 *
	 * @return A newly created item, (not inserted)
	 */
	public static ContentVersion newContentVersion(Id linkToObjectId, String fileName, Blob body)
	{
		ContentVersion newContentVersion = new ContentVersion();

		newContentVersion.FirstPublishLocationId = linkToObjectId;
		newContentVersion.PathOnClient = fileName;
		newContentVersion.Title = fileName;
		newContentVersion.VersionData = body;

		return newContentVersion;
	}

	
	/**
	 * @description Will generate an inbound email envelope
	 *
	 * @return Email Envelope
	 */
	@TestVisible
	private static Messaging.InboundEnvelope newInboundEnvelope()
	{
		Messaging.InboundEnvelope newEnvelope = new Messaging.InboundEnvelope();

		newEnvelope.fromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		newEnvelope.toAddress = CMN_DAL_SObjectDomain.generateRandomEmail();

		return newEnvelope;
	}

	private static final String DUMMY_FILE_PATH = '/dummy/local/directory/';
	private static final String TEXT_FILE_EXTENSION = '.txt';
	@TestVisible
	private static final Integer NUMBER_HEADERS_AND_ATTACHMENTS_TO_CREATE = 10;
	@TestVisible
	private static final Integer NUMBER_ATTACHMENTS_TO_CREATE = NUMBER_HEADERS_AND_ATTACHMENTS_TO_CREATE;

	/**
	 * @description Will generate an inbound email
	 *
	 * @return Inbound Email
	 */
	@TestVisible
	private static Messaging.InboundEmail newInboundEmail()
	{
		Messaging.InboundEmail newEmail = new Messaging.InboundEmail();

		newEmail.fromAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		newEmail.fromName = CMN_DAL_SObjectDomain.generateRandomName();
		newEmail.subject = CMN_DAL_SObjectDomain.generateRandomDescription();
		newEmail.plainTextBody = CMN_DAL_SObjectDomain.generateRandomDescription();
		newEmail.messageId = CMN_DAL_SObjectDomain.generateRandomNumber();

		newEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>();
		newEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>();
		newEmail.headers = new List<Messaging.InboundEmail.Header>();

		for(Integer i = 0; i < NUMBER_HEADERS_AND_ATTACHMENTS_TO_CREATE; i++)
		{
			Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();

			binaryAttachment.body = Blob.valueOf(CMN_DAL_SObjectDomain.generateRandomDescription());
			binaryAttachment.fileName = DUMMY_FILE_PATH + CMN_DAL_SObjectDomain.generateRandomName() + TEXT_FILE_EXTENSION;
			binaryAttachment.mimeTypeSubType = TEXT_FILE_EXTENSION;

			newEmail.binaryAttachments.add(binaryAttachment);

			Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();

			textAttachment.body = binaryAttachment.body.toString();
			textAttachment.fileName = binaryAttachment.fileName;
			textAttachment.mimeTypeSubType = binaryAttachment.mimeTypeSubType;

			newEmail.textAttachments.add(textAttachment);

			Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();

			header.name = CMN_DAL_SObjectDomain.generateRandomName();
			header.value = CMN_DAL_SObjectDomain.generateRandomName();

			newEmail.headers.add(header);

		}

		return newEmail;
	}

	/**
	 * @description This method is use to get the scheduler class to run the schedule job
	 *
	 * @param schedulerClassName The name of the class to run
	 *
	 * @return a scheduler object not inserted
	 */
	@TestVisible
	private static CMN_JobScheduler__c newJobScheduler(String schedulerClassName)
	{
		CMN_JobScheduler__c scheduler = new CMN_JobScheduler__c();

		scheduler.CMN_Description__c = CMN_DAL_SObjectDomain.generateRandomDescription();
		scheduler.CMN_SchedulerName__c = CMN_DAL_SObjectDomain.generateRandomName();
		scheduler.CMN_ScheduleClassName__c = schedulerClassName;
		scheduler.CMN_CronExpression__c = DEFAULT_CHRON_EXPRESSION;

		return scheduler;
	}

	/**
	 * @description This method is use to insert the object in scheduler class
	 *
	 * @param schedulerClassName The name of the class to run
	 *
	 * @return a newly inserted row
	 */
	@TestVisible
	private static CMN_JobScheduler__c insertJobScheduler(String schedulerClassName)
	{
		CMN_JobScheduler__c scheduler = newJobScheduler(schedulerClassName);

		CMN_DAL_SObjectDomain.insertDBObject(scheduler);

		return scheduler;
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @return A webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newWebserviceQueue()
	{
		CMN_WebserviceCallQueue__c queueItem = new CMN_WebserviceCallQueue__c();

		queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_QUEUED;
		queueItem.CMN_Retries__c = 0;

		return queueItem;
	}

	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @param serviceName The name of the webservice class
	 *
	 * @return A webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newWebserviceQueue(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue();

		queueItem.CMN_Service__c = serviceName;

		return queueItem;
	}
        
	/**
	   * @description This method is use to return a WebServiceQueue record based on the input fields
	   *
	   * @return A webservice queue object, not inserted
	   */
	  public static CMN_WebserviceCallQueue__c newWebserviceQueue(
	    String status,
	    Id trigeringObjId,
	    String statusCode,
	    String serviceName
	  ) {
	    CMN_WebserviceCallQueue__c queueItem = new CMN_WebserviceCallQueue__c();
	    queueItem.CMN_Status__c = status;
	    queueItem.CMN_TriggeringObjectId__c = trigeringObjId;
	    queueItem.CMN_StatusCode__c = statusCode;
	    queueItem.CMN_Service__c = serviceName;
	    return queueItem;
	  }
	/**
	 * @description This method is use to display Webservice call queue date.
	 *
	 * @param serviceName The name of the webservice class
	 *
	 * @return An inbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newInboundWebserviceQueue(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue(serviceName);

		queueItem.CMN_Type__c = CMN_DAL_WebserviceCallQueue.TYPE_INBOUND;
		queueItem.CMN_StatusCode__c = CMN_UTIL_String.EMPTY;
		queueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_COMPLETED;
		queueItem.CMN_Response__c = CMN_UTIL_String.EMPTY;
		String requestBody = RestContext.request?.requestBody != null
			? RestContext.request.requestBody.toString()
			: CMN_UTIL_String.EMPTY;

		queueItem.CMN_Request__c =
			requestBody.length() > CMN_DAL_WebserviceCallQueue.REQUEST_LEN
				? requestBody.substring(0, CMN_DAL_WebserviceCallQueue.REQUEST_LEN)
				: requestBody;
		queueItem.CMN_Errors__c = CMN_UTIL_String.EMPTY;

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the service for this queue item
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = newWebserviceQueue(serviceName);
		queueItem.CMN_Type__c = CMN_DAL_WebserviceCallQueue.TYPE_OUTBOUND;

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the webservice class
	 * @param triggeringObjectId The object that is triggering the service class
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId)
	{
		CMN_WebserviceCallQueue__c queueItem = newOutboundWebserviceQueue(serviceName);

		queueItem.CMN_TriggeringObjectId__c = triggeringObjectId;

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the webservice class
	 * @param triggeringObjectId The object that is triggering the service class
	 * @param requestParameters The name/value pair of parameters used in construction of the request
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId, Map<String, String> requestParameters)
	{
		CMN_WebserviceCallQueue__c queueItem = newOutboundWebserviceQueue(serviceName, triggeringObjectId);

		CMN_DTO_NameValues dtoNameValues = new CMN_DTO_NameValues(requestParameters);
		queueItem.CMN_Request_Parameters__c = dtoNameValues.items.isEmpty() ? queueItem.CMN_Request_Parameters__c : dtoNameValues.serialize();

		return queueItem;
	}

	/**
	 * @description This method is use to get the outbound of webservice call queue.
	 *
	 * @param serviceName The name of the webservice class
	 * @param triggeringObjectId The object that is triggering the service class
	 * @param parameterName The name of additional parameter to passed to service
	 * @param parameterValue The value of the additional parameter
	 *
	 * @return An outbound webservice queue object, not inserted
	 */
	public static CMN_WebserviceCallQueue__c newOutboundWebserviceQueue(String serviceName, Id triggeringObjectId, String parameterName, String parameterValue)
	{
		return newOutboundWebserviceQueue(serviceName, triggeringObjectId, new Map<String, String>
		{
				parameterName => parameterValue
		});
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
		Case newCase = new Case();

		newCase.Subject = CMN_DAL_SObjectDomain.generateRandomName();
		newCase.Description = CMN_DAL_SObjectDomain.generateRandomDescription();
		newCase.ContactId = contactId;
		newCase.Reason = CMN_DAL_SObjectDomain.generateRandomName();

		return newCase;
	}

	/**
	 * @description Will instantiate a new foo with relevant fields filled
	 *
	 * @return A completed foo, note this foo is not saved to the database
	 */
	public static CMN_Foobar__c newFoobar()
	{
		CMN_Foobar__c newFoo = new CMN_Foobar__c();

		newFoo.CMN_Datetime__c = CMN_DAL_SObjectDomain.generateRandomDateTime();
		newFoo.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newFoo.CMN_Text__c = CMN_DAL_SObjectDomain.generateRandomDescription();
		newFoo.CMN_Phone__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		newFoo.CMN_NumberInteger__c = CMN_DAL_SObjectDomain.generateRandomInteger(2);
		newFoo.CMN_Checkbox__c = CMN_DAL_SObjectDomain.generateRandomBoolean();
		newFoo.RecordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.RT_DEFAULT);

		return newFoo;
	}

	/**
	 * @description Will instantiate a new recurring Holiday
	 *
	 * @param aDate The date for the recurring holiday
	 *
	 * @return A completed Holiday, note this Holiday is not saved to the database
	 */
	public static Holiday newRecurringHoliday(Date aDate)
	{
		Holiday newHoliday = new Holiday();
		Datetime aDatetime = Datetime.newInstance(aDate.year(), aDate.month(), aDate.day());

		newHoliday.RecurrenceStartDate = aDate;
		newHoliday.RecurrenceDayOfMonth = aDate.day();
		newHoliday.RecurrenceMonthOfYear = aDatetime.format(FULL_MONTH_DATE_FORMAT);
		newHoliday.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newHoliday.IsAllDay = true;
		newHoliday.IsRecurrence = true;
		newHoliday.RecurrenceType = CMN_DAL_Holiday.PICK_RECURS_YEARLY;

		return newHoliday;
	}

	/**
	 * @description Method is used to return a new LiveChatVisitor
	 *
	 * @return newChatVisitor
	 */
	public static LiveChatVisitor newChatVisitor()
	{
		LiveChatVisitor newChatVisitor = new LiveChatVisitor();
		return newChatVisitor;
	}

	/**
	 * @description Method is used to return a new LiveChatTranscript
	 *
	 * @param visitorId The visitor to which the transcript should be linked
	 *
	 * @return newChatTranscript
	 */
	public static LiveChatTranscript newChatTranscript(Id visitorId)
	{
		LiveChatTranscript newChatTranscript = new LiveChatTranscript();

		newChatTranscript.LiveChatVisitorId = visitorId;
		newChatTranscript.Body = CMN_DAL_SObjectDomain.generateRandomDescription();

		return newChatTranscript;
	}

	/**
	 * @description Will create a new (uncommitted) content workspace
	 *
	 * @param name The name to give the content workspace
	 *
	 * @return A content workspace object
	 */
	@TestVisible
	private static ContentWorkspace newContentWorkspace(String name)
	{
		ContentWorkspace library = new ContentWorkspace();
		library.Name = String.isBlank(name) ? CMN_DAL_SObjectDomain.generateRandomName() : name;
		library.DeveloperName = CMN_DAL_SObjectDomain.generateRandomName();
		library.Description = CMN_DAL_SObjectDomain.generateRandomDescription();
		return library;
	}

	/**
	 * @description Will create new (uncommitted) content folders
	 *
	 * @param num Number of folders to create
	 * @param parentFolderId id of parent folder to house the folders
	 *
	 * @return List of content folder objects
	 */
	@TestVisible
	private static List<ContentFolder> newContentFolders(Integer num, Id parentFolderId)
	{
		List<ContentFolder> folders = new List<ContentFolder>();
		for(Integer i = 0; i < num; i++)
		{
			folders.add(newContentFolder(parentFolderId));
		}
		return folders;
	}

	/**
	 * @description Will create a new (uncommitted) content folder
	 *
	 * @return A content folder object
	 */
	@TestVisible
	private static ContentFolder newContentFolder()
	{
		return newContentFolder(CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description Will create a new (uncommitted) content folder
	 *
	 * @param name The name to give the content folder
	 *
	 * @return A content folder object
	 */
	@TestVisible
	private static ContentFolder newContentFolder(String name)
	{
		ContentFolder folder = new ContentFolder();
		folder.Name = String.isBlank(name) ? CMN_DAL_SObjectDomain.generateRandomName() : name;
		return folder;
	}

	/**
	 * @description Will create a new (uncommitted) content folder
	 *
	 * @param parentFolderId The Id of the parent content workspace
	 *
	 * @return A content folder object
	 */
	@TestVisible
	private static ContentFolder newContentFolder(Id parentFolderId)
	{
		ContentFolder fol = newContentFolder();
		fol.ParentContentFolderId = parentFolderId;
		return fol;
	}

	/**
	 * @description Generates new content versions
	 *
	 * @param num number of content versions
	 * @param contentWorkspaceId Id of the library the content versions should be published
	 *
	 * @return List of Content versions
	 */
	@TestVisible
	private static List<ContentVersion> newContentVersions(Integer num, Id contentWorkspaceId)
	{
		List<ContentVersion> contentVersions = new List<ContentVersion>();
		for(Integer i = 0; i < num; i++)
		{
			ContentVersion version = newContentVersion();
			version.FirstPublishLocationId = contentWorkspaceId;
			contentVersions.add(version);
		}
		return contentVersions;
	}

	/**
	 * @description Generates new content version
	 *
	 * @return Content version
	 */
	@TestVisible
	private static ContentVersion newContentVersion()
	{
		return newContentVersion(null);
	}

	/**
	 * @description Generates new content version
	 *
	 * @param title Title of the document
	 *
	 * @return Content version
	 */
	@TestVisible
	private static ContentVersion newContentVersion(String title)
	{
		ContentVersion doc = new ContentVersion();
		doc.Title = String.isBlank(title) ? CMN_DAL_SObjectDomain.generateRandomName() : title;
		doc.ContentUrl = CMN_DAL_SObjectDomain.generateRandomName();
		return doc;
	}

	/**
	 * @description Will publish log events
	 *
	 * @param numberofItems Number of items to create
	 */
	@TestVisible
	private static void publishLogEvents(Integer numberofItems)
	{
		for(Integer i = 0; i < numberofItems; i++) {
			//CMN_DAL_Logger.log(String.valueOf(i), 'CMN_DAL_Logger_TEST/testLimitBreach', LoggingLevel.INFO);
			CMN_UTIL_Logger.info(String.valueOf(i), 'CMN_DAL_Logger_TEST/testLimitBreach');
		}
	}

	/**
	 * @description Will generate a group
	 *
	 * @param type The Group type. See CMN_DAL_Group.Type
	 *
	 * @return A Group
	 */
	@TestVisible
	private static Group insertGroup(String type)
	{
		Group newGroup = new Group();

		newGroup.Name = CMN_DAL_SObjectDomain.generateRandomName();
		newGroup.Type = type;
		newGroup.Email = CMN_DAL_SObjectDomain.generateRandomEmail();

		insert newGroup;
		return newGroup;
	}
}