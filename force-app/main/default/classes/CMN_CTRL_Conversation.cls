/**
 * @description Controller Class for NBA Conversation-related logic
 * @author Joan MacDonald
 * @date October 2021
 */
public with sharing class CMN_CTRL_Conversation {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CTRL_Conversation');

    /**
	 * @description Method to Get Grouped Banker Conversations
	 * @param recordId Record Id
	 * @param rmAeCode RM AE code
	 * @return groupedConversationList List<GroupedConversationWrapper>
	 */
    @AuraEnabled
    public static List<GroupedConversationWrapper> getGroupedBankerConversations(Id recordId, String rmAeCode) {
        List<CMN_Conversation__c> conversationsList = getBankerConversations(recordId, rmAeCode);
        return getGroupedConversations(conversationsList);
    }

    /**
	 * @description Method to Get Banker Conversations
	 * @param recordId Record Id
	 * @param rmAeCode RM AE code
	 * @return conversationsList List<CMN_Conversation__c>
	 */
    public static List<CMN_Conversation__c> getBankerConversations(Id recordId, String rmAeCode) {
        List<CMN_Conversation__c> conversationsList;
        // get conversations for account
        if (recordId != null) {
            Account account = CMN_DAL_Account.findById(recordId);
            if (account != null) {
                retrieveAccountConversations(account);
                conversationsList = CMN_DAL_Conversation.getAccountConversations(recordId);
            }
        }
        // get conversations for specified rm ae code
        else if (recordId == null && rmAeCode != null) {
            List<User> users = CMN_DAL_User.findByAECode(new Set<String>{ rmAeCode });
            if (users.size() > 0) {
                retrieveRMConversations(users);
                conversationsList = CMN_DAL_Conversation.getConversationsByRmAeCode(rmAeCode);
            }
        }
        // get conversations for current user
        else if (recordId == null && rmAeCode == null) {
            rmAeCode = CMN_DAL_Conversation.getRmAeCode(UserInfo.getUserId());
            if (String.isNotBlank(rmAeCode)) {
                List<User> users = CMN_DAL_User.findByAECode(new Set<String>{ rmAeCode });
                retrieveRMConversations(users);
                conversationsList = CMN_DAL_Conversation.getConversationsByRmAeCode(rmAeCode);
            }
        }
        return conversationsList;
    }

    /**
     * @description Retrieves NBA conversations for RM users from API
     * @param users List<User> users
     */
    public static void retrieveRMConversations(List<User> users) {
        try {
            CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
            if (accessToken == null || accessToken.access_token == null) {
                LOGGER.error('No API access token available', new String[] {'Class: CMN_CTRL_Conversation', 'Method: retrieveRMConversations'});
                return;
            }
            // execute API calls, collect responses
            List<CMN_DTO_ConversationsResponse> responses = new List<CMN_DTO_ConversationsResponse>();
            Set<String> rmAeCodes = new Set<String>();
            Set<String> bpIdsQuery = new Set<String>();
            Set<String> conversationIds = new Set<String>();
            Map<String, Date> userAENumber2EarliestDate = new Map<String, Date>();
            for (User user : users) {
                Date earliestCalloutDate = Date.today();
                rmAeCodes.add(user.RM_AE_Code__c);
                // call API with single AE Code
                CMN_DTO_ConversationsResponse response = CMN_API_GetConversations.getRMConversations(accessToken.access_token, user.RM_AE_Code__c);
                responses.add(response);
                // collect accounts BP Ids, lead keys
                if (response == null) {
                    continue;
                }
                for (CMN_DTO_ConversationsResponse.Conversation conversation : response.clientPortfolioConversationList) {
                    String bpIdString = '%' + conversation.newCustN;
                    bpIdsQuery.add(bpIdString);
                    conversationIds.add(conversation.conversationId);
                }
                userAENumber2EarliestDate.put(user.RM_AE_Code__c, earliestCalloutDate);
            }
            // query accounts, prepare BP Ids maps
            List<Account> accounts = CMN_DAL_Account.findAccountsForConversations(rmAeCodes, bpIdsQuery);
            Map<String, Id> bpIdsMap = new Map<String, Id>();
            Map<String, Id> bpIdsWithoutOpeningZerosMap = new Map<String, Id>();
            for (Account account : accounts) {
                bpIdsMap.put(account.ExternalCIFId__c, account.Id);
                bpIdsWithoutOpeningZerosMap.put(account.ExternalCIFId__c.replaceAll('^0+', ''), account.Id);
            }
            // query existing conversation records, build map by lead keys
            List<CMN_Conversation__c> existingConversations = CMN_DAL_Conversation.getConversationsByConversationIds(conversationIds);
            Map<String, CMN_Conversation__c> existingConversationsMap = new Map<String, CMN_Conversation__c>();
            for (CMN_Conversation__c conversation : existingConversations) {
                existingConversationsMap.put(conversation.CMN_ConversationId__c, conversation);
            }
            UpsertConversationWrapper params = new UpsertConversationWrapper();
            params.responses = responses;
            params.existingConversationsMap = existingConversationsMap;
            params.bpIdsMap = bpIdsMap;
            params.bpIdsWithoutOpeningZerosMap = bpIdsWithoutOpeningZerosMap;
            upsertConversationRecords(params);
            System.enqueueJob(new CMN_QUEUE_Conversation(userAENumber2EarliestDate));
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'Class: CMN_CTRL_Conversation', 'Method: retrieveRMConversations'}, ex);
        }
    }

    /**
     * @description Retrieves NBA conversations for Person Account from API
     * @param account Account account
     */
    public static void retrieveAccountConversations(Account account) {
        try {
            CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
            if (accessToken == null || accessToken.access_token == null) {
                LOGGER.error('No API access token available', new String[] {'Class: CMN_CTRL_Conversation', 'Method: retrieveAccountConversations'});
                return;
            }
            // execute API call
            CMN_DTO_ConversationsResponse response = CMN_API_GetConversations.getAccountConversations(accessToken.access_token, account.ExternalCIFId__c);
            // prepare data
            List<CMN_DTO_ConversationsResponse> responses = new List<CMN_DTO_ConversationsResponse>();
            responses.add(response);
            Map<String, Id> bpIdsMap = new Map<String, Id>();
            bpIdsMap.put(account.ExternalCIFId__c, account.Id);
            // query existing conversation records, build map by lead keys
            Set<String> conversationIds = new Set<String>();
            Date earliestCalloutDate = Date.today();
            for (CMN_DTO_ConversationsResponse.Conversation conversation : response.clientPortfolioConversationList) {
                conversationIds.add(conversation.conversationId);
            }
            List<CMN_Conversation__c> existingConversations = CMN_DAL_Conversation.getConversationsByConversationIds(conversationIds);
            Map<String, CMN_Conversation__c> existingConversationsMap = new Map<String, CMN_Conversation__c>();
            for (CMN_Conversation__c conversation : existingConversations) {
                existingConversationsMap.put(conversation.CMN_ConversationId__c, conversation);
            }
            UpsertConversationWrapper params = new UpsertConversationWrapper();
            params.responses = responses;
            params.existingConversationsMap = existingConversationsMap;
            params.bpIdsMap = bpIdsMap;
            params.bpIdsWithoutOpeningZerosMap = null;
            upsertConversationRecords(params);
            System.enqueueJob(new CMN_QUEUE_Conversation(account.Id, earliestCalloutDate));
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'Class: CMN_CTRL_Conversation', 'Method: retrieveAccountConversations'}, ex);
        }
    }

    /**
     * @description Prepares and inserts new conversation records, updates existing when needed
     * @param params wrapper containing all of parameters for upsert conversation
     */
    private static void upsertConversationRecords(UpsertConversationWrapper params) {
        List<CMN_Conversation__c> conversationsToInsert = new List<CMN_Conversation__c>();
        List<CMN_Conversation__c> conversationsToUpdate = new List<CMN_Conversation__c>();
        Set<String> discardedConversationAccountKeys = new Set<String>();
        // prepare conversation records
        for (CMN_DTO_ConversationsResponse response : params.responses) {
            if (response == null) {
                continue;
            }
            for (CMN_DTO_ConversationsResponse.Conversation conversation : response.clientPortfolioConversationList) {
                // existing conversation
                if (params.existingConversationsMap.containsKey(conversation.conversationId)) {
                    CMN_Conversation__c existingConversation = params.existingConversationsMap.get(conversation.conversationId);
                    Boolean doesRequireUpdate = conversationRequireUpdateCheck(existingConversation, conversation);
                    // status
                    updateExistingConversationStatus(existingConversation);
                    // add to list for update
                    if (doesRequireUpdate) {
                        conversationsToUpdate.add(existingConversation);
                    }
                }
                // new conversation
                else {
                    CMN_Conversation__c conversationToInsert = prepareNewConversation(conversation, params, discardedConversationAccountKeys);
                    // add to list for insert
                    if(conversationToInsert != null) {
                        conversationsToInsert.add(conversationToInsert);
                    }
                }
            }
        }
        try {
            insert conversationsToInsert;
            update conversationsToUpdate;
            if (discardedConversationAccountKeys.size() > 0) {
                String message = prepareErrorMessage(discardedConversationAccountKeys);
                LOGGER.error(message, new String[] {'Class: CMN_CTRL_Conversation', 'Method: upsertConversationRecords'});
            }
        }
        catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {'Class: CMN_CTRL_Conversation', 'Method: upsertConversationRecords'}, error);
        }
    }
    private static CMN_Conversation__c prepareNewConversation(CMN_DTO_ConversationsResponse.Conversation conversation, UpsertConversationWrapper params, Set<String> discardedConversationAccountKeys) {
        CMN_Conversation__c conversationToInsert = new CMN_Conversation__c();
        String newCustNString = String.valueOf(conversation.newCustN);
        // newCustN is null when requesting conversations only for a specific account
        if (conversation.newCustN == null) {
            conversationToInsert.Account__c = params.bpIdsMap.values().get(0);
        }
        // seek account in maps
        else if (params.bpIdsMap.containsKey(newCustNString)) {
            conversationToInsert.Account__c = params.bpIdsMap.get(newCustNString);
        }
        else if (params.bpIdsWithoutOpeningZerosMap.containsKey(newCustNString)) {
            conversationToInsert.Account__c = params.bpIdsWithoutOpeningZerosMap.get(newCustNString);
        }
        else {
            // do not create conversations that we can't link to account in salesforce
            discardedConversationAccountKeys.add(newCustNString);
            return null;
        }
        // set conversation type
        setConversationType(conversationToInsert, conversation);
        // set other fields
        setOtherConversationFields(conversationToInsert, conversation);
        // status
        setConversationStatus(conversationToInsert, conversation);

        return conversationToInsert;
    }

    private static Boolean conversationRequireUpdateCheck(CMN_Conversation__c existingConversation, CMN_DTO_ConversationsResponse.Conversation conversation) {
        Boolean doesRequireUpdate = false;
        if (existingConversation.Response__c != conversation.response) {
            existingConversation.Response__c = conversation.response;
            doesRequireUpdate = true;
        }
        if (existingConversation.Reason__c != conversation.reason) {
            existingConversation.Reason__c = conversation.reason;
            doesRequireUpdate = true;
        }
        if (existingConversation.Details__c != conversation.additionalInformation) {
            existingConversation.Details__c = conversation.additionalInformation;
            doesRequireUpdate = true;
        }
        return doesRequireUpdate;
    }

    private static void updateExistingConversationStatus(CMN_Conversation__c existingConversation) {
        Boolean updateStatus =
                existingConversation.Status__c != 'Actioned' &&
                        String.isNotBlank(existingConversation.Response__c) &&
                        String.isNotBlank(existingConversation.Reason__c) &&
                        String.isNotBlank(existingConversation.Details__c);
        if (updateStatus) {
            existingConversation.Status__c = 'Actioned';
        }

    }

    private static void setConversationType (CMN_Conversation__c conversationToInsert, CMN_DTO_ConversationsResponse.Conversation conversation) {
        if (conversation.clientType == 'P') {
            conversationToInsert.Client_Type__c = 'Personal';
        }
        else if (conversation.clientType == 'B') {
            conversationToInsert.Client_Type__c = 'Business';
        }
    }

    private static void setOtherConversationFields(CMN_Conversation__c conversationToInsert, CMN_DTO_ConversationsResponse.Conversation conversation) {
        conversationToInsert.Lead_Key__c = conversation.leadKey;
        conversationToInsert.CMN_ConversationId__c = conversation.conversationId;
        conversationToInsert.IsActive__c = true;
        conversationToInsert.AE_Number__c = conversation.aeNumber;
        conversationToInsert.Category__c = conversation.category;
        conversationToInsert.Sub_Category__c = conversation.subCategory;
        conversationToInsert.Conversation_Details__c = conversation.detail;
        conversationToInsert.Response__c = conversation.response;
        conversationToInsert.Reason__c = conversation.reason;
        conversationToInsert.Details__c = conversation.additionalInformation;
        conversationToInsert.Cat_Position__c = conversation.catPosition;
        conversationToInsert.CMN_ExpectedRevenue__c = conversation.expectedRevenue;
        conversationToInsert.CMN_ValueTier__c = conversation.tier;
        conversationToInsert.CMN_SubCategoryPosition__c = conversation.subCatPosition;
    }

    private static void setConversationStatus(CMN_Conversation__c conversationToInsert, CMN_DTO_ConversationsResponse.Conversation conversation) {
        Boolean isActioned =
                String.isNotBlank(conversation.response) &&
                        String.isNotBlank(conversation.reason) &&
                        String.isNotBlank(conversation.additionalInformation);
        if (isActioned) {
            conversationToInsert.Status__c = 'Actioned';
        }
        else {
            conversationToInsert.Status__c = 'In Progress';
        }
    }

    private static String prepareErrorMessage(Set<String> discardedConversationAccountKeys) {
        String message = 'Some conversations were not inserted as no matching account was found: ';
        for (String discardedConversationAccountKey : discardedConversationAccountKeys) {
            message += discardedConversationAccountKey + ', ';
        }
        message = message.removeEnd(', ');
        return message;
    }

    private static List<GroupedConversationWrapper> getGroupedConversations(List<CMN_Conversation__c> conversations) {
        List<GroupedConversationWrapper> groupedConversationWrappers = new List<GroupedConversationWrapper>();
        Map<Id, List<CMN_Conversation__c>> accountIdToConversationList = createAccountIdToConversationsMap(conversations);

        for (Id clientId : accountIdToConversationList.keySet()) {
            GroupedConversationWrapper groupedClientConversations = createGroupedConversationWrapper(accountIdToConversationList, clientId);
            groupedConversationWrappers.add(groupedClientConversations);
        }

        priorityValueSort(groupedConversationWrappers);

        return groupedConversationWrappers;
    }

    private static Map<Id, List<CMN_Conversation__c>> createAccountIdToConversationsMap(List<CMN_Conversation__c> conversations) {
        Map<Id, List<CMN_Conversation__c>> accountIdToConversationList = new Map<Id, List<CMN_Conversation__c>>();
        for(CMN_Conversation__c conversation : conversations) {
            if(accountIdToConversationList.get(conversation.Account__c) == null) {
                accountIdToConversationList.put(conversation.Account__c, new List<CMN_Conversation__c>());
            }
            accountIdToConversationList.get(conversation.Account__c).add(conversation);
        }
        return accountIdToConversationList;
    }

    private static GroupedConversationWrapper createGroupedConversationWrapper(Map<Id, List<CMN_Conversation__c>> accountIdToConversationList, Id clientId) {
        List<CMN_Conversation__c> clientConversations = accountIdToConversationList.get(clientId);
        GroupedConversationWrapper groupedClientConversations = new GroupedConversationWrapper(clientId);
        groupedClientConversations.clientName = accountIdToConversationList.get(clientId).get(0).Account__r.Name;
        groupedClientConversations.valueTier = accountIdToConversationList.get(clientId).get(0).CMN_ValueTier__c;
        groupedClientConversations.aeNumber = accountIdToConversationList.get(clientId).get(0).AE_Number__c;
        for(CMN_Conversation__c conversation : clientConversations) {
            if(conversation.CMN_ExpectedRevenue__c != null) {
                groupedClientConversations.expectedRevenue += conversation.CMN_ExpectedRevenue__c;
            }
            groupedClientConversations.numberOfConversations++;
            groupedClientConversations.conversationCategories.add(conversation.Category__c);
            groupedClientConversations.priorityValue += conversation.Cat_Position__c == null ? 0 : conversation.Cat_Position__c;
            groupedClientConversations.priorityValue += conversation.CMN_SubCategoryPosition__c == null ? 0 : conversation.CMN_SubCategoryPosition__c;
        }
        return groupedClientConversations;
    }

    private static void priorityValueSort(List<GroupedConversationWrapper> groupedConversationWrappers) {
        Integer minIndex;
        Integer i;
        GroupedConversationWrapper temp;

        for (i = 0; i < groupedConversationWrappers.size() - 1; i++) {
            minIndex = i;
            for (Integer j = i + 1; j < groupedConversationWrappers.size(); j++) {
                if (groupedConversationWrappers[j].priorityValue < groupedConversationWrappers[minIndex].priorityValue) {
                    minIndex = j;
                }
            }
            temp = groupedConversationWrappers[i];
            groupedConversationWrappers[i] = groupedConversationWrappers[minIndex];
            groupedConversationWrappers[minIndex] = temp;
        }
    }

    /**
     * @description Method to Get COAP data
     * @param recordId Record Id
     * @param componentsType components Type
     * @return String
     */
    @AuraEnabled
    public static List<COAP_DTO_CoapPoapComponent> getCustomerOnAPage(Id recordId, String componentsType) {
        List<COAP_DTO_CoapPoapComponent> coap_response = new List<COAP_DTO_CoapPoapComponent>();
        String json_response;
        try{
            // get access token
            CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
            if (accessToken == null || accessToken.access_token == null) {
                LOGGER.error('No API access token available', new String[] {'Class: CMN_CTRL_Conversation', 'Method: getCustomerOnAPage'});
                return coap_response;
            }
            // get BPID
            if (recordId != null) {
                Account account = CMN_DAL_Account.findById(recordId);
                if (account != null && account.ExternalCIFId__c != null) {
                    // execute API call
                    json_response = CMN_API_GetConversations.getCustomerOnAPage(accessToken.access_token, account.ExternalCIFId__c);

                    //sort data for accesses and components
                    coap_response = COAP_Components_Helper.getComponents(json_response, componentsType);
                }
            }
        }
        catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'Class: CMN_CTRL_Conversation', 'Method: getCustomerOnAPage'}, ex);
        }
        return coap_response;
    }

    /**
     * @description Method to Get POAP data
     * @param componentsType component Type
     * @return String
     */
    @AuraEnabled
    public static List<COAP_DTO_CoapPoapComponent> getPortfolioOnAPage(String componentsType) {
        List<COAP_DTO_CoapPoapComponent> poap_response = new List<COAP_DTO_CoapPoapComponent>();
        try{
            // get access token
            CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
            if (accessToken == null || accessToken.access_token == null) {
                LOGGER.error('No API access token available', new String[] {'Class: CMN_CTRL_Conversation', 'Method: getPortfolioOnAPage'});
                return poap_response;
            }
            // get rmAeCode
            String rmAeCode = CMN_DAL_Conversation.getRmAeCode(UserInfo.getUserId());
            if (rmAeCode != null) {

                // execute API call
                String json_response = CMN_API_GetConversations.getPortfolioOnAPage(accessToken.access_token, rmAeCode);

                //preparing and sorting POAP data
                poap_response = COAP_Components_Helper.getComponents(json_response, componentsType);
            }
        }
        catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'Class: CMN_CTRL_Conversation', 'Method: getPortfolioOnAPage'}, ex);
        }
        return poap_response;
    }

    private class UpsertConversationWrapper {
        List<CMN_DTO_ConversationsResponse> responses;
        Map<String, CMN_Conversation__c> existingConversationsMap;
        Map<String, Id> bpIdsMap;
        Map<String, Id> bpIdsWithoutOpeningZerosMap;

        UpsertConversationWrapper() {

        }
    }

    /**
     * @description Wrapper class to show grouped conversations
     */
    public class GroupedConversationWrapper {
        @AuraEnabled public String clientName;
        @AuraEnabled public Id accountId;
        @AuraEnabled public String valueTier;
        @AuraEnabled public Decimal expectedRevenue = 0;
        @AuraEnabled public Integer numberOfConversations = 0;
        @AuraEnabled public String aeNumber;
        @AuraEnabled public Decimal priorityValue = 0;
        @AuraEnabled public List<String> conversationCategories = new List<String>();

        GroupedConversationWrapper(Id accountId) {
            this.accountId = accountId;
        }
    }
}