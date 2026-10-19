/**
 * @description       : API class to create customer CIF.
 * @author            : Jagadish Thummala
 * @group             : 
 * @last modified on  : 10-27-2025
 * @last modified by  : jagadish Thummala
 */
public without sharing class AOB_Create_CIF {
    private AOB_Create_CIF() {}
    // HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/external-partners/customers';
    public static final String ERROR_DESCR = 'ErrorDescription';
    public static final String STATUS_FAILED = 'FAILED'; 
    public static final String STATUS_SUCCESS = 'SUCCESS';

    
    // Test class variables
    @TestVisible
    private static Integer mockHttpStatusCode;
    @TestVisible
    private static String mockHttpStatus;
    @TestVisible
    private static String mockHttpBody = '';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Customer'); 
    /**
     * @description Invokes customer creation callout for guardian
     * @param application Primary application record
     * @return String JSON-serialized response
     */
    public static String invokeCustomerCreate(Application__c application) {
        return invokeCustomerCreate(application, null);
    }
    /**
     * @description Invokes customer creation callout
     * @param application Primary application record
     * @param childApplication Optional child application record
     * @return String JSON-serialized response
     */
    public static String invokeCustomerCreate(Application__c application, Application__c childApplication) {
        if (application == null) {
            throw new AuraHandledException('Application cannot be null');
        }
        List<Application__c> applicationList = new SEL_Application().selectAppsById(application.Id);
        Map<String, Object> responseObject = makeCustomerCallout(applicationList[0], childApplication);
        if (responseObject == null) {
            return null;
        }
        String status = responseObject.containsKey(ERROR_DESCR) ? STATUS_FAILED : STATUS_SUCCESS;
        Application__c targetApplication = childApplication == null ? applicationList[0] : childApplication;
        
        if (status == STATUS_SUCCESS) {
            AOB_FlowController.createVerificationRecord(targetApplication, 'Customer 3.0.0', status);
        } else {
            Verification__c verificationInstance = new Verification__c(
                Application__c = targetApplication.Id,
                Verification_Source__c = 'Customer 3.0.0',
                AOB_DSX_Response__c = String.valueOf(responseObject),
                Verification_Status__c = STATUS_FAILED
            );
            AOB_FlowController.createVerificationWithInstance(verificationInstance);
        }
        
        return JSON.serialize(responseObject);
    }

    /**
     * @description Makes a callout to the customer endpoint
     * @param record Primary application record
     * @param childApplication Optional child application record
     * @return Map<String, Object> Response from the callout
     */
    public static Map<String, Object> makeCustomerCallout(Application__c record, Application__c childApplication) {
        Map<String, Object> response = new Map<String, Object>();
        String isChildAcc = childApplication?.AOB_Schema_Code__c == 'SBCHD' ? 'Y' : 'N';

        try {
            ValidationResult validationResult = validateRecords(record, childApplication);
            if (!validationResult.isValid) {
                response.put('status', STATUS_FAILED);
                response.put(ERROR_DESCR, validationResult.errorMessage);
                return response;
            }

            HttpRequest httpRequest = prepareHttpRequest(record, childApplication);
            HttpResponse httpResponse = sendHttpRequest(httpRequest);
            response = (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) 
                ? handleSuccessfulResponse(httpResponse)
                : handleFailedResponse(httpResponse, isChildAcc == 'Y' ? childApplication : record);
        } catch (Exception ex) {
            LOGGER.error('AOB_Create_CIF.makeCustomerCallout', ex);
            response.put('status', STATUS_FAILED);
            response.put(ERROR_DESCR, ex.getMessage());
        }

        return response;
    }

    /**
     * @description Validates the provided records
     * @param record Primary application record
     * @param childApplication Optional child application record
     * @return ValidationResult Validation result
     */
    private static ValidationResult validateRecords(Application__c record, Application__c childApplication) {
        if (record == null) {
            return new ValidationResult(false, 'Primary application record is required');
        }
        if (childApplication != null && childApplication.AOB_Schema_Code__c != 'SBCHD') {
                return new ValidationResult(false, 'Child application required for SBCHD product');
        } 
        return new ValidationResult(true, null);
    }

    /**
     * @description Prepares the HTTP request for the callout
     * @param record Primary application record
     * @param childApplication Optional child application record
     * @return HttpRequest Prepared HTTP request
     */
    private static HttpRequest prepareHttpRequest(Application__c record, Application__c childApplication) {
        AOB_CustomerBean customerBean = populateCustomerBeanRecord(record, childApplication);
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(customerBean));        
        if (Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
            AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
        
        return httpRequest;
    }

    /**
     * @description Sends the HTTP request
     * @param httpRequest The HTTP request to send
     * @return HttpResponse The response from the server
     */
    private static HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        return new Http().send(httpRequest);
    }

    /**
     * @description Populates the customer bean with data
     * @param record Primary application record
     * @param childApplication Optional child application record
     * @return AOB_CustomerBean Populated customer bean
     */
    private static AOB_CustomerBean populateCustomerBeanRecord(Application__c record, Application__c childApplication) {
        Map<String, Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_Customer');
        String isChildAcc = childApplication?.AOB_Schema_Code__c == 'SBCHD' ? 'Y' : 'N';
        
        AOB_CustomerBean.StudentDetails studentDetails = new AOB_CustomerBean.StudentDetails();
        studentDetails.studyYear = String.valueOf(mData.get('studyYear') ?? '');
        studentDetails.Institution = String.valueOf(mData.get('Institution') ?? '');
        studentDetails.courseName = '';
        studentDetails.commencedDate = '';
        studentDetails.expectedCompletionDate = '';
        studentDetails.enrollmentType = '';
        studentDetails.renewalDate = '';

        AOB_CustomerBean.PersonDetails personDetails = new AOB_CustomerBean.PersonDetails();
        personDetails.firstName = isChildAcc == 'Y' ? (childApplication?.AOB_FirstName__c ?? '') : (record.AOB_FirstName__c ?? '');
        personDetails.lastName = isChildAcc == 'Y' ? (childApplication?.AOB_LastName__c ?? '') : (record.AOB_LastName__c ?? '');
        personDetails.initials = '';
        personDetails.otherName = isChildAcc == 'Y' ? (childApplication?.AOB_Other_Name__c ?? '') : (record.AOB_Other_Name__c ?? '');
        personDetails.preferredName = isChildAcc == 'Y' ? (childApplication?.AOB_FirstName__c ?? '') : (record.AOB_FirstName__c ?? '');
        personDetails.dob = Datetime.newInstance(
            isChildAcc == 'Y' ? (childApplication?.AOB_DOB__c ?? Date.today()) : (record.AOB_DOB__c ?? Date.today()),
            Time.newInstance(0, 0, 0, 0)
        ).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        personDetails.gender = isChildAcc == 'Y' ? (childApplication?.AOB_Gender__c ?.substring(0, 1) ?? '') : (record.AOB_Gender__c?.substring(0, 1) ?? '');
        personDetails.title = isChildAcc == 'Y' ? (childApplication?.AOB_Title__c ?? '') : (record.AOB_Title__c ?? '');
        personDetails.maritalStatus = record.AOB_Marital_Status__c ?? '';
        personDetails.citizenshipCountry = String.valueOf(mData.get('citizenshipCountry') ?? '');
        personDetails.nationality = record.AOB_Nationality__c ?? '';
        personDetails.countryOfBirth = record.AOB_Nationality__c ?? '';
        personDetails.ethnicity = '';
        personDetails.foreignNationalIndicator = String.valueOf(mData.get('foreignNationalIndicator') ?? '');
        personDetails.foreignNationalReport = String.valueOf(mData.get('foreignNationalReport') ?? '');
        personDetails.foreignNationalStatus = String.valueOf(mData.get('foreignNationalStatus') ?? '');
        personDetails.assetClassification = '';
        personDetails.homeOwnership = record.AOB_Accommodation_Type__c ?? '';
        personDetails.qualification = '';
        personDetails.maritalPropertyRegime = '';
        personDetails.dependants = Integer.valueOf(mData.get('dependants') ?? 0);
        personDetails.dependantsMinor = Integer.valueOf(mData.get('dependantsMinor') ?? 0);
        personDetails.clientType = '';
        personDetails.studentIndicator = Boolean.valueOf(mData.get('studentIndicator') ?? false);
        personDetails.purgeAllowedIndicator = String.valueOf(mData.get('purgeAllowedIndicator') ?? '');
        personDetails.studentDetails = studentDetails;
        personDetails.digitalBankingIndicator = '';

        AOB_CustomerBean.OrgDetails orgDetails = new AOB_CustomerBean.OrgDetails();
        orgDetails.legalName = '';
        orgDetails.companyName = '';
        orgDetails.legalForm = '';
        orgDetails.orgEstablishDt = '';
        orgDetails.numEmployees = Integer.valueOf(mData.get('numEmployees') ?? 0);
        orgDetails.fiscalYearEnd = '';
        orgDetails.ownership = '';

        AOB_CustomerBean.Contacts phoneContact = new AOB_CustomerBean.Contacts();
        phoneContact.contactType = record.AOB_Phone_Type__c ?? '';
        phoneContact.value = String.valueOf(mData.get('contactsRecord.value') ?? '') + (record.AOB_Phone__c ?? '');
        phoneContact.countryCode = String.valueOf(mData.get('countryCode') ?? '');
        phoneContact.preferredInd = String.valueOf(mData.get('preferredInd') ?? '');
        phoneContact.cityCode = String.valueOf(mData.get('cityCode') ?? '');
        phoneContact.localCode = record.AOB_Phone__c ?? '';
        phoneContact.phoneType = String.valueOf(mData.get('phoneType') ?? '');

        AOB_CustomerBean.Contacts emailContact = new AOB_CustomerBean.Contacts();
        emailContact.contactType = record.AOB_Email_Type__c ?? '';
        emailContact.value = record.AOB_Email__c ?? '';
        emailContact.preferredInd = String.valueOf(mData.get('emailRecord.preferredInd') ?? '');
        emailContact.phoneType = String.valueOf(mData.get('emailRecord.phoneType') ?? '');

        AOB_CustomerBean.ComplianceRoles complianceRoles = new AOB_CustomerBean.ComplianceRoles();
        complianceRoles.compRole = '';
        complianceRoles.complianceGrade = record.AOB_Risk_Score_Rating__c ?? '';
        complianceRoles.complianceStatus = String.valueOf(mData.get('complianceStatus') ?? '');
        complianceRoles.statusReason = '';
        complianceRoles.verifiedBy = '';

        AOB_CustomerBean.Identification identification = new AOB_CustomerBean.Identification();
        identification.identificationType = String.valueOf(mData.get('identificationType') ?? '');
        identification.identificationNumber = record.AOB_NIN__c ?? '';
        identification.issuingCountry = record.AOB_Nationality__c ?? '';
        identification.issuedOrganisation = String.valueOf(mData.get('issuedOrganisation') ?? '');
        identification.issuedDate = String.valueOf(mData.get('issuedDate') ?? '');
        identification.expirationDate = record.AOB_Identifii_Expire_Date__c?.format() ?? String.valueOf(mData.get('expirationDate') ?? '');
        identification.PreferredIdentificationIndicator = String.valueOf(mData.get('PreferredIdentificationIndicator') ?? '');
        identification.documentCode = String.valueOf(mData.get('documentCode') ?? '');
        identification.documentDescription = String.valueOf(mData.get('documentDescription') ?? '');
        identification.documentTypeCode = String.valueOf(mData.get('documentTypeCode') ?? '');
        identification.documentTypeDescription = String.valueOf(mData.get('documentTypeDescription') ?? '');

        AOB_CustomerBean.ProminentInfluentialPerson pip = new AOB_CustomerBean.ProminentInfluentialPerson();
        pip.pipInd = String.valueOf(mData.get('pipInd') ?? '');
        pip.relatedInd = String.valueOf(mData.get('relatedInd') ?? '');
        pip.name = record.AOB_FirstName__c ?? '';
        pip.relationType = '';

        String empId;
        for (AOB_ReferencedData__c emp : new SEL_ReferenceData().getReferencedDataName('PPB_EMP_NAME', 'AOB_SEQUENCE__C')) {
            if (emp.Name == record.AOB_Employer_Name__c) {
                empId = emp.AOB_Code__c;
                break;
            }
        }

        String territorySec = record.Employment_Details_Notes__c ?? '';
        String industry = String.isNotBlank(territorySec) ? territorySec.substring(0, 1) : '';

        AOB_CustomerBean.EmploymentDetails employmentDetails = new AOB_CustomerBean.EmploymentDetails();
        employmentDetails.orgName = record.AOB_Employer_Name__c ?? '';
        employmentDetails.staffIndicator = String.valueOf(mData.get('staffIndicator') ?? '');
        employmentDetails.startDate = '';
        employmentDetails.endDate = '';
        employmentDetails.industrialSector = industry;
        employmentDetails.occupation = String.isNotBlank(record.AOB_Nature_Of_Employment__c) 
            ? record.AOB_Nature_Of_Employment__c 
            : (record.AOB_Occupation__c ?? '');
        employmentDetails.employmentType = record.AOB_Employment_Type__c ?? '';
        employmentDetails.employerId = record.AOB_Employment_Type__c == '008' ? '304004' 
            : new List<String>{'004','002','005','012'}.contains(record.AOB_Employment_Type__c) ? '304003' 
            : (empId ?? '');

        AOB_CustomerBean.SourceOfFunds sourceOfFunds = new AOB_CustomerBean.SourceOfFunds();
        sourceOfFunds.sourceFundType = String.valueOf(mData.get('sourceFundType') ?? '');
        sourceOfFunds.sourceFundAmount = String.valueOf(record.AOB_Monthly_Income_in_UGX__c ?? '0');
        sourceOfFunds.currencyCode = record.AOB_Selected_Currency__c ?? '';
        sourceOfFunds.tradeFinanceIndicator = String.valueOf(mData.get('tradeFinanceIndicator') ?? '');

        AOB_CustomerBean.TaxDetails taxDetails = new AOB_CustomerBean.TaxDetails();
        taxDetails.taxType = String.valueOf(mData.get('taxDetailsRecord.taxType') ?? '');
        taxDetails.taxNumber = String.valueOf(mData.get('taxNumber') ?? '');
        taxDetails.provisionalTaxPayerInd = '';

        AOB_CustomerBean.CustomerRoles customerRoles = new AOB_CustomerBean.CustomerRoles();
        customerRoles.role = '';
        customerRoles.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        customerRoles.endDate = '';

        AOB_CustomerBean.AddressTypes homeAddressType = new AOB_CustomerBean.AddressTypes();
        homeAddressType.addressType = String.valueOf(mData.get('typeHomeRecord.addressType') ?? '');

        AOB_CustomerBean.Addresses homeAddress = new AOB_CustomerBean.Addresses();
        homeAddress.uuid = '';
        homeAddress.line1 = record.AOB_Street__c ?? '';
        homeAddress.line2 = record.AOB_County__c ?? '';
        homeAddress.line3 = record.AOB_Address_Line3__c ?? '';
        homeAddress.city = record.AOB_City__c ?? '';
        homeAddress.province = record.AOB_State__c ?? '';
        homeAddress.postalCode = record.AOB_PostalCode__c ?? '';
        homeAddress.countryCode = record.AOB_Country__c ?? '';
        homeAddress.preferredInd = String.valueOf(mData.get('preferredInd') ?? '');
        homeAddress.preferredFormat = String.valueOf(mData.get('addressesRecord.preferredFormat') ?? '');
        homeAddress.comment = String.valueOf(mData.get('addressesRecord.comment') ?? '');
        homeAddress.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        homeAddress.addressTypes = new List<AOB_CustomerBean.AddressTypes>{homeAddressType};

        AOB_CustomerBean.AddressTypes mailingAddressType = new AOB_CustomerBean.AddressTypes();
        mailingAddressType.addressType = String.valueOf(mData.get('typeMailingRecord.addressType') ?? '');

        AOB_CustomerBean.Addresses mailingAddress = new AOB_CustomerBean.Addresses();
        mailingAddress.uuid = '';
        mailingAddress.line1 = record.AOB_Current_Address_Street__c ?? record.AOB_Street__c ?? '';
        mailingAddress.line2 = record.AOB_Current_Address_County__c ?? record.AOB_County__c ?? '';
        mailingAddress.line3 = record.AOB_Current_Address_Line3__c ?? '';
        mailingAddress.city = record.AOB_Current_Address_City__c ?? record.AOB_City__c ?? '';
        mailingAddress.province = record.AOB_Current_Address_State__c ?? record.AOB_State__c ?? '';
        mailingAddress.postalCode = record.AOB_Current_Address_PostalCode__c ?? record.AOB_PostalCode__c ?? '';
        mailingAddress.countryCode = record.AOB_Current_Address_Country__c ?? record.AOB_Country__c ?? '';
        mailingAddress.preferredInd = String.valueOf(mData.get('mailingAddRecord.preferredInd') ?? '');
        mailingAddress.preferredFormat = String.valueOf(mData.get('mailingAddRecord.preferredFormat') ?? '');
        mailingAddress.comment = String.valueOf(mData.get('mailingAddRecord.comment') ?? '');
        mailingAddress.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        mailingAddress.addressTypes = new List<AOB_CustomerBean.AddressTypes>{mailingAddressType};

        List<AOB_CustomerBean.MktgConsents> consents = new List<AOB_CustomerBean.MktgConsents>();
        for (String field : new List<String>{
            'AOB_Personal_Information_Consent__c', 
            'AOB_Services_Special_Offers_Consent__c', 
            'AOB_Research_Consent__c', 
            'AOB_Market_Your_Product_Consent__c'
        }) {
            AOB_CustomerBean.MktgConsents consent = new AOB_CustomerBean.MktgConsents();
            consent.consentStatus = (Boolean)record.get(field);
            consent.consentCode = String.valueOf(mData.get('consentCode') ?? '');
            consents.add(consent);
        }

        AOB_CustomerBean.IndustrialSectors industrialSectors = new AOB_CustomerBean.IndustrialSectors();
        industrialSectors.industrialClassificationSystem = territorySec?.substring(0, Math.min(territorySec.length(), 4)) ?? '';
        industrialSectors.industrialSector = territorySec?.substring(0, Math.min(territorySec.length(), 3)) ?? '';

        AOB_CustomerBean.TaxClassification taxClassification = new AOB_CustomerBean.TaxClassification();
        taxClassification.taxCountry = record.AOB_Nationality__c ?? '';
        taxClassification.taxRegion = String.valueOf(mData.get('taxRegion') ?? '');
        taxClassification.taxType = String.valueOf(mData.get('taxClassificationRecord.taxType') ?? '');
        taxClassification.taxGroup = '';
        taxClassification.taxExemptReason = String.valueOf(mData.get('taxExemptReason') ?? '');

        AOB_CustomerBean.Permits permit = new AOB_CustomerBean.Permits();
        permit.permitType = '';
        permit.permitNumber = '';
        permit.effDt = '';
        permit.expDt = '';

        AOB_CustomerBean.Misc misc = new AOB_CustomerBean.Misc();
        misc.key = String.valueOf(mData.get('miscRecord.key') ?? '');
        misc.value = String.valueOf(mData.get('miscRecord.value') ?? '');
        misc.miscDate = '';
        misc.counterPartyInfo = String.valueOf(mData.get('counterPartyInfo') ?? '');
        misc.distributionChannel = String.valueOf(mData.get('distributionChannel') ?? '');

        AOB_CustomerBean customerBean = new AOB_CustomerBean();
        customerBean.portFolioNum = record?.AOB_Preferred_Branch__c?.right(4) ?? '';
        customerBean.EASIndicator = String.valueOf(mData.get('EASIndicator') ?? '');
        customerBean.customerType = String.valueOf(mData.get('customerType') ?? '');
        customerBean.personDetails = personDetails;
        customerBean.orgDetails = orgDetails;
        customerBean.contacts = new List<AOB_CustomerBean.Contacts>{phoneContact};
        if (String.isNotBlank(record.AOB_Email__c)) {
            customerBean.contacts.add(emailContact);
        }
        customerBean.complianceRoles = new List<AOB_CustomerBean.ComplianceRoles>{complianceRoles};
        customerBean.identification = new List<AOB_CustomerBean.Identification>{identification};
        customerBean.residenceCountry = record.AOB_Nationality__c ?? '';
        customerBean.relManagerLink = String.valueOf(mData.get('relManagerLink') ?? '');
        customerBean.prefLanguage = String.valueOf(mData.get('prefLanguage') ?? '');
        customerBean.prominentInfluentialPerson = pip;
        customerBean.employmentDetails = employmentDetails;
        customerBean.sourceOfFunds = new List<AOB_CustomerBean.SourceOfFunds>{sourceOfFunds};
        customerBean.taxDetails = new List<AOB_CustomerBean.TaxDetails>{taxDetails};
        customerBean.customerRoles = new List<AOB_CustomerBean.CustomerRoles>{customerRoles};
        customerBean.addresses = new List<AOB_CustomerBean.Addresses>{homeAddress, mailingAddress};
        customerBean.mktgConsents = consents;
        customerBean.responsibleBranch = record?.AOB_Preferred_Branch__c ?? '';
        customerBean.authorizationGroup = '';
        customerBean.industrialSectors = new List<AOB_CustomerBean.IndustrialSectors>{industrialSectors};
        customerBean.taxClassification = taxClassification;
        customerBean.permits = new List<AOB_CustomerBean.Permits>{permit};
        customerBean.gIIN = '';
        customerBean.mktgSegment = String.valueOf(mData.get('mktgSegment') ?? '');
        customerBean.accessOwnerSegment = String.valueOf(mData.get('accessOwnerSegment') ?? '');
        customerBean.segmentCategory =
            record.Code_word__c == 'Women CVP Opted in' ? String.valueOf(mData.get('womenCVPsegment')) :
            record.AOB_Schema_Code__c == 'OD003' ? '102' :
            record.AOB_Schema_Code__c == 'OD004' ? '103' :
            String.valueOf(mData.get('segmentCategory')) ?? '';        
        customerBean.minorIndicator = System.today().addYears(-18) >= (isChildAcc == 'Y' ? (childApplication?.AOB_DOB__c ?? Date.today()) : (record.AOB_DOB__c ?? Date.today())) ? 'N' : 'Y';
        customerBean.seniorIndicator = System.today().addYears(-60) >= (isChildAcc == 'Y' ? (childApplication?.AOB_DOB__c ?? Date.today()) : (record.AOB_DOB__c ?? Date.today())) ? 'Y' : 'N';
        customerBean.misc = new List<AOB_CustomerBean.Misc>{misc};

        if (isChildAcc == 'Y') {
            AOB_CustomerBean.relationshipDetails childDetails = new AOB_CustomerBean.relationshipDetails();
            childDetails.childCustId = record.AOB_Customer_Id__c ?? '';
            childDetails.childEntity = 'CUSTOMER';
            childDetails.childEntityType = 'Retail';
            childDetails.relationship = childApplication?.Relationship_to_You__c;
            childDetails.relationshipCategory = 'Social';
            childDetails.guardCode = 'FATHER';

            AOB_CustomerBean.relationshipMiscInfo childMisc = new AOB_CustomerBean.relationshipMiscInfo();
            childMisc.countryOfIssue = 'Uganda';
            childMisc.DTDt1 = Datetime.newInstance(childApplication?.AOB_DOB__c ?? Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
            childMisc.DTDt2 = Datetime.newInstance((childApplication?.AOB_DOB__c ?? Date.today()).addYears(18), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
            childMisc.Type = childApplication?.Relationship_to_You__c;
            childDetails.relationshipMiscInfo = childMisc;
            customerBean.relationshipDetails = childDetails;
           
        }

        return customerBean;
    }

    /**
     * @description Handles failed HTTP response
     * @param httpResponse The HTTP response object
     * @param record The associated application record
     * @return Map<String, Object> Updated response
     */
    private static Map<String, Object> handleFailedResponse(HttpResponse httpResponse, Application__c record) {
        String errorMessage = 'No Response From Server';
        if (String.isNotBlank(httpResponse.getBody())) {
            Map<String, Object> responseObject = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String)responseObject.get('moreInformation') ?? errorMessage;
        }

        Map<String, Object> response = new Map<String, Object>{
            'status' => STATUS_FAILED,
            'statusCode' => httpResponse.getStatusCode(),
            ERROR_DESCR => errorMessage
        };
        LOGGER.error('AOB_Create_CIF.handleFailedResponse', new String[]{'AOB_Create_CIF.handle-Orchestrator', record.Id, errorMessage});
        return response;
    }

    /**
     * @description Handles successful HTTP response
     * @param httpResponse The HTTP response object
     * @return Map<String, Object> Updated response
     */
    private static Map<String, Object> handleSuccessfulResponse(HttpResponse httpResponse) {
        String responseBody = httpResponse.getBody();
        if (String.isBlank(responseBody)) {
            return new Map<String, Object>{
                'status' => 'NO_CONTENT',
                'statusCode' => 204,
                ERROR_DESCR => 'No response body'
            };
        }

        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        response.put('status', STATUS_SUCCESS);
        return response;
    }

    /**
     * @description Wrapper class for validation results
     */
    public class ValidationResult {
        public Boolean isValid { get; set; }
        public String errorMessage { get; set; }

        public ValidationResult(Boolean isValid, String errorMessage) {
            this.isValid = isValid;
            this.errorMessage = errorMessage;
        }
    }
}