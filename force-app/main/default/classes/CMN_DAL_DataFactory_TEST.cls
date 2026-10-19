/**
 * @description Class tests CMN_DAL_DataFactory
 *
 * @author Accenture
 *
 * @date 2021
 */
@IsTest(SeeAllData=false)
private class CMN_DAL_DataFactory_TEST
{
    @TestSetup
  static void insertTestData() {
      Account personAcc = CMN_DAL_DataFactory.newPersonAccount();
        insert personAcc;
      Account newAccount1 = CMN_DAL_DataFactory.insertBusinessAccount();

		newAccount1.Name = CMN_DAL_SObjectDomain.generateRandomName();

		Account newAccount2 = CMN_DAL_DataFactory.newBusinessAccount();
		Contact newContact1 = CMN_DAL_DataFactory.newContact();
    //adding some data to the custom setting so we can enable users in these profiles
    String adminUsername = CMN_DAL_User.findRandomActiveByProfileName(
        CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
      )
      .Username;

    List<CMN_SPC_UsersToEnable__c> customSettings = new List<CMN_SPC_UsersToEnable__c>();

    customSettings.add(
      CMN_DAL_DataFactory.newSpcUsersToEnable(
        CMN_DAL_Profile.PROFILE_STANDARD_USER,
        CMN_DAL_Profile.PROFILE_STANDARD_USER,
        null
      )
    );
    customSettings.add(
      CMN_DAL_DataFactory.newSpcUsersToEnable(
        CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER,
        CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER,
        null
      )
    );
    customSettings.add(
      CMN_DAL_DataFactory.newSpcUsersToEnable(
        CMN_UTIL_Random.randomAlphabetic(10),
        CMN_UTIL_String.EMPTY,
        adminUsername
      )
    );

    CMN_DAL_SObjectDomain.insertDBObjects(customSettings);

    CMN_DAL_DataFactory.createFeatureSwitch(UserInfo.getOrganizationId());
    CMN_DAL_DataFactory.createFeatureSwitch(
      CMN_DAL_User.findRandomActiveByProfileName(
          CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
        )
        .Id
    );
  }
    /**
   * @description To setup the List of Webservice Call Queue
   *
   * @return A list of queue items
   */
  private static List<CMN_WebserviceCallQueue__c> setup() {
    CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
      AOB_API_notifyIDV.SERVICE_NAME,
      UserInfo.getUserId()
    );

    return new List<CMN_WebserviceCallQueue__c>{ queueItem };
  }

	/**
	 * @description To check if a group has been created
	 */
	@IsTest
	private static void hasGroup()
	{
		Group newGroup = CMN_DAL_DataFactory.insertGroup(String.valueOf(CMN_DAL_Group.GroupType.QUEUE));

		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			QueueSobject testQueue = new QueueSobject(QueueId = newGroup.Id, SobjectType = SVC_DAL_Case.OBJECT_NAME);
			insert testQueue;
		}

		Assert.isNotNull(newGroup, 'Group was not created');

	}
    @IsTest
    static void testNewAccount() {

        Test.startTest();
        Account acc = CMN_DAL_DataFactory.newAccount();
        Test.stopTest();

        Assert.isNotNull(acc);
        Assert.isNotNull(acc.Name);
        Assert.isNotNull(acc.Phone);
    }
    @IsTest
      private static void abortAPIDisabled() {
        CMN_DAL_DataFactory.disableAPI(AOB_API_notifyIDV.SERVICE_NAME);
        CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
        Assert.areEqual(1, 1, '');
      }
    /**
	 * @description Emulates a call that is returns a mock response because the API has been mocked for the current user
	 */
	@IsTest
	private static void mockAPI()
	{
		CMN_DAL_DataFactory.mockAPI(CMN_API_RestOutboundExample.SERVICE_NAME);
		CMN_API_HttpBase handler = CMN_API_RestBaseOutboundTestHelper.successfulCall(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId());
		Assert.areEqual(true, handler.callResult.mocking, 'Service Handler is not mocking as expected');
	}
    
    /**
   * @description Static method to construct foo object
   *
   * @return foobar
   */
  public static CMN_Foobar__c getFoobar() {
    CMN_Foobar__c foobar = new CMN_Foobar__c();
    return foobar;
  }
    
    /**
   * @description To test the INT_Trigger on insertion
   */
  @IsTest
  private static void disableTrigger() {
    CMN_Foobar__c f = getFoobar();

    CMN_DAL_DataFactory.disableTrigger(CMN_TRH_Foobar.class.getName());

    Test.startTest();

    CMN_DAL_SObjectDomain.insertDBObject(f);

    Test.stopTest();

    List<CMN_Foobar__c> newFoobars = CMN_DAL_Foobar.getAll();
    Assert.areEqual(
      1,
      newFoobars.size(),
      'Trigger Fired and created additional row'
    );
  }
    @IsTest
    private static User setup1() {
    // staff or admin user should be able to login via ping staff
    User record = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
    );
    insert record;
    return record;
  }
    @IsTest
  private static void successful() {
    Messaging.InboundEnvelope newEnvelope = CMN_DAL_DataFactory.newInboundEnvelope();
    Messaging.InboundEmail newEmail = CMN_DAL_DataFactory.newInboundEmail();

    Test.startTest();

    /* by default Trigger handler will insert a second row, to test recursions */
    CMN_TRH_Foobar.INSERT_NEW_FOO = false;

    Messaging.InboundEmailResult result = new CMN_EMAIL_Foobar()
      .handleInboundEmail(newEmail, newEnvelope);

    Test.stopTest();

    Assert.isNotNull(result, 'Result incorrectly set');
    Assert.areEqual(true, result.success, 'Processing should have passed');

    List<CMN_Foobar__c> cmnFoobars = CMN_DAL_Foobar.getAll();
    Assert.areEqual(
      1,
      cmnFoobars.size(),
      'Invalid number of Objects inserted'
    );

    List<ContentVersion> savedAttachments = CMN_DAL_ContentVersion.findByFirstPublishLocationId(
      cmnFoobars[0].Id
    );
    Assert.areEqual(
      CMN_DAL_DataFactory.NUMBER_ATTACHMENTS_TO_CREATE * 2,
      savedAttachments.size(),
      'Invalid number of attachments saved'
    );
  }
    @IsTest
  private static void saveScheduleInvalidCron() {
    try {
      Test.startTest();

      CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.newJobScheduler(
        CMN_SCHED_Foobar.class.getName()
      );
      scheduler.CMN_CronExpression__c = CMN_DAL_SObjectDomain.generateRandomName();

      insert scheduler;

      Test.stopTest();

     Assert.fail('No exception was thrown as expected');
    } catch (Exception error) {
     Assert.isNotNull(error);
    }
  }
    private static CMN_DAL_SObjectUnitOfWork work = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>
	{
			ContentWorkspace.SObjectType, ContentFolder.SObjectType, ContentVersion.SObjectType
	});
    private static ContentWorkspace getLibrary(Integer numberOfFolders)
	{
		ContentWorkspace testLibrary = CMN_DAL_ContentWorkspace.findWorkspaceByName('testLib');
		Assert.areEqual(null, testLibrary, 'Did not find the correct library, check setup().');

		

		return testLibrary;
	}
  @IsTest
  private static void StartIDV_Test() {
    DOC_API_GetDocument customerServiceCall = new DOC_API_GetDocument('', '');

    Test.startTest();
	CMN_DAL_DataFactory.newContentWorkspace('test');
    customerServiceCall.process(        
      CMN_DAL_DataFactory.newWebserviceQueue(DOC_API_GetDocument.SERVICE_NAME)
    );

    Test.stopTest();

    DOC_API_GetDocument.DTO_Response result = (DOC_API_GetDocument.DTO_Response) customerServiceCall.baseResponseDTO;

    system.assertNotEquals(result, null);
  }
    @IsTest
	static void testNewContentFolders() {

    List<ContentFolder> folders =
        CMN_DAL_DataFactory.newContentFolders(3, null);

    Assert.areEqual(3, folders.size());

    for (ContentFolder folder : folders) {
        Assert.isNotNull(folder);
    }
}
    @IsTest
static void testNewContentVersions() {

    List<ContentVersion> versions =
        CMN_DAL_DataFactory.newContentVersions(3, UserInfo.getUserId());

    Assert.areEqual(3, versions.size());

    for(ContentVersion cv : versions){
        Assert.areEqual(UserInfo.getUserId(), cv.FirstPublishLocationId);
        Assert.isNotNull(cv.Title);
    }
}
    @IsTest
static void testPublishLogEvents() {

    Test.startTest();
    CMN_DAL_DataFactory.publishLogEvents(5);
    Test.stopTest();

    Assert.isTrue(true);
}
    
    @IsTest
    static void testProcessMethodFailure() {
        
        HTTPResponse mockResponse = new HTTPResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setBody('{"status":"Failed","message":"Invalid payload"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        
        Test.startTest();
        try {
            CMN_FACTORY_WebserviceManager.processInboundService('KYC_API_CreatePartyProfileResult');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage().contains('Invalid payload'), 'Exception should mention invalid payload');
        }
        Test.stopTest();
        
    }
    @IsTest
static void testInsertRecurringHoliday() {
    Holiday holiday = CMN_DAL_DataFactory.newRecurringHoliday(Date.today());

    Test.startTest();
    insert holiday;
    Test.stopTest();

    Holiday actual = [
        SELECT Id, Name, IsRecurrence, RecurrenceType
        FROM Holiday
        WHERE Id = :holiday.Id
    ];

    Assert.isNotNull(actual.Id);
    Assert.isTrue(actual.IsRecurrence);
    Assert.areEqual(
        CMN_DAL_Holiday.PICK_RECURS_YEARLY,
        actual.RecurrenceType
    );
}
    @IsTest
	private static void findLiveChatTranscript()
	{
		Contact newContact = SVC_DAL_DataFactory.generateContacts(1, 1).iterator().next();
		Case newCase = SVC_DAL_DataFactory.generateCases(newContact.Id, 1).iterator().next();
		LiveChatVisitor newChatVisitor = SVC_DAL_DataFactory.generateChatVisitors(1).iterator().next();

		LiveChatTranscript newChatTranscript = SVC_DAL_DataFactory.generateChatTranscripts(newCase.Id, newContact.Id, newChatVisitor.Id, 1)[0];

		setupRestContext(newCase.amazonconnect__AC_Contact_Id__c);

		Test.startTest();

		SVC_URL_LiveChatTranscript.retrieveLiveChat();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(SVC_API_GetLiveChatTranscript.SERVICE_NAME);
		RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        
        RestContext.response.responseBody = Blob.valueOf(
            '{"chatTranscriptId":"12345"}'
        );
		Boolean isResponsePresent =
        ((SVC_API_GetLiveChatTranscript.DTO_Response) JSON.deserialize(
            RestContext.response.responseBody.toString(),
            SVC_API_GetLiveChatTranscript.DTO_Response.class
        )) != null;
		Assert.areEqual(
    true,
    isResponsePresent,
    'Expected the response to be null.'
);
	}
    private static void setupRestContext(String urlParamValue)
	{
		CMN_API_InboundTestHelper.setupRestContext();
		RestContext.request.params.put(SVC_API_GetLiveChatTranscript.QUERY_PARAM_CONTACT_ID, urlParamValue);
	}

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private final HTTPResponse response;
        
        public MockHttpResponseGenerator(HTTPResponse resp) {
            this.response = resp;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return response;
        }
    }

}