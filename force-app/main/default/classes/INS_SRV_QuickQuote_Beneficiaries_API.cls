/***************************************************************************************
@Name of the Class : INS_SRV_QuickQuote_Beneficiaries_API
@Description       : SFP-51843: Handles add and edit beneficiary API callouts.
                     Builds the beneficiary request payload and calls the external API
                     via INS_SRV_QuickQuote_Beneficiaries service class.
@Author            : Irshad
@Created Date      : 14/04/2026
@Last Modified     : 14/04/2026
***************************************************************************************/
public with sharing class INS_SRV_QuickQuote_Beneficiaries_API {

    /**
     * @description Adds or edits a beneficiary on an existing quote.
     *              isEdit flag in input map determines add vs edit operation.
     *              Builds payload, calls the external API, processes and returns the response.
     * @param quoteId The external quote reference number.
     * @param input   Map containing beneficiary details from the LWC component.
     * @return        Serialised JSON string with hasError, beneficiaries, or error message.
     */
    @AuraEnabled
    public static String addEditBeneficiary(String quoteId, Map<String, Object> input) {
        try {
            // Determine add vs edit from input flag
            Object isEditObj         = input.get('isEdit');
            Boolean isEdit           = isEditObj != null && (Boolean) isEditObj;
            Boolean isAddBeneficiary = !isEdit;

            // Build and log payload
            quoteId='e0c45f25-d31a-4617-9041-b54c84146b2e';
            String payloadJson = buildBeneficiaryPayload(quoteId, input);
            System.debug('Beneficiary payload (' + (isEdit ? 'EDIT' : 'ADD') + '): ' + payloadJson);

            // Make API callout
            INS_SRV_QuickQuote_Beneficiaries service = new INS_SRV_QuickQuote_Beneficiaries(
                payloadJson, quoteId, isAddBeneficiary
            );
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
                INS_SRV_QuickQuote_Beneficiaries.SERVICE_NAME
            );
            service.process(obj);
            insert obj;

            Integer statusCode  = service.getResponseStatusCode();
            String responseBody = service.getResponseBody();
            System.debug('Beneficiary API status: '   + statusCode);
            System.debug('Beneficiary API response: ' + responseBody);

            return processResponse(statusCode, responseBody);

        } catch (Exception ex) {
            System.debug(
                'Beneficiary API exception: ' + ex.getMessage()
                + ' | ' + ex.getStackTraceString()
            );
            throw new AuraHandledException('Beneficiary API failed: ' + ex.getMessage());
        }
    }

    /**
     * @description Builds the serialised JSON request payload for the Beneficiary API.
     *              Maps all LWC input fields into the BeneficiaryRequest wrapper.
     *              Includes allocation (PERCENTAGE type), dateOfBirth, and contact details.
     * @param quoteId The external quote reference number.
     * @param input   Map containing beneficiary details from the LWC component.
     * @return        Serialised JSON string of the complete beneficiary request payload.
     */
    @TestVisible
    private static String buildBeneficiaryPayload(String quoteId, Map<String, Object> input) {

        BeneficiaryRequest request = new BeneficiaryRequest();
        request.referenceNumber    = quoteId;

        Beneficiary ben      = new Beneficiary();
        String firstName = (String) input.get('firstName');
        String surname   = (String) input.get('surname');
        ben.firstName        = firstName;
        ben.surname          = surname;
        ben.relationship     = (String) input.get('relationship');
        ben.identityNumber   = (String) input.get('idNumber');
        ben.identityType     = (String) input.get('identityDocumentType');
        ben.gender           = (String) input.get('gender');
        ben.beneficiaryId    = (String) input.get('beneficiaryId');
        ben.personId         = (String) input.get('personId');
        ben.idCountryOfIssue = (String) input.get('idCountryOfIssue');
        ben.initials   = (String.isNotBlank(firstName) ? firstName.substring(0, 1).toUpperCase() : '')
               + (String.isNotBlank(surname)    ? surname.substring(0, 1).toUpperCase()   : '');
        ben.title            = (String) input.get('title');
        ben.benefitId        = '11.Extended Family Benefit';//hardcoded to test (String) input.get('benefitId');
        ben.allocationType   = 'PERCENTAGE';

        // Parse allocation amount — comes as Integer from LWC
        Object allocationObj = input.get('allocationAmount');
        ben.allocationAmount = allocationObj != null
            ? Integer.valueOf(String.valueOf(allocationObj))
            : 0;

        // Parse dateOfBirth — strip time component if present, then parse
        String dobStr = (String) input.get('dateOfBirth');
        if (String.isNotBlank(dobStr)) {
            String cleanDate = dobStr.contains('T') ? dobStr.substringBefore('T') : dobStr;
            ben.dateOfBirth  = DateTime.newInstance(
                Date.valueOf(cleanDate),
                Time.newInstance(0, 0, 0, 0)
            );
        }

        // Build contacts from email and phone
        ben.contacts = new List<contacts>();

        String email = (String) input.get('emailAddress');
        if (String.isNotBlank(email)) {
            contacts emailContact    = new contacts();
            emailContact.contactType = 'EMAIL';
            emailContact.text        = email;
            ben.contacts.add(emailContact);
        }

        String phone = (String) input.get('phoneNumber');
        if (String.isNotBlank(phone)) {
            contacts phoneContact    = new contacts();
            phoneContact.contactType = 'MOBILE';
            phoneContact.text        = phone;
            ben.contacts.add(phoneContact);
        }

        request.beneficiaries = new List<Beneficiary>{ ben };
        return JSON.serialize(request);
    }

    /**
     * @description Processes the API HTTP response into a standardised LWC-ready JSON result.
     *              Checks ValidationResult.ResultStatus to determine success or failure.
     * @param statusCode   HTTP status code returned from the service callout.
     * @param responseBody Raw JSON response body string returned from the service callout.
     * @return             Serialised JSON string with hasError and beneficiaries or error.
     */
    /**
     * @description Processes the API HTTP response.
     *              The response body mirrors the request body structure —
     *              same shape as BeneficiaryRequest but with beneficiaryId populated
     *              on each beneficiary in the list.
     *              Success is determined by HTTP 200/201 + a non-blank beneficiaryId
     *              on the first beneficiary in the returned list.
     * @param statusCode   HTTP status code returned from the service callout.
     * @param responseBody Raw JSON response body string — same shape as request payload.
     * @return             Serialised JSON string with hasError, beneficiaries list, and referenceNumber.
     */
    private static String processResponse(Integer statusCode, String responseBody) {
        if (statusCode == 200 || statusCode == 201) {
            try {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

                // Response mirrors request — extract beneficiaries list and referenceNumber
                List<Object> beneficiaries = (List<Object>) responseMap.get('beneficiaries');
                String referenceNumber     = (String) responseMap.get('referenceNumber');

                // Validate that at least the first beneficiary has a beneficiaryId populated
                if (beneficiaries != null && !beneficiaries.isEmpty()) {
                    Map<String, Object> firstBen = (Map<String, Object>) beneficiaries[0];
                    String beneficiaryId         = (String) firstBen.get('beneficiaryId');

                    if (String.isNotBlank(beneficiaryId)) {
                        return JSON.serialize(new Map<String, Object>{
                            'hasError'        => false,
                            'beneficiaries'   => beneficiaries,
                            'referenceNumber' => referenceNumber
                        });
                    }

                    // beneficiaryId missing — API returned response without populating it
                    return JSON.serialize(new Map<String, Object>{
                        'hasError' => true,
                        'error'    => 'Beneficiary was not created — beneficiaryId missing in response'
                    });
                }

                // No beneficiaries in response
                return JSON.serialize(new Map<String, Object>{
                    'hasError' => true,
                    'error'    => 'No beneficiaries returned in API response'
                });

            } catch (Exception ex) {
                System.debug('processResponse parse error: ' + ex.getMessage());
                return JSON.serialize(new Map<String, Object>{
                    'hasError' => true,
                    'error'    => 'Failed to parse API response: ' + ex.getMessage()
                });
            }
        }

        return JSON.serialize(new Map<String, Object>{
            'hasError' => true,
            'error'    => 'API error ' + statusCode + ': ' + responseBody
        });
    }

    // ========================================
    // WRAPPER CLASSES
    // ========================================

    public class BeneficiaryRequest {
        public String            referenceNumber;
        public List<Beneficiary> beneficiaries;
    }

    public class Beneficiary {
        public String         title;
        public String         surname;
        public String         relationship;
        public String         personId;
        public String         initials;
        public String         identityType;
        public String         identityNumber;
        public String         idCountryOfIssue;
        public String         gender;
        public String         firstName;
        public Datetime       dateOfBirth;
        public String         benefitId;
        public String         beneficiaryId;
        public String         allocationType;
        public Integer        allocationAmount;
        public List<contacts> contacts;
    }

    public class contacts {
        public String text;
        public String contactType;
    }
}