/**
*   @description    SFP-36638 - Rest Api class for integration with WorkFusion for ServiceFullfillment records get and post action
*  @author Adam Redlinski
*  @date   2023/06/12
*  @last modified by Karabo Machubeni - Fix the fields referenced for Salutation/Title and Debit Account Number
                                      - SFP-38675 - Added the case number and risk rating on the payload, the client to be debited is also changed to look up accounts to appear on the Proof of Payment.
                                      - SFP-38890 - Remove the case number and risk rating on payload sent to the BOT. These fields are unrecognized by the Bot and causing it to fail.
                                      - SFP-44864 - Added the case number, risk rating, and parent service fulfillment fields to the wrapper class. Reference the SEL_ProcessInstanceNode and SEL_ServiceFulfillment selector classes for queries.
*  @last modified date 2024/05/30
*  @last modified by Vikash Beersye - [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
*  @last modified date 2026/03/20
*  @last modified by Vikash Beersye - SFP-58345 : HOTFIX - Salesforce VT
*  @last modified date 2026/05/15
*/

@RestResource(UrlMapping='/v1/ServiceFulfillment/*')
global with sharing class WI_API_ServiceFullfillment {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(WI_API_ServiceFullfillment.class.getName());
    
    static final private Schema.DescribeFieldResult STATUS_SCHEMA_DESCRIBE = ServiceFulfillment__c.Status__c.getDescribe();
    static final private String FIRST_APPROVAL_STEP_NAME = 'W&I CSC Team approve step';
    static final private String SECOND_APPROVAL_STEP_NAME = 'W&I Manager Approve';
    static final private String VVIP_FIRST_APPROVAL_STEP_NAME = 'W&I VVIP Transfer Approval';
    static final private String VVIP_SECOND_APPROVAL_STEP_NAME = 'W&I VVIP Transfer Approval Over 10mil';
    
    /**
    * @description SFP-23329 - Get REST method returns all ServiceFulfillment__c records with status provided as parameter
    * @param status - string with the status of Service Fulfillment to be searched for
    */
    @HttpGet
    global static void getRecordsByStatus() {
        String status = RestContext.request.params.get('status');
        String body;
        
        try{
            
            if (String.isBlank(status) || !checkStatus(status)) {
                body = 'Provided status ' + status + ' doesn\'t exist';
                RestContext.response.statusCode = CMN_API_HttpBase.HTTP_BAD_REQUEST;
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(body);
                return;
            }
            List<ServiceFulfillment__c> records = getServiceFulfillmentsByStatus(status);
            Map<Id, Id> approvalInstanceIdByRecordId = getApprovalInstanceIdByRecordId(records);
            List<ProcessInstanceNode> instanceNodes = getInstanceNodes(approvalInstanceIdByRecordId);
            Map<Id, List<ProcessInstanceNode>> nodeListByProcessInstanceId = getNodeListByProcessInstanceId(instanceNodes);
            List<WrapperItem> items = createWrapperItems(records, approvalInstanceIdByRecordId, nodeListByProcessInstanceId);
            ResponseWrapper responseWrapper = new ResponseWrapper(items);
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(responseWrapper));
            RestContext.response.statusCode = CMN_API_HttpBase.HTTP_OK;
        }catch(JSONException ex){
            LOGGER.error('getRecordsByStatus: Unhandled exception', ex);
            RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(ex.getMessage()));
            RestContext.response.statusCode = CMN_API_HttpBase.HTTP_BAD_REQUEST;
        }
    }
    
    /**
    * @description SFP-23329 - Get map of ProcessInstanceHistory id by  ServiceFulfillment__c id
    * @param List<ServiceFulfillment__c> records - list of ServiceFulfillment__c records
    * @return Map<Id, Id> approvalInstanceIdByRecordId
    */
    @TestVisible
    private static Map<Id, Id> getApprovalInstanceIdByRecordId(List<ServiceFulfillment__c> records) {
        Map<Id, Id> approvalInstanceIdByRecordId = new Map<Id, Id>();
        for (ServiceFulfillment__c single : records) {
            if (!single.ProcessSteps.isEmpty()) {
                approvalInstanceIdByRecordId.put(single.Id, single.ProcessSteps[0].ProcessInstanceId);
            }
        }
        return approvalInstanceIdByRecordId;
    }
    
    /**
    * @description SFP-23329 - Create Wrapper items from data passed in params
    * @param List<ServiceFulfillment__c> records,
    * @param Map<Id, Id> approvalInstanceIdByRecordId,
    * @param Map<Id, List<ProcessInstanceNode>> nodeListByProcessInstanceId
    * @return List<WrapperItem> wrapper items
    */
    private static List<WrapperItem> createWrapperItems(List<ServiceFulfillment__c> records, Map<Id, Id> approvalInstanceIdByRecordId, Map<Id, List<ProcessInstanceNode>> nodeListByProcessInstanceId) {
        List<WrapperItem> items = new List<WI_API_ServiceFullfillment.WrapperItem>();
        
        for (ServiceFulfillment__c sfRecord : records) {
            
            Id processInstanceId = approvalInstanceIdByRecordId.get(sfRecord.Id);
            List<ProcessInstanceNode> nodes = nodeListByProcessInstanceId.get(processInstanceId);
            ApprovalData approvalData = getApprovalData(nodes);
            WrapperItem item = new WrapperItem();
            item.id = sfRecord.Id;
            item.status = sfRecord.Status__c;
            item.debitAccount = sfRecord.Debit_Account_Number__c;
            item.amount = sfRecord.Amount__c;
            item.narrativeDebitAccount = sfRecord.NarrativeDebitAccount__c;
            item.beneficiaryAccountName = sfRecord.BeneficiaryAccountName__c;
            item.beneficiaryAccountBank = sfRecord.BeneficiaryAccountBank__c;
            item.beneficiaryAccountNumber = sfRecord.BeneficiaryAccountNumber__c;
            item.narrativeCreditAccount = sfRecord.NarrativeCreditAccount__c;
            item.retro = sfRecord.Case__r.WI_Retro__c;
            item.debitName = sfRecord.Account__r.Name;
            item.serviceFulfilmentCreator = sfRecord.CreatedBy.Name;
            item.firstApprover = approvalData.firstApprover;
            item.dateOfApproval = approvalData.approvedDate;
            item.secondApprover = approvalData.secondApprover;
            item.title = getSalutationLabel(sfRecord.Account__r.Salutation);
            item.parentId = sfRecord.WI_Parent_Service_Fulfillment__c;
            item.riskRating = sfRecord.Risk_Rating__c;
            item.caseNumber = sfRecord.Case__r.CaseNumber;
            item.caseOwnerEmailAddress = sfRecord.Case__r.Owner.Email;

            items.add(item);
        }
        return items;
    }
    /**
    * @description Extract approval information such as approved date, first approver, and second approver from ProcessInstanceNodes
    * @param List<ProcessInstanceNode> nodes List of approval process nodes
    * @return ApprovalData Object containing approval details
    */
    private static ApprovalData getApprovalData(List<ProcessInstanceNode> nodes) {
        ApprovalData data = new ApprovalData();

        if (nodes == null) {
            return data;
        }

        for (ProcessInstanceNode node : nodes) {

            if (data.approvedDate == null || data.approvedDate < node.CompletedDate) {
                data.approvedDate = node.CompletedDate;
            }

            if (isFirstApprover(node.ProcessNodeName)) {
                data.firstApprover = node.LastActor.Name;
            }

            if (isSecondApprover(node.ProcessNodeName)) {
                data.secondApprover = node.LastActor.Name;
            }
        }

        return data;
    }
    /**
     * @description Translates a Salutation picklist API value into its corresponding readable Label.
     * This is used to ensure the integration payload contains "BISHOP" instead of "139".
     * @param salutationValue The raw API value/code from the Account Salutation field.
     * @return String The human-readable label (e.g., 'Mr.', 'Dr.'), or null if not found.
     */
    private static String getSalutationLabel(String salutationValue){
        
        Map<String, String> salutationMap = new Map<String, String>();
        String title;
        
        Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> salutationPicklist = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry picklist : salutationPicklist) {
            salutationMap.put(picklist.getValue(), picklist.getLabel());
        }
        
        if (salutationMap.containsKey(salutationValue)) {
            title = salutationMap.get(salutationValue);
        } else {
            title = salutationValue; 
        }
        
        return title;
    }
    
    /**
    * @description Check if the node name corresponds to the first approval step
    * @param String nodeName Name of the approval process node
    * @return Boolean True if node represents first approval step
    */
    private static Boolean isFirstApprover(String nodeName) {
        return nodeName == FIRST_APPROVAL_STEP_NAME || nodeName == VVIP_FIRST_APPROVAL_STEP_NAME;
    }
    /**
    * @description Check if the node name corresponds to the second approval step
    * @param String nodeName Name of the approval process node
    * @return Boolean True if node represents second approval step
    */
    private static Boolean isSecondApprover(String nodeName) {
        return nodeName == SECOND_APPROVAL_STEP_NAME || nodeName == VVIP_SECOND_APPROVAL_STEP_NAME;
    }
    /**
    * @description Helper class to store approval details extracted from approval process nodes
    */
    private class ApprovalData {
        public Datetime approvedDate;
        public String firstApprover;
        public String secondApprover;
    }
    
    /**
    * @description SFP-23329 - Get map of Nodes for every related ProcessInstance
    * @param List<ProcessInstanceNode> instanceNodes
    * @return Map<Id, List<ProcessInstanceNode>> nodeListByProcessInstanceId
    */
    private static Map<Id, List<ProcessInstanceNode>> getNodeListByProcessInstanceId(List<ProcessInstanceNode> instanceNodes) {
        Map<Id, List<ProcessInstanceNode>> nodeListByProcessInstanceId = new Map<Id, List<ProcessInstanceNode>>();
        for (ProcessInstanceNode node : instanceNodes) {
            if (node.ProcessNodeName.equals(FIRST_APPROVAL_STEP_NAME) || node.ProcessNodeName.equals(SECOND_APPROVAL_STEP_NAME) || node.ProcessNodeName.equals(VVIP_FIRST_APPROVAL_STEP_NAME) || node.ProcessNodeName.equals(VVIP_SECOND_APPROVAL_STEP_NAME)) {
                List<ProcessInstanceNode> nodeList = nodeListByProcessInstanceId.get(node.ProcessInstanceId);
                if (nodeList != null) {
                    nodelist.add(node);
                } else {
                    nodeListByProcessInstanceId.put(node.ProcessInstanceId, new List<ProcessInstanceNode>{
                        node
                    });
                }
            }
        }
        return nodeListByProcessInstanceId;
    }
    
    /**
    * @description SFP-23329 - Retrieves list of InstanceNodes
    * @param Map<Id, Id> approvalInstanceIdByRecordId
    * @return List<ProcessInstanceNode> instanceNodes
    */
    @TestVisible
    private static List<ProcessInstanceNode> getInstanceNodes(Map<Id, Id> approvalInstanceIdByRecordId) {
       return new SEL_ProcessInstanceNode().getInstanceNodesByInstanceIds(new Set<Id>(approvalInstanceIdByRecordId.values()));
    }
    
    /**
    * @description SFP-23329 - Retrieves list of WI_ServiceFulfillment__c by provided status
    * @param String status
    * @return List<ServiceFulfillment__c> records
    */
    private static List<ServiceFulfillment__c> getServiceFulfillmentsByStatus(String status) {
            return new SEL_ServiceFulfillment().getServiceFulfillmentsWithProcessInstanceByStatus(status);
    }
    
    /**
    * @description SFP-23329 - Checks if provided status exists
    * @param String status
    * @return Boolean provided status result
    */
    private static Boolean checkStatus(String status) {
        List<Schema.PicklistEntry> picklistEntries = STATUS_SCHEMA_DESCRIBE.getPicklistValues();
        for (Schema.PicklistEntry singleEntry : picklistEntries) {
            if (singleEntry.getLabel() == status) {
                return true;
            }
        }
        return false;
    }
    
    /**
    * @description SFP-23329 - Post method, updates WI_ServiceFulfillment__c records with id passed in the request with statuses passed in the request. Returns Response wrapper which contains updated record ids and status of update Successful or failure
    */
    @HttpPost
    global static void updateRecords() {

        RestContext.response.addHeader('Content-Type', 'application/json');

        try {

            RequestWrapper wrapper = validateAndParseRequest();

            List<ServiceFulfillment__c> fulfillmentsList = wrapper.getRecords();

            List<Id> lockedSf = getLockedRecords(fulfillmentsList);

            CMN_RecordUnlocker.unlockRecords(lockedSf);
            if (!Schema.sObjectType.ServiceFulfillment__c.isUpdateable()) {
                throw new JSONException('Insufficient permissions to update ServiceFulfillment');
            }
            List<Database.SaveResult> resultList = Database.update(fulfillmentsList, false);

            List<WrapperItem> itemsList = buildResponseItems(fulfillmentsList, resultList);

            Approval.lock(lockedSf);

            RestContext.response.responseBody =
                Blob.valueOf(JSON.serializePretty(new ResponseWrapper(itemsList)));

            RestContext.response.statusCode = CMN_API_HttpBase.HTTP_OK;

        } catch (JSONException ex) {

            RestContext.response.responseBody =
                Blob.valueOf(JSON.serializePretty(ex.getMessage()));

            RestContext.response.statusCode = CMN_API_HttpBase.HTTP_BAD_REQUEST;
        }
    }
    /**
    * @description Validate REST request body and deserialize into RequestWrapper
    * @return RequestWrapper Parsed request wrapper containing records
    */
    private static RequestWrapper validateAndParseRequest() {

        String requestBody = RestContext.request.requestBody.toString();

        if (String.isBlank(requestBody)) {
            throw new JSONException('For POST request records have to be provided');
        }

        RequestWrapper wrapper =
            (RequestWrapper) JSON.deserialize(requestBody, RequestWrapper.class);

        if (wrapper?.records?.isEmpty() != false) {
            throw new JSONException('For POST request records have to be provided');
        }

        return wrapper;
    }
    /**
    * @description Identify locked Service Fulfillment records
    * @param List<ServiceFulfillment__c> fulfillmentsList List of SF records
    * @return List<Id> Locked record Ids
    */
    private static List<Id> getLockedRecords(List<ServiceFulfillment__c> fulfillmentsList) {

        List<Id> sfIds = new List<Id>();

        for (ServiceFulfillment__c sf : fulfillmentsList) {
            sfIds.add(sf.Id);
        }

        Map<Id, Boolean> lockMap = Approval.isLocked(sfIds);

        List<Id> lockedSf = new List<Id>();

        for (Id sfId : lockMap.keySet()) {
            if (lockMap.get(sfId)) {
                lockedSf.add(sfId);
            }
        }

        return lockedSf;
    }
    /**
    * @description Build response wrapper items from update results
    * @param List<ServiceFulfillment__c> fulfillmentsList List of SF records
    * @param List<Database.SaveResult> resultList SaveResult list from database update
    * @return List<WrapperItem> Response items
    */
    private static List<WrapperItem> buildResponseItems(
        List<ServiceFulfillment__c> fulfillmentsList,
        List<Database.SaveResult> resultList) {

        List<WrapperItem> itemsList = new List<WrapperItem>();
        Integer index = 0;

        for (ServiceFulfillment__c singleSF : fulfillmentsList) {

            String status = 'Successful update on SF';
            String errorMessage = '';

            Database.SaveResult singleResult = resultList[index];

            if (!singleResult.isSuccess()) {

                status = 'Failed update on SF';

                for (Database.Error er : singleResult.errors) {
                    errorMessage += er.getMessage();
                }
            }

            itemsList.add(new WrapperItem(singleSF.Id, status, errorMessage));

            index++;
        }

        return itemsList;
    }
    /**
    * @description SFP-23329 - Wrapper class to map data passed in the Post request
    */
    @TestVisible
    private class RequestWrapper {
        public List<WrapperItem> records;
        List<ServiceFulfillment__c> getRecords() {
            List<ServiceFulfillment__c> sfList = new List<ServiceFulfillment__c>();
            for (WrapperItem item : this.records) {
                sfList.add(new ServiceFulfillment__c(Id = item.id, Status__c = item.status));
            }
            return sfList;
        }
    }
    
    /**
    * @description SFP-23329 - Wrapper class to map data passed as a response
    */
    @TestVisible
    private class ResponseWrapper {
        public List<WrapperItem> records;
        
        ResponseWrapper(List<WrapperItem> items) {
            this.records = items;
        }
    }
    
    /**
    * @description SFP-23329 - Wrapper class to map each item with proper data, used in the Response and Request wrappers
    */
    @TestVisible
    private class WrapperItem {
        public Id id;
        public String status;
        public String debitAccount;
        public Decimal amount;
        public String narrativeDebitAccount;
        public String beneficiaryAccountName;
        public String beneficiaryAccountBank;
        public String beneficiaryAccountNumber;
        public String narrativeCreditAccount;
        public String retro;
        public String debitName;
        public String serviceFulfilmentCreator;
        public String firstApprover;
        public Datetime dateOfApproval;
        public String secondApprover;
        public String title;
        public String errorMessage;
        public String parentId;
        public String riskRating;
        public String caseNumber;
        public String caseOwnerEmailAddress;
        
        public WrapperItem(Id id, String status, String message) {
            this.id = id;
            this.status = status;
            this.errorMessage = message;
        }
        
        
        public WrapperItem(Id id, String status) {
            this.id = id;
            this.status = status;
        }
        
        /*
         * @description Default no-argument constructor. 
         * Required for JSON deserialization in RequestWrapper and manual instantiation 
         * in createWrapperItems, as multiple parameterized constructors are defined.
         */
        public WrapperItem() {}
        
    }
}