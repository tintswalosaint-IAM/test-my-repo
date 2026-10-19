/**
 * @description test class for CMN_UTIL_Logger
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author mlockett
 *
 * @date 2019-01-15
 */
@IsTest(SeeAllData=false)
private class CMN_UTIL_Logger_TEST {
  	private static final String RECORD_ID = 'my id';
  	private static final String CLASS_METHOD = 'foo/method';
  	private static final String MESSAGE = CMN_DAL_SObjectDomain.generateRandomName();
    
    @TestSetup
    private static void createData() {
        sbgplatform__rflib_Logger_Settings__c newrec = new sbgplatform__rflib_Logger_Settings__c
        	(sbgplatform__Archive_Log_Level__c='NONE',sbgplatform__Batched_Log_Event_Reporting_Level__c='NONE',
            sbgplatform__Client_Console_Log_Level__c='DEBUG',sbgplatform__Client_Log_Size__c=100,sbgplatform__Client_Server_Log_Level__c='INFO',
            sbgplatform__Email_Log_Level__c='NONE',sbgplatform__Enable_Log_Masking__c=false,sbgplatform__Flush_Log_Cache_Level__c='NONE',
            sbgplatform__Functions_Compute_Log_Level__c='DEBUG',sbgplatform__Functions_Log_Size__c=100,sbgplatform__Functions_Server_Log_Level__c='WARN',
            sbgplatform__General_Log_Level__c='TRACE',sbgplatform__Log_Event_Reporting_Level__c='INFO',
            sbgplatform__Log_Finalizer_Class__c='rflib_DefaultLogFinalizer',sbgplatform__Log_Size__c=100,
            sbgplatform__Log_Timer_Class__c='rflib_DefaultLogTimer',sbgplatform__Logger_Factory_Class__c='rflib_DefaultLoggerFactory',
            sbgplatform__System_Debug_Log_Level__c='DEBUG', SetupOwnerId=UserInfo.getOrganizationId());
        insert newrec;
    }

  	@IsTest
  	private static void debugWritesCorrectValues() {
		Test.startTest();
    	CMN_UTIL_Logger.debug(MESSAGE, CLASS_METHOD);
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='DEBUG'];
		Assert.areEqual(0, debugRecord.size(), 'No log stored for debug level');
  	}

	@IsTest
  	private static void infoWritesCorrectValues() {
		Test.startTest();
    	CMN_UTIL_Logger.info(MESSAGE, CLASS_METHOD);
		Test.getEventBus().deliver();		
        Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='INFO'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for info level');
  	}
    
    @IsTest
  	private static void errorWritesCorrectValues() {
    	Test.startTest();
    	CMN_UTIL_Logger.error(MESSAGE, CLASS_METHOD);
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for error level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
  	}

  	@IsTest
  	private static void debugWithIdWritesCorrectValues() {
		Test.startTest();
		CMN_UTIL_Logger.debug(MESSAGE, CLASS_METHOD, RECORD_ID);
		Test.getEventBus().deliver();
		Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='DEBUG'];
		Assert.areEqual(0, debugRecord.size(), 'No log stored for debug level');
  	}

  	@IsTest
  	private static void warnWritesCorrectValues() {
    	Test.startTest();
    	CMN_UTIL_Logger.warn(MESSAGE, CLASS_METHOD);
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='WARN'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for warning level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
  	}

	@IsTest
	private static void warnWithIdWritesCorrectValues() {
    	Test.startTest();
    	CMN_UTIL_Logger.warn(MESSAGE, CLASS_METHOD, RECORD_ID);
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='WARN'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for warning level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(RECORD_ID), 'Message log stored contains the record ID');
	}

	@IsTest
  	private static void errorWritesCorrectValues2() {
    	Test.startTest();
    	CMN_UTIL_Logger.error(MESSAGE, CLASS_METHOD, RECORD_ID);
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for error level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(RECORD_ID), 'Message log stored contains the class method');
  	}

  	@IsTest
  	private static void errorWritesCorrectValuesForException() {
    	Test.startTest();
    	try {
      		Double badNumber = 1 / 0;
    	} catch (Exception ex) {
      		CMN_UTIL_Logger.error(ex, CLASS_METHOD);
   	 	}
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for error level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase('Divide by 0'), 'Message log stored contains Divide by 0');
  	}

  	@IsTest
  	private static void errorWithIdWritesCorrectValuesForException() {  		
    	Test.startTest();
		try {
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		} catch (Exception ex) {
			CMN_UTIL_Logger.error(ex, CLASS_METHOD, RECORD_ID);
		}
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for error level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase('Divide by 0'), 'Message log stored contains Divide by 0');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(RECORD_ID), 'Message log stored contains the record ID');
  	}

	@IsTest
  	private static void errorWithIdShortMessageWritesCorrectValuesForException() {  		
		String shortMessage = 'Math Exception';
    	Test.startTest();
		try {
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		} catch (Exception ex) {
			CMN_UTIL_Logger.error(shortMessage, MESSAGE, CLASS_METHOD, RECORD_ID,ex);
		}
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'Log stored for error level');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(CLASS_METHOD), 'Message log stored contains the class method');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase('Divide by 0'), 'Message log stored contains Divide by 0');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(RECORD_ID), 'Message log stored contains the record ID');
		Assert.areEqual(true, debugRecord[0].sbgplatform__Log_Messages__c.containsIgnoreCase(shortMessage), 'Message log stored contains the short message');
  	}
}