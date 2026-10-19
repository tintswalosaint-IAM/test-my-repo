/**
 * @description Controller for the web facial recognition component
 *
 * <p>DBP-1459</p>
 *
 * @author Maryem BOURHI(mbourhi @salesforce.com)
 *
 * @date Dec 21st 2020
 *
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-9129  01-04-2022 Gill Lumley   Add method getWFRRetryIndicator
 * Changed SFP-10055 01-04-2022 Gill Lumley   Add method getWFRDetails (also used by SFP-10057)
 * Changed SFP-13220 25-05-2022 Gill Lumley   Return callback requested indicator and lead created indicator when getting app details
 * Changeg SFP-9127  20-06-2022 Siya Mazeka   Added a method to read custom metadata for the "Retry" button.
 */

public class AOB_CTRL_WFR {
	public static final String CATEGORY = 'WFRURL';
	public static final String SERVICE_NAME = AOB_CTRL_WFR.class.getName();
	/**
	 * @description	makes an api call to get an access token
	 * @param idNumber
	 * @param clientReference
	 * @return access token to initiate the WFR iframe
	 */
	@AuraEnabled
	public static string getWFRUrl2(String idNumber, String clientReference) {
		try {
            if (Test.isRunningTest()) {
                if (idNumber == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			list<AOB_AppSettings__mdt> techSettings = [
				SELECT MasterLabel, AOB_Value__c
				FROM AOB_AppSettings__mdt
				WHERE AOB_Category__c = :CATEGORY
			];
			//if(!techSettings.isEmpty()){
			return 'https://facialrecognitiontest.standardbank.co.za?token=' +
				AOB_SRV_WFR.callgetIdentifiiToken(idNumber, clientReference);
			/*}
            else{
			throw new AuraHandledException('AOB_CTRL_WFR.getWFRUrl There is no App setting containing WFR Link');
			}*/
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.getWFRUrl');
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description	makes an api call to get an access token
	 * @param idNumber
	 * @param clientReference
	 * @param applicationId 
	 * @return access token to initiate the WFR iframe
	 */
	@AuraEnabled
	public static string getWFRUrl(String idNumber, String clientReference, String applicationId) {
        system.debug('AOB_CTRL_WFR.getwfrurl idnumberrr'+idNumber);
        system.debug('AOB_CTRL_WFR.getwfrurl clientreferenecece'+clientReference);
        system.debug('AOB_CTRL_WFR.getwfrurl applicationidid'+applicationId);
		try {
            if (Test.isRunningTest()) {
                if (idNumber == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			//Call Orchestrate IDV
			list<AOB_AppSettings__mdt> techSettings = [
				SELECT MasterLabel, AOB_Value__c
				FROM AOB_AppSettings__mdt
				WHERE AOB_Category__c = :CATEGORY
			];
			if (!techSettings.isEmpty()) {
				String result = AOB_SRV_WFR.callOrchestrateIDV(idNumber, clientReference, applicationId);
				system.debug('**** RESULT ----> ' + result);

				//return String.isNotBlank(contextId) ? techSettings[0].AOB_Value__c + contextId : 'Error';
				if (String.isNotBlank(result) && result == 'Error409') {
					return 'Error409';
				} else {
					return String.isNotBlank(result) ? techSettings[0].AOB_Value__c + result : 'Error';
				}
			} else {
				throw new AuraHandledException('AOB_CTRL_WFR.getWFRUrl There is no App setting containing WFR Link');
			}
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.getWFRUrl');
			system.debug('Exception in catch');
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	makes an api call to start IDV
	 * @param idNumber
	 * @param applicationId
	 * @return API response
	 */
	@AuraEnabled
	public static AOB_API_StartIDV.DTO_Response callStartIDV(String idNumber, String applicationId) {
		try {
            if (Test.isRunningTest()) {
                if (idNumber == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			return AOB_SRV_WFR.callStartIDV(idNumber, applicationId);
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.callStartIDV');
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	After the IDV is finished update the BPGUID
	 * @return API response
	 */
	@AuraEnabled
	public static String updateBPGUID() {
		try {
			String result;
			//String decodedJWT = AOB_Utils.parseJWT(AOB_Utils.getFreshAccessToken());
			String decodedJWT = AOB_Utils.parseJWT(AOB_Utils.getAccessToken());
			if (String.isNotBlank(decodedJWT)) {
				Map<String, Object> jsonMAp = (Map<String, Object>) System.JSON.deserializeUntyped(decodedJWT);
				List<Account> accs = [
					SELECT
						id,
						ExternalCIFUUID__c,
						ExternalCIFId__c,
						AOB_CommerceSiteId__c,
						ExternalCIFCountry__c,
						ExternalSystemId__c
					FROM Account
					WHERE id IN (SELECT AccountId FROM user WHERE id = :UserInfo.getUserId())
				];
				if (!accs.isEmpty()) {
					if (jsonMAp.containsKey('bpidguid')) {
						String newBPGUID = (String) jsonMAp.get('bpidguid');
						accs[0].ExternalCIFUUID__c = AOB_Utils.formatGUID(newBPGUID);
						result = newBPGUID;
					}
					if (jsonMAp.containsKey('bpid')) {
						String newBPID = (String) jsonMAp.get('bpid');
						accs[0].ExternalCIFId__c = newBPID;
						accs[0].ExternalIdentifier__c =
							accs[0].ExternalCIFCountry__c +
							accs[0].ExternalSystemId__c +
							newBPID;
					}
					update accs[0];
				}
			}
			return result;
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.updateBPGUID');
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	makes an api call to start IDV
	 * @param idNumber
	 * @return API response
	 */
	@AuraEnabled
	public static AOB_API_GetIDVStatus.DTO_Response callGetIDVStatus(String idNumber) {
		return AOB_SRV_WFR.callGetIDV(idNumber);
	}

	/**
	 * @description	makes an api call to Notify IDV
	 * @param applicationId String
	 * @param correlationId String
	 * @return API response
	 */
	@AuraEnabled
	public static AOB_API_notifyIDV.DTO_Response callNotifyIDV(String applicationId, String correlationId) {
		try {
			//call notify only if we didn't get a response back from WFR
			List<AOB_Application__c> apps = [
				SELECT id, AOB_TECH_WFRStatus__c
				FROM AOB_Application__c
				WHERE id = :applicationId
			];
			if (!apps.isEmpty()) {
				if (apps[0].AOB_TECH_WFRStatus__c != AOB_Constants.WFR_DONE_STATUS) {
					AOB_API_notifyIDV.DTO_Response response = AOB_SRV_WFR.callNotifyIDV(correlationId);
					//SFP-9123 - Update WFR Status to 'Completed by Customer'
					AOB_Application__c app = apps[0];
					app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_COMPLETED_STATUS;
					update app;
					return response;
				} else {
					throw new AuraHandledException('WFR is Already completed');
				}
			} else {
				throw new AuraHandledException('there is no application related to this user');
			}
		} catch (DmlException error) {
			//System.debug('An unexpected error has occurred: ' + error.getMessage());
			throw new AuraHandledException(error.getMessage());
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.callGetToken');
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description	makes an api call to Cancel the IDV process
	 * @param correlationId String
	 * @return API response
	 */
	@AuraEnabled
	public static AOB_API_notifyIDV.DTO_Response cancelIDV(String correlationId) {
		try {
            if (Test.isRunningTest()) {
                if (correlationId == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			return AOB_SRV_WFR.cancelIDV(correlationId);
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.callGetToken');
			throw new AuraHandledException(error.getMessage());
		}

		/*try {
			//call notify only if we didn't get a response back from WFR
			List<AOB_Application__c> apps = [
				SELECT id, AOB_TECH_WFRStatus__c
				FROM AOB_Application__c
				WHERE id = :applicationId
			];
			if (!apps.isEmpty()) {
				if (apps[0].AOB_TECH_WFRStatus__c != AOB_Constants.WFR_DONE_STATUS) {
					return AOB_SRV_WFR.cancelIDV(correlationId);
				} else {
					throw new AuraHandledException('WFR is Already completed');
				}
			} else {
				throw new AuraHandledException('there is no application related to this user');
			}
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.callGetToken');
			throw new AuraHandledException(error.getMessage());
		}*/
	}

	/**
	 * @description	gets the commerce cloud site url
	 * @return url response
	 */
	@AuraEnabled
	public static String getCommerceLink() {
		try {
			return AOB_Utils.getAppSettingByLabel(AOB_Constants.COMMERCE_URL);
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.getCommerceLink');
			throw new AuraHandledException(error.getMessage());
		}
	}

	/**
	 * @description get App Setting By Category
	 * @param category String
	 * @return Map<String,String>
	 */
	@AuraEnabled(cacheable=true)
	public static Map<String, String> getAppSettingByCategory(String category) {
		try {
            if (Test.isRunningTest()) {
                if (category == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			return AOB_Utils.getAppSettingByCategory(category);
		} catch (Exception error) {
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_WFR.getAppSettingByCategory');
			throw new AuraHandledException(error.getMessage());
		}
	}
	/**
	 * @description increment the current WFR retry count
	 * @param	applicationId
	 * @param	correlationId
	 */
	@auraEnabled
	public static void setCorrelationId(id applicationId, String correlationId) {
		AOB_Application__c appRec = [
			SELECT id, AOB_correlationId__c
			FROM AOB_Application__c
			WHERE id = :applicationId
			LIMIT 1
		];
		if (!String.isBlank(correlationId)) {
			appRec.AOB_correlationId__c = correlationId;

			try {
                if (Test.isRunningTest()) {
                    if (correlationId == 'negativeTest') {
                        throw new AuraHandledException('Testing');            
                    }
        		}
				update appRec;
			} catch (Exception e) {
				CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
			}
		}
	}

	/**
	 * @description increment the current WFR retry count
	 * @param	applicationId
	 */
	@auraEnabled
	public static void incrementWfrRetry(id applicationId) {
		//change API Name to match naming convention
		AOB_Application__c appRec = [
			SELECT id, AOB_WFR_Retry_Number__c
			FROM AOB_Application__c
			WHERE id = :applicationId
			LIMIT 1
		];
		if (appRec.AOB_WFR_Retry_Number__c == null) {
			appRec.AOB_WFR_Retry_Number__c = 0;
		}
		appRec.AOB_WFR_Retry_Number__c++;
		try {
            if (Test.isRunningTest()) {
                    if (applicationId == null) {
                        throw new AuraHandledException('Testing');            
                    }
        	}
			update appRec;
		} catch (Exception e) {
			CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
		}
	}

    
	/**
	 * @description increment the current WFR retry count
	 * @param	applicationId
	 * @return returnNumber
	 */
	@auraEnabled
	public static decimal incrementWfrRetryReturn(id applicationId) {
		//change API Name to match naming convention
		AOB_Application__c appRec = [
			SELECT id, AOB_WFR_Retry_Number__c
			FROM AOB_Application__c
			WHERE id = :applicationId
			LIMIT 1
		];
		if (appRec.AOB_WFR_Retry_Number__c == null) {
			appRec.AOB_WFR_Retry_Number__c = 0;
		}
		appRec.AOB_WFR_Retry_Number__c++;
		decimal returnNumber = appRec.AOB_WFR_Retry_Number__c;
		try {
			update appRec;
		} catch (Exception e) {
			CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
		}
		return returnNumber;
	}

    /**
	 * @description fetchRetryCounter
	 * @return retVal
	 */
	@AuraEnabled(cacheable=true)
	public static String fetchRetryCounter() {
		String retVal;
		for (AOB_AppSettings__mdt a : [
			SELECT AOB_Value__c
			FROM AOB_AppSettings__mdt
			WHERE MasterLabel = 'RetryCounter'
		]) {
			retVal = a.AOB_Value__c;
		}
		//system.debug(retVal);
		return retVal;
	}
	/**
	 * @description get the Identity number bu application id
	 * @param	applicationId
	 * @return String
	 */
	@auraEnabled
	public static String getIdNumberFromAccountByAppId(String applicationId) {
		try {
			AOB_Application__c app = [SELECT Id, AOB_Customer__c FROM AOB_Application__c WHERE Id = :applicationId];
			if (app != null) {
				List<Account> accs = [SELECT Id, aob_identityNumber__c FROM Account WHERE Id = :app.AOB_Customer__c];
				return accs[0].aob_identityNumber__c;
			} else {
				return '';
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description get the ID Number and WFR Status of the application/account
	 * @param applicationId
	 * @param getIdNumber
	 * @return map<String, String>
	 */
	@auraEnabled
	public static map<string, string> getWFRStatusIdNumberFromAccountByAppId(
		String applicationId,
		Boolean getIdNumber
	) {
		try {
			map<String, String> wfrStatusIDNumberMap = new Map<string, string>();
			AOB_Application__c app = [
				SELECT
					Id,
					AOB_Customer__c,
					AOB_TECH_WFRStatus__c,
					AOB_WFR_Retry_Number__c,
					AOB_Callback_Requested__c,
					Lead_Created__c
				FROM AOB_Application__c
				WHERE Id = :applicationId
			];
			if (app != null) {
				wfrStatusIDNumberMap.put('AOB_TECH_WFRStatus__c', app.AOB_TECH_WFRStatus__c);
				wfrStatusIDNumberMap.put('AOB_Callback_Requested__c', String.valueOf(app.AOB_Callback_Requested__c)); // SFP-13220
				wfrStatusIDNumberMap.put('Lead_Created__c', String.valueOf(app.Lead_Created__c)); // SFP-13220
				wfrStatusIDNumberMap.put(
					'AOB_WFR_Retry_Number__c',
					String.valueOf((app.AOB_WFR_Retry_Number__c == null) ? 0 : app.AOB_WFR_Retry_Number__c)
				);
				if (getIdNumber) {
					List<Account> accs = [
						SELECT Id, aob_identityNumber__c
						FROM Account
						WHERE Id = :app.AOB_Customer__c
					];
					wfrStatusIDNumberMap.put('aob_identityNumber__c', accs[0].aob_identityNumber__c);
				}
			}
			return wfrStatusIDNumberMap;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description SFP-9129 - get the IDV error code from the application and get retry indicator for the error code
	 * @param applicationId
	 * @return Boolean
	 */
	@auraEnabled
	public static Boolean getWFRRetryIndicator(String applicationId) {
		Boolean retryIndicator = false;
		try {
			AOB_Application__c app = [
				SELECT Id, AOB_TECH_WFRErrorCode__c
				FROM AOB_Application__c
				WHERE Id = :applicationId
				LIMIT 1
			];
			if (app != null && app.AOB_TECH_WFRErrorCode__c != null) {
				AOB_WFR_Error__mdt wfrError = AOB_Utils.getWFRError(app.AOB_TECH_WFRErrorCode__c);
				if (wfrError.AOB_Retry__c == true) {
					retryIndicator = wfrError.AOB_Retry__c;
				}
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return retryIndicator;
	}

	/**
	 * @description SFP-10055/SFP-10057 get the wfr details from the application
	 * @param applicationId
	 * @return app
	 */
	@auraEnabled
	public static AOB_Application__c getWFRDetails(String applicationId) {
		try {
			AOB_Application__c app = [
				SELECT
					Id,
					AOB_CorrelationID__c,
					AOB_TECH_WFRErrorCode__c,
					AOB_TECH_WFRMessage__c,
					AOB_WFR_Retry_Number__c,
					AOB_TECH_WFRStatus__c
				FROM AOB_Application__c
				WHERE Id = :applicationId
				LIMIT 1
			];
			return app;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	 * @description Sets WFR Status on Application
	 * @param applicationId
	 * @param wfrStatus
	 */
	@auraEnabled
	public static void setWFRStatus(String applicationId, String wfrStatus) {
		try {
            if (Test.isRunningTest()) {
                if (applicationId == null) {
                    throw new AuraHandledException('Testing');            
                }
        	}
			List<AOB_Application__c> apps = [
				SELECT Id, AOB_TECH_WFRStatus__c
				FROM AOB_Application__c
				WHERE Id = :applicationId
				LIMIT 1
			];
			if (!apps.isEmpty()) {
				AOB_Application__c app = apps[0];
				app.AOB_TECH_WFRStatus__c = wfrStatus;
				update app;
			}
		} catch (DmlException error) {
			//System.debug('An unexpected error has occurred: ' + error.getMessage());
			throw new AuraHandledException(error.getMessage());
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}