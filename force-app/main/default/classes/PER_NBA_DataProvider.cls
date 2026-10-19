/**
 * @description       : Recommendation Manager Data Provider for NBA (Smart Conversations)
 * @author            : Derek Hughes
 * @group             : PER: Personalisation
 * @last modified on  : 10-04-2024
 * @last modified by  : Derek Hughes
 * Test Class		  : PER_NBA_DataProvider_Test
**/
@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it called from another namespace in the Recommendation Manager
global with sharing class PER_NBA_DataProvider extends sbgpers.RemoteDataProvider {

    private static final sbgplatform.rflib_Logger LOGGER2 = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PER_NBA_DataProvider');

    sbgpers.LocalDataProvider locaProvider;

    /**
    * @description Implements the method to get all the active actions for a single portfolio 
    * @author Derek Hughes | 13-11-2023 
    * @param portfolioCode 
    * @return List<sbgpers.RecommendedAction> 
    **/
    global override List<sbgpers.RecommendedAction> getActionsForPortfolioCode(String portfolioCode) {
        LOGGER2.info('getActionsForPortfolio: Start: ' + portfolioCode);
        List<sbgpers.RecommendedAction> actions = getNbaActionsForPortfolio(portfolioCode);
        return actions;
    }

    /**
    * @description Implements the method to get all the active actions for a single client
    * @author Derek Hughes | 13-11-2023 
    * @param externalId 
    * @return List<sbgpers.RecommendedAction> 
    **/
    global override List<sbgpers.RecommendedAction> getActionsForClientExternalId (String externalId) {
        LOGGER2.info('getActionsForClientExternalId: Start: ' + externalId);

        if (String.isBlank(externalId)) {
            return new List<sbgpers.RecommendedAction>();
        }
        List<sbgpers.RecommendedAction> actions = getNbaActionsForClient(externalId);
        return actions;
    }

    /**
    * @description Implements the method to update an action as completed
    * @author Derek Hughes | 13-11-2023 
    * @param action 
    * @param result 
    * @return sbgpers.RecommendedAction 
    **/
    global override sbgpers.RecommendedAction updateActionComplete(sbgpers.RecommendedAction action, sbgpers.RecommendedActionResult result) {
        
        LOGGER2.info('updateNbaAction: Start: ' + action.clientName + ' - ' + action.subCategory);
        
        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>{action};
        List<sbgpers.RecommendedActionResult> results = new  List<sbgpers.RecommendedActionResult>{result};

        updateNbaActions(actions, results);
       
        action.status = 'Completed';
        action.result = result;

        return action;
    }

    /**
    * @description Implements a method to updatem multiple actions that have been actioned
    * @author Derek Hughes | 13-03-2024 
    * @param actionsList 
    * @param resultsList 
    * @return virtual 
    **/
    global override List<sbgpers.RecommendedAction> updateMultiActionComplete (List<sbgpers.RecommendedAction> actions, List<sbgpers.RecommendedActionResult> results) {
          
        LOGGER2.info('updateMultiActionComplete: Start: actions.size=' + actions.size() + ' results.size=' + results.size());
        
        updateNbaActions(actions, results);
        
        for (Integer i=0; i<actions.size(); i++) {
            actions[i].status = 'Completed';
            actions[i].result = results[i];
        }

        return actions;
       
    }

    /**
    * @description Implements the method to update an action as dismissed
    * @author Derek Hughes | 13-11-2023 
    * @param action 
    * @param result 
    * @return sbgpers.RecommendedAction 
    **/
    global override sbgpers.RecommendedAction updateActionDismiss(sbgpers.RecommendedAction action, sbgpers.RecommendedActionResult result) {
        
        LOGGER2.info('updateActionDismiss: Start: ' + action.clientName + ' - ' + action.subCategory);
        
         
        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>{action};
        List<sbgpers.RecommendedActionResult> results = new  List<sbgpers.RecommendedActionResult>{result};

        updateNbaActions(actions, results);
        
        action.status = 'Dismissed';
        action.result = result;

        return action;
    }

  
    /**
    * The following 3 methods are not supported by this data provider but must be implemented as they are abstract.
    * They throw an exception if they are called in error
    **/
    global override sbgpers.RecommendedAction updateActionSnooze(sbgpers.RecommendedAction action, String snoozeReason, Integer snoozeHours) {
        throw new DataProviderException ('NBA Data Provider does not support updateActionSnooze (coming soon).');
    }

    global override sbgpers.RecommendedAction updateActionUnsnooze(sbgpers.RecommendedAction action) {
        throw new DataProviderException ('NBA Data Provider does not support updateActionUnsnooze (coming soon).');
    }

    public override sbgpers.RecommendedAction updateActionOpportunity(sbgpers.RecommendedAction action, String opportunityId) {
        throw new DataProviderException ('NBA Data Provider does not support updateActionOpportunity (coming soon).');
    }


    /**
    * @description Local method to get and check the access token required for calls to conversation API
    * @author Derek Hughes | 12-11-2023 
    * @return String 
    **/
    public String getAccessToken() {
        CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
        
        if (accessToken == null || accessToken.access_token == null) {
            String errorMessage = 'No API access token available';
            LOGGER2.error('getNbaActions: '+errorMessage);
            throw new DataProviderException(errorMessage);
        }
        return accessToken.access_token;
    }

    /**
    * @description Private method to call the NBA Conversation API to get conversatons and convert them to actions
    * @author Derek Hughes | 13-11-2023 
    * @param portfolioCode 
    * @return List<sbgpers.RecommendedAction> 
    **/
    private List<sbgpers.RecommendedAction> getNbaActionsForPortfolio(String portfolioCode) {

        List<CMN_DTO_ConversationsResponse.Conversation> allActions = new List<CMN_DTO_ConversationsResponse.Conversation>();
        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>();
        Set<String> invalidConversationCIFs = new Set<String>();

        CMN_DTO_ConversationsResponse response;

        if (this.config.configCountryCode=='ZA') {
            // This is for South Africa 
            String accessToken = getAccessToken();

            if (String.isBlank(accessToken)) {
                throw new DataProviderException('SYSTEM ERROR: Unable to obtain a valid access token for the call to the NBA API.');
            }

            response = CMN_API_GetConversations.getRMConversations(accessToken, portfolioCode);
        }
        else {
            // This is for other African countries
            // if the portfolio code includes the country code, then strip it before call in the API 
            String pCode = portfolioCode.left(2) == this.config.configCountryCode ? portfolioCode.mid(2,255) : portfolioCode;
            response = new PER_API_NBA_Service().getPortfolioSingle(this.config.configCountryCode, pCode);
        }

        allActions = response.clientPortfolioConversationList;
        LOGGER2.debug('getNbaActionsForPortfolio: allActions: '+allActions.size());
        Set<String> externalIds = new Set<String>();
        for(CMN_DTO_ConversationsResponse.Conversation conversation : allActions) {
            String externalId =  this.config.configCountryCode + '01' + conversation.newCustN;
            externalIds.add(externalId);
        }
		
        List<Account> accounts = [SELECT Id, Name, ExternalIdentifier__c, RelationshipMgrCode__c FROM ACCOUNT WHERE ExternalIdentifier__c IN :externalIds ];
        
        Map<String, Account> accountsByExternalId = new Map<String, Account>();
        for (Account account : accounts) {
            accountsByExternalId.put(account.ExternalIdentifier__c, account);
        }

        // Iterate actions again to filter based on accont bpIds

        for (CMN_DTO_ConversationsResponse.Conversation conversation : allActions){
            String externalId =  this.config.configCountryCode + '01' + conversation.newCustN;
            Account account = accountsByExternalId.get(externalId);
            actions.add(transformActionData(conversation, account, externalId));

            if (account == null) {
                invalidConversationCIFs.add(externalId);
            }
        }

        if (invalidConversationCIFs.size() > 0) {
            String missingCIFs = string.join(invalidConversationCIFs,',');
            LOGGER2.warn('getNbaActions: Invalid or missing CIF numbers: '+missingCIFs);
        }

        addResponses(actions);
        return actions;
    }

      /**
    * @description Private method to call the NBA Conversation API to get conversatons and convert them to actions
    * @author Derek Hughes | 13-11-2023 
    * @param cifNumber  
    * @return List<sbgpers.RecommendedAction> 
    **/
    private List<sbgpers.RecommendedAction> getNbaActionsForClient(String externalId) {

        List<sbgpers.RecommendedAction> actions = new List<sbgpers.RecommendedAction>();

        List<Account> accounts = [SELECT Id, Name, ExternalCIFId__c, ExternalIdentifier__c, RelationshipMgrCode__c FROM ACCOUNT WHERE ExternalIdentifier__c = :externalId ];

        if (accounts.size() == 0) {
            return new List<sbgpers.RecommendedAction> ();
        }
        else if (accounts.size() > 1) {
            throw new DataProviderException('INTERNAL SYSTEM ERROR: This account has a duplicate External Identifider (CIF or BPID): '+externalId);
        }

        Account account = accounts[0];

        CMN_DTO_ConversationsResponse response;

        if (this.config.configCountryCode=='ZA') {
            String accessToken = getAccessToken();
            response = CMN_API_GetConversations.getAccountConversations(accessToken, account.ExternalCIFId__c);
        }
        else {
            // response = CMN_API_GetConversations.getAccountConversationsSingle(accessToken, this.config.configCountryCode, account.ExternalCIFId__c);
            response = new PER_API_NBA_Service().getClientSingle(this.config.configCountryCode, account.ExternalCIFId__c);
        }

        for (CMN_DTO_ConversationsResponse.Conversation conversation : response.clientPortfolioConversationList) {
            actions.add(transformActionData(conversation, account, externalId));
        }
  
        addResponses(actions);
        return actions;
    }

    /**
    * @description Private method to call the NBA Conversation API to update an actions with its result
    * @author Derek Hughes | 13-11-2023 
    * @param action 
    * @param result 
    **/
    private void updateNbaActions (List<sbgpers.RecommendedAction> actions, List<sbgpers.RecommendedActionResult> results) {

        // This is for South Africa 
        if (this.config.configCountryCode=='ZA') {

            List<CMN_Conversation__c> conversations = new List<CMN_Conversation__c>();

            for (Integer i=0; i<actions.size(); i++) {
                CMN_Conversation__c conversation = new CMN_Conversation__c(
                    Lead_Key__c = actions[i].id,
                    Response__c = results[i].response,
                    Reason__c = results[i].reason,
                    Details__c = results[i].notes
                );
                conversations.add(conversation);

            }

            String accessToken = getAccessToken();

            CMN_API_GetConversations.sendConversations(accessToken, conversations);
        }
        else {
            // This is for other African countries
            List<String> actionIds = new List<String>();
            for (Integer i=0; i<actions.size(); i++) {
                actionIds.add(actions[i].Id);
            }

            new PER_API_NBA_Service().sendConversations(this.config.configCountryCode, actionIds, results);
        }
    }

    /**
    * @description Private method to transform a conversation DTO into an action DTO
    * @author Derek Hughes | 13-11-2023 
    * @param conversation 
    * @param account 
    * @param externalId 
    * @return sbgpers.RecommendedAction 
    **/
    private sbgpers.RecommendedAction transformActionData(CMN_DTO_ConversationsResponse.Conversation conversation, Account account, String externalId) {
        sbgpers.RecommendedAction action = new sbgpers.RecommendedAction();
        String newCustNString = String.valueOf(conversation.newCustN);

        action.countryCode        = this.config.configCountryCode;
        action.systemId           = this.config.sourceSystemId;
        action.id                 = conversation.leadKey;
        action.identifier         = action.countryCode+action.systemId+action.id;

        action.isActive             = true;

        if (account != null) {
            action.accountId = account.Id;
            action.accountUrl = '/' + account.Id;
            action.accountName = account.Name;
            action.clientName = String.IsNotBlank(conversation.clientName) ? conversation.clientName : account.Name+'*';

            // Has there already been a response?  If so then set the status
            if (String.IsNotBlank(conversation.response)) {
                action.result = new sbgpers.RecommendedActionResult();
                action.result.response = conversation.response;
                action.result.reason = conversation.reason;
                if (String.IsNotBlank(conversation.futureContactDate)) {
                    action.result.followUpDate = convertToDate(conversation.futureContactDate);
                }
                action.result.notes = conversation.additionalInformation;

                if (String.IsNotBlank(this.config.declinedResponses) && this.config.declinedResponses.contains(conversation.response)) {
                    action.status =  'Dismissed';
                }
                else {
                    action.status =  'Completed';
                }
            }
            else {
                action.status =  'To Do';
            }
        }
        else {
            action.accountUrl = '/';
            action.accountName = '[ ' + newCustNString + ' not found ]';
            action.clientName = String.IsNotBlank(conversation.clientName) ? conversation.clientName : '[ '+newCustNString+' ]';
            action.status = 'Invalid';
        }


        // WORKAROUND - The NBA APi does not return the AeNumber on a single conversation call

        if (String.isNotBlank(conversation.aeNumber)) {
            action.portfolioCode = this.config.configCountryCode+conversation.aeNumber;
        }
        else {
            action.portfolioCode = account.RelationshipMgrCode__c;
        }
        LOGGER2.debug('transformActionData: action.portfolioCode = '+action.portfolioCode);

        action.actionType = 'NBA Conversation';
        action.countryCode = this.config.configCountryCode;
        action.clientCIF = String.valueOf(conversation.newCustN);
        action.clientIdentifer = externalId;
        action.category = conversation.category;
        action.subCategory = conversation.subCategory;
        action.details = conversation.detail;
        action.clientTier = conversation.tier;
        action.validFrom= Date.today(); 
        action.validUntil = Date.today(); 
        action.isSnoozed = false;

        return action;
    }

    private static Date convertToDate(String numberText){
		try{
			return DateTime.newInstance(Long.valueof(numberText)).Date();
		}
		catch (Exception ex) {
			return null;
		}	
	}

    private class DataProviderException extends Exception {}
}