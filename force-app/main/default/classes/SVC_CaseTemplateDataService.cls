/**
 * @description       : Class for obtaining all the information for Template request
 * User Story		  : SFP-31300
 * @author            : Aliaksei Koval
 * @last modified on  : 08-12-2025
 * @last modified by  : Aliaksei Koval
**/
public with sharing class SVC_CaseTemplateDataService {

    private SVC_CaseTemplateDataService() {}
    
    private static final String SVC_API_TEMPLATE  = 'SVC_API_TEMPLATE';
    private static final String FIELDVALUE = 'field';
    private static final String RECORDVALUE = 'record';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CaseTemplateDataService');
    
    /**
    * @description constructing template request body
    * @param caseId 
    * @param reason 
    * @return SVC_DTO_TemplateServiceRestRequest 
    **/
    public static SVC_DTO_TemplateServiceRestRequest prepareTemplateRequestBody(String caseId, String reason) {
        Case cs;
        try{
            cs = SVC_DAL_Case.findById(caseId);
        } catch(Exception ex){
            LOGGER.error('Error retrieving case', new String[] {'SVC_CaseTemplateDataService', 'prepareTemplateRequestBody'}, ex);
        }
        String accName = 'Customer';
        Account caseAccount = new Account();
        String customerBPID = '';
        if(cs.AccountId != null){
            caseAccount = CMN_DAL_Account.findById(cs.AccountId);
            accName = toTitleCase(caseAccount.Name);
            customerBPID = caseAccount.CMN_CustomerBPID__pc;
        }
        
        User caseOwner;
        try{
            caseOwner = CMN_DAL_User.findByUserId(cs.OwnerId);
        } catch(Exception ex){
            LOGGER.error('Error retrieving User', new String[] {'SVC_CaseTemplateDataService', 'prepareTemplateRequestBody'}, ex);
        }
        User caseOwnerManager;
        if (caseOwner.ManagerId == null) {
            caseOwnerManager = caseOwner;
        } else {
            caseOwnerManager = CMN_DAL_User.findByUserId(caseOwner.ManagerId);
        }
        
        CMN_WebserviceSetting__mdt webServiceSetting;
        try{
            webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(SVC_API_TEMPLATE);
        } catch(Exception ex){
            LOGGER.error('Error retrieving WebserviceSettings', new String[] {'SVC_CaseTemplateDataService', 'prepareTemplateRequestBody'}, ex);
        }

        SVC_DTO_TemplateServiceRestRequest request = new SVC_DTO_TemplateServiceRestRequest();
        
        SVC_DTO_TemplateServiceRestRequest.Template template = new SVC_DTO_TemplateServiceRestRequest.Template();
        template.channelId = webServiceSetting.SVC_ChannelId__c;
        template.templateDefId = webServiceSetting.SVC_TemplateId__c;
        request.template = new List<SVC_DTO_TemplateServiceRestRequest.Template>{template};
        
        request.merge_fields = new List<SVC_DTO_TemplateServiceRestRequest.Merge_fields>{
            createMergeFields(cs.CaseNumber, accName, cs.Description, reason, 
                           Datetime.now().format('yyyy-MM-dd'), caseOwnerManager, webServiceSetting.SVC_ChannelId__c)
        };
        
        request.output_mime_type = 'pdf';
        request.is_store_after_generate = true;
        request.is_include_output_file = true;
        
        SVC_DTO_TemplateServiceRestRequest.Document_properties docProps = new SVC_DTO_TemplateServiceRestRequest.Document_properties();
        SVC_DTO_TemplateServiceRestRequest.CustomerProperty custProps = new SVC_DTO_TemplateServiceRestRequest.CustomerProperty();
        custProps.bpid = customerBPID;
        custProps.identityNumber = customerBPID;
        custProps.surNameOrCompanyName = accName;
        docProps.customerProperty = custProps;
        request.document_properties = docProps;
        
        request.channel_id = webServiceSetting.SVC_ChannelId__c;
        
        return request;
    }
    
    /**
    * @description helper method to create mergeFields
    * @param caseNumber 
    * @param accName 
    * @param complaintDesc 
    * @param reason 
    * @param dateToday 
    * @param manager 
    * @param templateId 
    * @return SVC_DTO_TemplateServiceRestRequest.Merge_fields 
    **/
    private static SVC_DTO_TemplateServiceRestRequest.Merge_fields createMergeFields(
    String caseNumber, String accName, String complaintDesc, String reason, 
    String dateToday, User manager, String templateId
    ) {
        SVC_DTO_TemplateServiceRestRequest.Merge_fields mergeField = new SVC_DTO_TemplateServiceRestRequest.Merge_fields();
        mergeField.key = 'CONTR';
        mergeField.type = 'file';
        
        SVC_DTO_TemplateServiceRestRequest.Fields contractRecord = new SVC_DTO_TemplateServiceRestRequest.Fields();
        contractRecord.key = 'Contract record';
        contractRecord.type = RECORDVALUE;
        
        List<SVC_DTO_TemplateServiceRestRequest.Fields> contractFields = new List<SVC_DTO_TemplateServiceRestRequest.Fields>();
        
        contractFields.add(createField('TEMPLATE_ID', FIELDVALUE, templateId));
        
        SVC_DTO_TemplateServiceRestRequest.Fields customerData = new SVC_DTO_TemplateServiceRestRequest.Fields();
        customerData.key = 'CUSTOMER_DATA';
        customerData.type = RECORDVALUE;
        customerData.fields = new List<SVC_DTO_TemplateServiceRestRequest.Fields>{
            createField('ADDRESS', RECORDVALUE, 'ADDRESS')
        };
        contractFields.add(customerData);

        SVC_DTO_TemplateServiceRestRequest.Fields commData = new SVC_DTO_TemplateServiceRestRequest.Fields();
        commData.key = 'COMM_DATA';
        commData.type = RECORDVALUE;
        commData.fields = new List<SVC_DTO_TemplateServiceRestRequest.Fields>{
            createField('DATE', FIELDVALUE, dateToday)
        };
        contractFields.add(commData);

        SVC_DTO_TemplateServiceRestRequest.Fields complaint = new SVC_DTO_TemplateServiceRestRequest.Fields();
        complaint.key = 'COMPLAINT';
        complaint.type = RECORDVALUE;
        complaint.fields = new List<SVC_DTO_TemplateServiceRestRequest.Fields>{
            createField('COMPLAINT_REF', FIELDVALUE, caseNumber),
            createField('DATE', FIELDVALUE, dateToday),
            createField('DEAR', FIELDVALUE, accName),
            createField('COMPLAINT', FIELDVALUE, complaintDesc),
            createField('REASON_FOR_DECISSION1', FIELDVALUE, reason),
            createField('ESCALATE_TO_NAME', FIELDVALUE, 'Escalation Team'),
            createField('MANAGER', FIELDVALUE, manager.Name),
            createField('DEPARTMENT', FIELDVALUE, manager.Title),
            createField('MOBILE', FIELDVALUE, manager.Phone)
        };
        contractFields.add(complaint);
        
        contractRecord.fields = contractFields;
        mergeField.fields = new List<SVC_DTO_TemplateServiceRestRequest.Fields>{contractRecord};
        
        return mergeField;
    }

    /**
    * @description helper method to create fields
    * @param key 
    * @param type 
    * @param value 
    * @return SVC_DTO_TemplateServiceRestRequest.Fields 
    **/
    private static SVC_DTO_TemplateServiceRestRequest.Fields createField(String key, String type, String value) {
        SVC_DTO_TemplateServiceRestRequest.Fields field = new SVC_DTO_TemplateServiceRestRequest.Fields();
        field.key = key;
        field.type = type;
        field.value = value;
        return field;
    }

        /**
    * @description helper method parse Account Name
    * @param input 
    * @return String 
    **/
    public static String toTitleCase(String input) {
        if(String.isBlank(input)){
            return input;
        } 
        
        input = input.toLowerCase();
        List<String> pieces = new List<String>();
        for(String s : input.split(' ')){
            pieces.add(s.capitalize());
        }
        return String.join(pieces, ' ');
    }
}