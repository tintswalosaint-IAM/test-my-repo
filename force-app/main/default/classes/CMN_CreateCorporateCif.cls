/***************************************************************************************
@Name of the Class : CMN_CreateCorporateCif
@description       : CreateCorporateCif will be called based on the customer have the cifid.
@Author            : Lokesh Bothsa(lokesh.bothsa@standardbank.co.za) 
@Date              : June 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 03-04-2024
@Modification Description : SFP-37302
***************************************************************************************/
public class CMN_CreateCorporateCif {
    //HTTP Constants
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String CIF_COUNTRY = 'cifCountry';
    private static final String CUSTOMER_TYPE = 'customerType';
    private static final String CIF_COUNTRY_CODE  = 'UG';
    private static final String CUSTOMER_TYPE_CODE = 'corporate';
    
    
    //Generic Constants
    private static final String PARAM_COLON = ':';
    //API specific
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/external-partners/customers';    
    //used for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';  
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_CreateCorporateCif');
    
    
    /** 
* @description This method used for main callout createCorporateCif
* @param applicationList
* @param applicationParticipantList
* @return Returns a callout response in stringified format to process in the UI
*/
    public static String invocableMethod(List<Application__c> applicationList,List<Application_Participant__c> applicationParticipantList)  {
        
        if(applicationList != null && applicationList.isEmpty() == false) {
            
            Map<String, Object> response =  makeCreateCorporateCifCallout(applicationList,applicationParticipantList);
            
            if(response != null && response.containsKey('ErrorDescription') == true) {
                response.put('status', 'Error');
                BCB_FlowController.createVerificationRecord(applicationList[0], 'Customer Check', 'Failed');
                BCB_FlowController.assignLeadToQueue(applicationList[0].AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');
            }
            return JSON.serialize(response);
        }
        
        return null;
    }
    /** 
* @description This method used for main callout that is createCorporateCif API 
* @param applicationRecords
* @param applicationParticipantList
* @return  responseToReturnObject
*/
    public static Map<String, Object> makeCreateCorporateCifCallout(List<Application__c> applicationRecords,List<Application_Participant__c> applicationParticipantList) {
        
        Application__c applicationRecord = applicationRecords[0];
        Application_Participant__c applicationParticipant = applicationParticipantList[0];
        BCB_CreateCorporateCifBean createCorporateCif = new BCB_CreateCorporateCifBean();
        BCB_CreateCorporateCifBean.ProminentInfluentialPerson prominentInfluentialPersonObj = new BCB_CreateCorporateCifBean.ProminentInfluentialPerson();        
        BCB_CreateCorporateCifBean.OrgDetails orgDetailsObj = new BCB_CreateCorporateCifBean.OrgDetails(); 
        
        BCB_CreateCorporateCifBean.RoutingInformation routinginfoobj  = new BCB_CreateCorporateCifBean.RoutingInformation();
        routinginfoobj.cifCountry = 'Uganda';
        routinginfoobj.systemIdentificationNumber = '365';
        routinginfoobj.applicationIdentificationNumber = '365';
        createCorporateCif.routingInformation =  new List<BCB_CreateCorporateCifBean.RoutingInformation> {routinginfoobj};
            
        String portFolioNum = applicationRecord.AOB_Preferred_Branch__c;
        createCorporateCif.depositAccountIndicator = 'Y';
        createCorporateCif.seniorIndicator = System.today().addYears(-60) >= applicationParticipant.AOB_DateofBirth__c ? 'Y' : 'N';
        createCorporateCif.segmentCategory = '105';
        createCorporateCif.responsibleBranch = applicationRecord.AOB_Preferred_Branch__c != null ?  applicationRecord.AOB_Preferred_Branch__c : '';
        createCorporateCif.residenceCountry =  applicationRecord.AOB_Country__c;
        createCorporateCif.relManagerLink = 'UGUBSADMIN';
        createCorporateCif.prefLanguage = 'EN';
        createCorporateCif.taxIdentificationNumber =applicationRecord.Tax_Identification_Number__c;
        createCorporateCif.businessRegistrationNumber = applicationRecord.AOB_RegistrationNumber__c;
        createCorporateCif.portFolioNum = portFolioNum.right(4);
        
        prominentInfluentialPersonObj.relationType = '';
        prominentInfluentialPersonObj.relatedInd = 'true';
        prominentInfluentialPersonObj.pipInd = 'false';
        prominentInfluentialPersonObj.name = applicationParticipant.CNGCU_First_Name__c;
        createCorporateCif.prominentInfluentialPerson =  prominentInfluentialPersonObj;
        
        orgDetailsObj.ownership = '';
        orgDetailsObj.orgEstablishDt = Datetime.newInstance(applicationRecord.AOB_DateofRegistration__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
        orgDetailsObj.numEmployees = string.valueOf(applicationRecord.AOB_Company_employees__c);
        orgDetailsObj.legalName = applicationRecord.AOB_BusinessLegalName__c;
        orgDetailsObj.legalForm = '012';
        orgDetailsObj.companyName = applicationRecord.AOB_BusinessLegalName__c;
        orgDetailsObj.description = 'Corporate account creation';
        orgDetailsObj.turnover = string.valueOf(applicationRecord.Expected_Annual_Yearly_Turnover_To__c);
        createCorporateCif.orgDetails = orgDetailsObj;
        
        createCorporateCif.mktgSegment = '001';
        createCorporateCif.minorIndicator= System.today().addYears(-18) >= applicationParticipant.AOB_DateofBirth__c ? 'N' : 'Y';
        
        createCorporateCif.EASIndicator = 'EASCustomerAdd';
        createCorporateCif.customerType ='INDIVIDUAL';
        createCorporateCif.authorizationGroup = '';
        createCorporateCif.accessOwnerSegment = 'Preferential Banking';
        
        BCB_CreateCorporateCifBean.sourceOfFunds sourceOfFundsObj = new BCB_CreateCorporateCifBean.sourceOfFunds();
        sourceOfFundsObj.tradeFinanceIndicator = 'Y';
        sourceOfFundsObj.sourceFundType = 'Income from Own Business';
        sourceOfFundsObj.sourceFundAmount = string.valueOf(applicationRecord.Expected_Annual_Yearly_Turnover_To__c) != null ?string.valueOf(applicationRecord.Expected_Annual_Yearly_Turnover_To__c) : '';
        sourceOfFundsObj.currencyCode =applicationRecord.AOB_Selected_Currency__c;
        createCorporateCif.sourceOfFunds = new List<BCB_CreateCorporateCifBean.sourceOfFunds>{sourceOfFundsObj};
            
        BCB_CreateCorporateCifBean.relatedParties relatedPartiesObj = new BCB_CreateCorporateCifBean.relatedParties();
        relatedPartiesObj.partyId =applicationParticipant.AOB_CIFID__c;
        relatedPartiesObj.relatedTitle = 'Contact';
        relatedPartiesObj.signatoryIndicator = 'Y';
        relatedPartiesObj.lastName =applicationParticipant.CNGCU_Last_Name__c;
        relatedPartiesObj.firstName =applicationParticipant.CNGCU_First_Name__c;
        createCorporateCif.relatedParties = new List<BCB_CreateCorporateCifBean.RelatedParties>{relatedPartiesObj};
            
        BCB_CreateCorporateCifBean.mktgConsents mktgConsentsObj = new BCB_CreateCorporateCifBean.mktgConsents();
        mktgConsentsObj.consentStatus = string.valueOf(true);
        mktgConsentsObj.consentCode = '7';
        createCorporateCif.mktgConsents = new List<BCB_CreateCorporateCifBean.MktgConsents>{mktgConsentsObj};
            
        BCB_CreateCorporateCifBean.misc miscObj = new BCB_CreateCorporateCifBean.misc();
        miscObj.value = 'FATCA_DETAILS';
        miscObj.miscDate = '';
        miscObj.key = 'Type';
        miscObj.distributionChannel = 'B';
        miscObj.counterPartyInfo = '011';
        createCorporateCif.misc = new List<BCB_CreateCorporateCifBean.Misc>{miscObj};

        string inflight =applicationRecord.AOB_inflightData__c;
        Map<String, Object> inflightmap  = new Map<String, Object>();
		if(!String.isEmpty(inflight)){  
            inflightmap = (Map<String, Object>)system.JSON.deserializeUntyped(inflight);
        }      
        BCB_CreateCorporateCifBean.IndustrialSectors industrialSectorsObj = new BCB_CreateCorporateCifBean.IndustrialSectors();
        industrialSectorsObj.industrialClassificationSystem = ((String)inflightmap.get('secondarySectorCode'));
        industrialSectorsObj.industrialSector = ((String)inflightmap.get('industrialSector'));
        createCorporateCif.industrialSectors = new List<BCB_CreateCorporateCifBean.IndustrialSectors>{industrialSectorsObj};
          
       

        BCB_CreateCorporateCifBean.finacleSectors financialObj = new BCB_CreateCorporateCifBean.finacleSectors();
        financialObj.tertiaryClassificationCode = (string)inflightmap.get('tertiorySectorCode');
        financialObj.primaryClassificationCode = (string)inflightmap.get('primarySectorCode');
        financialObj.secondaryClassificationCode = (string)inflightmap.get('secondarySectorCode');
        createCorporateCif.finacleSectors = new List<BCB_CreateCorporateCifBean.finacleSectors>{financialObj};

        BCB_CreateCorporateCifBean.Identification identificationObj = new BCB_CreateCorporateCifBean.Identification();
        identificationObj.PreferredIdentificationIndicator = 'Y';
        identificationObj.issuingCountry = applicationRecord.AOB_Country__c;
        identificationObj.issuedOrganisation = '021';
        identificationObj.issuedDate = '2022-05-04T00:00:00.000';
        identificationObj.identificationType = 'IDTypeR35';
        identificationObj.identificationNumber = applicationParticipant.AOB_IDNumber__c;
        identificationObj.expirationDate = '9999-12-31T00:00:00.000Z';
        identificationObj.documentTypeDescription = 'Identification Proof Individual';
        identificationObj.documentTypeCode = 'DT000';
        identificationObj.documentDescription = 'NATIONAL IDENTITY CARD';
        identificationObj.documentCode = 'D0021';
        createCorporateCif.identification = new List<BCB_CreateCorporateCifBean.Identification>{identificationObj};
            
        BCB_CreateCorporateCifBean.Contacts contactObj1 = new BCB_CreateCorporateCifBean.Contacts();
        contactObj1.value = applicationRecord.CNGCU_CSEmail__c; 
        contactObj1.preferredInd = 'Y';
        contactObj1.contactType = 'COMMEML';
        contactObj1.countryCode = applicationRecord.AOB_Country__c;
        
        BCB_CreateCorporateCifBean.Contacts contactObj2 = new BCB_CreateCorporateCifBean.Contacts();
        contactObj2.value = '+256(000)'+applicationRecord.AOB_Phone__c.replaceFirst('^0', '');
        contactObj2.preferredInd = 'Y';
        contactObj2.phoneType = 'PHONE';
        contactObj2.localCode = applicationRecord.AOB_Phone__c.replaceFirst('^0+', '');
        contactObj2.countryCode = '256';
        contactObj2.cityCode = '000';
        contactObj2.contactType = 'CELLPH';
        createCorporateCif.contacts = new List<BCB_CreateCorporateCifBean.Contacts>{};
        createCorporateCif.contacts.add(contactObj2);
        if(String.isNotBlank(applicationRecord.CNGCU_CSEmail__c)){
            createCorporateCif.contacts.add(contactObj1);
        }
            
        BCB_CreateCorporateCifBean.AddressTypes addressTypeObj1 = new BCB_CreateCorporateCifBean.AddressTypes('Home');
        
        BCB_CreateCorporateCifBean.AddressTypes addressTypeObj2 = new BCB_CreateCorporateCifBean.AddressTypes('Mailing');
        
        BCB_CreateCorporateCifBean.Addresses addressObj1 = new BCB_CreateCorporateCifBean.Addresses();
        addressObj1.uuid = '';
        addressObj1.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 
        addressObj1.province = applicationRecord.AOB_State__c;
        addressObj1.preferredInd = 'Y';
        addressObj1.postalCode = '256'; 
        addressObj1.line1 =applicationRecord.AOB_Street__c != null ?  applicationRecord.AOB_Street__c :  'lajdafisnofewiz';
        addressObj1.line2 = applicationRecord.AOB_City__c != null ? applicationRecord.AOB_City__c : 'ABIM';
        addressObj1.countryCode = applicationRecord.AOB_Country__c != null ? applicationRecord.AOB_Country__c : 'UG';
        addressObj1.plotNumber = '';
        addressObj1.city =applicationRecord.AOB_City__c != null ? applicationRecord.AOB_City__c : 'ABIM';
        addressObj1.addressTypes = new List<BCB_CreateCorporateCifBean.AddressTypes>{addressTypeObj1};
            
        BCB_CreateCorporateCifBean.Addresses addressObj2 = new BCB_CreateCorporateCifBean.Addresses();
        addressObj2.uuid = '';
        addressObj2.startDate = Datetime.newInstance(System.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'); 
        addressObj2.province = applicationRecord.AOB_State__c;
        addressObj2.preferredInd = 'N';
        addressObj2.postalCode = '256';
        addressObj2.line1 = applicationRecord.AOB_Street__c != null ?  applicationRecord.AOB_Street__c :  'lajdafisnofewiz';
        addressObj2.line2 = applicationRecord.AOB_City__c != null ? applicationRecord.AOB_City__c : 'ABIM';
        addressObj2.countryCode = applicationRecord.AOB_Country__c != null ? applicationRecord.AOB_Country__c : 'UG';
        addressObj2.city = applicationRecord.AOB_City__c != null ? applicationRecord.AOB_City__c : 'ABIM';
        addressObj2.plotNumber = '';
        addressObj2.addressTypes = new List<BCB_CreateCorporateCifBean.AddressTypes>{addressTypeObj2};
            
        createCorporateCif.addresses = new List<BCB_CreateCorporateCifBean.Addresses>{AddressObj1,AddressObj2};
                
                
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
            httpRequest.setHeader(CIF_COUNTRY, CIF_COUNTRY_CODE);
            httpRequest.setHeader(CUSTOMER_TYPE,CUSTOMER_TYPE_CODE);
            
            //Set Request Details
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
           
            httpRequest.setBody(JSON.serialize(createCorporateCif));
            httpRequest.setTimeout(120000);
            
            //Make HTTP Request
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                sendMockResponse();
                
                httpResponse = http.Send(httpRequest);
                
                responseToReturnObject =  sendResponse(httpResponse,applicationRecord,applicationParticipant);
                
            } catch (Exception ex) {
                LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout:Some Un-Handled Exception Occurred', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id,JSON.serialize( ex.getMessage())});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout:Access Token Failure', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id});
            
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        return responseToReturnObject;
    }
    private static void sendMockResponse(){
        if (System.Test.isRunningTest()) {
            if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
            } 
        }
    }
    private static map<string,object> sendResponse(HttpResponse httpResponse,Application__c applicationRecord, Application_Participant__c applicationParticipant ){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = httpResponse.getBody();
            responseToReturnObject = sendResponseBody(responseBody,applicationRecord,applicationParticipant);
            
        } else {
       
            responseToReturnObject =  sendNoResponseFromServer(httpResponse,applicationRecord,applicationParticipant
                                                              );
            LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout:No Response From Server', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});
            
        }
        return responseToReturnObject;
    }
    private static map<string,Object> sendResponseBody(string responseBody,Application__c applicationRecord,Application_Participant__c applicationParticipant){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if (responseBody != null) {
            responseToReturnObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout: Status : SUCCESS', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id});
            
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout: No response body', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id});
        }
        return responseToReturnObject;
    }
    private static map<string,object> sendNoResponseFromServer(HttpResponse httpResponse,Application__c applicationRecord,Application_Participant__c applicationParticipant){
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        String errorMessage;
        if(httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
            LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout: Need More Information', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});
            
        }
        
        responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
            LOGGER.error('CMN_CreateCorporateCif.makeCreateCorporateCifCallout:Response status:FAILED', new String[] {'CMN_CreateCorporateCif.makeCreateCorporateCifCallout', applicationParticipant.Id, JSON.serialize(responseToReturnObject)});
        return responseToReturnObject;
    }
    
}