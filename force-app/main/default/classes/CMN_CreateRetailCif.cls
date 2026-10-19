/***************************************************************************************
@Name of the Class : CMN_CreateRetailCif
@description       : CreateRetailCif will be called based on the Retail Customer Doesn't have the cifid.
@Author            : Lokesh Bothsa(lokesh.bothsa@standardbank.co.za) 
@Date              : June 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 03-04-2024
@Modification Description : SFP-37302
***************************************************************************************/
public class CMN_CreateRetailCif {
/** 
* @description CONTENT_TYPE_APPLICATION_JSON 
*/
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
/** 
* @description HEADER_ACCEPT 
*/
    private static final String HEADER_ACCEPT = 'accept';
/** 
* @description HEADER_CONTENT_TYPE 
*/
    private static final String HEADER_CONTENT_TYPE = 'content-type';
/** 
* @description HEADER_CLIENT_ID 
*/
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
/** 
* @description HEADER_CLIENT_SECRET 
*/
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
/** 
* @description HEADER_CLIENT_CERTIFICATE 
*/
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
/** 
* @description HEADER_AUTHORIZATION 
*/
    private static final String HEADER_AUTHORIZATION = 'Authorization';
/** 
* @description HEADER_INTERACTION_ID 
*/
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
/** 
* @description AUTHORIZATION_TYPE_BEARER 
*/
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
/** 
* @description HTTP_METHOD_POST 
*/
    private static final String HTTP_METHOD_POST = 'POST';
/** 
* @description PARAM_COLON 
*/
    private static final String PARAM_COLON = ':';
/** 
* @description PATH_TOKEN 
*/
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
/** 
* @description PATH_CALLOUT 
*/
    private static final String PATH_CALLOUT = '/external-partners/customers';  
/** 
* @description mockHttpStatusCode 
*/  
    @testVisible private static Integer mockHttpStatusCode;
/** 
* @description mockHttpStatus 
*/
    @testVisible private static String mockHttpStatus;
/** 
* @description mockHttpBody 
*/
    @testVisible private static String mockHttpBody = '';  
/** 
* @description LOGGER 
*/
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CreateRetailCif');
    
/** 
* @description This method used for main callout createRetailCif
* @param applicationList
* @param applicationParticipantList
* @param indivudualRecords
* @return Returns a callout response in stringified format to process in the UI
*/
    public static Map<String, String> maritalStatusNameVsCode = new Map<String, String> {
        'SINGLE' => '001',
        'MARRIED' => '002',
        'SEPARATED' => '003',
        'DIVORCED' => '004',
        'WIDOWED' => '005',
        'NOT GIVEN' => '008',
        'LIVE-IN RELATIONSHIP' => '009'
    };

    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> applicationParticipantList,List<Individual> indivudualRecords)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> response =  makeCreateRetailCifCallout(applicationList,applicationParticipantList,indivudualRecords);
            if(response != null && response.containsKey('ErrorDescription') == true) {
                response.put('status', 'Error');
                BCB_FlowController.createVerificationRecordForParticipant(applicationParticipantList[0], 'Customer Check', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');           
            }
            return JSON.serialize(response);
        }
        
        return null;
    }
    
/**
* @description This method used for main callout that is createRetailCif API 
* @param applicationRecords
* @param applicationParticipantList
* @param indivudualRecords
* @return Map<String, Object>
*/
public static Map<String, Object> makeCreateRetailCifCallout(List<Application__c> applicationRecords,List<Application_Participant__c> applicationParticipantList,List<Individual> indivudualRecords) {
        
        Application__c applicationRecord = applicationRecords[0];
        Application_Participant__c applicationParticipantRecord  = applicationParticipantList[0];
        Individual individualRecord =  indivudualRecords[0];
        BCB_CreateRetailCifBean createRetailCif = new BCB_CreateRetailCifBean();
        BCB_CreateRetailCifBean.TaxClassification taxClassficationObj = new BCB_CreateRetailCifBean.TaxClassification();        
        BCB_CreateRetailCifBean.ProminentInfluentialPerson prominentInfluentialPersonObj = new BCB_CreateRetailCifBean.ProminentInfluentialPerson();        
        BCB_CreateRetailCifBean.PersonDetails personDetailsObj = new BCB_CreateRetailCifBean.PersonDetails(); 
        BCB_CreateRetailCifBean.OrgDetails orgDetailsObj = new BCB_CreateRetailCifBean.OrgDetails(); 
        BCB_CreateRetailCifBean.EmploymentDetails employementDetailsObj = new BCB_CreateRetailCifBean.EmploymentDetails(); 
        BCB_CreateRetailCifBean.StudentDetails studentDetailsObj = new BCB_CreateRetailCifBean.StudentDetails();
        
        taxClassficationObj.taxType = 'AMT1';
        taxClassficationObj.taxRegion = '001';
        taxClassficationObj.taxGroup = '';
        taxClassficationObj.taxExemptReason = 'Y';
        taxClassficationObj.taxCountry = applicationRecord.Country_of_Tax__c;
        createRetailCif.taxClassification =  taxClassficationObj;
        
        String portFolioNum = applicationRecord.AOB_Preferred_Branch__c;
        createRetailCif.seniorIndicator = System.today().addYears(-60) >= applicationParticipantRecord.AOB_DateofBirth__c ? 'Y' : 'N';
        createRetailCif.segmentCategory = '105';
        createRetailCif.portFolioNum = portFolioNum.right(4);
        createRetailCif.enableCrmAlerts = 'Y';
        createRetailCif.responsibleBranch = applicationRecord.AOB_Preferred_Branch__c != null ?  applicationRecord.AOB_Preferred_Branch__c : '';
        createRetailCif.residenceCountry = applicationRecord.AOB_Country__c;
        createRetailCif.relManagerLink = 'UGUBSADMIN';
        createRetailCif.prefLanguage = 'en';
        
        prominentInfluentialPersonObj.relationType = '';
        prominentInfluentialPersonObj.relatedInd = 'true';
        prominentInfluentialPersonObj.pipInd = 'N';
        prominentInfluentialPersonObj.name = applicationParticipantRecord.CNGCU_First_Name__c;
        
        createRetailCif.prominentInfluentialPerson =  prominentInfluentialPersonObj;
        
        personDetailsObj.title = applicationParticipantRecord.AOB_Title__c.length() == 2 ? '0'+applicationParticipantRecord.AOB_Title__c : applicationParticipantRecord.AOB_Title__c;
        personDetailsObj.studentIndicator = false;
        personDetailsObj.qualification = '';
        personDetailsObj.purgeAllowedIndicator = 'N';
        personDetailsObj.preferredName = applicationParticipantRecord.CNGCU_First_Name__c; 
        personDetailsObj.otherName = applicationParticipantRecord.AOB_Preferred_Name__c != null ? applicationParticipantRecord.AOB_Preferred_Name__c : '';//other name is not captured in the bcb flow so we are passing the preferred name.
        personDetailsObj.nationality = applicationRecord.AOB_Nationality__c;
        personDetailsObj.maritalStatus =maritalStatusNameVsCode.get(applicationParticipantRecord.AOB_MaritalStatus__c); //applicationRecord.AOB_Marital_Status__c != null ? applicationRecord.AOB_Marital_Status__c : '';
        personDetailsObj.maritalPropertyRegime = '';
        personDetailsObj.lastName = applicationParticipantRecord.CNGCU_Last_Name__c;
        personDetailsObj.initials = '';
        personDetailsObj.gender = applicationParticipantRecord.AOB_Gender__c    != null ? applicationParticipantRecord.AOB_Gender__c.substring(0, 1) : '';
        personDetailsObj.foreignNationalStatus = '02';
        personDetailsObj.foreignNationalReport = '01';
        personDetailsObj.foreignNationalIndicator = 'N';
        personDetailsObj.firstName = applicationParticipantRecord.CNGCU_First_Name__c;
        personDetailsObj.ethnicity = '';
        personDetailsObj.dob = Datetime.newInstance(applicationParticipantRecord.AOB_DateofBirth__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        personDetailsObj.digitalBankingIndicator  = '';
        personDetailsObj.dependantsMinor = 0;
        personDetailsObj.dependants = 0;
        personDetailsObj.countryOfBirth = applicationRecord.AOB_Country__c; 
        personDetailsObj.clientType = '';
        personDetailsObj.citizenshipCountry = 'Y';
        personDetailsObj.birthName = '';
        personDetailsObj.assetClassification = '';
        createRetailCif.personDetails = personDetailsObj;
        
        studentDetailsObj.studyYear = '04';
        studentDetailsObj.renewalDate = '';
        studentDetailsObj.Institution = 'ZAF.EC';
        studentDetailsObj.expectedCompletionDate = '';
        studentDetailsObj.enrollmentType = '';
        studentDetailsObj.courseName = '';
        studentDetailsObj.commencedDate = '';
        personDetailsObj.studentDetails = studentDetailsObj;
        
        orgDetailsObj.ownership = '';
        orgDetailsObj.orgEstablishDt = '';
        orgDetailsObj.numEmployees = integer.valueOf(applicationRecord.AOB_Company_employees__c);
        orgDetailsObj.legalName = applicationRecord.AOB_BusinessLegalName__c;//'Testing';
        orgDetailsObj.legalForm = '';
        orgDetailsObj.fiscalYearEnd = '';
        orgDetailsObj.companyName = '';
        createRetailCif.orgDetails = orgDetailsObj;
        
        createRetailCif.mktgSegment = '001';
        createRetailCif.minorIndicator= System.today().addYears(-18) >= applicationParticipantRecord.AOB_DateofBirth__c ? 'N' : 'Y';
        createRetailCif.gIIN = '';
        
        employementDetailsObj.startDate = '';
        employementDetailsObj.staffIndicator = 'N';
        employementDetailsObj.orgName =  applicationRecord.AOB_BusinessLegalName__c != null ? applicationRecord.AOB_BusinessLegalName__c : '';
        employementDetailsObj.occupation = '004';// occupation is not captured as part of the bcb flow, employmenttype is not captured as part of the bcb.
        employementDetailsObj.industrialSector = '';
        employementDetailsObj.endDate = '';
        createRetailCif.employmentDetails = employementDetailsObj;
        
        createRetailCif.EASIndicator = 'RetCustomerAdd';
        createRetailCif.customerType ='010';
        createRetailCif.authorizationGroup = '';
        createRetailCif.accessOwnerSegment = 'Preferential Banking';
        
        BCB_CreateRetailCifBean.TaxDetails taxDetailsObj = new BCB_CreateRetailCifBean.TaxDetails();
        taxDetailsObj.taxType = 'NA';
        taxDetailsObj.taxNumber = '123-56-23';
        taxDetailsObj.provisionalTaxPayerInd ='';
        createRetailCif.taxDetails = new List<BCB_CreateRetailCifBean.TaxDetails>{taxDetailsObj};
            
        BCB_CreateRetailCifBean.SourceOfFunds sourceOfFundsObj = new BCB_CreateRetailCifBean.SourceOfFunds();
        sourceOfFundsObj.tradeFinanceIndicator = 'N';
        sourceOfFundsObj.sourceFundType = 'Income from Own Business';
        sourceOfFundsObj.sourceFundAmount =string.valueOf(applicationRecord.Expected_Annual_Yearly_Turnover_To__c) != null ?string.valueOf(applicationRecord.Expected_Annual_Yearly_Turnover_To__c) : '';
        sourceOfFundsObj.currencyCode =applicationRecord.AOB_Selected_Currency__c;
        createRetailCif.sourceOfFunds = new List<BCB_CreateRetailCifBean.SourceOfFunds>{sourceOfFundsObj};
            
        BCB_CreateRetailCifBean.Permits permitsObj = new BCB_CreateRetailCifBean.Permits();
        permitsObj.permitType = '';
        permitsObj.permitNumber = '';
        permitsObj.expDt ='';
        permitsObj.effDt ='';
        createRetailCif.permits = new List<BCB_CreateRetailCifBean.Permits>{permitsObj};
            
        BCB_CreateRetailCifBean.MktgConsents mktgConsentsObj1 = new BCB_CreateRetailCifBean.MktgConsents();
        mktgConsentsObj1.consentStatus = individualRecord.AOB_Personal_Information_Consent__c;
        mktgConsentsObj1.consentCode = 'SAF';
        BCB_CreateRetailCifBean.MktgConsents mktgConsentsObj2 = new BCB_CreateRetailCifBean.MktgConsents();
        mktgConsentsObj2.consentStatus = individualRecord.AOB_Market_Your_Product_Consent__c;
        mktgConsentsObj2.consentCode = 'SAF';
        BCB_CreateRetailCifBean.MktgConsents mktgConsentsObj3 = new BCB_CreateRetailCifBean.MktgConsents();
        mktgConsentsObj3.consentStatus = individualRecord.AOB_Research_Consent__c;
        mktgConsentsObj3.consentCode = 'SAF';
        BCB_CreateRetailCifBean.MktgConsents mktgConsentsObj4 = new BCB_CreateRetailCifBean.MktgConsents();
        mktgConsentsObj4.consentStatus = individualRecord.AOB_Services_Special_Offers_Consent__c;
        mktgConsentsObj4.consentCode = 'SAF';
        createRetailCif.mktgConsents = new List<BCB_CreateRetailCifBean.MktgConsents>{mktgConsentsObj1,mktgConsentsObj2,mktgConsentsObj3,mktgConsentsObj4};
            
        BCB_CreateRetailCifBean.Misc miscObj = new BCB_CreateRetailCifBean.Misc();
        miscObj.value = 'FATCA_DETAILS';
        miscObj.miscDate = '';
        miscObj.key = 'Type';
        miscObj.distributionChannel = 'B';
        miscObj.counterPartyInfo = '011';
        createRetailCif.misc = new List<BCB_CreateRetailCifBean.Misc>{miscObj};
            
        BCB_CreateRetailCifBean.IndustrialSectors industrialSectorsObj = new BCB_CreateRetailCifBean.IndustrialSectors();
        industrialSectorsObj.industrialClassificationSystem = 'S960';
        industrialSectorsObj.industrialSector = 'S96';
        createRetailCif.industrialSectors = new List<BCB_CreateRetailCifBean.IndustrialSectors>{industrialSectorsObj};
            
        BCB_CreateRetailCifBean.Identification identificationObj = new BCB_CreateRetailCifBean.Identification();
        identificationObj.PreferredIdentificationIndicator = 'N';
        identificationObj.issuingCountry = applicationRecord.AOB_Country__c;
        identificationObj.issuedOrganisation = '021';
        identificationObj.issuedDate = '2022-05-04T00:00:00.000';
        identificationObj.identificationType = 'IDTypeR35';
        identificationObj.identificationNumber = applicationParticipantRecord.AOB_IDNumber__c;
        identificationObj.expirationDate = applicationParticipantRecord.AOB_National_ID_expiry_date__c != null ? string.valueOf(applicationParticipantRecord.AOB_National_ID_expiry_date__c) : '9999-12-31T00:00:00.000'; 
        identificationObj.documentTypeDescription = 'Identification Proof Individual';
        identificationObj.documentTypeCode = 'DT000';
        identificationObj.documentDescription = 'NATIONAL IDENTITY CARD';
        identificationObj.documentCode = 'D0021';
        createRetailCif.identification = new List<BCB_CreateRetailCifBean.Identification>{identificationObj};
            
        BCB_CreateRetailCifBean.CustomerRoles customerRolesObj = new BCB_CreateRetailCifBean.CustomerRoles();
        customerRolesObj.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 
        customerRolesObj.role = '';
        customerRolesObj.endDate = '';
        createRetailCif.customerRoles = new List<BCB_CreateRetailCifBean.CustomerRoles>{customerRolesObj};
            
        BCB_CreateRetailCifBean.Contacts contactObj1 = new BCB_CreateRetailCifBean.Contacts();
        contactObj1.value =  '256'+applicationRecord.AOB_Phone__c.replaceFirst('^0+', '');
        contactObj1.startDate = null; 
        contactObj1.preferredInd = 'Y';
        contactObj1.preferredFormat =null;
        contactObj1.phoneType = 'PHONE';
        contactObj1.obsoleteInd  = null;
        contactObj1.localCode =  applicationRecord.AOB_Phone__c.replaceFirst('^0+', '');
        contactObj1.extension = null;
        contactObj1.endDate = null;
        contactObj1.countryCode = '256';
        contactObj1.contactType = 'CELLPH';//not captured as part of bcb project flow.
        contactObj1.contactPeriod = null;
        contactObj1.cityCode = '0';
        
        BCB_CreateRetailCifBean.Contacts contactObj2 = new BCB_CreateRetailCifBean.Contacts();
        contactObj2.value = applicationParticipantRecord.CNGCU_Email__c;   
        contactObj2.startDate = null;
        contactObj2.preferredInd = 'Y';
        contactObj2.preferredFormat =null;
        contactObj2.phoneType = 'EMAIL';
        contactObj2.obsoleteInd  = null;
        contactObj2.extension = null;
        contactObj2.endDate = null;
        contactObj2.countryCode = '';
        contactObj2.contactType = 'COMMEML'; //not captured as part of bcb project flow.
        contactObj2.contactPeriod = null;
        contactObj2.cityCode = '';
        
        createRetailCif.contacts = new List<BCB_CreateRetailCifBean.Contacts>{contactObj1};
        if(String.isNotBlank(applicationParticipantRecord.CNGCU_Email__c)){
            createRetailCif.contacts.add(contactObj2);
        }
            
        BCB_CreateRetailCifBean.complianceRoles complianceRolesObj = new BCB_CreateRetailCifBean.complianceRoles();
        complianceRolesObj.verifiedBy = '';
        complianceRolesObj.statusReason = '';
        complianceRolesObj.compRole = '';
        complianceRolesObj.complianceStatus = 'Y';
        complianceRolesObj.complianceGrade = 'MEDIUM';
        createRetailCif.complianceRoles = new List<BCB_CreateRetailCifBean.ComplianceRoles>{complianceRolesObj};
            
        BCB_CreateRetailCifBean.AddressTypes addressTypeObj1 = new BCB_CreateRetailCifBean.AddressTypes('Home');
        
        BCB_CreateRetailCifBean.AddressTypes addressTypeObj2 = new BCB_CreateRetailCifBean.AddressTypes('Mailing');
        
        BCB_CreateRetailCifBean.Addresses addressObj1 = new BCB_CreateRetailCifBean.Addresses();
        addressObj1.uuid = '';
        addressObj1.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 

        string inflight =applicationRecord.AOB_inflightData__c;
        Map<String, Object> inflightmap  = new Map<String, Object>();
		if(!String.isEmpty(inflight)){  
            inflightmap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
        }   
        addressObj1.province = applicationRecord.AOB_State__c;  //((String)inflightmap.get('State'));
        addressObj1.preferredInd = 'Y';
        addressObj1.preferredFormat = 'FREE_TEXT_FORMAT';
        addressObj1.postalCode = '256';
        addressObj1.line1 = applicationRecord.AOB_Street__c != null ?  applicationRecord.AOB_Street__c : ''; //line2,line3 is not captured as part of bcb flow
        addressObj1.line2 = applicationRecord.AOB_City__c != null ?  applicationRecord.AOB_City__c : '';
        addressObj1.countryCode = applicationRecord.AOB_Country__c != null ? applicationRecord.AOB_Country__c : '';
        addressObj1.comment= 'Home';
        addressObj1.city = applicationRecord.AOB_City__c != null ? applicationRecord.AOB_City__c : '';
        addressObj1.addressTypes = new List<BCB_CreateRetailCifBean.AddressTypes>{addressTypeObj1};
            
            BCB_CreateRetailCifBean.Addresses addressObj2 = new BCB_CreateRetailCifBean.Addresses();
        addressObj2.uuid = '';
        addressObj2.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 
        addressObj2.province = applicationRecord.AOB_State__c;//((String)inflightmap.get('State'));
        addressObj2.preferredInd = 'N';
        addressObj2.preferredFormat = 'FREE_TEXT_FORMAT';
        addressObj2.postalCode =  '256';
        addressObj2.line1 =  applicationRecord.AOB_Street__c != null ?  applicationRecord.AOB_Street__c :  applicationRecord.AOB_Street__c;
        addressObj2.line2 = applicationRecord.AOB_City__c != null ?  applicationRecord.AOB_City__c : '';
        addressObj2.countryCode = applicationRecord.AOB_Country__c != null ? applicationRecord.AOB_Country__c : applicationRecord.AOB_Country__c;
        addressObj2.comment= 'Mailing';
        addressObj2.city = applicationRecord.AOB_City__c != null ? applicationRecord.AOB_City__c : applicationRecord.AOB_City__c;
        addressObj2.addressTypes = new List<BCB_CreateRetailCifBean.AddressTypes>{addressTypeObj2};
            
        createRetailCif.addresses = new List<BCB_CreateRetailCifBean.Addresses>{addressObj1,addressObj2};
                
                
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        
        //Prepare Request
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_FlowController.createGUID();
        
        string accessToken = CMN_SRV_GetAccessToken.getAccessToken();
        
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        
        if(String.isNotBlank(accessToken) == true && accessToken != null) {
            
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, accessToken);
            
            //Set HTTP Request Headers
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            
            //Set Request Details
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
            httpRequest.setBody(JSON.serialize(createRetailCif));
          
            httpRequest.setTimeout(120000);
            
            //Make HTTP Request
            responseToReturnObject =  prepareRequestMethod(applicationRecord,httpRequest,applicationParticipantRecord);
        } else {
            LOGGER.error('CMN_CreateRetailCif.makeCreateRetailCifCallout:Access Token Failure', new String[] {'CMN_CreateRetailCif.makeCreateRetailCifCallout', applicationParticipantRecord.Id});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        return responseToReturnObject;
    }
/** 
* @description This method used for main callout that is createCorporateCif API 
* @param applicationRecord
* @param httpRequest
* @param applicationParticipantRecord
* @return  responseToReturnObject
*/ 
    private static Map<String, Object> prepareRequestMethod(Application__c applicationRecord, HttpRequest httpRequest,Application_Participant__c applicationParticipantRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();
            sendMockResponseStatus();
            httpResponse = http.Send(httpRequest);
            responseToReturnObject = sendResponse(httpResponse,applicationRecord,applicationParticipantRecord);    
        } catch (Exception ex) {
            LOGGER.error('CMN_CreateRetailCif.makeCreateRetailCifCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_CreateRetailCif.makeCreateRetailCifCallout', applicationParticipantRecord.Id,JSON.serialize( ex.getMessage())});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                }
        
        return responseToReturnObject;
    }
/** 
* @description This method used for main callout that is createCorporateCif API 
*/
    private static void sendMockResponseStatus(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            }
        }
    }
    
/** 
* @description This method used for main callout that is createCorporateCif API 
* @param httpResponse
* @param applicationRecord
* @param applicationParticipantRecord
* @return  responseToReturnObject
*/
    private static map<string,object> sendResponse(HttpResponse httpResponse,Application__c applicationRecord,Application_Participant__c applicationParticipantRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = httpResponse.getBody();
            responseToReturnObject = sendApiResonse(responseBody,applicationRecord,applicationParticipantRecord);     
        } else {
            responseToReturnObject =  noServerResponse(httpResponse,applicationRecord,applicationParticipantRecord);
        }
        return responseToReturnObject;
    }
/** 
* @description This method used for main callout that is createCorporateCif API 
* @param responseBody
* @param applicationRecord
* @param applicationParticipantRecord
* @return  responseToReturnObject
*/ 
    
    private static Map<string,Object> sendApiResonse(string responseBody,Application__c applicationRecord,Application_Participant__c applicationParticipantRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (responseBody != null) {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
            LOGGER.error('CMN_CreateRetailCif.makeCreateRetailCifCallout: No response body', new String[] {'CMN_CreateRetailCif.makeCreateRetailCifCallout', applicationParticipantRecord.Id});
        }
        return responseToReturnObject;
    }
/** 
* @description This method used for main callout that is createCorporateCif API 
* @param httpResponse
* @param applicationRecord
* @param applicationParticipantRecord
* @return  responseToReturnObject
*/

    private static map<string,object>  noServerResponse(HttpResponse httpResponse, Application__c applicationRecord,Application_Participant__c applicationParticipantRecord){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        String errorMessage = 'No Response From Server';
        if(httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
            LOGGER.error('CMN_CreateRetailCif.makeCreateRetailCifCallout: Need moreInformation', new String[] {'CMN_CreateRetailCif.makeCreateRetailCifCallout', applicationParticipantRecord.Id, JSON.serialize(responseObject)});
        }
        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            LOGGER.error('CMN_CreateRetailCif.makeCreateRetailCifCallout:Response status:FAILED', new String[] {'CMN_CreateRetailCif.makeCreateRetailCifCallout', applicationParticipantRecord.Id, JSON.serialize(responseToReturnObject)});
        return responseToReturnObject;
    }
}