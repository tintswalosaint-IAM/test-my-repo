/***************************************************************************************
@Name of the Component : BCBP_URL_CrossOrgCasesRest
@Description : Rest Service for creating cases from external systems
@Author : Siarhei Maroz
@Created Date : 17 July 2025
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 18 July 2025
@Modification description: this RestResource class uses to create and get cases on org from external services
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 06 October 2025
@Modification description: removed BCBP_DTO_CaseRequest type to separated class
 User Story: BCBSFSA-429 | BCBSFSA-641
/***************************************************************************************
@Last Modified By : Gordon Mzizi
@Last Modified On : 07 October 2025
@Modification description: Adding country code mapping for Ghana
 User Story: BCBSFSA-1642
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 04 November 2025
@Modification description: refactored class, added separate methods createContact, createCase,
 getContactByEmail
 User Story: BCBSFSA-1765
***************************************************************************************/

@RestResource(urlMapping='/crossOrgCases/*')
global with sharing class BCBP_URL_CrossOrgCasesRest {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(BCBP_URL_CrossOrgCasesRest.class.getName());

    private static sbgplatform.fflib_SObjectUnitOfWork uow =
        (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();

    private static final Map<String, String> COUNTRY_MAP = new Map<String, String>{
        'Uganda' => 'UG',
        'Botswana' => 'BW',
        'Ghana' => 'GH'
    };

    /**
     * @description Global static method to handle the HTTP POST request for creating case
     * @return BCBP_DTO_CaseResponse
	*/
    @HttpPost
    global static BCBP_DTO_CaseResponse createCase() {
        BCBP_DTO_CaseResponse response = new BCBP_DTO_CaseResponse();
        response.errors = new List<String>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            BCBP_DTO_CaseRequest caseData =
                    (BCBP_DTO_CaseRequest)JSON.deserialize(req.requestBody.toString(), BCBP_DTO_CaseRequest.class);

            Case newCase = createCase(caseData);
            Contact contact = getContactByEmail(caseData.email);

            if (contact == null && Schema.SobjectType.Contact.isCreateable() && String.isNotBlank(caseData.lastName)) {
                contact = createContact(caseData);
                uow.registerNew(contact);
            }

            if (Schema.SobjectType.Case.isCreateable()){
                uow.registerNew(newCase, Case.ContactId, contact);
                uow.commitWork();
            }

            List<Case> caseRecords = new SEL_Case().selectCaseById(newCase.id);

            response.success = true;
            response.message = 'Case created successfully';
            response.caseNumber = caseRecords.get(0).CaseNumber;
            response.caseId = newCase.id;
            
        } catch (Exception e) {
            res.statusCode = 400;
            response.success = false;
            response.message = 'Failed to create case: ' + e.getMessage();
            response.errors.add(e.getMessage());

            LOGGER.error(e.getMessage(), new String[] {BCBP_URL_CrossOrgCasesRest.class.getName(), 'Method: createCase'}, e);
        }
        
        return response;
    }

    /**
     * @description Global static method to handle the HTTP GET request for getting cases by user email
     * @return List<BCBP_DTO_CaseResponse>
	*/
    @HttpGet
    global static List<BCBP_DTO_CaseResponse> getCasesBySuppliedEmail() {
        List<BCBP_DTO_CaseResponse> responses = new List<BCBP_DTO_CaseResponse>();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String suppliedEmail = req.requestURI.substringAfterLast('/');
            
            if (String.isBlank(suppliedEmail)) {
                throw new IllegalArgumentException('Email parameter is required');
            }
            
            List<Case> caseRecords = new SEL_Case().selectCasesBySuppliedEmail(suppliedEmail);
            
            if (caseRecords.isEmpty()) {
                throw new IllegalArgumentException('No cases found for email: ' + suppliedEmail);
            }
            
            // Prepare response for each case
            for (Case caseRecord : caseRecords) {
                caseRecord.Account = null;
                BCBP_DTO_CaseResponse response = new BCBP_DTO_CaseResponse();
                response.success = true;
                response.message = 'Case retrieved successfully';
                response.caseRecord = caseRecord;
                responses.add(response);
            }
            
        } catch (Exception e) {
            res.statusCode = 400;
            BCBP_DTO_CaseResponse errorResponse = new BCBP_DTO_CaseResponse();
            errorResponse.success = false;
            errorResponse.message = 'Failed to retrieve cases: ' + e.getMessage();
            errorResponse.errors = new List<String>{e.getMessage()};
            responses.add(errorResponse);

            LOGGER.error(e.getMessage(), new String[] {BCBP_URL_CrossOrgCasesRest.class.getName(), 'Method: getCasesBySuppliedEmail'}, e);
        }
        
        return responses;
    }

    /**
     * @description find existing Contact record by email
     * @param email String
     * @return Contact
	*/
    private static Contact getContactByEmail(String email) {
        if (String.isBlank(email) || !Schema.sObjectType.Contact.isAccessible()) {
            return null;
        }
        List<Contact> contactList = new SEL_Contact().selectByEmail(email);
        return contactList.isEmpty() ? null : contactList[0];
    }

    /**
     * @description create a new Case using BCBP_DTO_CaseRequest data
     * @param caseData BCBP_DTO_CaseRequest
     * @return Case
	*/
    private static Case createCase(BCBP_DTO_CaseRequest caseData) {
        if (COUNTRY_MAP.get(caseData.country) != null) {
            caseData.country = COUNTRY_MAP.get(caseData.country);
        }
        Case newCase = new Case(
                Subject                 = caseData.subject,
                Description             = caseData.description,
                Origin                  = caseData.origin,
                Priority                = caseData.priority,
                SuppliedName            = caseData.firstName + ' ' + caseData.lastName,
                SuppliedEmail           = caseData.email,
                Type                    = caseData.type,
                Case_Owner_Country__c   = caseData.country
        );

        if (caseData.customFields != null) {
            for (String field : caseData.customFields.keySet()) {
                newCase.put(field, caseData.customFields.get(field));
            }
        }
        return newCase;
    }

    /**
     * @description create a new Contact using BCBP_DTO_CaseRequest data
     * @param caseData BCBP_DTO_CaseRequest
     * @return Contact
	*/
    private static Contact createContact(BCBP_DTO_CaseRequest caseData) {
        return new Contact(
            FirstName = caseData.firstName,
            LastName = caseData.lastName,
            Email = caseData.email
        );
    }
}