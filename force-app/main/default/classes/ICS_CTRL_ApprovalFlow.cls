/**
 * @description                 : Class needed by Application flow stories
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @ last modified on           : 28-07-2025
 * @modification description    : Created
 * @last modified on            : 03-10-2025
 * @last modified by            : Tushar Walse
 * @modification description    : SFP-52492 Reconfigure the GSD Referral Process - support reporting of triggering conditions
 * @ last modified on            : 15-10-2025
 * @last modified by            : Tushar Walse
 * @modification description    : SFP-53780 UAT BUG: Needed improvement on Joint opp with GSD Prohibited country and CASE: GSD Sanctioned and GSD Prohibited in the same application
 * @ last modified on            : 30-04-2026
 * @last modified by            : Ridhima Saxena
 * @modification description    : SFP-57688 PROD INCIDENT:Update saveAssessmentData else logic to prevent stage/status change when the record is already in In Review stage to doc upload and SCA .
 */

 public without sharing class ICS_CTRL_ApprovalFlow {
    static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_ApprovalFlow');
    static ICS_CTRL_GetData dataObj;
    static StaticResource staticResource;
    public static Map<String, String> conditions;
    static String logLabel = '';
    static String allLog = '';
    static Boolean allLogTitleAdded = false;

    static String[] countryPickListFieldNames = new String[]{
        'PartyProfile.Country_of_Residence__c',
        'PartyProfile.Country_of_Nationality__c',
        'PartyProfile.CountryofBirth',
        'PartyProfileAddress.Country',
        'FinServ__Employment__c.Employer_s_Country__c',
        'Party_Assets_Funds__c.Business_Location__c',
        'Party_Assets_Funds__c.Country__c',
        'Party_Assets_Funds__c.Jurisdiction_Where_Investments_Held__c',
        'PartyProfile.Second_Country_of_Nationality__c',
        'Party_Assets_Funds__c.Locations__c'
    };

    static Map<String, String> countryNames = new ICS_CTRL_GetDataUtils(dataObj).getPickListValueMap('PartyProfile.Country_of_Residence__c');

    static Map<String, String> fieldAlias = new Map<String, String> {
        'PartyProfile.Country_of_Residence__c' => 'Country of Residence',
        'PartyProfile.Country_of_Nationality__c' => 'Country of Nationality',
        'PartyProfile.CountryofBirth' => 'Country of Birth',
        'PartyProfileAddress.Country' => 'Country of Address',
        'FinServ__Employment__c.Employer_s_Country__c' => 'Employer\'s Country',
        'Party_Assets_Funds__c.Business_Location__c' => 'Business Location',
        'Party_Assets_Funds__c.Country__c' => 'Party Assets Country',
        'Party_Assets_Funds__c.Jurisdiction_Where_Investments_Held__c' => 'Jurisdiction Where Investments Are Held',
        'Party_Assets_Funds__c.Jurisdictional_Cover_of_Sale__c' => 'Jurisdictional Cover of Sale',
        'PartyProfile.Second_Country_of_Nationality__c' => 'Second Country of Nationality',
        'Party_Assets_Funds__c.Locations__c' => 'Party Assets Location',
        'Party_Assets_Funds__c.Trust__c' => ''
    };

    private static final string STAGE_CLOSED_LOST = 'Closed Lost';
    private static final string OPPORTUNITY_LOST_REASON = 'Reason unknown';
    private static final string ASSESSMENT_STATUS_IN_PROGRESS = 'In Progress';
    private static final string DOCUMENTATION_ASSESSED_BY_NC = 'Documentation Assessed By New Client User';
    private static final string QUERY_APPLICANT = 'Applicant(Sort By Role ["Primary Applicant"])';
    private static final string MOTIVATION_REQUIRED = 'Motivation Required';
    private static final string MOTIVATION_NOT_REQUIRED = 'Motivation Not Required';
    private static final string CONFIG_FR = 'QC 01 FR';
    private static final string ELIGIBLE_FOR_FR = 'Eligible For Full Onboarding Review Queue';
    private static final string CONFIG_FT = 'QC 02 FT';
    private static final string ELIGIBLE_FOR_FT = 'Eligible For Fast Track Queue';
    private static final string ELIGIBLE_FOR_ST = 'Eligible For Straight Through Process';
    private static final string CONFIG_COMMON = 'Common';
    private static final string CONFIG_ATM = 'Applicant In African Target Market';
    private static final string STRING_CARRIAGE_RETURN = '\r';
    private static final string STRING_BLANK = '';
    private static final string CONFIG_NC_LAYOUT = 'New Client Officer Layout';
    private static final string CONFIG_TAB_TITLE = 'Applicant Tab Title';
    private static final string CONFIG_GROUPED_DETAILS = 'Grouped Details';
    private static final string FIELD_CONDITIONS = 'Conditions__c';
    private static final string FIELD_LABEL = 'Label';
    private static final string QUERY_ACCOUNTID = 'Applicant(Serial number).(AccountId)';
    private static final string QUERY_OPPORTUNITYID = 'Applicant(Serial number).ApplicationForm.(OpportunityId)';
    private static final string QUERY_QUEUE = 'Opportunity.(Queue__c)';
    private static final string JSON_KEY_PID = 'pId';
    private static final string JSON_KEY_NAME = 'name';
    private static final string JSON_KEY_OPPORTUNITYID = 'OpportunityId';
    private static final string JSON_KEY_TABLES = 'tables';
    private static final string JSON_KEY_TITLE = 'title';
    private static final string JSON_KEY_ACCOUNTID = 'AccountId';
    private static final string JSON_KEY_ON_HOLD_REASON = 'On hold reason';
    private static final string JSON_KEY_RISK_RATING_OUTCOME = 'Risk Rating Outcome';
    private static final string STRING_RISK_RATING_UPGRADED = 'Risk Rating Upgraded';
    private static final string STRING_RISK_RATING_DOWNGRADED = 'Risk Rating Downgraded';
    private static final string STRING_RISK_RATING_CHANGED = 'Risk Rating Changed';
    private static final string STRING_APPLICATION_ISSUES = 'Application Issues (RFT)';
    private static final string OBJECT_APPLICANT = 'Applicant';
    private static final string OBJECT_ACCOUNT = 'Account';
    private static final string OBJECT_OPPORTUNITY = 'Opportunity';
    public static final string STRING_START_LOG = 'StartBusinessLog;';
    public static final string STRING_END_LOG = 'EndBusinessLog;';
    private static final string STRING_NOT_AVAILABLE = ': Not Available\n\n';
    private static final string STRING_NOT_SATISFIED = ': NOT SATISFIED\n\n';
    private static final string STRING_GETLOG = ' getLog';
    

    /**
    * @description Generate developer name from question text
    * @author Tushar Walse | 21-09-2024 
    * @param name Text of the question
    * @return String The generated developer name
    **/
    @testvisible
    public static String getDeveloperName(String name) {
        try {
            String returnVe = name.replace(' ', '_');
            returnVe = returnVe.replaceAll('[.,;?!]', STRING_BLANK).left(80).removeEnd('_');
            return returnVe;
        } catch (Exception e) {
            LOGGER.error('Error in getDeveloperName: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }

    /**
    * @description Update opportunity stage and reason
    * @author Tushar Walse | 21-09-2024 
    * @param opportunityId Id of the opportunity to be updated
    * @param stage New value of the stage
    * @return Boolean Return true if successfull
    **/
    @AuraEnabled
    public static Boolean updateOpportunity(Id opportunityId, String stage) {
        try {
            if(String.isBlank(stage)) {
                return false;
            }
            Opportunity opportunity = new SEL_Opportunity().selectById(opportunityId);
            if(opportunity == null) {
                return false;
            }
            opportunity.StageName = stage;
            if(stage == STAGE_CLOSED_LOST) {
                opportunity.Loss_Reason__c = OPPORTUNITY_LOST_REASON;
            }
            if(!Schema.sObjectType.Opportunity.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Opportunity.');
            }
            update opportunity;
            return true;
        } catch (Exception e) {
            LOGGER.error('Error in updateOpportunity: {0}', new Object[]{e.getMessage()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Add party profile Id of primary applicant so that documents can be attached
    * @author Tushar Walse | 28-10-2024 
    * @param approvalProcess String indicating documents need to be attached
    **/
    public static String addPartyProfileId(String approvalProcess) {
        try {
            if(approvalProcess == 'Need GSD Approval') {
                approvalProcess = 'PrimaryPartyProfileId;' + dataObj.getSingleFieldValue('Applicant(Sort By Role ["Primary Applicant"]).PartyProfile.(Id)', 0) + ';' + approvalProcess;
            }
            return approvalProcess;
        } catch (Exception e) {
            LOGGER.error('Error in addPartyProfileId: {0}', new Object[]{e.getMessage()});
            return approvalProcess;
        }
    }

    /**
    * @description Update Required_Approval_Processes__c field with str
    * @author Tushar Walse | 29-09-2024 
    * @param opportunityId Id of the opportunity to update
    * @param approvalProcess String to remove or add if not present
    **/
    public static void addRequiredApproval(Id[] opportunityIds, String approvalProcess) {
        try {
            Opportunity[] opportunities = new SEL_Opportunity().selectByIds(new Set<Id>(opportunityIds));
            for(Opportunity opportunity : opportunities) {
                String[] requiredApprovalProcesses = (opportunity.Required_Approval_Processes__c ?? STRING_BLANK).split(';');
                if(!requiredApprovalProcesses.contains(approvalProcess)) {
                    requiredApprovalProcesses.add(addPartyProfileId(approvalProcess));
                }
                String newValue = String.join(requiredApprovalProcesses, ';');
                newValue = newValue.endsWith(';') ? newValue : newValue + ';';
                opportunity.Required_Approval_Processes__c = newValue;
            }
            if(!Schema.sObjectType.Opportunity.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Opportunity.');
            }
            update opportunities;
        } catch (Exception e) {
            LOGGER.error('Error in addRequiredApproval: {0}\nargument: {1}', new Object[]{e.getMessage(), approvalProcess});
        }
    }

    /**
    * @description Update Required_Approval_Processes__c field by removing str
    * @author Tushar Walse | 29-09-2024 
    * @param opportunityId Id of the opportunity to update
    * @param str String to remove or add if not present
    **/
    public static void removeRequiredApproval(Id[] opportunityIds, String approvalProcess) {
        try {
            Opportunity[] opportunities = new SEL_Opportunity().selectByIds(new Set<Id>(opportunityIds));
            for(Opportunity opportunity : opportunities) {
                String[] requiredApprovalProcesses = (opportunity.Required_Approval_Processes__c ?? STRING_BLANK).split(';');
                Integer index = requiredApprovalProcesses.indexOf(approvalProcess);
                if(index != -1) {
                    requiredApprovalProcesses.remove(index);
                }
                opportunity.Required_Approval_Processes__c = String.join(requiredApprovalProcesses, ';');
            }
            if(!Schema.sObjectType.Opportunity.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Opportunity.');
            }
            update opportunities;
        } catch (Exception e) {
            LOGGER.error('Error in removeRequiredApproval: {0}', new Object[]{e.getMessage()});
        }
    }

    /**
    * @description Get map of sObjectField vs sObject records
    * @author Tushar Walse | 15-10-2024 
    * @param sObjects Records containing the sObjectField that are to be mapped
    * @param sObjectField Field whose value is to be retrieved from sObjects and used as key
    * @return Map<String, List<Object>> Map of the sObjectField value vs sObjects records
    **/
    public static Map<String, List<Object>> getStringMap(SObject[] sObjects, SObjectField sObjectField) {
        try {
            Map<String, List<Object>> result = new Map<String, List<Object>>();
            for (SObject child : (sObjects ?? new SObject[]{})) {
                String key = STRING_BLANK + child.get(sObjectField);
                if(result.containsKey(key)) {
                    result.get(key).add(child);
                } else {
                    result.put(key, new List<SObject>{child});
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getStringMap: {0}', new Object[]{e.getMessage()});
            return new Map<String, List<Object>>();
        }
    }

    @AuraEnabled
    public static Boolean assignRequest(Id processInstanceWorkItemId) {
        try {
            ProcessInstanceWorkItem processInstanceWorkItem = new Sel_ProcessInstanceWorkItem().selectById(processInstanceWorkItemId);
            processInstanceWorkItem.ActorId = UserInfo.getuserid();
            if(!Schema.sObjectType.ProcessInstanceWorkitem.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update ProcessInstanceWorkitem.');
            }
            update processInstanceWorkItem;
            return true;
        } catch (Exception e) {
            LOGGER.error('Error in assignRequest: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getRequiredApprovalProcessesValue(Id opportunityId) {
        try {
            Opportunity opportunity = new SEL_Opportunity().selectById(opportunityId);
            return opportunity?.Required_Approval_Processes__c;
        } catch (Exception e) {
            LOGGER.error('Error in getRequiredApprovalProcessesValue: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String[] getAssignedTo(Id processInstanceWorkItemId) {
        try {
            ProcessInstanceWorkItem processInstanceWorkItem = new Sel_ProcessInstanceWorkItem().selectById(processInstanceWorkItemId);
            String[] result = new String[]{};
            if(processInstanceWorkItem.ActorId.getSobjectType() == Schema.Group.getSObjectType()) {
                String[] memberOfQueues = ICS_CTRL_GetData.getQueueMembership();
                Group groupRecord = new SEL_Group().selectById(processInstanceWorkItem.ActorId);
                result.add(groupRecord?.Name);
                result.add(STRING_BLANK + memberOfQueues.contains(groupRecord?.DeveloperName));
            } else {
                User[] users = new Sel_User().selectUsersByIds(new Set<Id>{processInstanceWorkItem.ActorId});
                result.add(users?.size() > 0 ? users[0].Name : STRING_BLANK);
                result.add('true');
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getAssignedTo: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Get tables from query
    * @author Tushar Walse | 10-04-2025 
    * @param String The query
    * @return String The tables asked by the query
    **/
    @AuraEnabled(cacheable=true)
    public static String getTables(String query) {
        try {
            Map<String, Object> tables;
            switch on query {
                when 'Items to Approve' {
                    dataObj = new ICS_Ctrl_GetData(UserInfo.GetUserId());
                    dataObj.init('ProcessInstanceStep');
                    tables = dataObj.getFieldValueTables(ICS_CTRL_ApprovalFlow.getConfig(query), 0);
                }
                when else {
                    LOGGER.warn('getTables: Unrecognised query value: {0}', new Object[]{query});
                }
            }
            return(JSON.Serialize(tables));
        } catch (Exception e) {
            LOGGER.error('Error in getTables: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Tushar Walse | 10-07-2025 
    * @param jsonString 
    * @param key 
    * @param value 
    * @return String 
    **/
    public static String jsonSet(String jsonString, String key, String value) {
        if(jsonString == null) {
            jsonString = '';
        }
        String startString = '<start json string>';
        String endString = '<end json string>';

        if (!jsonString.contains(startString)) {
            jsonString = startString + '{}' +  endString + ';' + jsonString;
        }

        Integer startIndex = jsonString.indexOf(startString);
        Integer endIndex = jsonString.indexOf(endString);
        String part1 = jsonString.substring(0, startIndex);
        String part2 = jsonString.substring(startIndex + startString.length(), endIndex);
        String part3 = jsonString.substring(endIndex + endString.length(), jsonString.length());

        Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(part2, Map<String, String>.class);
        if(key != null) {
            jsonData.put(key, value);
        }

        return part1 + startString + JSON.serialize(jsonData) + endString + part3;

    }

    /**
    * @description 
    * @author Tushar Walse | 10-07-2025 
    * @param jsonString 
    * @param key 
    * @return String 
    **/
    public static String jsonGet(String jsonString, String key) {
        String startString = '<start json string>';
        String endString = '<end json string>';

        if(jsonString == null || !jsonString.contains(startString) || !jsonString.contains(endString) || key == null) {
            return null;
        }

        Integer startIndex = jsonString.indexOf(startString);
        Integer endIndex = jsonString.indexOf(endString);
        String part2 = jsonString.substring(startIndex + startString.length(), endIndex);

        Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(part2, Map<String, String>.class);

        return jsonData.get(key);
    }
    
    /**
    * @description Approve/Reject allOrNone request
    * @author Tushar Walse | 02-02-2025 
    * @param processInstanceWorkItemId 
    * @param action Approve/Reject string
    * @param comment Comment to be set
    * @return Boolean Whether operation was successfull
    **/
    @AuraEnabled
    public static Boolean approveRequest(Id processInstanceWorkItemId, String action, String comment) {
        try {
            if(!Schema.sObjectType.Opportunity.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Opportunity.');
            }
            ProcessInstanceWorkitem processInstanceWorkitem = new SEL_ProcessInstanceWorkItem().selectById(processInstanceWorkItemId);
            ProcessInstance processInstance = new Sel_ProcessInstance().selectById(processInstanceWorkitem.ProcessInstanceId);
    
            action = handleDeclineAction(action, comment, processInstance);
    
            Boolean sendBack = action.startsWith('Send Back');
            Id opportunityId = processInstance.TargetObjectId;
    
            action = prepareOpportunityForApproval(opportunityId, action, sendBack);
    
            Approval.ProcessWorkitemRequest processWorkitemRequest = new Approval.ProcessWorkitemRequest();
            processWorkitemRequest.setAction(action);
            processWorkitemRequest.setComments(comment);
            processWorkitemRequest.setWorkitemId(processInstanceWorkItemId);
            Approval.process(processWorkitemRequest, true);
    
            updateRequiredApprovalAfterProcess(opportunityId, sendBack);
    
            return true;
        } catch (Exception e) {
            LOGGER.error('Error in approveRequest: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static String handleDeclineAction(String action, String comment, ProcessInstance processInstance) {
        if(action.startsWith('Reject;')) {
            String declineString = action.substringAfter(';');
            String otherLossReason = declineString.substringAfter(';');
            declineString = declineString.substringBefore(';');
            Opportunity opportunity = new Opportunity(
                Id = processInstance.TargetObjectId,
                ICS_Decline_Reason__c = declineString,
                Description = comment,
                Other_Loss_Reason__c = otherLossReason
            );
            update opportunity;
            action = action.substringBefore(';');
        }
        return action;
    }
    
    private static String prepareOpportunityForApproval(Id opportunityId, String action, Boolean sendBack) {
        Opportunity opportunityToUpdate = new SEL_Opportunity().selectById(opportunityId);
        if(sendBack) {
            String rightPart = opportunityToUpdate.Required_Approval_Processes__c.substringAfterLast(';');
            if(rightPart.countMatches('.') <= 1) {
                throw new IllegalArgumentException('No where to go back!');
            }
            opportunityToUpdate.Required_Approval_Processes__c = jsonSet(
                opportunityToUpdate.Required_Approval_Processes__c, 'SentBack', 'true'
            );
            Opportunity opportunity = new Opportunity(
                Id = opportunityId,
                Required_Approval_Processes__c = opportunityToUpdate.Required_Approval_Processes__c.replace('$', '')
            );
            update opportunity;
            return 'Reject';
        } else {
            Opportunity opportunity = new Opportunity(
                Id = opportunityId,
                Required_Approval_Processes__c = jsonSet(
                    opportunityToUpdate.Required_Approval_Processes__c, 'SentBack', ''
                )
            );
            update opportunity;
            return action;
        }
    }
    
    private static void updateRequiredApprovalAfterProcess(Id opportunityId, Boolean sendBack) {
        Opportunity opportunityToUpdate = new SEL_Opportunity().selectById(opportunityId);
        String jsonString = opportunityToUpdate.Required_Approval_Processes__c;
        if(sendBack) {
            Integer targetChar = '.'.charAt(0);
            String queueString = jsonString.substringAfterLast(';');
            jsonString = jsonSet(jsonString, queueString.replace('$', ''), UserInfo.getuserid());
            List<Integer> indexes = new List<Integer>();
            for(Integer i = 0; i < queueString.length(); i++) {
                if(queueString.charAt(i) == targetChar) {
                    indexes.add(i);
                }
            }
            if(indexes.size() >= 2) {
                Integer secondLastIndex = indexes.get(indexes.size() - 2);
                String newValue = queueString.left(secondLastIndex) + '$';
                jsonString = jsonString.substringBeforeLast(';') + ';' + newValue;
            }
        } else {
            String queueString = jsonString.substringAfterLast(';');
            jsonString = jsonSet(jsonString, queueString.substring(0, queueString.lastIndexOf('.')-1), UserInfo.getuserid());
        }
        Opportunity opportunity = new Opportunity(
            Id = opportunityId,
            Required_Approval_Processes__c = jsonString
        );
        update opportunity;
    }

    /**
    * @description Save assessment data
    * @author Tushar Walse | 21-09-2024 
    * @param jsonString JSON containing data
    * @return Boolean Return true if successfull
    **/
    @AuraEnabled
    public static Boolean saveAssessmentData(String jsonString) {
        try {
            Id pId;
            Id opportunityId;
            String name;
    
            if(String.isBlank(jsonString)) {
                return false;
            }
            Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(jsonString, Map<String,String>.class);
            pId = jsonData.get(JSON_KEY_PID);
            name = jsonData.get(JSON_KEY_NAME);
            opportunityId = jsonData.get(JSON_KEY_OPPORTUNITYID);
            
            jsonData.remove(JSON_KEY_PID);
            jsonData.remove(JSON_KEY_NAME);
            jsonData.remove(JSON_KEY_OPPORTUNITYID);
                
            Assessment assessmentRecord = new Assessment();
            assessmentRecord.AssessmentStatus = ASSESSMENT_STATUS_IN_PROGRESS;
            assessmentRecord.name = name;
            assessmentRecord.AccountId = pId;
            List<Assessment> assessmentList = new List<Assessment>{assessmentRecord};
            if(!Schema.sObjectType.Assessment.isCreateable()) {
                throw new AuraHandledException('Insufficient permissions to create Assessment.');
            }
            insert assessmentList;
            Set<String> developerNames = new Set<String>();
    
            for(String key: jsonData.keySet()) {
                developerNames.add(getDeveloperName(key));
            }
    
            List<AssessmentQuestion> assessmentQuestionRecords = new SEL_AssessmentQuestion().selectByDeveloperNames(developerNames);
            Map<String, List<Object>> assesmentQuestionMap = getStringMap(assessmentQuestionRecords, AssessmentQuestion.DeveloperName);
    
            List<AssessmentQuestionResponse> assessmentQuestionResponseRecords = new List<AssessmentQuestionResponse>();
            for(String key: jsonData.keySet()) {
                List<AssessmentQuestion> assessmentQuestionRecordsForKey = (List<AssessmentQuestion>)assesmentQuestionMap.get(getDeveloperName(key));
                if(assessmentQuestionRecordsForKey != null) {
                    AssessmentQuestionResponse assessmentQuestionResponseRecord = new AssessmentQuestionResponse();
                    assessmentQuestionResponseRecord.AssessmentId = assessmentRecord.Id;
                    assessmentQuestionResponseRecord.AssessmentQuestionId = assessmentQuestionRecordsForKey[0].ActiveVersionId;
                    assessmentQuestionResponseRecord.IsTrueOrFalseValue = false;
                    assessmentQuestionResponseRecord.name = assessmentRecord.name;
                    assessmentQuestionResponseRecord.ResponseText = jsonData.get(key);
                    assessmentQuestionResponseRecords.add(assessmentQuestionResponseRecord);
                }
            }
            List<AssessmentQuestionResponse> assessmentQuestionResponseList = new List<AssessmentQuestionResponse>(assessmentQuestionResponseRecords);
            if(Schema.sObjectType.AssessmentQuestionResponse.isCreateable()==false) {
                throw new AuraHandledException('Insufficient permissions to create AssessmentQuestionResponse.');
            }
            insert assessmentQuestionResponseList;
            if(opportunityId != null) {
                updateOpportunityAfterAssessment(opportunityId, pId, jsonData);
            }
            
            return true;
        } catch (Exception e) {
            LOGGER.error('Error in saveAssessmentData: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }
     /**
    * @description Update opportunity and application form after assessment data is saved
    * @param opportunityId Id of the opportunity to update
    * @param pId Account Id of the applicant
    * @param jsonData Map of assessment question responses
    **/
    private static void updateOpportunityAfterAssessment(Id opportunityId, Id pId, Map<String, String> jsonData) {
        Opportunity[] opportunities = new SEL_Opportunity().selectByIds(new Set<Id>{opportunityId});
        Opportunity opportunity = opportunities[0];
        if(!(opportunity.Required_Approval_Processes__c ?? STRING_BLANK).contains(DOCUMENTATION_ASSESSED_BY_NC)) {
            opportunity.Required_Approval_Processes__c = DOCUMENTATION_ASSESSED_BY_NC + ';' + opportunity.Required_Approval_Processes__c;
        }
        Boolean riskRatingChanged = 
            jsonData.get(JSON_KEY_RISK_RATING_OUTCOME) == (STRING_RISK_RATING_UPGRADED) ||
            jsonData.get(JSON_KEY_RISK_RATING_OUTCOME) == (STRING_RISK_RATING_DOWNGRADED);
        String on_hold_reason;
        if(riskRatingChanged) {
            on_hold_reason = 'Challenging Risk Rating';
        }
        if(riskRatingChanged && !(opportunity.Required_Approval_Processes__c ?? STRING_BLANK).contains(STRING_RISK_RATING_CHANGED)) {
            opportunity.Required_Approval_Processes__c = STRING_RISK_RATING_CHANGED + ';' + opportunity.Required_Approval_Processes__c;
        }
        if(jsonData.get(JSON_KEY_ON_HOLD_REASON) == STRING_APPLICATION_ISSUES) {
            on_hold_reason = STRING_APPLICATION_ISSUES;
        }
        updateApplicationFormAndOpportunity(opportunity, pId, jsonData, riskRatingChanged, on_hold_reason);
        if(!Schema.sObjectType.Opportunity.isUpdateable()) {
            throw new AuraHandledException('Insufficient permissions to update Opportunity.');
        }
        update opportunities;
    }
    
    /**
    * @description Update application form stage and opportunity queue based on assessment outcome
    * @param opportunity Opportunity record to update
    * @param pId Account Id of the applicant
    * @param jsonData Map of assessment question responses
    * @param riskRatingChanged Whether risk rating was upgraded or downgraded
    * @param on_hold_reason Reason for putting application on hold
    **/
    private static void updateApplicationFormAndOpportunity(Opportunity opportunity, Id pId, Map<String, String> jsonData, Boolean riskRatingChanged, String on_hold_reason) {
        if(jsonData.get(JSON_KEY_ON_HOLD_REASON) == STRING_APPLICATION_ISSUES || riskRatingChanged) {
            ApplicationForm[] applicationForms = new SEL_ApplicationForm().selectByAccountId(pId);
            if(!applicationForms.isEmpty()) {
                applicationForms[0].stage = 'On Hold';
                applicationForms[0].On_hold_reason__c = on_hold_reason;
                if(!Schema.sObjectType.ApplicationForm.isUpdateable()) {
                    throw new AuraHandledException('Insufficient permissions to update ApplicationForm.');
                }
                update(applicationForms);
            }
            opportunity.Required_Approval_Processes__c = opportunity.Required_Approval_Processes__c.replace(';FT.NC$', ';FR.NC$');
            opportunity.Queue__c = 'New Client Onboarding Review';
        } else {
            ApplicationForm[] applicationForms = new SEL_ApplicationForm().selectByAccountId(pId);
            if(!applicationForms.isEmpty()) {
                ApplicationFormHistory[] applicationFormHistorys = new SEL_ApplicationFormHistory().selectByApplicationFormIdAndField(applicationForms[0].Id, 'Stage');
                if(!applicationFormHistorys.isEmpty() && applicationForms[0].stage == 'On Hold') {
                    applicationForms[0].stage = applicationFormHistorys[0].OldValue?.toString();
                    if(!Schema.sObjectType.ApplicationForm.isUpdateable()) {
                        throw new AuraHandledException('Insufficient permissions to update ApplicationForm.');
                    }
                    update(applicationForms);    
                }
            }
        }
    }

    /**
    * @description Get list of specified field values from all records
    * @author Tushar Walse | 29-09-2024 
    * @param sObjects Records from which field is to be retrieved
    * @param field The field value to be retrieved
    * @return List<String> The list of retrieved values
    **/
    public static List<String> getFieldValues(SObject[] sObjects, SObjectField field) {
        try {
            List<String> result = new List<String>();
            for (SObject eachSObject : (sObjects ?? new SObject[]{})) {
                result.add(STRING_BLANK + eachSObject.get(field));
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getFieldValues: {0}', new Object[]{e.getMessage()});
            return new List<String>();
        }
    }

    /**
    * @description Get set of Id field values from all records
    * @author Tushar Walse | 29-09-2024 
    * @param objects Records from which field is to be retrieved
    * @param field The field containing the Id to be retrieved
    * @return Set<Id> The set of Ids retrieved
    **/
    public static Set<Id> getSetOfIds(SObject[] objects, SObjectField field) {
        try {
            return new Set<Id>((List<Id>)getFieldValues(objects, field));
        } catch (Exception e) {
            LOGGER.error('Error in getSetOfIds: {0}', new Object[]{e.getMessage()});
            return new Set<Id>();
        }
    }

    /**
    * @description Load assessment data from AccountId
    * @author Tushar Walse | 21-09-2024 
    * @param pId Account Id to retrieve assessment record
    * @param name Name of the section
    * @return String JSON String containing questions and answers
    **/
    @AuraEnabled
    public static String loadAssessmentData(Id pId, String name) {
        try {
            List<AssessmentQuestionResponse> assessmentQuestionResponses = new SEL_AssesmentQuestionResponse().selectByAccountIdAndName(pId, name);
            Map<String, String> jsonData = new Map<String, String>();
            if(assessmentQuestionResponses.isEmpty()) {
                return JSON.serialize(jsonData);
            }
            Set<Id> assessmentQuestionIds = getSetOfIds(assessmentQuestionResponses, AssessmentQuestionResponse.AssessmentQuestionId) ?? new Set<Id>();
            List<AssessmentQuestion> assessmentQuestions =  new SEL_AssessmentQuestion().selectByActiveVersionIds(assessmentQuestionIds);
            Map<Id, AssessmentQuestion> assessmentQuestionsMap = new Map<Id, AssessmentQuestion>();
            for(AssessmentQuestion assessmentQuestion : assessmentQuestions) {
                assessmentQuestionsMap.put(assessmentQuestion.ActiveVersionId, assessmentQuestion);
            }
            for (AssessmentQuestionResponse a : assessmentQuestionResponses) {
                String key = assessmentQuestionsMap?.get(a.AssessmentQuestionId)?.QuestionText;
                if(key != null && !jsonData.containsKey(key)) {
                    jsonData.put(key, a.ResponseText);
                }
            }
            return JSON.serialize(jsonData);
        } catch (Exception e) {
            LOGGER.error('Error in loadAssessmentData: {0}', new Object[]{e.getMessage()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Retrive New Client Officer Layout
    * @author Tushar Walse | 21-09-2024 
    * @param pId ProcessIntanceStep or other root Id to retrieve details
    * @return String JSON containing New Client Officer Layout data
    **/
    @AuraEnabled(cacheable=true)
    public static String getDetails(Id pId) {
        try {
            dataObj = new ICS_Ctrl_GetData(pId);
            dataObj.init('AOB_ReferencedData__c');
            dataObj.init('BusinessHours');
            dataObj.init('CurrencyType');
            
            String commonQueryPart = getConfig(CONFIG_COMMON) + '\n\n';
            
            String query = commonQueryPart + getConfig(CONFIG_NC_LAYOUT);
            String applicantTabTitlequery = getConfig(CONFIG_TAB_TITLE);
            Map<String, Object> returnMap = new Map<String, Object>();

            List<Map<String, Object>> applicantDetails = new List<Map<String, Object>>();

            Integer[] idx = dataObj.getSortIndex(QUERY_APPLICANT, OBJECT_APPLICANT);
            for(Integer i : idx) {
                Map<String, Object> tables = dataObj.getFieldValueTables(query, i);
                applicantDetails.add(new Map<String, Object>{
                    JSON_KEY_TABLES => tables, 
                    JSON_KEY_TITLE => dataObj.getSingleFieldValue(applicantTabTitlequery, i),
                    JSON_KEY_ACCOUNTID => dataObj.getSingleFieldValue(QUERY_ACCOUNTID, i),
                    JSON_KEY_OPPORTUNITYID => dataObj.getSingleFieldValue(QUERY_OPPORTUNITYID, i)
                });
            }

            returnMap.put('applicantDetails', applicantDetails);

            String outPut = STRING_BLANK;
            for(String eachQuery : getConfig(CONFIG_GROUPED_DETAILS).split('\n')) {
                if(eachQuery == '<br>') {
                    outPut = outPut.removeEnd(', ') + '<br>';
                } else {
                    List<Map<String,Object>> queryResult = dataObj.getFieldValue(eachQuery);
                    if(queryResult.size() > 0) {
                        Map<String,Object> v = queryResult[0];
                        for(String eachKey : v.keySet()) {
                            outPut += eachKey + ': ' + v.get(eachKey) + ', ';
                        }
                    }    
                }
            }
            returnMap.put('groupedDetails', outPut.removeEnd(', '));
            returnMap.put('queue', dataObj.getSingleFieldValue(QUERY_QUEUE, 0));
            return(JSON.Serialize(returnMap));
        } catch (Exception e) {
            LOGGER.error('Error in getDetails: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Get Id of the opportunity triggering the flow
    * @author Tushar Walse | 21-09-2024 
    * @param inputs Inputs from the flow
    * @return Set<Id> Set of Ids
    **/
    @testvisible
    private static Set<Id> getIdsSet(List<Input> inputs) {
        try {
            Set<Id> result = new Set<Id>{};
            for(Input input : inputs) {
                result.add(input.opportunityId);
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getIdsSet: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }

    /**
    * @description  Retrieve an approval condition from the static resource
    * @author Tushar Walse | 21-09-2024 
    * @param label The name of the approval condition to retrieve
    * @return String The text of the approval condition
    **/
    @testvisible
    public static String getConfig(String label) {
        try {
            if(staticResource == null) {
                if(!Schema.sObjectType.StaticResource.isAccessible()) {
                    throw new AuraHandledException('Insufficient permissions to access StaticResource.');
                }
                staticResource = [SELECT Body FROM StaticResource WHERE Name = 'ICSApprovalProcessCondition' LIMIT 1];
                conditions = (Map<String, String>)JSON.deserialize(staticResource.Body.toString(), Map<String, String>.class);
            }
            logLabel = label;
            return conditions.get(label).replace(STRING_CARRIAGE_RETURN, STRING_BLANK);
        } catch (Exception e) {
            LOGGER.error('Error in getConfig: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }

    /**
    * @description Delete record for the given Id
    * @author Tushar Walse | 28-07-2025 
    * @param recordId Id of the record to be deleted
    * @return String Return 'true' if operation was succcessfull
    **/
	@AuraEnabled
    public static String deleteRecord(String id) {
        try {
            String returnVe = 'false';
            if(String.isBlank(id)) {
                throw new IllegalArgumentException('No record Id to delete!');
            }
            Id recordId = id;
            Schema.DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
            
            if(!describeResult.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access: ' + recordId.getSObjectType());
            }
            if(!describeResult.isDeletable()) {
                throw new AuraHandledException('Insufficient permissions to delete: ' + recordId.getSObjectType());
            }
            
            SObject recordToDelete = recordId.getSObjectType().newSObject(recordId);
            delete recordToDelete;
            returnVe = 'true';
            return returnVe;
        } catch (Exception e) {
            LOGGER.error('Error in deleteRecord: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Retrieve all approval conditions from the static resource
    * @author Tushar Walse | 21-09-2024 
    * @param label  The name of the approval condition to retrieve
    * @return List<Map<String, String>> Map of all approval conditions
    **/
   @testvisible
    private static List<Map<String, String>> getConditions(String label) {
        try {
            if(staticResource == null) {
                if(!Schema.sObjectType.StaticResource.isAccessible()) {
                    throw new AuraHandledException('Insufficient permissions to access StaticResource.');
                }
                staticResource = [SELECT Body FROM StaticResource WHERE Name = 'ICSApprovalProcessCondition' LIMIT 1];
                conditions = (Map<String, String>)JSON.deserialize(staticResource.Body.toString(), Map<String, String>.class);
            }
            List<Map<String, String>> result = new List<Map<String, String>>();
            String[] keySet = new List<String>(conditions.keySet());
            keySet.sort();
            for(String key : keySet) {
                if(key.contains(label)) {
                    Map<String, String> row = new Map<String, String>();
                    row.put(FIELD_LABEL, key);
                    row.put(FIELD_CONDITIONS, conditions.get(key));
                    result.add(row);    
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in getConditions: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }

    /**
    * @description Determine the next step after current approval request has been responded
    * @author Tushar Walse | 21-09-2024 
    * @param inputs Values coming from ICS_Opportunity_After_Trigger flow
    * @param commonQueryPart Containing approval flow settings
    * @return String[] containing the response to be sent back to the flow 
    **/
    @testvisible
    static String[] evalQueueCode(List<Input> inputs, String commonQueryPart) {
        try {
            List<String> returnVe = new List<String>{STRING_BLANK};
            String lastString;
            if(!String.isEmpty(inputs[0].value)) {
                lastString = inputs[0].value;
            }
            if(String.isEmpty(lastString) || !lastString.endsWith('$')) {
                return returnVe;
            }
            lastString = ' ' + lastString.substringAfterLast(';').replace('$', '=>');
            List<Map<String, Object>> records = getConditions(lastString);
            LOGGER.warn('\nrecords: {0}', new Object[]{JSON.serialize(records)});
            for(Map<String, Object> record : records) {
                String conditions = STRING_BLANK + record.get(FIELD_CONDITIONS);
                String query = record.get(FIELD_CONDITIONS) == null ? STRING_BLANK : commonQueryPart + conditions.replace(STRING_CARRIAGE_RETURN, STRING_BLANK);
                logLabel = '' + record.get(FIELD_LABEL);
                if(String.isBlank(query) || checkAllCriteria(query)) {
                    returnVe[0] = (STRING_BLANK + record.get(FIELD_LABEL)).right(2);
                    break;
                }
            }    
            return returnVe;
        } catch (Exception e) {
            LOGGER.error('Error in evalQueueCode: {0}', new Object[]{e.getMessage()});
            return null;
        }
    }

    /**
     * @description                 : Class to carry inputs from flow to processFlowRequests method
     * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
     * @author                      : Tushar Walse
     * @date                        : 21-09-2024
     * @last modified on            : 15-10-2025
     * @last modified by            : Tushar Walse
     * @modification description    : Created
     */
    public class Input {
        @InvocableVariable
        public Id opportunityId;
        @InvocableVariable
        public String str;
        @InvocableVariable
        public String value;
    }

    /**
    * @description Method called by ICS_Opportunity_After_Trigger flow to drive approval the process
    * @author Tushar Walse | 21-09-2024 
    * @param inputs .opportunityId containing the Id of triggerring opportunity
    * @param inputs .str containing the request string to be processed
    * @param inputs .value containing the state of the approval request
    * @return List<String> containing the response to be sent back to the flow
    **/
    @InvocableMethod(
        label = 'Invoke Approval Process Checks'
        description = 'Perform checks as per the criteria'
        category = 'Approvals'
    )
    public static List<String> processFlowRequests(List<Input> inputs) {
        return processFlowRequestsMethod(inputs);
    }

    /**
    * @description Method called by processFlowRequests to drive approval the process
    * @author Tushar Walse | 21-09-2024 
    * @param inputs .opportunityId containing the Id of triggerring opportunity
    * @param inputs .str containing the request string to be processed
    * @param inputs .value containing the state of the approval request
    * @return List<String> containing the response to be sent back to the flow
    **/
   public static List<String> processFlowRequestsMethod(List<Input> inputs) {
        try {
            LOGGER.warn('\nprocessFlowRequestsMethod:\ninputs: {0}', new Object[]{JSON.serialize(inputs)});
            List<String> returnVe = new List<String>{STRING_BLANK};
    
            if(dataObj == null && inputs[0].opportunityId != null) {
                dataObj = new ICS_Ctrl_GetData(getIdsSet(inputs));
                dataObj.init('AOB_ReferencedData__c');
            }
    
            String commonQueryPart = getConfig(CONFIG_COMMON) + '\n\n';
    
            Boolean getLog = inputs[0].str?.endsWith(STRING_GETLOG);
            if(getLog == true) {
                inputs[0].str = inputs[0].str.removeEnd(STRING_GETLOG);
            }
    
            returnVe = handleSwitchCase(inputs, commonQueryPart, returnVe, getLog);
    
            if(getLog) {
                returnVe[0] = allLog;
            }
    
            return returnVe;
        } catch (Exception e) {
            LOGGER.error('Error in processFlowRequestsMethod: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }
     /**
        * @description Route flow request to appropriate handler based on input string
        * @param inputs Inputs from the flow
        * @param commonQueryPart Common query configuration string
        * @param returnVe Current return value list
        * @param getLog Whether to return log output
        * @return List<String> Updated return value list
        **/
   private static List<String> handleSwitchCase(List<Input> inputs, String commonQueryPart, List<String> returnVe, Boolean getLog) {
	Logger.debug('INPUT STR = ' + inputs[0].str);
        switch on inputs[0].str {
            when 'jsonGet' {
                returnVe[0] = jsonGet(inputs[0]?.value?.substringAfter(';'), inputs[0]?.value?.substringBefore(';'));
            }
            when 'saveAssessmentData' {
                saveAssessmentData(inputs[0].value);
            }
            when 'Load GSD Comment' {
                returnVe[0] = loadAssessmentDataComment(inputs[0].value, 'GSD Approval');
            }
            when 'Load Ukraine Exception Comment' {
                returnVe[0] = loadAssessmentDataComment(inputs[0].value, 'Ukraine Exception Approval');
            }
            when 'Update Required Approval Process(Set)' {
                addRequiredApproval(new Id[]{inputs[0].opportunityId}, inputs[0].value);
            }
            when 'Update Required Approval Process(Unset)' {
                removeRequiredApproval(new Id[]{inputs[0].opportunityId}, inputs[0].value);
            }
            when 'Check Additional Risk Factors' {
                returnVe = handleCheckAdditionalRiskFactors(inputs, commonQueryPart, returnVe);
            }
            when else {
                returnVe = handleSwitchCaseProcess(inputs, commonQueryPart, returnVe, getLog);
            }
        }
        return returnVe;
    }
    
    private static List<String> handleSwitchCaseProcess(List<Input> inputs, String commonQueryPart, List<String> returnVe, Boolean getLog) {
        switch on inputs[0].str {
            when 'Get Queue Code' {
                returnVe = evalQueueCode(inputs, commonQueryPart);
            }
            when 'Check Queue Conditions' {
                returnVe = handleCheckQueueConditions(commonQueryPart, returnVe);
            }
            when 'Check Motivation Required' {
                returnVe = handleCheckMotivationRequired(commonQueryPart, returnVe);
            }
            when 'Group Sanctions Desk' {
                returnVe = handleGroupSanctionsDesk(inputs, commonQueryPart, returnVe, getLog);
            }
            when 'Get Party Profile IDs for GSD' {
                returnVe = handleGetPartyProfileIDs(inputs, returnVe);
            }
            when 'All Applicants Assessed' {
                returnVe[0] = STRING_BLANK + dataObj.check(getConfig(inputs[0].str));
            }
            when 'Last approver not a Client Manager' {
                returnVe[0] = STRING_BLANK + dataObj.check(getConfig(inputs[0].str));
            }
            when else {
                returnVe[0] = STRING_BLANK + checkAllCriteria(commonQueryPart + getConfig(inputs[0].str));
            }
        }
        return returnVe;
    }
    /**
    * @description Evaluate motivation required condition and return result
    * @param commonQueryPart Common query configuration string
    * @param returnVe Current return value list
    * @return List<String> Updated return value list
    **/
    private static List<String> handleCheckMotivationRequired(String commonQueryPart, List<String> returnVe) {
        Boolean result = checkAllCriteria(commonQueryPart + getConfig(MOTIVATION_REQUIRED));
        returnVe[0] = result ? MOTIVATION_REQUIRED : MOTIVATION_NOT_REQUIRED;
        return returnVe;
    }
    
    /**
    * @description Extract party profile IDs for GSD from value string
    * @param inputs Inputs from the flow
    * @param returnVe Current return value list
    * @return List<String> Updated return value list
    **/
    private static List<String> handleGetPartyProfileIDs(List<Input> inputs, List<String> returnVe) {
        String partyProfileIDs = inputs[0].value.substringBetween('Need GSD Approval;', 'End Need GSD Approval;');
        if(!String.isBlank(partyProfileIDs)) {
            returnVe[0] = partyProfileIDs;
        }
        return returnVe;
    }
    /**
    * @description Load comment field from assessment data for a given section
    * @param value Account Id to retrieve assessment record
    * @param section Name of the assessment section
    * @return String The comment value from the assessment response
    **/
    private static String loadAssessmentDataComment(Id value, String section) {
        String jsonString = loadAssessmentData(value, section);
        Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(jsonString, Map<String,String>.class);
        return jsonData.get('Comment');
    }
    
    private static List<String> handleCheckAdditionalRiskFactors(List<Input> inputs, String commonQueryPart, List<String> returnVe) {
        String query = commonQueryPart + getConfig(inputs[0].str.removeStart('Check '));
        Boolean aRFCondition = checkAllCriteria(query);
        returnVe[0] = STRING_BLANK + aRFCondition;
        if(aRFCondition) {
            query = commonQueryPart + getConfig(CONFIG_ATM);
            returnVe[0] = checkAllCriteria(query) ? 'Africa' : 'Yes';
        }
        return returnVe;
    }
    
    private static List<String> handleCheckQueueConditions(String commonQueryPart, List<String> returnVe) {
        if(checkAllCriteria(commonQueryPart + getConfig(CONFIG_FR))) {
            returnVe[0] = ELIGIBLE_FOR_FR;
        } else if(checkAllCriteria(commonQueryPart + getConfig(CONFIG_FT))) {
            returnVe[0] = ELIGIBLE_FOR_FT;
        } else {
            returnVe[0] = ELIGIBLE_FOR_ST;
        }
        return returnVe;
    }
    
    private static List<String> handleGroupSanctionsDesk(List<Input> inputs, String commonQueryPart, List<String> returnVe, Boolean getLog) {
        String[] result = checkAndGetIds(commonQueryPart + getConfig('Group Sanctions Desk - Prohibited Countries'));
        if(!String.isBlank(result[0])) {
            returnVe[0] = 'Group Sanctions Desk - Prohibited Countries;' + result[0] + 'End Group Sanctions Desk - Prohibited Countries;';
        } else {
            result = checkAndGetIds(commonQueryPart + getConfig(inputs[0].str));
            if(!String.isBlank(result[0]) && !getLog) {
                returnVe[0] = 'Need GSD Approval;' + result[0] + 'End Need GSD Approval;';
                ApplicationForm[] applicationForms = dataObj.getRecords('ApplicationForm(Id = :' + JSON.serialize(result[1].split(';')) + ')').getRecords();
                for(ApplicationForm applicationForm : applicationForms) {
                    applicationForm.stage = 'On Hold';
                    applicationForm.On_hold_reason__c = 'GSD Referral';
                }
                if(!Schema.sObjectType.ApplicationForm.isUpdateable()) {
                    throw new AuraHandledException('Insufficient permissions to update ApplicationForm.');
                }
                update(applicationForms);
            }
            result = checkAndGetIds(commonQueryPart + getConfig('Group Sanctions Desk - Prohibited Countries'));
            if(!String.isBlank(result[0])) {
                returnVe[0] = 'Group Sanctions Desk - Prohibited Countries;' + result[0] + 'End Group Sanctions Desk - Prohibited Countries;';
            }
        }
        return returnVe;
    }

    /**
    * @description Approve/Reject the approval request
    * @author Tushar Walse | 08-02-2025 
    * @param id Id of the ProcessInstanceWorkitem record
    * @param str Function name to be performed like 'All Applicants Assessed', 'Last approver not a Client Manager'
    * @param value null
    * @return String Evaluated value which may be "true" or "false" string
    **/
    @AuraEnabled
    public static String processRequestsMethod(Id id, String str, String value) {
        try {
            Input[] inputs = new Input[]{};
            Input input = new Input();
            input.opportunityId = id;
            input.str = str;
            input.value = value;
            inputs.add(input);

            String[] returnVe = new String[]{};
            returnVe = processFlowRequestsMethod(inputs);
            return returnVe[0];

        } catch (Exception e) {
            LOGGER.error('Error in processRequestsMethod: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Check conditions for each of the applicants
    * @author Tushar Walse | 21-09-2024 
    * @param query Text containing conditions
    * @return String Outcome of evaluation with Ids
    **/
    @testvisible
    private static String[] checkAndGetIds(String query) {
        try {
            String[] result = new String[]{'', ''};
            Integer[] idx = dataObj.getSortIndex(QUERY_APPLICANT, OBJECT_APPLICANT);
            Applicant[] applicants = dataObj.getRecords(OBJECT_APPLICANT).getRecords();
            Account[] accounts = dataObj.getRecords(OBJECT_ACCOUNT).getRecords();
            allLogTitleAdded = false;
            for(Integer i : idx) {
                Boolean subResult = dataObj.check(query, i);
                log('<br>Applicant Name: <b>' + accounts[i].Name + '</b>');
                if(subResult == null) {
                    subResult = false;
                }
                if(!subResult) {
                    result[0] = result[0] + applicants[i].PartyProfileId + ';';
                    result[1] = result[1] + applicants[i].ApplicationFormId + ';';
                }
            }
            return result;
        } catch (Exception e) {
            LOGGER.error('Error in checkAndGetIds: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
            return null;
        }
    }


    /**
    * @description Get part of the list starting from start to endIndex
    * @author Tushar Walse | 10-09-2025 
    * @param input The whole list
    * @param start The start index of the list to retrieve
    * @param endIndex The end index of the list to retrieve
    * @return String[] The sublist retrieved
    **/
    @testvisible
    private static String[] subList(String[] input, Integer start, Integer endIndex) {
        String[] output = new String[]{};
        try {
            endIndex++;
            if (input == null || input.isEmpty()) {
                return output;
            }
            if (start < 0) {
                start = 0;
            }
            if (endIndex > input.size()) {
                endIndex = input.size();
            }
            if (start >= endIndex) {
                return output;
            }
            for (Integer i = start; i < endIndex; i++) {
                output.add(input[i]);
            }
            return output;
        } catch (Exception e) {
            LOGGER.error('Error: {0}\nline: {1}\nexception type: {2}\nstack trace: {3}', new Object[]{e.getMessage(), e.getLineNumber(), e.getTypeName(), e.getStackTraceString()});
            return output;
        }
    }

    /**
    * @description Replace country codes with full country names and field titles with alias
    * @author Tushar Walse | 10-09-2025 
    * @param triggeringConditions List of triggering conditions with raw descriptions
    * @return String[] Processed descriptions of triggering conditions
    **/
   @testvisible
    private static String[] processTriggers(String[] triggeringConditions) {
        try {
            if(countryPickListFieldNames.contains(triggeringConditions[0])) {
                for(Integer i = 1; i < triggeringConditions.size(); i++) {
                    if(countryNames.containsKey(triggeringConditions[i])) {
                        triggeringConditions[i] = countryNames.get(triggeringConditions[i]);
                    }
                }
            }
            if(fieldAlias.containsKey(triggeringConditions[0])) {
                triggeringConditions[0] = fieldAlias.get(triggeringConditions[0]);
            }
            return triggeringConditions;
        } catch (Exception e) {
            LOGGER.error('Error: {0}\nline: {1}\nexception type: {2}\nstack trace: {3}', new Object[]{e.getMessage(), e.getLineNumber(), e.getTypeName(), e.getStackTraceString()});
            return triggeringConditions;
        }
    }

    /**
    * @description Log details of individual conditions checked for current applicant
    * @author Tushar Walse | 07-01-2025 
    * @param entryLabel Label under which it's logged
    **/
    @testvisible
   private static void log(String entryLabel) {
        try {
            String log = buildLogFromDataObj();
            if(!String.isBlank(log)) {
                if(!allLogTitleAdded) {
                    allLog = '<br><b>' + logLabel + ': </b>';
                    allLogTitleAdded = true;
                }
                allLog += entryLabel + log.replaceAll('(<br>)+', '<br>');
            }
            SObject[] sObjects = dataObj.getRecords(OBJECT_OPPORTUNITY).getRecords();
            if(sObjects != null && sObjects.isEmpty()) {
                Opportunity opportunity = (Opportunity)sObjects[0];
                LOGGER.warn('\n{0}\nOpportunity Id: {1}\nOpportunity Name: {2}\nCriteria set Label: {3}\n{4}',
                    new Object[]{entryLabel, opportunity.Id, opportunity.Name, logLabel, log?.replaceAll('<br>', '\n')});
            }
        } catch (Exception e) {
            LOGGER.error('Error in log: {0}\nline: {1}', new Object[]{e.getMessage(), e.getLineNumber()});
        }
    }
    /**
    * @description Build log string from data object evaluation results
    * @return String HTML formatted log string
    **/
    private static String buildLogFromDataObj() {
        String[] logLines = dataObj.getLog();
        String log = '';
        String triggeringConditions = '';
        for(String logLine : logLines) {
            if(logLine.contains('. Evaluation Start:\n')) {
                triggeringConditions = '';
            } else if(logLine.startsWith('\nTriggers: ')) {
                triggeringConditions = parseTriggerConditions(logLine, triggeringConditions);
            } else if(logLine.endsWith(STRING_NOT_SATISFIED) || logLine.endsWith(STRING_NOT_AVAILABLE)) {
                log += '<br>' + triggeringConditions;
            }
        }
        return log;
    }
     /**
    * @description Parse and format triggering conditions from a log line
    * @param logLine Raw log line containing trigger data
    * @param triggeringConditions Existing triggering conditions string to append to
    * @return String Updated triggering conditions string
    **/      
    private static String parseTriggerConditions(String logLine, String triggeringConditions) {
        String[] triggersList = (String[])JSON.deserialize(
            logLine.substringAfter('\nTriggers: '), String[].class
        );
        triggersList = processTriggers(triggersList);
        if(!String.isBlank(triggersList[0])) {
            triggeringConditions += '<br>' + triggersList[0] + ': '
                + String.join(subList(triggersList, 1, triggersList.size()-1), ', ');
        }
        return triggeringConditions;
    }

    /**
    * @description Check conditions for each of the applicants
    * @author Tushar Walse | 21-09-2024 
    * @param query Text containing conditions
    * @param nullValue Value to consider when null
    * @return Boolean Outcome of evaluation
    **/
    @testvisible
    private static Boolean checkAllCriteria(String query) {
        try {
            Boolean result = false;
            Integer[] idx = dataObj.getSortIndex(QUERY_APPLICANT, OBJECT_APPLICANT);
            Account[] accounts = dataObj.getRecords(OBJECT_ACCOUNT).getRecords();

            for(Integer i : idx) {
                Boolean subResult = dataObj.check(query, i);
                log('<br>Applicant Name: ' + accounts[i].Name);
                if(subResult == null) {
                    subResult = false;
                }
                result = result || !subResult;
                if(result) {
                    break;
                }
            }

            return result;
        } catch (Exception e) {
            LOGGER.error('Error in checkAllCriteria: {0}\nargument: {1}', new Object[]{e.getMessage(), query});
            return null;
        }
    }

    /**
    * @description Validate file being uploaded
    * @author Tushar Walse | 14-04-2025 
    * @param jsonFiles Input
    * @return Boolean Validation result
    **/
    @AuraEnabled
    public static Boolean uploadFile(String jsonFiles) {
        try {
            if(String.isBlank(jsonFiles)) {
                return false;
            }

            LOGGER.warn('\njsonFiles: {0}', new Object[]{jsonFiles});
            
            return true;
        } catch (Exception e) {
            LOGGER.error('Error in uploadFile: {0}', new Object[]{e.getMessage()});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Get Approval History from ProcessInstance
    * @author Ramya Gurram | 17-03-2025 
    * @param recordId ProcessInstance
    * @return List<Map<String, Object>> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getApprovalHistory(Id recordId) {
        try {
            SEL_ProcessInstance processInstance = new SEL_ProcessInstance();
            List<ProcessInstance> processInstances = processInstance.selectByTargetObjectIdWithCreatedDate(recordId);
        
            if (processInstances.isEmpty()) {
                return new List<Map<String, Object>>();
            }
        
            Set<Id> processInstanceIds = new Set<Id>();
            for (ProcessInstance pi : processInstances) {
                processInstanceIds.add(pi.Id);
            }
            SEL_ProcessInstanceStep processInstanceStep = new SEL_ProcessInstanceStep();
            List<ProcessInstanceStep> steps = processInstanceStep.selectByProcessInstanceId(processInstanceIds);
            Set<Id> processNodeIds = new Set<Id>();
            for (ProcessInstanceStep step : steps) {
                if (step.stepnodeid != null) {
                    processNodeIds.add(step.stepnodeid);
                }
            }
        
          Map<Id, ProcessNode> nodeMap = new Map<Id, ProcessNode>();
            if (!processNodeIds.isEmpty()) {
                if(!Schema.sObjectType.ProcessNode.isAccessible()) {
                    throw new AuraHandledException('Insufficient permissions to access ProcessNode.');
                }
                nodeMap = new Map<Id, ProcessNode>([
                    SELECT Id, Name, DeveloperName, Description
                    FROM ProcessNode
                    WHERE Id IN :processNodeIds
                ]);
            }
            List<Map<String, Object>> combinedData = new List<Map<String, Object>>();
            for (ProcessInstanceStep step : steps) {
                combinedData.add(buildStepData(step, nodeMap));
            }
            return combinedData;
    
        } catch (Exception e) {
            LOGGER.error('Error in getApprovalHistory: {0}', new Object[]{e.getMessage()});
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static Map<String, Object> buildStepData(ProcessInstanceStep step, Map<Id, ProcessNode> nodeMap) {
        Map<String, Object> stepData = new Map<String, Object>();
        stepData.put('id', step.Id);
        stepData.put('createdDate', step.CreatedDate);
        stepData.put('status', step.StepStatus);
        stepData.put('processStatus', step.ProcessInstance.Status);
        stepData.put('comments', step.Comments);
        stepData.put('assignedTo', step.OriginalActor != null ? step.OriginalActor.Name : '');
        stepData.put('actualApprover', step.Actor != null ? step.Actor.Name : '');
        stepData.put('stepnodeid', step.stepnodeid);
        String stepName = '';
        if (step.stepnodeid != null && nodeMap.containsKey(step.stepnodeid)) {
            ProcessNode node = nodeMap.get(step.stepnodeid);
            stepName = node.Name;
            stepData.put('stepDeveloperName', node.DeveloperName);
            stepData.put('stepDescription', node.Description);
        } else {
            stepName = 'Approval Request Submitted';
        }
        stepData.put('stepName', stepName);
        return stepData;
    }
}