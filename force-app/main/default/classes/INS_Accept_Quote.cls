/**
 * @description  Sends a POST request to the INS_Accept_Quote API endpoint with the provided Request.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param Request containing applicant details.
 * @return HttpResponse object containing the response from the API.
 * @date Nov 07th 2023
 */
public class INS_Accept_Quote {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Accept_Quote');
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_COUNTRY = 'x-iam-country';
    private static final String CLIENT_COUNTRY_SA = 'SA';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    /**
 * @description class  BaseException implements Exception class
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
    public virtual class BaseException extends Exception{}
       /**
 * @description class  CustomException implements BaseException class
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
    public class CustomException extends BaseException{}
    /**
     * @description Obtains the Request  for API.
     *
     * @return.
     */
    public class Request {
        @InvocableVariable(label='ApplicantDetails' description='ApplicantDetails' required=true)
        public InsurancePolicyParticipant applicantDetails;
        @InvocableVariable(label='QuoteNumber' description='QuoteNumber' required=true)
        public string quoteNumber;
        @InvocableVariable(label='BranchCode' description='Branch Code' required=true)
        public String branchCode;
        @InvocableVariable(label='BranchName' description='Branch Name' required=true)
        public String branchName;
        @InvocableVariable(label='BankName' description='Bank Name' required=true)
        public String bankName;
        @InvocableVariable(label='AccountNumber' description='Account Number' required=true)
        public String accountNumber;
        @InvocableVariable(label='debitOrderDay' description='debitOrderDay' required=true)
        public String debitOrderDay;
        @InvocableVariable(label='User Country' description='User Country' required=true)
        public String userCountry;
    }
    /**
     * @description Obtains the Response  from API Response.
     *
     * @return Boolean representing the Response class.
     */
    public class Response{
        @InvocableVariable
        public Boolean isSuccess;
    }
    
    /**
     * @description Invocable method to createQuote  for the provided requestDetails.
     *
     * @param requestDetails
     * @return List<Response>.
     */
    
    @InvocableMethod( Label = 'Accept Quote' Description = 'Accept quote for the applicant' )
    public static List<Response> createQuote(List<Request> requestDetails){
        try{
            List<Response> responseList = new List<Response> ();
            Request req = requestDetails[0];
            AcceptQuoteWrapper wrap = new AcceptQuoteWrapper();
            InsurancePolicyParticipant applicant = req.applicantDetails;
            wrap.QuoteNumber = req.quoteNumber;
            wrap.CoverEffectiveDate = String.valueOf(system.now());
            wrap.UnderwriterNotes = '';
            wrap.DebitOrderDate = req.debitOrderDay=='last day of month'?'-1':req.debitOrderDay;
            wrap.premiumTypes = 1;//hardcoded
            wrap.referralOverrideIndicator = true;//hardcoded
            wrap.policyNumber = req.quoteNumber;
            wrap.policyId = req.quoteNumber;
            wrap.prorataPremium = 0;//hardcoded
            AcceptQuoteWrapper.BankingDetails bankDetails = new AcceptQuoteWrapper.BankingDetails();
            User loggedInUser = getUserDetails();
            if (req.userCountry != null && req.userCountry.length() <= 3) {
                bankDetails.idCountryOfIssue = getPicklistValueLabelMap('Account','WI_PassportIssuingCountry__pc').get(req.userCountry);
            }else{
                bankDetails.idCountryOfIssue = req.userCountry;
            }
            if(applicant.IdType__c == 'NATIONAL ID')
            {
                bankDetails.identityDocumentType = 'SAIDENTITYDOCUMENT';
            }
        	else
            {
                bankDetails.identityDocumentType =  'PASSPORT';
            }
            bankDetails.title = (applicant.Title__c != null) ? String.valueOf(applicant.Title__c) : '0';
            bankDetails.idNumber = applicant.IdentityNumber__c;
            bankDetails.gender = applicant.Gender__c;
            bankDetails.contactNumber = String.valueOf(applicant.MobilePhone__c);
            bankDetails.dateOfBirth = String.valueOf(applicant.BirthDate__c);
            bankDetails.initials = applicant.Initial__c;
            bankDetails.branchCode = req.branchCode;
            bankDetails.branchName = req.branchName;
            bankDetails.surname = applicant.LastName__c;
            bankDetails.bankName = req.bankName;
            bankDetails.name = applicant.FirstName__c+' '+applicant.LastName__c;
            bankDetails.accountType = 2;
            bankDetails.accountNumber = req.accountNumber;
            bankDetails.debitOrderMandateCheck = true;//hardcoded
            bankDetails.validationResponse = '';
            bankDetails.isValidated = true;
           	bankDetails.validationOverridden = true;
            bankDetails.bankAccountKey = '';
            wrap.bankingDetails = bankDetails;
            
            String payloadJson = JSON.serialize(wrap);
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes/acceptance');
            request.setMethod(HTTP_METHOD_POST);
            request.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            request.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            request.setTimeout(60000);
            request.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
            request.setHeader(HEADER_CLIENT_COUNTRY, CLIENT_COUNTRY_SA);
          
            request.setBody(payloadJson);    
            Http http = new Http();
            // Send HTTP request
            HttpResponse response = http.send(request);
             // Handle response based on status code
            if (response.getStatusCode() == 200) {
                // Handle successful response
                 
                Response responses = new Response();
                responses.isSuccess = true;
                responseList.add(responses);
            } else {
                // Handle error response
                LOGGER.error('INS_Accept_Quote.getAccessToken: No response body', new String[] {'INS_Accept_Quote.getAccessToken', response.getBody()});
                throw new INS_CustomException(response.getBody());
            }
            return  responseList;       
        }
        Catch(Exception ex){
            // Log error response for debugging purposes
            LOGGER.error('INS_Accept_Quote.createQuote', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }
    public static Map<String, String> getPicklistValueLabelMap(String objectName, String fieldName) {
        Map<String, String> picklistMap = new Map<String, String>();
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType == null) {
            return picklistMap;
        }
        
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
       
        if (!fieldMap.containsKey(fieldName)) {
            return picklistMap;
        }
        
        Schema.SObjectField field = fieldMap.get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        
        if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
            
            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistMap.put(entry.getValue(), entry.getLabel());
            }
        } 
        
        return picklistMap;
    }
    @AuraEnabled
    public static User getUserDetails(){
        try {
            return [select Id,User_Country__c, CompanyName from User where id=:userinfo.getuserid()];
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
    }
}