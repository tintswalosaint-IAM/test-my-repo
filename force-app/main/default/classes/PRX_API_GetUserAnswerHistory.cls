/***************************************************************************************
@ Author            :prem.lingala@standardbank.co.za
@ Date              :Feb 2024
@ Name of the Class :PRX_API_GetUserAnswerHistory
@description       :Apex class responsible for making RESTful API calls to retrieve user answer history 
                     and related information from the Standard Bank API. This class extends the PRX_API_RestBase class 
                     to provide common functionality for handling API requests.
@ Last Modified By  :prem.lingala@standardbank.co.za
@ Last Modified On  :
@ Jira Ticket       : SFP-29221, SFP-34158  
***************************************************************************************/
public with sharing class PRX_API_GetUserAnswerHistory extends PRX_API_RestBase {
    /* @description Declaring the PATH_CALLOUT for Endpoints */
     private static final String PATH_CALLOUT = '/questionnaire'; 
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PRX_API_GetUserAnswerHistory');
    public String userId;
    /**
     * @description get the User Id 
     *@param userId
     */
    public PRX_API_GetUserAnswerHistory(String userId){
        this.userId = userId;  
    }
     /**
     * @description Overrides the getEndpoint method to provide the API endpoint URL for fetching user answer history. Constructs the endpoint based on the current user's Salesforce ID.
     * @return String representing the API endpoint URL.
     */
  protected override String getEndpoint() {
    String currentUserId = userId;
    return 'callout:PRX_ESB_TOKEN_CREDENTIALS_NC' + PATH_CALLOUT + '/' + 
           CMN_WebserviceSetting__mdt.getInstance('PRX_API_FHQ').CMN_Path__c + 
           '?reference=' + currentUserId;
}
    /**
     * @description Overrides the getRequestHeaders method to provide the required HTTP request headers. Retrieves the access token from the PRX_API_AccessToken class and includes it in the headers.
     * @return Map<String, String> containing the HTTP request headers.
     */
    protected override Map<String, String> getRequestHeaders() {
        PRX_API_AccessToken obj = new PRX_API_AccessToken();
        String accessToken = obj.callApi();
        Map<String, String> headers = new Map<String, String>();
        headers.put('Accept', 'application/json');
        headers.put('X-Client-Certificate',getCertificate());   
        headers.put('Authorization', 'Bearer '+accessToken);
        return headers;
    }
     /**
     * @description Overrides the getRequestBody method to provide an empty request body, as the GET request does not have a request body.
     * @return null An empty String representing the request body.
     */
    protected override String getRequestBody() {
        return '';
    }
    /**
     * @description Calls the API by sending a GET request and returns the HTTP response.
     * @return resp which has HttpResponse object representing the response from the API.
     */
    public HttpResponse callApi(){
        HttpResponse resp = super.sendHttpRequest('GET');
        return resp;
    }
     /**
     * @description Invokable method exposed to Salesforce Lightning components. Retrieves user answer history information and returns a list of UserHistory objects.
     * @param recordId
     * @return List<UserHistory> representing user answer history information.
*/
    @AuraEnabled
    public static List<UserHistory> getUserHistoryInfo(String recordId) {
        try {
            if (String.isBlank(recordId)) {  throw new AuraHandledException('Record ID cannot be empty');
            }
            List<Lead> leadList = getLeadRecord(recordId);
            if (leadList.isEmpty()) { throw new AuraHandledException('No Lead found with the provided ID');
            }
            HttpResponse resp;
            try {
                resp = callApiForLead(leadList[0]);
            } catch (CalloutException e) {
                LOGGER.error('API Callout failed: ' + e.getMessage());
                throw new AuraHandledException('Failed to retrieve user history. Please try again later.');
            }
            if (resp.getStatusCode() != 200) {
                LOGGER.error('API returned non-200 status code: ' + resp.getStatusCode());
                throw new AuraHandledException('Unable to retrieve user history. Status: ' + resp.getStatusCode());
            }
            UserHistoryResponse wrapObj = parseResponseBody(resp.getBody());
            if (wrapObj == null) {  throw new AuraHandledException('Failed to process user history data');
            }
            List<UserHistory> userHistoryList = processUserHistory(wrapObj);
            if (userHistoryList.isEmpty()) {
                return null;
            }
            return userHistoryList;
        } catch (AuraHandledException e) {
            LOGGER.error('Aura Exception in getUserHistoryInfo: ' + e.getMessage());
            throw e;
        } catch (Exception e) { throw new AuraHandledException('An unexpected error occurred while retrieving user history');
        }
    }
    /**
    * @description getLeadRecord
    * @param recordId 
    * @return List<Lead> 
    **/
    private static List<Lead> getLeadRecord(String recordId) {
        SEL_Lead leadSelector = new SEL_Lead();
        return leadSelector.selectByIdHavingSystemReference(recordId);
    }
     /**
    * @description callApiForLead
    * @param lead 
    * @return HttpResponse 
    **/
    private static HttpResponse callApiForLead(Lead lead) {
        PRX_API_GetUserAnswerHistory obj = new PRX_API_GetUserAnswerHistory(lead.Source_System_Reference__c);
        HttpResponse resp = obj.callApi();
        if (resp.getStatusCode() == 200) {
            updateLeadFHQStatus(lead);
        }
        return resp;
    }
       /**
    * @description updateLeadFHQStatus
    * @param lead 
    **/
    private static void updateLeadFHQStatus(Lead lead) {
        Lead leadToUpdate = lead.clone(true, true, true, true);
        leadToUpdate.Was_FHQ_Completed__c = 'Yes';
    }
        /**
    * @description  parseResponseBody
    * @param responseBody 
    * @return UserHistoryResponse 
    **/
    private static UserHistoryResponse parseResponseBody(String responseBody) {
        try {
            return (UserHistoryResponse)JSON.deserialize(responseBody, UserHistoryResponse.class);
        } catch (Exception e) {
            LOGGER.error('PRX_API_GetUserAnswerHistory.getUserHistoryInfo' + e.getMessage());
            return null;
        }
    }
    /**
    * @description  processUserHistory
    * @param wrapObj 
    * @return List<UserHistory> 
    **/
    private static List<UserHistory> processUserHistory(UserHistoryResponse wrapObj) {
        List<UserHistory> userHistoryList = new List<UserHistory>();
        
        if (wrapObj.modules == null || wrapObj.modules.isEmpty()) {  return userHistoryList;
        }

        List<Section> sections = getSections(wrapObj.modules[0]);
        if (sections.isEmpty()) {return userHistoryList;
        }

        List<Activity> activities = getActivities(sections[0]);
        return createUserHistoryList(activities);
    }
     /**
    * @description  getSections
    * @param module 
    * @return List<Section>
    **/
    private static List<Section> getSections(Module module) {
         return module.sections ?? new List<Section>();
    }
      /**
    * @description  getActivities
    * @param module 
    * @return List<Activity>
    **/
    private static List<Activity> getActivities(Section section) {
          return section.activities ?? new List<Activity>();
    }
       /**
    * @description  createUserHistoryList
    * @param activities 
    * @return List<UserHistory>
    **/
  private static List<UserHistory> createUserHistoryList(List<Activity> activities) {
    List<UserHistory> userHistoryList = new List<UserHistory>();
    for (Activity activityObj : activities) {
        UserHistory ushObj = new UserHistory();
        ushObj.activityName = activityObj.title;
        ushObj.activityPersent = activityObj.formulaResult;
        userHistoryList.add(ushObj);
    }
    return userHistoryList;
}
    /**
     * @description Invokable method exposed to Salesforce Lightning components. Retrieves user answer history information and returns a list of UserHistoryAnswer objects.
     * @param recordId
     * @return List<UserHistoryAnswer> representing user answer history information.
     */
@AuraEnabled
public static List<UserHistoryAnswer> getUserAnswerHistoryInfo(String recordId) {
    try {
        SEL_Lead leadSelector = new SEL_Lead(); 
        List<Lead> leadList = leadSelector.selectByIdHavingSystemReference(recordId); 
        
        if (leadList.isEmpty()) {  return new List<UserHistoryAnswer>(); 
        }
        PRX_API_GetUserAnswerHistory obj = new PRX_API_GetUserAnswerHistory(leadList[0].Source_System_Reference__c);
        HttpResponse resp = obj.callApi();
        
        if (resp.getStatusCode() != 200) {
            LOGGER.error('PRX_API_GetUserAnswerHistory.getUserAnswerHistoryInfo - API Call Failed: Status Code ' + resp.getStatusCode());
            return new List<UserHistoryAnswer>();
        }
        List<UserHistoryAnswer> userAnswerHistoryList = parseUserHistoryResponse(resp.getBody());
        updateLeadFHQCompleted(leadList[0]);
        return userAnswerHistoryList;
    } catch (Exception e) {
        LOGGER.error('PRX_API_GetUserAnswerHistory.getUserAnswerHistoryInfo - Exception: ' + e.getMessage());
        throw new AuraHandledException('An error occurred while retrieving user answer history. Please try again.');
    }
}
/**
 * @description Parses the user history response JSON and extracts the list of user history answers.
 * @param responseBody JSON response containing user history data.
 * @return List<UserHistoryAnswer> Extracted user history answers.
 */
private static List<UserHistoryAnswer> parseUserHistoryResponse(String responseBody) {
        try {
            UserHistoryResponse wrapObj = deserializeResponse(responseBody);
            return processHistoryResponse(wrapObj);
        } catch (Exception e) {
            LOGGER.error('PRX_API_GetUserAnswerHistory.parseUserHistoryResponse: ' + e.getMessage());
            return new List<UserHistoryAnswer>();
        }
    }
/**
 * @description Deserializes the JSON response into a UserHistoryResponse object.
 * @param responseBody JSON string to deserialize.
 * @return UserHistoryResponse Deserialized response object.
 */
    private static UserHistoryResponse deserializeResponse(String responseBody) {
        return (UserHistoryResponse) JSON.deserialize(responseBody, UserHistoryResponse.class);
    }
/**
 * @description Processes the UserHistoryResponse object and extracts relevant activities.
 * @param wrapObj The parsed user history response.
 * @return List<UserHistoryAnswer> Extracted answers.
 */
    private static List<UserHistoryAnswer> processHistoryResponse(UserHistoryResponse wrapObj) {
        if (!isValidResponse(wrapObj)) {  return new List<UserHistoryAnswer>();
        }

        List<Module> modules = wrapObj.modules;
        List<Section> sections = getModuleSections(modules[0]);
        List<Activity> activities = getSectionActivities(sections);
        
        return processActivities(activities);
    }
/**
 * @description Checks if the response contains valid data.
 * @param wrapObj The parsed user history response.
 * @return boolean True if the response is valid, otherwise false.
 */
    private static boolean isValidResponse(UserHistoryResponse wrapObj) {
        return wrapObj != null && 
               wrapObj.modules != null && 
               !wrapObj.modules.isEmpty();
    }
/**
 * @description Retrieves sections from a module.
 * @param module The module containing sections.
 * @return List<Section> Sections from the module.
 */
    private static List<Section> getModuleSections(Module module) {
        if (module == null || module.sections == null || module.sections.isEmpty()) {  
            return new List<Section>();
        }
        return module.sections;
    }
/**
 * @description Retrieves activities from the first section.
 * @param sections The list of sections.
 * @return List<Activity> Activities from the first section.
 */
    private static List<Activity> getSectionActivities(List<Section> sections) {
        if (sections.isEmpty() || sections[0].activities == null) {  return new List<Activity>();
        }
        return sections[0].activities;
    }
/**
 * @description Processes activities and maps them to user history answers.
 * @param activities The list of activities.
 * @return List<UserHistoryAnswer> Extracted user history answers.
 */
    private static List<UserHistoryAnswer> processActivities(List<Activity> activities) {
        List<UserHistoryAnswer> userAnswerHistoryList = new List<UserHistoryAnswer>();
        
        for (Activity activityObj : activities) {
            if (activityObj.questions != null) {
                userAnswerHistoryList.addAll(mapQuestionsToAnswers(activityObj));
            }
        }
        
        return userAnswerHistoryList;
    }
/**
 * @description Processes activities and maps them to user history answers.
 * @param activityObj
 * @return List<UserHistoryAnswer> Extracted user history answers.
 */
private static List<UserHistoryAnswer> mapQuestionsToAnswers(Activity activityObj) {
    List<UserHistoryAnswer> answersList = new List<UserHistoryAnswer>();
    for (Question ques : activityObj.questions) {
        UserHistoryAnswer uansObj = new UserHistoryAnswer();
        uansObj.activityId = activityObj.id;
        uansObj.id = ques.id;
        uansObj.title = ques.title;
        uansObj.type = ques.type;
        Map<String, Object> configMap = (Map<String, Object>) JSON.deserializeUntyped(ques.config);
        if (configMap.containsKey('options') && configMap.get('options') instanceof List<Object>) {
            List<Object> optionsList = (List<Object>) configMap.get('options');
            List<String> options = new List<String>();
            for (Object option : optionsList) {
                options.add(String.valueOf(option));
            }
            uansObj.config = options;
        } else {
            uansObj.config = new List<String>();
        }

        uansObj.answer = ques.answer;
        answersList.add(uansObj);
    }
    return answersList;
}
/**
 * @description updateLeadFHQCompleted
 * @param leadToUpdate
 */
private static void updateLeadFHQCompleted(Lead leadToUpdate) {
    if (!Schema.sObjectType.Lead.isUpdateable() || !Schema.sObjectType.Lead.fields.Was_FHQ_Completed__c.isUpdateable()) {
        LOGGER.error('PRX_API_GetUserAnswerHistory.updateLeadFHQCompleted: Insufficient permissions to update Lead');
        throw new SecurityException('Insufficient permissions to update Lead record');
    }
    leadToUpdate.Was_FHQ_Completed__c = 'Yes';
    try {
        update leadToUpdate;
    } catch (Exception e) {
        LOGGER.error('PRX_API_GetUserAnswerHistory.updateLeadFHQCompleted: ' + e.getMessage());
    }
}
          /**
     * @description : Method to Retrieve Encrypted Certificate 
     * @param None
     * @return String 
     */
    public static String getCertificate(){
        List<CMN_WebserviceSetting__mdt> mdtList = [SELECT Id, AOB_ClientCertificate__c,DeveloperName FROM CMN_WebserviceSetting__mdt WHERE DeveloperName = :PRX_CTRL_Constants.PRXAPIFHQ  ];
        if (mdtList.isEmpty()) {  throw new IllegalArgumentException('No custom metadata record found for API certificate Details in IntegrationDetails record.');
    }  
       String encodedCert = mdtList[0].AOB_ClientCertificate__c;
       Blob decryptedData = EncodingUtil.base64Decode(encodedCert);
       Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256',getSecretKey(), decryptedData);
    return decryptedBlob.toString();
    }
    
    /**
    * @description Retrieves the Secret Key Details
    * @author Krishna Ranjan | 02-12-2024
    * @return blob
    **/
    @AuraEnabled
public static Blob getSecretKey() {
    try{
        List<PRX_domain_Info__mdt> mdtList = [SELECT Id, AES_SecretKey__c,AES_SecretDetailsKey__c,DeveloperName 
                                              FROM PRX_domain_Info__mdt 
                                              WHERE DeveloperName = 'PRX_domain_SecretInfo'
                                              LIMIT 1];
        return EncodingUtil.base64Decode(mdtList[0].AES_SecretDetailsKey__c);   
 }catch(Exception e){throw new AuraHandledException('An error occurred while encrypting the User ID: ' + e.getMessage());    }
}

      /**
     * @description Inner class representing the response structure for user history information.
     */
    public class UserHistoryResponse {
        public List<Module> modules;
    }
     /**
     * @description Inner class representing a module in the API response.
     */
    public class Module {
        public List<Section> sections;
    }
     /**
     *@description Inner class representing a section in the API response.
     */
    public class Section {
        public Integer formulaResult;
        public List<Activity> activities;
    }
     /**
     * @description Inner class representing an activity in the API response.
     */
    public class Activity {
        public Integer id;
        public String title;
        public Integer formulaResult;
        public List<Question> questions;
    }
     /**
     * @description Inner class representing a question in the API response.
     */
    public class Question {
        public Integer id;
        public String title;
        public String type;
        public String answer;
        public String config;
    }  
     /**
     * @description Inner class representing user history information for presentation in Salesforce Lightning components.
     */
    public class UserHistory{
        @AuraEnabled
        public String activityName;
        @AuraEnabled
        public Integer activityPersent;
    }
     /**
     * @description Inner class representing user answer history information for presentation in Salesforce Lightning components.
     */
    public class UserHistoryAnswer{
        @AuraEnabled
        public Integer activityId;
        @AuraEnabled
        public Integer id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<String> config;
        @AuraEnabled
        public String answer;
    }
}