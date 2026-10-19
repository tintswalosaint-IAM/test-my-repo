/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_Customer
@ Description       :For dealing with Customer 3.0.0 api and sending the result to the main flow and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala.
@ Last Modified On  :26/08/2024.
@ Modification Description : SFP-41533
***************************************************************************************/
public class AOB_Customer {
private AOB_Customer(){}
    //HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/external-partners/customers';
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Customer'); 

    
    /** 
    * @description This method used for invoking the main callout method 
    * @param applications
    * @return Returns a callout response in map format for remaining processing
    */
    public static String invokeCustomerCreate(List<Application__c> applications) {
        if(applications==null || applications.isEmpty() == true){
            throw new AuraHandledException('application is null');
        }
    
        List<Application__c> applicationList = new SEL_Application().selectAppsById(applications[0].Id);
        if (applicationList.isEmpty()  || applicationList[0].AOB_Customer_Id__c != null) {
            return null;
        }
    
        Map<String, Object> responseObject = makeCustomerCallout(applicationList, applications);
        if (responseObject == null) {
            return null;
        }
    
        String status = responseObject.containsKey('ErrorDescription') ? 'Failed' : 'Success';
        if(status=='Success'){
            AOB_FlowController.createVerificationRecord(applicationList[0], 'Customer 3.0.0', status);
        }else{
            Verification__c verificationInstance = new Verification__c(
                Application__c = applicationList[0].Id,
                Verification_Source__c = 'Customer 3.0.0',
                AOB_DSX_Response__c = String.valueOf(responseObject),
                Verification_Status__c = 'Failed'
                );
                AOB_FlowController.createVerificationWithInstance(verificationInstance);
        }
        
        return JSON.serialize(responseObject);
    }
    
    

/**
 * This method makes a callout to a customer endpoint with provided records and returns the response.
 * @param records List of Application__c records to process.
 * @param notUpdatedInstances List of Application__c records that were not updated.
 * @return A map containing the response to the callout operation.
 */
    public static Map<String, Object> makeCustomerCallout(List<Application__c> records, List<Application__c> notUpdatedInstances) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();

        try {
            
            Map<String, Object> validatedRecords = areRecordsValid(records, notUpdatedInstances, responseToReturnObject);
            if(validatedRecords.containsKey('ErrorDescription') ){
                return validatedRecords;
            }
            // Prepare the HTTP request and response
            HttpRequest httpRequest = prepareHttpRequest(records[0], notUpdatedInstances[0]);
            HttpResponse httpResponse = sendHttpRequest(httpRequest);
            
            // Handle the response based on status code
            responseToReturnObject = (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) 
                ? handleSuccessfulResponse(httpResponse)
                : handleFailedResponse(httpResponse, records[0]);
            
        } catch (Exception ex) {
            LOGGER.error('AOB_Customer.makeCustomerCallout', ex);
            responseToReturnObject.put('status', 'FAILED');
            responseToReturnObject.put('ErrorDescription', ex.getMessage());
        }

        return responseToReturnObject;
    }
    
    // Method to validate records and instances
    private static ValidationResult validateRecords(List<Application__c> records, List<Application__c> notUpdatedInstances) {
        Application__c record = records.isEmpty() ? null : records[0];
        Application__c notUpdatedInstance = notUpdatedInstances.isEmpty() ? null : notUpdatedInstances[0];

        if (record == null || notUpdatedInstance == null) {
            return new ValidationResult(false, 'No records provided');
        }
        return new ValidationResult(true, null);
    }

    // Method to validate records and instances and update responseToReturnObject
    private static Map<String, Object> areRecordsValid(List<Application__c> records, List<Application__c> notUpdatedInstances, Map<String, Object> responseToReturnObject) {
        ValidationResult validationResult = validateRecords(records, notUpdatedInstances);

        if (!validationResult.isValid) {
            responseToReturnObject.put('status', 'FAILED');
            responseToReturnObject.put('ErrorDescription', validationResult.errorMessage);
        }
        return responseToReturnObject;

    }

    // Method to prepare the HTTP request
    private static HttpRequest prepareHttpRequest(Application__c record, Application__c notUpdatedInstance) {
        AOB_CustomerBean customerBeanRecord = populateCustomerBeanRecord(record, notUpdatedInstance);
        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(customerBeanRecord));
        if (System.Test.isRunningTest() && mockHttpStatusCode != null && mockHttpStatus != null) {
            AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
        }
        
        return httpRequest;
    }

    // Method to send the HTTP request and get the response
    private static HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        Http http = new Http();
        return http.Send(httpRequest);
    }


/**
 * Populates the customer bean record with data from provided records.
 * @param record Application__c record to extract data from.
 * @param notUpdatedInstance Application__c record that was not updated.
 * @return A populated AOB_CustomerBean object.
 */
private static AOB_CustomerBean populateCustomerBeanRecord(Application__c record, Application__c notUpdatedInstance) {
    AOB_CustomerBean.StudentDetails studentDetailsRecord = new AOB_CustomerBean.StudentDetails();
    Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_Customer');
  
    studentDetailsRecord.studyYear      = string.valueOf(mData.get('studyYear'))??''; 
    studentDetailsRecord.Institution    = string.valueOf(mData.get('Institution'))??'';
    studentDetailsRecord.courseName     = '';
    studentDetailsRecord.commencedDate  = '';
    studentDetailsRecord.expectedCompletionDate = '';
    studentDetailsRecord.enrollmentType     = '';
    studentDetailsRecord.renewalDate    = '';
    
    AOB_CustomerBean.PersonDetails personDetailsRecord = new AOB_CustomerBean.PersonDetails();
    personDetailsRecord.firstName   = record.AOB_FirstName__c ?? '';
    personDetailsRecord.lastName    = record.AOB_LastName__c ?? '';
    personDetailsRecord.initials    = '';
    personDetailsRecord.otherName   = record.AOB_Other_Name__c ?? '';
    personDetailsRecord.birthName   = '';
    personDetailsRecord.preferredName   = record.AOB_FirstName__c ?? '';
    personDetailsRecord.dob         = Datetime.newInstance(record.AOB_DOB__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
    personDetailsRecord.gender      = record.AOB_Gender__c?.substring(0, 1) ?? '';
    personDetailsRecord.title       = record.AOB_Title__c ?? ''; 
    personDetailsRecord.maritalStatus   = record.AOB_Marital_Status__c ?? '';
    personDetailsRecord.citizenshipCountry  = string.valueOf(mData.get('citizenshipCountry'))??'';
    personDetailsRecord.nationality         = record.AOB_Nationality__c ?? '';
    personDetailsRecord.countryOfBirth      = record.AOB_Nationality__c ?? ''; 
    personDetailsRecord.ethnicity   = '';
    personDetailsRecord.foreignNationalIndicator = string.valueOf(mData.get('foreignNationalIndicator'))??'';
    personDetailsRecord.foreignNationalReport =  string.valueOf(mData.get('foreignNationalReport'))??'';
    personDetailsRecord.foreignNationalStatus =string.valueOf(mData.get('foreignNationalStatus'))??'';
    personDetailsRecord.assetClassification = '';
    personDetailsRecord.homeOwnership = record.AOB_Accommodation_Type__c ?? '';
    personDetailsRecord.qualification = '';
    personDetailsRecord.maritalPropertyRegime = '';
    personDetailsRecord.dependants = integer.valueOf(mData.get('dependants'));
    personDetailsRecord.dependantsMinor =integer.valueOf(mData.get('dependantsMinor'));
    personDetailsRecord.clientType = '';
    personDetailsRecord.studentIndicator = Boolean.valueOf(mData.get('studentIndicator'));
    personDetailsRecord.purgeAllowedIndicator = string.valueOf(mData.get('purgeAllowedIndicator'));
    personDetailsRecord.studentDetails = studentDetailsRecord;
    personDetailsRecord.digitalBankingIndicator = '';
    
    AOB_CustomerBean.OrgDetails orgDetailsRecord = new AOB_CustomerBean.OrgDetails();
    orgDetailsRecord.legalName      = '';
    orgDetailsRecord.companyName    = '';
    orgDetailsRecord.legalForm      = '';
    orgDetailsRecord.orgEstablishDt = '';
    orgDetailsRecord.numEmployees   = integer.valueOf(mData.get('numEmployees'));
    orgDetailsRecord.fiscalYearEnd  = '';
    orgDetailsRecord.ownership      = '';
    
    AOB_CustomerBean.Contacts contactsRecord = new AOB_CustomerBean.Contacts();
    contactsRecord.contactType  = record.AOB_Phone_Type__c ?? '';
    contactsRecord.value        = string.valueOf(mData.get('contactsRecord.value')) + record.AOB_Phone__c;
    contactsRecord.countryCode  = string.valueOf(mData.get('countryCode'));
    contactsRecord.preferredInd = string.valueOf(mData.get('preferredInd'));
    contactsRecord.cityCode    	= string.valueOf(mData.get('cityCode'));
    contactsRecord.localCode 	= record.AOB_Phone__c ?? '';
    contactsRecord.phoneType    = string.valueOf(mData.get('phoneType'));
    
     AOB_CustomerBean.Contacts emailRecord = new AOB_CustomerBean.Contacts();
        
     emailRecord.contactType  = record.AOB_Email_Type__c ?? '';
     emailRecord.value        = record.AOB_Email__c ?? '';
     emailRecord.countryCode  = '';
     emailRecord.preferredInd = string.valueOf(mData.get('emailRecord.preferredInd'));
     emailRecord.cityCode     = ''; 
     emailRecord.localCode    = '';
     emailRecord.phoneType    = string.valueOf(mData.get('emailRecord.phoneType'));
    
    AOB_CustomerBean.ComplianceRoles complianceRolesRecord = new AOB_CustomerBean.ComplianceRoles();
    complianceRolesRecord.compRole = '';
    complianceRolesRecord.complianceGrade = record.AOB_Risk_Score_Rating__c;
    complianceRolesRecord.complianceStatus = string.valueOf(mData.get('complianceStatus'))??'';
    complianceRolesRecord.statusReason = '';
    complianceRolesRecord.verifiedBy = '';
    
    AOB_CustomerBean.Identification identificationRecord = new AOB_CustomerBean.Identification();
    identificationRecord.identificationType 				= string.valueOf(mData.get('identificationType'))??'';
    identificationRecord.identificationNumber   			= record.AOB_NIN__c ?? '';
    identificationRecord.issuingCountry 					= record.AOB_Nationality__c ?? '';
    identificationRecord.issuedOrganisation 				= string.valueOf(mData.get('issuedOrganisation'))??'';
    identificationRecord.issuedDate 						= string.valueOf(mData.get('issuedDate'))??'';
    identificationRecord.expirationDate                     = record.AOB_Identifii_Expire_Date__c?.format() ?? string.valueOf(mData.get('expirationDate'))??'';
    identificationRecord.PreferredIdentificationIndicator 	= string.valueOf(mData.get('PreferredIdentificationIndicator'))??'';
    identificationRecord.documentCode 						= string.valueOf(mData.get('documentCode'))??'';
    identificationRecord.documentDescription 				= string.valueOf(mData.get('documentDescription'))??'';
    identificationRecord.documentTypeCode 					= string.valueOf(mData.get('documentTypeCode'))??'';
    identificationRecord.documentTypeDescription 	        = string.valueOf(mData.get('documentTypeDescription'))??'';

    AOB_CustomerBean.ProminentInfluentialPerson prominentInfluentialPersonRecord = new AOB_CustomerBean.ProminentInfluentialPerson();
    prominentInfluentialPersonRecord.pipInd       	= string.valueOf(mData.get('pipInd'))??'';
    prominentInfluentialPersonRecord.relatedInd   	= string.valueOf(mData.get('relatedInd'))??'';
    prominentInfluentialPersonRecord.name     		= record.AOB_FirstName__c;
    prominentInfluentialPersonRecord.relationType 	= '';
    string empId;

    List<AOB_ReferencedData__c> empNames = new SEL_ReferenceData().getReferencedDataName('PPB_EMP_NAME', 'AOB_SEQUENCE__C');
    if (!empNames.isEmpty()) {
        for (AOB_ReferencedData__c emp : empNames) {
            if (emp.Name == record.AOB_Employer_Name__c) {
                empId = emp.AOB_Code__c;
                break;
            }
        }
    }

    String teritory_sec = record.Employment_Details_Notes__c??'';
    String industry = (teritory_sec != null && string.isNotBlank(teritory_sec)) ? teritory_sec.substring(0, 1) : '';

    AOB_CustomerBean.EmploymentDetails employmentDetailsRecord = new AOB_CustomerBean.EmploymentDetails();
    employmentDetailsRecord.orgName         = record.AOB_Employer_Name__c ?? '';
    employmentDetailsRecord.staffIndicator  = string.valueOf(mData.get('staffIndicator'))??'';
    employmentDetailsRecord.startDate       = '';
    employmentDetailsRecord.endDate         = '';
    employmentDetailsRecord.industrialSector= industry;
    employmentDetailsRecord.occupation = record.AOB_Nature_Of_Employment__c == null ? record.AOB_Occupation__c: record.AOB_Nature_Of_Employment__c;   
    employmentDetailsRecord.employmentType  = record.AOB_Employment_Type__c; 
    employmentDetailsRecord.employerId =
    record.AOB_Employment_Type__c == '008' ? '304004' :
    new List<String>{'004','002','005','012'}.contains(record.AOB_Employment_Type__c) ? '304003' :
    empId ?? ''; 
    AOB_CustomerBean.SourceOfFunds sourceOfFundsRecord = new AOB_CustomerBean.SourceOfFunds();
    sourceOfFundsRecord.sourceFundType      		= string.valueOf(mData.get('sourceFundType'))??'';
    sourceOfFundsRecord.sourceFundAmount            = String.valueOf(record.AOB_Monthly_Income_in_UGX__c) ?? '0.0';
    sourceOfFundsRecord.currencyCode        		= record.AOB_Selected_Currency__c;
    sourceOfFundsRecord.tradeFinanceIndicator       = string.valueOf(mData.get('tradeFinanceIndicator'))??'';
    
    AOB_CustomerBean.TaxDetails taxDetailsRecord = new AOB_CustomerBean.TaxDetails();
    taxDetailsRecord.taxType    			= string.valueOf(mData.get('taxDetailsRecord.taxType'))??'';
    taxDetailsRecord.taxNumber  			= string.valueOf(mData.get('taxNumber'))??'';
    taxDetailsRecord.provisionalTaxPayerInd = '';
    
    AOB_CustomerBean.CustomerRoles customerRolesRecord = new AOB_CustomerBean.CustomerRoles();
    customerRolesRecord.role    			= '';
    customerRolesRecord.startDate   		= Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 
    customerRolesRecord.endDate     		= '';
    
    AOB_CustomerBean.addressTypes typeHomeRecord = new AOB_CustomerBean.addressTypes();
    typeHomeRecord.addressType  = string.valueOf(mData.get('typeHomeRecord.addressType'))??'';

    AOB_CustomerBean.Addresses addressesRecord = new AOB_CustomerBean.Addresses();
    addressesRecord.uuid    		= '';
    addressesRecord.line1   		= record.AOB_Street__c ?? '';
    addressesRecord.line2   		= record.AOB_County__c ?? '';
    addressesRecord.line3   		= record.AOB_Address_Line3__c ?? '';
    addressesRecord.city    		= record.AOB_City__c ?? '';
    addressesRecord.province		= record.AOB_State__c ?? '';
    addressesRecord.postalCode  	= record.AOB_PostalCode__c ?? '';
    addressesRecord.countryCode 	= record.AOB_Country__c ?? '';
    addressesRecord.preferredInd    = string.valueOf(mData.get('preferredInd'))??'';
    addressesRecord.preferredFormat = string.valueOf(mData.get('addressesRecord.preferredFormat'))??'';
    addressesRecord.comment         = string.valueOf(mData.get('addressesRecord.comment'))??'';
    addressesRecord.startDate       = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 
    addressesRecord.addressTypes    = new List<AOB_CustomerBean.addressTypes> {typeHomeRecord};
     
    AOB_CustomerBean.AddressTypes typeMailingRecord = new AOB_CustomerBean.AddressTypes();
    typeMailingRecord.addressType  = string.valueOf(mData.get('typeMailingRecord.addressType'))??'';

    AOB_CustomerBean.Addresses mailingAddRecord = new AOB_CustomerBean.Addresses();
    mailingAddRecord.uuid = '';
    mailingAddRecord.line1 = record.AOB_Current_Address_Street__c ?? record.AOB_Street__c;
    mailingAddRecord.line2 = record.AOB_Current_Address_County__c ?? record.AOB_County__c;
    mailingAddRecord.line3 = record.AOB_Current_Address_Line3__c ?? '';
    mailingAddRecord.city = record.AOB_Current_Address_City__c ?? record.AOB_City__c;
    mailingAddRecord.province = record.AOB_Current_Address_State__c ?? record.AOB_State__c;
    mailingAddRecord.postalCode = record.AOB_Current_Address_PostalCode__c ?? record.AOB_PostalCode__c;
    mailingAddRecord.countryCode = record.AOB_Current_Address_Country__c ?? record.AOB_Country__c;
    mailingAddRecord.preferredInd = string.valueOf(mData.get('mailingAddRecord.preferredInd'))??'';
    mailingAddRecord.preferredFormat = string.valueOf(mData.get('mailingAddRecord.preferredFormat'))??'';
    mailingAddRecord.comment = string.valueOf(mData.get('mailingAddRecord.comment'))??'';
    mailingAddRecord.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
    mailingAddRecord.addressTypes = new List<AOB_CustomerBean.addressTypes> {typeMailingRecord};
            
    AOB_CustomerBean.MktgConsents personalInfoConsent = new AOB_CustomerBean.MktgConsents();
    personalInfoConsent.consentStatus = record.AOB_Personal_Information_Consent__c;
    personalInfoConsent.consentCode = string.valueOf(mData.get('consentCode'))??'';
    AOB_CustomerBean.MktgConsents specialOffersConsent = new AOB_CustomerBean.MktgConsents();
    specialOffersConsent.consentStatus = record.AOB_Services_Special_Offers_Consent__c;
    specialOffersConsent.consentCode =  string.valueOf(mData.get('consentCode'))??'';
    AOB_CustomerBean.MktgConsents researchConsent = new AOB_CustomerBean.MktgConsents();
    researchConsent.consentStatus = record.AOB_Research_Consent__c;
    researchConsent.consentCode = string.valueOf(mData.get('consentCode'))??'';
    AOB_CustomerBean.MktgConsents marketProductConsent = new AOB_CustomerBean.MktgConsents();
    marketProductConsent.consentStatus = record.AOB_Market_Your_Product_Consent__c;
    marketProductConsent.consentCode = string.valueOf(mData.get('consentCode'))??'';
    
    AOB_CustomerBean.IndustrialSectors industrialSectorsRecord = new AOB_CustomerBean.IndustrialSectors();
    industrialSectorsRecord.industrialClassificationSystem  =  teritory_sec?.substring(0, Math.min(teritory_sec.length(), 4));
    industrialSectorsRecord.industrialSector                =   teritory_sec?.substring(0, Math.min(teritory_sec.length(), 3));
    
    
    AOB_CustomerBean.TaxClassification taxClassificationRecord = new AOB_CustomerBean.TaxClassification();
    taxClassificationRecord.taxCountry  	= record.AOB_Nationality__c;
    taxClassificationRecord.taxRegion   	= string.valueOf(mData.get('taxRegion'))??'';
    taxClassificationRecord.taxType     	= string.valueOf(mData.get('taxClassificationRecord.taxType'))??'';
    taxClassificationRecord.taxGroup    	= '';
    taxClassificationRecord.taxExemptReason = string.valueOf(mData.get('taxExemptReason'))??'';
    AOB_CustomerBean.Permits permitsRecord = new AOB_CustomerBean.Permits();
    permitsRecord.permitType    = '';
    permitsRecord.permitNumber  = '';
    permitsRecord.effDt         = '';
    permitsRecord.expDt         = '';  

    AOB_CustomerBean.Misc miscRecord = new AOB_CustomerBean.Misc();
    miscRecord.key  = string.valueOf(mData.get('miscRecord.key'))??'';
    miscRecord.value= string.valueOf(mData.get('miscRecord.value'))??'';
    miscRecord.miscDate  = '';
    miscRecord.counterPartyInfo= string.valueOf(mData.get('counterPartyInfo'))??'';
    miscRecord.distributionChannel  = string.valueOf(mData.get('distributionChannel'))??'';
    
    AOB_CustomerBean customerBeanRecord = new AOB_CustomerBean(); 
    customerBeanRecord.portFolioNum = notUpdatedInstance.AOB_Preferred_Branch__c.right(4)??'';
    customerBeanRecord.EASIndicator  = string.valueOf(mData.get('EASIndicator'))??'';
    customerBeanRecord.customerType  = string.valueOf(mData.get('customerType'))??'';
    customerBeanRecord.personDetails = personDetailsRecord;
    customerBeanRecord.orgDetails    = orgDetailsRecord;

    customerBeanRecord.contacts = new List<AOB_CustomerBean.Contacts> { contactsRecord };
      if (String.isNotBlank(record.AOB_Email__c)) {
             customerBeanRecord.contacts.add(emailRecord);
       }

    customerBeanRecord.complianceRoles      = new List<AOB_CustomerBean.ComplianceRoles> {complianceRolesRecord};
    customerBeanRecord.identification      = new List<AOB_CustomerBean.Identification> {identificationRecord};
    customerBeanRecord.residenceCountry    = record.AOB_Nationality__c;
    customerBeanRecord.relManagerLink      = string.valueOf(mData.get('relManagerLink'))??'';
    customerBeanRecord.prefLanguage        = string.valueOf(mData.get('prefLanguage'))??'';
    customerBeanRecord.prominentInfluentialPerson = prominentInfluentialPersonRecord;
    customerBeanRecord.employmentDetails    = employmentDetailsRecord;
    customerBeanRecord.sourceOfFunds        = new List<AOB_CustomerBean.SourceOfFunds> {sourceOfFundsRecord};
    customerBeanRecord.taxDetails           = new List<AOB_CustomerBean.taxDetails> {taxDetailsRecord};
    customerBeanRecord.customerRoles        = new List<AOB_CustomerBean.customerRoles> {customerRolesRecord};
    customerBeanRecord.addresses            = new List<AOB_CustomerBean.Addresses> {addressesRecord, mailingAddRecord};
    customerBeanRecord.mktgConsents         = new List<AOB_CustomerBean.mktgConsents> {personalInfoConsent,specialOffersConsent,researchConsent,marketProductConsent};
    customerBeanRecord.responsibleBranch    = notUpdatedInstance.AOB_Preferred_Branch__c;
    customerBeanRecord.authorizationGroup   = '';
    customerBeanRecord.industrialSectors    = new List<AOB_CustomerBean.IndustrialSectors> {industrialSectorsRecord};
    customerBeanRecord.taxClassification    = taxClassificationRecord;
    customerBeanRecord.permits              = new List<AOB_CustomerBean.Permits> {permitsRecord};
    customerBeanRecord.gIIN                 = '';
    customerBeanRecord.mktgSegment          = string.valueOf(mData.get('mktgSegment'))??'';
    customerBeanRecord.accessOwnerSegment   = string.valueOf(mData.get('accessOwnerSegment'))??'';
    customerBeanRecord.segmentCategory      = string.valueOf(mData.get('segmentCategory'))??'';
    customerBeanRecord.minorIndicator       = System.today().addYears(-18) >= record.AOB_DOB__c ? 'N' : 'Y';
    customerBeanRecord.seniorIndicator      = System.today().addYears(-60) >= record.AOB_DOB__c ? 'Y' : 'N';
    customerBeanRecord.misc                 = new List<AOB_CustomerBean.Misc> {miscRecord};
    return customerBeanRecord;
}

/**
 * Handles the failed HTTP response.
 * @param httpResponse The HTTP response object.
 * @param responseToReturnObject The response map to be updated.
 * @param record The Application__c record associated with the callout.
 * @return A map updatedResponse.
 */
private static  Map<String, Object> handleFailedResponse(HttpResponse httpResponse, Application__c record) {
    String errorMessage = 'No Response From Server';
    if (httpResponse.getBody() != null) {
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
        errorMessage = (String) responseObject.get('moreInformation');
    }

    Map<String, Object> updatedResponse = new Map<String, Object>{
        'status'         => 'FAILED',
        'statusCode'      =>  httpResponse.getStatusCode(),
        'ErrorDescription' => errorMessage
    };
    LOGGER.error('AOB_Customer.makeCustomerCallout: Failed', new String[] {'AOB_Customer.makeCustomerCallout', record.Id, errorMessage});
    return updatedResponse;
}

/**
 * Handles the successful HTTP response.
 * @param httpResponse The HTTP response object.
 * @param responseToReturnObject The response map to be updated.
 * @param record
 * @return A map updatedResponse.
 */
private static Map<String, Object> handleSuccessfulResponse(HttpResponse httpResponse) {
    String responseBody = httpResponse.getBody();

    if (responseBody == null) {
        return new Map<String, Object> {
            'status' => 'NO_CONTENT',
            'statusCode' => 204,
            'ErrorDescription' => 'No response body'
        };
    }

    Map<String, Object> updatedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    updatedResponse.put('status', 'SUCCESS');
    return updatedResponse;
}
//wrapper class to encapsulate the result of a validation process.
    public class ValidationResult {
    public Boolean isValid;
    public String errorMessage;

    public ValidationResult(Boolean isValid, String errorMessage) {
        this.isValid = isValid;
        this.errorMessage = errorMessage;   

    }
    }
}