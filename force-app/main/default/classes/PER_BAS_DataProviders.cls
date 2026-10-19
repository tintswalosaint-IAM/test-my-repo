/**
 * @description       : Recommendation Manager Data Provider for NBA event Alerts 
 * @author            : Sandile Mathe
 * @group             : PER: Personalisation
 * @Created on        : 19-05-2024
**/
@SuppressWarnings('PMD.AvoidGlobalModifier') 
global with sharing class PER_BAS_DataProviders  extends sbgpers.RemoteDataProvider {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PER_BAS_DataProviders');

    /**
    * @description Implements the method to get all the active Event Alerts for a single portfolio 
    * @author Sandile Mathe 
    * @param portfolioCode
    * @return List<sbgpers.RecommendedAction> 
    **/
    global override List<sbgpers.RecommendedAction> getActionsForPortfolioCode(String portfolioCode) {
        LOGGER.info('getActionsForPortfolioCode: Start: ' + portfolioCode);
        List<sbgpers.RecommendedAction> actions = getEventAlertsActionsForPortfolio(portfolioCode);
        return actions;
    }

    /**
    * @description Implements the method to get all the active actions for a single client
    * @author Sandile Mathe
    * @param externalId 
    * @return List<sbgpers.RecommendedAction> 
    **/
    global override List<sbgpers.RecommendedAction> getActionsForClientExternalId (String externalId) {
        LOGGER.info('getActionsForClientExternalId: Start: ' + externalId);

        /**
        * Return an Empty List Instead of throwing an Exception and Prevents errors from breaking the application.
        * Banker Assistant Alerts Data Provider does not support getActionsForClientExternalId()
        **/
        return new List<sbgpers.RecommendedAction>();
    }
      
    /**
    * The following 3 methods are not supported by this data provider but must be implemented as they are abstract.
    * They throw an exception if they are called in error
    **/
    global override sbgpers.RecommendedAction updateActionSnooze(sbgpers.RecommendedAction action, String snoozeReason, Integer snoozeHours) {
        throw new DataProviderException ('Banker Assistant Alerts Data Provider does not support updateActionSnooze');
    }

    global override sbgpers.RecommendedAction updateActionUnsnooze(sbgpers.RecommendedAction action) {
        throw new DataProviderException ('Banker Assistant Alerts Data Provider does not support updateActionUnsnooze');
    }

    public override sbgpers.RecommendedAction updateActionOpportunity(sbgpers.RecommendedAction action, String opportunityId) {
        throw new DataProviderException ('Banker Assistant Alerts Data Provider does not support updateActionOpportunity');
    }

    /**
    * @description Implements the method to update an action as dismissed
    * @author Sandile Mathe 
    * @param action 
    * @param result 
    * @return sbgpers.RecommendedAction 
    **/
    global override sbgpers.RecommendedAction updateActionDismiss(sbgpers.RecommendedAction action, sbgpers.RecommendedActionResult result) {
        
        LOGGER.info('updateActionDismiss: Start: ' + action.clientName + ' - ' + action.subCategory);
         
        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>{action};
        List<sbgpers.RecommendedActionResult> results = new  List<sbgpers.RecommendedActionResult>{result};
        
        action.status = 'Dismissed';
        action.result = result;

        return action;
    }

  /**
    * @description Implements the method to update an action as completed
    * @author Sandile Mathe
    * @param action 
    * @param result 
    * @return sbgpers.RecommendedAction 
    **/
    global override sbgpers.RecommendedAction updateActionComplete(sbgpers.RecommendedAction action, sbgpers.RecommendedActionResult result) {
        
        LOGGER.info('updateEventAlertAction: Start: ' + action.clientName + ' - ' + action.subCategory);
        
        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>{action};
        List<sbgpers.RecommendedActionResult> results = new  List<sbgpers.RecommendedActionResult>{result};
   
        action.status = 'Completed';
        action.result = result;

        return action;
    }
    
    /**
    * @description Private method to call the Event Alert API to get Events and convert them to actions
    * @author Derek Hughes | 13-11-2023 
    * @param portfolioCode 
    * @return List<sbgpers.RecommendedAction> 
    **/
    global List<sbgpers.RecommendedAction> getEventAlertsActionsForPortfolio(String portfolioCode) {

        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>();
        Set<String> invalidEventAlertCIFs = new Set<String>();
        List<BAS_DTO_EventAlertsResponse> responses;

        if(portfolioCode != '' && portfolioCode != null && this.config.configCountryCode != null){
        	responses = new PER_API_BAS_Service().getEventAlertsByAENumber(portfolioCode); 
        	LOGGER.debug('getEventAlertsActionsForPortfolio: responses.size=' + responses.size());
      

       		// Get all the accounts related to the actions
        	//=========================================================
        	// DEREK - This needs to be moved into the base class - for now it works locally
        	final Set<String> externalIds = new Set<String>();
         
        	for (BAS_DTO_EventAlertsResponse alert : responses) {
            	if(alert.bpid != null){ 
            		final String externalId =  this.config.configCountryCode + '01' + transformBPId(alert.bpid);
                	externalIds.add(externalId);
            	}
        	}
        
        	List<Account> accounts = [SELECT Id, Name,FirstName, ExternalIdentifier__c, RelationshipMgrCode__c FROM ACCOUNT WHERE ExternalIdentifier__c IN :externalIds ];
        
        	final Map<String, Account> accountsByExternalId = new Map<String, Account>();
        	for (Account account : accounts) {
            	accountsByExternalId.put(account.ExternalIdentifier__c, account);
        	}
        	//=========================================================

        	// DEREK - This may be temporary code:  Get the local cached actions
        	sbgpers.LocalDataProvider localProvider = new sbgpers.LocalDataProvider();
        	localProvider.setConfig(this.config);

        	List<sbgpers.RecommendedAction> cachedActions = localProvider.getActionsForPortfolioCode(portfolioCode);

        	LOGGER.debug('getEventAlertsActionsForPortfolio: cachedActions.size='+cachedActions.size());

        	Map<String, sbgpers.RecommendedAction> cachedActionsById = new  Map<String, sbgpers.RecommendedAction>();

        	for (sbgpers.RecommendedAction cachedAction : cachedActions) {
            	cachedActionsById.put(cachedAction.Identifier, cachedAction);
          		}
        	
        	//Loop through the Response and return Actions
        	if (!responses.isEmpty() && responses != null && this.config.configCountryCode != null) {
            
            for (BAS_DTO_EventAlertsResponse alert : responses) {
                String externalId =  this.config.configCountryCode + '01' + transformBPId(alert.bpid);
                Account account = accountsByExternalId.get(externalId);
            
          
                sbgpers.RecommendedAction action = new sbgpers.RecommendedAction();
            
                action.clientCIF            = alert.bpid;
                action.clientIdentifer      = externalId; 

                //=========================================================
                // DEREK - This needs to be moved into the base class - for now it works locally
                if (account != null) {
                    action.accountId = account.Id;
                    action.accountUrl = '/' + account.Id;
                    action.accountName = account.Name;
                    action.clientName = account.Name+'*';
                    action.additionalData     = alert.eventContent.replace('[Client]', account.FirstName).replace('[Your Name]', UserInfo.getName());
                }
                else {
                    action.accountUrl = '/';
                    action.accountName = '[ ' + alert.bpid + ' not found ]';
                    action.clientName = '[ '+alert.bpid+' ]';
                    action.status = 'Invalid';
                }        
                //=========================================================
                
                action.countryCode        = this.config.configCountryCode;
                action.isActive           = true;
                action.systemId           = this.config.sourceSystemId;
                action.id                 = alert.eventId;
                action.identifier         = action.countryCode+action.systemId+alert.eventId;   
                action.actionType         = alert.eventType;
                action.category           = 'Alert';
                action.subCategory        = alert.eventType;
                action.details            = alert.eventDetails;
                action.validFrom          = Date.today(); 
                action.validUntil         = Date.today(); 
                action.portfolioCode      = alert.aeNumber;
                
                // if there is a cached action then use its result
                // Check if there is a cached action for this alert
                sbgpers.RecommendedAction cachedAction = cachedActionsById.get(action.identifier);
                if (cachedAction != null) {
                    action.status = cachedAction.status;
                    action.result = cachedAction.result;
                }
                
                actions.add(action);
            }
          
         } 
       }
        return actions;

    }
   
    private class DataProviderException extends Exception {}
    
    public static String transformBPId(string bpId){
        return '0'.repeat(10 - bpId.length()) + bpId;
    }
}