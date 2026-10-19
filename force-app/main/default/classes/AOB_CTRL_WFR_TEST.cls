/*
* @description Test for the web facial recognition component
*
* <p>DBP-1459</p>
*
* @author Gill Lumley
*
* @date Aprl 1st 2022
*
* ACTION  TICKET    DATE       OWNER         COMMENTgetappsettings
setCorrelationId
* Changed SFP-9129  01-04-2022 Gill Lumley   Add method getWFRRetryIndicatorTest
* Changed SFP-10055 01-04-2022 Gill Lumley   Add method getWFRDetailsTest (also used by SFP-10057)
*/

@isTest
public class AOB_CTRL_WFR_TEST {
     /**
     * @description test Set Up
     */
	@TestSetup
	public static void testSetUp() {
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
		Map<string, string> applicationData = new Map<string, string>();
		Account acc = [
			SELECT id
			FROM account
			WHERE id IN (SELECT accountId FROM contact WHERE id = :communityUser.contactId)
		];
		System.runAs(communityUser) {
			ApplicationData.put('AOB_Customer__c', acc.id);
			insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c', applicationData);
		}
	}
 
      /**
     * @description Wfr Url test
     */
    	@isTest
	public static void aobGetWFRUrl2Test() {
        //boolean failed=false;
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			Test.startTest();
			string result = AOB_CTRL_WFR.getWFRUrl2('', '');
            system.assertNotEquals(result, '','');
            try {
            	string result2 = AOB_CTRL_WFR.getWFRUrl2(null, null);
                system.assertNotEquals(result2, '','');
            } catch(Exception e) {
                CMN_UTIL_Logger.error(e.getMessage(), 'aobGetWFRUrl2Test');



			}    
			Test.stopTest();
		}
	}
	/**
	 * @description This method is used to test callGetCustomerAPI_contact methd
	 */
	@isTest
	public static void getWFRUrlTestAOB() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			Test.startTest();
			string result = AOB_CTRL_WFR.getWFRUrl('', '', '');
            system.assertNotEquals(result, '','');
            try {
            	string result2 = AOB_CTRL_WFR.getWFRUrl(null, null, null);
                system.assertNotEquals(result2, '','');
            } catch (Exception e) {
				//System.debug(e);
				                CMN_UTIL_Logger.error(e.getMessage(), 'getWFRUrlTestAOB');

			}    

			Test.stopTest();
		}
	}

	/**
	 * @description This method is used to test callStartIDV methd
	 */
	@isTest
	public static void aobCallStartIDVTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			Test.startTest();
			AOB_API_StartIDV.DTO_Response result = AOB_CTRL_WFR.callStartIDV('', '');
            system.assertNotEquals(result, null,'');
            try {
            	AOB_API_StartIDV.DTO_Response result2 = AOB_CTRL_WFR.callStartIDV(null, null);
                system.assertNotEquals(result2, null,'');
            } catch (Exception e) {
				//System.debug(e);
								                CMN_UTIL_Logger.error(e.getMessage(), 'aobCallStartIDVTest');

			}        

			Test.stopTest();
		}
	}

	/**
	 * @description This method is used to test callGetIDVStatus methd
	 */
	@isTest
	public static void aobCallGetIDVStatusTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			Test.startTest();
			AOB_API_GetIDVStatus.DTO_Response result = AOB_CTRL_WFR.callGetIDVStatus('');
			Test.stopTest();
			system.assertNotEquals(result, null,'');
		}
	}

	/**
	 * @description This method is used to test callNotifyIDV methd
	 */
	@isTest
	public static void aobCallNotifyIDVTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			AOB_Application__c app = [SELECT id FROM AOB_Application__c];
			Test.startTest();
			AOB_API_notifyIDV.DTO_Response result = AOB_CTRL_WFR.callNotifyIDV(app.id, 'CorrId');
			Test.stopTest();
			system.assertNotEquals(result, null,'');
		}
	}
    
    @isTest
	public static void setCorrelationIdTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        Exception unexpectedException;
		System.runAs(communityUser) {
			AOB_Application__c app = [SELECT id, AOB_WFR_Retry_Number__c FROM AOB_Application__c LIMIT 1];
            AOB_Application__c appRec = [SELECT id, AOB_correlationId__c FROM AOB_Application__c Limit 1];
			Test.startTest();
			//System.debug('TESTING:' + app.id);
			AOB_CTRL_WFR.setCorrelationId(app.id,appRec.AOB_correlationId__c);
            	AOB_Application__c app2 = [
				SELECT id, AOB_correlationId__c
				FROM AOB_Application__c
				WHERE Id = :app.Id
				LIMIT 1
			];
            try{
               AOB_CTRL_WFR.setCorrelationId(app.id,'negativeTest'); 
            }
			catch (Exception e) {
              	unexpectedException = e;
                CMN_UTIL_Logger.error(e.getMessage(), 'aobIncrementWfrRetryTest');
				system.assertEquals(unexpectedException.getMessage(), 'List has no rows for assignment to SObject','');
				//System.debug(e);
			} 
            
			Test.stopTest();
        }
	}

	/**
	 * @description This method is used to test incrementWfrRetry methd
	 */
	@isTest
	public static void aobIncrementWfrRetryTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			AOB_Application__c app = [SELECT id, AOB_WFR_Retry_Number__c FROM AOB_Application__c LIMIT 1];
			Test.startTest();
			//System.debug('TESTING:' + app.id);
			AOB_CTRL_WFR.incrementWfrRetry(app.id);
			AOB_Application__c app2 = [
				SELECT id, AOB_WFR_Retry_Number__c
				FROM AOB_Application__c
				WHERE Id = :app.Id
				LIMIT 1
			];
            system.assertNotEquals(app.AOB_WFR_Retry_Number__c, app2.AOB_WFR_Retry_Number__c,'');

            try {
            AOB_CTRL_WFR.incrementWfrRetry(null);
            } catch (Exception e) {
              CMN_UTIL_Logger.error(e.getMessage(), 'aobIncrementWfrRetryTest');

				//System.debug(e);
			}    

			Test.stopTest();
		}
	}
    
    @isTest
	public static void aobIncrementWfrRetryReturnTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		System.runAs(communityUser) {
			AOB_Application__c app = [SELECT id, AOB_WFR_Retry_Number__c FROM AOB_Application__c LIMIT 1];
			Test.startTest();
			//System.debug('TESTING:' + app.id);
			AOB_CTRL_WFR.incrementWfrRetryReturn(app.id);
			AOB_Application__c app2 = [
				SELECT id, AOB_WFR_Retry_Number__c
				FROM AOB_Application__c
				WHERE Id = :app.Id
				LIMIT 1
			];
            Test.stopTest();
            system.assertNotEquals(app.AOB_WFR_Retry_Number__c, app2.AOB_WFR_Retry_Number__c,'');

            //AOB_CTRL_WFR.incrementWfrRetryReturn(null);

			
		}
	}


         @isTest
	public static void setWFRStatusTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        		//Exception unexpectedException;

		System.runAs(communityUser) {
            AOB_Application__c app = [SELECT id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
			Test.startTest();
            try{
            string wfrstatus = 'hello';
			AOB_CTRL_WFR.setWFRStatus(app.id,wfrstatus);
            }catch(Exception e){
              CMN_UTIL_Logger.error(e.getMessage(), 'setWFRStatusTest');
                system.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject','');
            }
             try{
			AOB_CTRL_WFR.setWFRStatus('133',null);
            }catch(Exception e){
                //system.debug('error'+e.getMessage());
               CMN_UTIL_Logger.error(e.getMessage(), 'setWFRStatusTest');
                system.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject','');
            }
            try {
            AOB_CTRL_WFR.setWFRStatus(null,null);
            } catch (Exception e) {
               	CMN_UTIL_Logger.error(e.getMessage(), 'setWFRStatusTest');
              	//system.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject');
            }    
			//system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception');

            Test.stopTest();
		}
	}
    
    /**
	 * @description setWFRStatus_Test negative test for exception handling code coverage
	 */
    
             @isTest
	public static void setWFRStatusTest2() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        		//Exception unexpectedException;

		System.runAs(communityUser) {
            //AOB_Application__c app = [SELECT id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
			Test.startTest();
            try{
            string wfrstatus = 'hello';
            string strBogusAppId = '1***#67';
			AOB_CTRL_WFR.setWFRStatus(strBogusAppId,wfrstatus);
           // System.debug('TESTING AOB_CTRL_WFR_TEST->setWFRStatus_Test2, appliationId:' + strBogusAppId);
            }catch(Exception e){
              CMN_UTIL_Logger.error(e.getMessage(), 'setWFRStatusTest');
               system.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject','');
            }
             try{
			AOB_CTRL_WFR.setWFRStatus('133',null);
            }catch(Exception e){
              CMN_UTIL_Logger.error(e.getMessage(), 'setWFRStatusTest');
              system.assertEquals(e.getMessage(), 'List has no rows for assignment to SObject','');
            }
            //system.assertEquals(unexpectedException.getMessage(), 'List has no rows for assignment to SObject');

            Test.stopTest();
		}
	}
    
	/**
	 * @description This method is used to test incrementWfrRetry exception
	 */
	@isTest
	public static void aobIncrementWfrRetryFailTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		Exception unexpectedException;
		System.runAs(communityUser) {
			Test.startTest();
			try {
				AOB_CTRL_WFR.incrementWfrRetry(null);
			} catch (Exception dmx) {
				unexpectedException = dmx;
                CMN_UTIL_Logger.error(dmx.getMessage(), 'aobIncrementWfrRetryFailTest');
				system.assertEquals(unexpectedException.getMessage(), 'List has no rows for assignment to SObject','');
			}
			Test.stopTest();
			//system.assertEquals(unexpectedException.getMessage(), 'List has no rows for assignment to SObject');
		}
	}

    	@isTest
	public static void fetchRetryCounterTest() {
		User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		Exception unexpectedException;
		System.runAs(communityUser) {
			Test.startTest();
			try {
				AOB_CTRL_WFR.fetchRetryCounter();
			} catch (Exception dmx) {
				unexpectedException = dmx;
				system.assertEquals(unexpectedException.getMessage(), 'List has no rows for assignment to SObject','');
            }

			Test.stopTest();
		}
	}
	/**
	 * @description This method is used to test getIdNumberFromAccountByAppId
	 */
	@isTest
	public static void getIdNumberFromAccountByAppIdTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_Customer__c FROM AOB_Application__c LIMIT 1];

		System.runAs(communityUser) {
			Test.startTest();
			String result = AOB_CTRL_WFR.getIdNumberFromAccountByAppId(Id.valueOf(app.Id));
			Test.stopTest();
			system.assertEquals(result, null,'');
		}
	}

	/**
	 * @description Method used to Test setCallBackRequested exception
	 */
	@isTest
	public static void getIdNumberFromAccountByAppIdExceptionTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			Test.startTest();
			try {
				String result = AOB_CTRL_WFR.getIdNumberFromAccountByAppId(null);
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
			}
			Test.stopTest();
			system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
		}
	}

	/**
	 * @description Method used to Test setCallBackRequested exception
	 */
	@isTest
	public static void getIdNumberFromAccountByAppIdExceptionNullTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			Test.startTest();
			try {
				String result = AOB_CTRL_WFR.getIdNumberFromAccountByAppId('123');
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
			}
			Test.stopTest();
			system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
		}
	}
	/**
	 * @description This method is used to test getAppSettingByCategory
	 */
	@isTest
	public static void getAppSettingByCategoryTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		//AOB_Application__c app = [SELECT Id, AOB_Customer__c FROM AOB_Application__c LIMIT 1];

		System.runAs(communityUser) {
			Test.startTest();
			Map<String, String> result = AOB_CTRL_WFR.getAppSettingByCategory('FLOW');
            system.assertNotEquals(result, null,'');
            try {
            	Map<String, String> result2 = AOB_CTRL_WFR.getAppSettingByCategory(null);
            } catch (Exception e) {
                              CMN_UTIL_Logger.error(e.getMessage(), 'getAppSettingByCategoryTest');
            }    

			Test.stopTest();
		}
	}

	/**
	 * @description This method is used to test getCommerceLink
	 */
	@isTest
	public static void getCommerceLinkTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_Customer__c FROM AOB_Application__c LIMIT 1];

		System.runAs(communityUser) {
			Test.startTest();
			String result = AOB_CTRL_WFR.getCommerceLink();
			Test.stopTest();
			system.assertNotEquals(result, null,'');
		}
	}

	/**
	 * @description This method is used to test CancelIDV
	 */
	@isTest
	public static void cancelIDVTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];

		System.runAs(communityUser) {
			Test.startTest();
			AOB_API_notifyIDV.DTO_Response result = AOB_CTRL_WFR.CancelIDV('9706075095086');
            
            try {
            	AOB_API_notifyIDV.DTO_Response result2 = AOB_CTRL_WFR.CancelIDV(null);
            } catch (Exception e) {
                              CMN_UTIL_Logger.error(e.getMessage(), 'cancelIDVTest');
                system.assertEquals(e.getMessage(), 'Script-thrown exception','');
            }        

			Test.stopTest();
           // system.assertNotEquals(result, null);
		}
	}

	/**
	 * @description This method is used to test CancelIDV excpetion 'WFR is Already completed'
	 */
	@isTest
	public static void cancelIDVFailTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_DONE_STATUS;
			update app;
			Test.startTest();
			try {
				AOB_API_notifyIDV.DTO_Response result = AOB_CTRL_WFR.CancelIDV('9706075095086');
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
				system.assertNotEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
            }

			Test.stopTest();
		}
	}

	/**
	 * @description This method is used to test CancelIDV excpetion 'there is no application related to this user'
	 */
	@isTest
	public static void cancelIDVAppIdNullFailTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_DONE_STATUS;
			update app;
			Test.startTest();
			try {
				AOB_API_notifyIDV.DTO_Response result = AOB_CTRL_WFR.CancelIDV(null);
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
			}
			Test.stopTest();
			system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
		}
	}

	/**
	 * @description This method is used to test callNotifyIDV excpetion 'WFR is Already completed'
	 */
	@isTest
	public static void callNotifyIDVFailTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_DONE_STATUS;
			update app;
			Test.startTest();
			try {
				AOB_API_notifyIDV.DTO_Response result = AOB_CTRL_WFR.callNotifyIDV(Id.valueOf(app.Id), '9706075095086');
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
			}
			Test.stopTest();
			system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
		}
	}

	/**
	 * @description This method is used to test CancelIDV excpetion 'there is no application related to this user'
	 */
	@isTest
	public static void callNotifyIDVAppIdNullFailTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_DONE_STATUS;
			update app;
			Test.startTest();
			try {
				AOB_API_notifyIDV.DTO_Response result = AOB_CTRL_WFR.callNotifyIDV(null, '9706075095086');
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
                system.assertEquals(dmx.getMessage(), 'Script-thrown exception','');
			}
			Test.stopTest();
			//system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception');
		}
	}

	/**
	 * @description This method is used to test updateBPGUID
	 */
	@isTest
	public static void updateBPGUIDTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_DONE_STATUS;
			update app;
			Test.startTest();
			try {
				String result = AOB_CTRL_WFR.updateBPGUID();
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
                system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
			}
            

			Test.stopTest();
		}
	}

	/**
	 * @description SFP-9129 - This method is used to test getWFRRetryIndicator
	 */
	@isTest
	public static void getWFRRetryIndicatorTest() {
		//User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		//AuraHandledException unexpectedException;
        app.id = null;
		Boolean retryIndicator;
		//System.runAs(communityUser) {
			Test.startTest();
        try {
			retryIndicator = AOB_CTRL_WFR.getWFRRetryIndicator(app.id);
            system.assertNotEquals(null, retryIndicator,'');
        } catch (Exception e) {
                              CMN_UTIL_Logger.error(e.getMessage(), 'getWFRRetryIndicatorTest');
        }    
		//}
        try {
            retryIndicator = AOB_CTRL_WFR.getWFRRetryIndicator(null);
        } catch (Exception e) {
                              CMN_UTIL_Logger.error(e.getMessage(), 'getWFRRetryIndicatorTest');
        }  
        Test.stopTest();

	}

	/**
	 * @description This method is used to test positive scenario of getWFRStatusIdNumberFromAccountByAppId
	 */
	@isTest
	public static void getWFRStatusIdNumberFromAccountByAppIdTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c LIMIT 1];

		System.runAs(communityUser) {
			Test.startTest();
			Map<String, String> result = AOB_CTRL_WFR.getWFRStatusIdNumberFromAccountByAppId(Id.valueOf(app.Id), true);
			Test.stopTest();
			system.assertNotEquals(result, null,'');
		}
	}

	/**
	 * @description Method used to Test setCallBackRequested exception
	 */
	@isTest
	public static void getWFRStatusIdNumberFromAccountByAppIdExceptionNullTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			Test.startTest();
			try {
				Map<String, String> result = AOB_CTRL_WFR.getWFRStatusIdNumberFromAccountByAppId(null, false);
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
			}
			Test.stopTest();
			system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
		}
	}

	/**
	 * @description Method used to Test setCallBackRequested exception
	 */
	@isTest
	public static void getWFRStatusIdNumberFromAccountByAppIdExceptionTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AuraHandledException unexpectedException;

		System.runAs(communityUser) {
			Test.startTest();
			try {
				Map<String, String> result = AOB_CTRL_WFR.getWFRStatusIdNumberFromAccountByAppId('123', false);
			} catch (AuraHandledException dmx) {
				unexpectedException = dmx;
			}
			Test.stopTest();
			system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
		}
	}

	/**
	 * @description SFP-10055/SFP-10057 - This method is used to test getWFRDetails
	 */
	@isTest
	public static void getWFRDetailsTest() {
		User communityUser = [SELECT Id, contactId FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
		AOB_Application__c app = [SELECT Id, AOB_TECH_WFRStatus__c FROM AOB_Application__c LIMIT 1];
		//AuraHandledException unexpectedException;
		AOB_Application__c appReturned;
		System.runAs(communityUser) {
			Test.startTest();
			appReturned = AOB_CTRL_WFR.getWFRDetails(app.id);
            system.assertNotEquals(null, appReturned,'');

            try{
            	appReturned = AOB_CTRL_WFR.getWFRDetails(null);
            } catch (Exception e) { 
                              CMN_UTIL_Logger.error(e.getMessage(), 'getWFRDetails');
            }

			Test.stopTest();
		}
		//system.debug('App Returned: '+appReturned);
	}

}