/**
 * @description : This class facilitates customer verification through external APIs.
 * @author : Shams Ul Arifeen
 * @date : October 2023
 */
public class INS_Customer_Verification {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Customer_Verification');

    // Constant for HTTP Headers
    private static final String X_FAPI_INTERACTION_ID_VALUE = System.Label.INS_x_fapi_interaction_id;

    /**
     * @description : Invocable method to verify for the provided applicants.
     * @author : Shams Ul Arifeen
     * @param  requestDetails
     * @return : List<CustomerVerificationResponse >
     **/
    @InvocableMethod(Label = 'Verify Customer' Description = 'Provide Insurance Policy Applicants to be verified' Category = 'Person Account')
    public static List<CustomerVerificationResponse> verifyCustomer(List<RequestWrapper> requestDetails) {
        // Get access token
        String accessToken = '';
        try {
            accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeCustomer);
        } catch (Exception ex) {
            LOGGER.error('INS_Customer_Verification.verifyCustomer - Error getting access token', ex);
            throw new AOB_CustomException('Error getting access token: ' + ex.getMessage());
        }
        Boolean accountFound = false;
        CustomerVerificationResponse verificationResponse = new CustomerVerificationResponse();
        String personFirstName = '';
        String personLastName = '';
        Date personDateOfBirth;
        String accountNumber = '';
        String accountId = '';

        // Prepare request parameters
        InsurancePolicyParticipant applicant = requestDetails[0].applicantDetails;
        Datetime dateOfBirth = applicant.BirthDate__c;
        String firstName = EncodingUtil.urlEncode(applicant.FirstName__c.toUpperCase().trim(), 'UTF-8');
        String lastName = EncodingUtil.urlEncode(applicant.LastName__c.toUpperCase().trim(), 'UTF-8');
        String dob = dateOfBirth.format('yyyy-MM-dd');
        String clientCertificate1 = '{!$Credential.INS_Customer_Verification_Credentials.XClientCertificate1}';
        String clientCertificate2 = '{!$Credential.INS_Customer_Verification_Credentials.XClientCertificate2}';
        String clientCertificate3 = '{!$Credential.INS_Customer_Verification_Credentials.XClientCertificate3}';
        String clientCertificate4 = '{!$Credential.INS_Customer_Verification_Credentials.XClientCertificate4}';
        String clientCertificate5 = '{!$Credential.INS_Customer_Verification_Credentials.XClientCertificate5}';

        // Create HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:INS_Customer_Verification' + '?firstName=' + firstName + '&lastName=' + lastName + '&dob=' + dob);
        request.setMethod(INS_Quote_Helper.HTTP_METHOD_GET);
        request.setHeader(INS_Quote_Helper.HEADER_AUTHORIZATION, INS_Quote_Helper.AUTHORIZATION_TYPE_BEARER + accessToken);
        request.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setTimeout(60000);
        request.setHeader(
            INS_Quote_Helper.X_CLIENT_CERTIFICATE,
            clientCertificate1 + '' + clientCertificate2 + '' + clientCertificate3 +
            '' + clientCertificate4 + '' + clientCertificate5
        );
        request.setHeader(INS_Quote_Helper.X_FAPI_INTERACTION_ID, X_FAPI_INTERACTION_ID_VALUE);

        Http http = new Http();

        //try{
            // Send HTTP request
            HttpResponse response = http.send(request);
            // Handle response based on status code
            if (response.getStatusCode() == 200) {
                // Parse the JSON response
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<object> customers = (List<object>) jsonResponse.get('customers');
                if(customers.size()> 0){
                    // expecting only 1 customer in customers
                    for (Object customer: customers){
                        Map<String, Object> customerMap = (Map<String, Object>) customer;
                        if (!customerMap.isEmpty() && customerMap.get('accountNumber') != null){
                            accountNumber = (String) customerMap.get('accountNumber');
                        }
                        Object personalDetails = (Object) customerMap.get('personDetails');
                        if (personalDetails != null){
                            Map<String, object> personDetailsMap = (Map<String, object>) personalDetails;
                            if (!personDetailsMap.isEmpty()) {
                                personFirstName = (String) personDetailsMap.get('firstName');
                                personLastName = (String) personDetailsMap.get('lastName');
                                String dateOfBirthResponse = (String) personDetailsMap.get('dob');
                                personDateOfBirth = Date.valueOf(dateOfBirthResponse);
                                // one query only as expected number of customers is one
                                List<Account> thisAccount = new INS_Get_Account().selectAccountByName(
                                    applicant.FirstName__c.toUpperCase().trim(),
                                    applicant.LastName__c.toUpperCase().trim(),
                                    personDateOfBirth,
                                    applicant.IdentityNumber__c,
                                    requestDetails[0].customerType,
                                    requestDetails[0].userCountry
                                );
                                accountId = thisAccount[0].Id;
                            }
                            accountFound = true;
                            break;
                        }
                    }
                }
            }
            else {
                throw new INS_CustomException('Error: ' + 'StatusCode: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        //} catch (Exception ex) {
        //    LOGGER.error('INS_Customer_Verification.verifyCustomer', ex);
        //    throw new INS_CustomException(ex.getMessage());
       // }
        verificationResponse.accountFound = accountFound;
        verificationResponse.accountId = accountId;
        verificationResponse.firstname = personFirstName;
        verificationResponse.lastName = personLastName;
        verificationResponse.accountNumber = accountNumber;
        verificationResponse.dateOfBirth = personDateOfBirth;
        return new List<CustomerVerificationResponse>{verificationResponse};
    }

    /**
     * @description : Wrapper Class to pass in the verifyCustomer.
     * @author : Shams Ul Arifeen
     **/
    public class RequestWrapper {
        @InvocableVariable(label='ApplicantDetails' description='ApplicantDetails' required=true)
        public InsurancePolicyParticipant applicantDetails;
        @InvocableVariable(label = 'Customer Type' description='Customer Type')
        public String customerType;
        @InvocableVariable(label='User Country' description='User Country' required=true)
        public String userCountry;
    }

    /**
     * @description : Wrapper Class for Customer Verification Response to pass back to flow.
     * @author : Shams Ul Arifeen
     **/
    public class CustomerVerificationResponse {

        @InvocableVariable(label = 'Account Found')
        public Boolean accountFound;
        @InvocableVariable(label = 'Account Id')
        public String accountId;
        @InvocableVariable(label = 'First Name')
        public String firstname;
        @InvocableVariable(label = 'Last Name')
        public String lastName;
        @InvocableVariable(label = 'Date of Birth')
        public Date dateOfBirth;
        @InvocableVariable(label = 'Account Number')
        public String accountNumber;
    }
}