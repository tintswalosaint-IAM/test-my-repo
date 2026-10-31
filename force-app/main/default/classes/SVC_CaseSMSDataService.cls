/**
 * @description       : Class for obtaining all the information for SMS request
 * @User Story        : SFP-35988
 * @author            : Aliaksei Koval
 * @last modified on  : 06-26-2025
 * @last modified by  : Aliaksei Koval
**/
public inherited sharing class SVC_CaseSMSDataService {
    @testVisible
    private SVC_CaseSMSDataService(){}

    public static final String PROVIDER_ID = 'CMS_SMS';
    public static final String DEFAULT_QUICKTEXT = 'SMS Case Default';
    public static final String SVC_API_MESSAGE_PROD = 'SVC_API_MESSAGE_PROD';

    public static final Map<String, String> STATUS_TO_QUICKTEXT = new Map<String, String>{
        'In Progress' => 'SMS Complaints Case Acknowledgement',
        'Resolved' => 'SMS Complaints Case Resolved',
        'Breached' => 'SMS Complaints Case Breached'
    };

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CaseSMSDataService');

    /**
     * @description Prepares SMS message data for a case
     * @param caseId ID of the case
     * @return SVC_DTO_SMSRestRequest
     */
    public static SVC_DTO_SMSRestRequest prepareSMSRequest(String caseId) {
        CMN_WebserviceSetting__mdt webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(SVC_API_MESSAGE_PROD);

        Case cs = SVC_DAL_Case.findById(caseId);
        if(cs == null){
            LOGGER.error('Error retrieving Case.', new String[] {'Class: SVC_CaseSMSDataService', 'Method: prepareSMSRequest'});
            return null;
        }

        Account acc = CMN_DAL_Account.findById(cs.AccountId);
        if(acc == null){
            LOGGER.error('Error retrieving Account.', new String[] {'Class: SVC_CaseSMSDataService', 'Method: prepareSMSRequest'});
            return null;
        }

        String status = cs.Status;
        if(status == 'In Progress' && cs.IsEscalated == true){
            status = 'Breached';
        }

        String caseNumber = cs.CaseNumber;
        String sla = cs.Entitlement.Name;
        String createdDate = (cs.CreatedDate).format('yyyy-MM-dd');
        String accName = 'Customer';
        if(acc?.Name != null){
            accName = acc.Name;
        }
        String phoneNum = acc?.PersonMobilePhone;
        String customerBPID = acc?.CMN_CustomerBPID__pc;
        if(phoneNum == null){
            return null;
        }
        String validPhoneNumber = '27' + phoneNum.substring(1);

        //Get Quick text based on case status
        String quickTextName = STATUS_TO_QUICKTEXT.get(status);
        if (quickTextName == null) {
            quickTextName = DEFAULT_QUICKTEXT;
        }

        String messageBody = getMessageBodyFromQuickText(quickTextName,
            new Map<String, String>{
                'caseNumber' => caseNumber,
                'sla' => sla,
                'status' => status,
                'dateLogged' => createdDate
            });

        SVC_DTO_SMSRestRequest request = new SVC_DTO_SMSRestRequest();
        request.externalReference = customerBPID;
        request.consumerId = webServiceSetting.SVC_ChannelId__c;

        SVC_DTO_SMSRestRequest.Message message = new SVC_DTO_SMSRestRequest.Message();
        message.messageBody = messageBody;
        message.externalReferenceId = customerBPID;

        SVC_DTO_SMSRestRequest.Recipient recipient = new SVC_DTO_SMSRestRequest.Recipient();
        recipient.phoneNumbers = new List<String>{validPhoneNumber};
        recipient.recipientName = accName;

        message.recipients = new List<SVC_DTO_SMSRestRequest.Recipient>{recipient};

        SVC_DTO_SMSRestRequest.MessagingProvider provider = new SVC_DTO_SMSRestRequest.MessagingProvider();
        provider.providerId = PROVIDER_ID;

        message.messagingProvider = provider;
        request.messages = new List<SVC_DTO_SMSRestRequest.Message>{message};

        return request;
    }

    /**
     * @description Retrieves and formats a QuickText message
     * @param quickTextName Name of the QuickText record
     * @param replacements Map of placeholder replacements
     * @return String
     */
    private static String getMessageBodyFromQuickText(String quickTextName, Map<String, String> replacements) {
        try {
            QuickText qt = [SELECT Message FROM QuickText WHERE Name = :quickTextName WITH SECURITY_ENFORCED  LIMIT 1];
            if (qt != null) {
                String message = qt.Message;
                for (String key : replacements.keySet()) {
                    message = message.replace('{' + key + '}', replacements.get(key));
                }
                return message;
            }
        } catch (Exception e) {
            LOGGER.error('Error retrieving QuickText: ' + e.getMessage(), new String[] {'Class: SVC_CaseSMSDataService', 'Method: getMessageBodyFromQuickText'});
        }
        return null;
    }
}