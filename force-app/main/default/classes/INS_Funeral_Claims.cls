/**
 * @description  Sends a POST request to the INS_Funeral_Claims API endpoint with the provided Request.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date Nov 8th 2023
 */
public class INS_Funeral_Claims {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Funeral_Claims');
    private static Map<String, Generic_Config__mdt> configMap = Generic_Config__mdt.getAll();
    private static final String REQUEST_DLB = configMap.get('FuneralClaims_Dlb').Value__c;
    private static final String REQUEST_ENV = configMap.get('FuneralClaims_ENV').Value__c;
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CONTENT_TYPE_VALUE = 'application/x-www-form-urlencoded';
    private static final String HEADER_CLIENT_COUNTRY = 'countryCode';
    private static final String CLIENT_COUNTRY_SA = 'SA';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String HEADER_TRANSACTION_ID = 'transaction_id';
    /**
 * @description class  BaseException implements Exception class
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 08th 2023
 */
    public virtual class BaseException extends Exception {}
    /**
 * @description class  CustomException implements BaseException class
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 08th 2023
 */
    public class CustomException extends BaseException {}
    /**
     * @description Obtains the Request  for API.
     *
     * @return.
     */
    public class Request {
        @InvocableVariable(label='contractNumber' description='Policy number or contractNumber of the policy holder' required=true)
        public String contractNumber;
        @InvocableVariable(label='fullName' description='Claimant fullName' required=true)
        public String fullName;
        @InvocableVariable(label='salutation' description='Claimant salutation')
        public String salutation;
        @InvocableVariable(label='idNumber' description='Claimant idNumber' required=true)
        public String idNumber;
        @InvocableVariable(label='relation' description='Claimant relation' required=true)
        public String relation;
        @InvocableVariable(label='emailAddress' description='Claimant emailAddress' required=true)
        public String emailAddress;
        @InvocableVariable(label='phoneNo' description='Claimant phoneNo' required=true)
        public String phoneNo;
        @InvocableVariable(label='street' description='Claimant street')
        public String street;
        @InvocableVariable(label='city' description='Claimant city')
        public String city;
        @InvocableVariable(label='state' description='Claimant state')
        public String state;
        @InvocableVariable(label='postalCode' description='Claimant postalCode')
        public String postalCode;
        @InvocableVariable(label='country' description='Claimant country')
        public String country;
        @InvocableVariable(label='ID_NUMBER_2' description='Deceased ID_NUMBER_2')
        public String ID_NUMBER_2;
        @InvocableVariable(label='FirstName' description='Deceased FirstName')
        public String FirstName;
        @InvocableVariable(label='LastName' description='Deceased LastName')
        public String LastName;
        @InvocableVariable(label='deathTime' description='Deceased deathTime')
        public Datetime deathTime;
        @InvocableVariable(label='title' description='Deceased title')
        public String title;
        @InvocableVariable(label='birthDate' description='Deceased birthDate')
        public String birthDate;
        @InvocableVariable(label='deathCause' description='Deceased deathCause')
        public String deathCause;
        @InvocableVariable(label='deathType' description='Deceased deathType')
        public String deathType;
        @InvocableVariable(label='deathDate' description='Deceased deathDate')
        public String deathDate;
        @InvocableVariable(label='gender' description='Deceased gender')
        public String gender;
        @InvocableVariable(label='headerCountry' description='Passing Country through header')
        public String headerCountry;
        @InvocableVariable(label='affectedLifeAssured' description='affected LifeAssured ID')
        public String affectedLifeAssuredId;
        @InvocableVariable(label='affectedLifeAssuredbirthdate' description='affected LifeAssured birthdate')
        public Date affectedLifeAssuredbirthdate;
        
    }
    /**
     * @description Obtains the Response  from API Response.
     *
     * @return Boolean,String,String,String,String representing the Response class.
     */
    public class Response{
        @InvocableVariable
        public Boolean isSuccess;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String claimEventNumber;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String responseCode;
        
    }
    /**
     * @description Invocable method to execute  for the provided requestDetails.
     *
     * @param requestDetails
     * @return List<Response>.
     */
    @InvocableMethod( Label = 'funeralclaims' Description = 'funeral claims Registartion API Call' )
    public static List<Response> execute(List <Request> requestDetails) {
        try {
            List<Response> responseList = new List<Response> ();
            Request req = requestDetails[0];
             /*** New Request Wrapper starts***/ 
            FuneralClaimRequestWrapper_New newWrap = new FuneralClaimRequestWrapper_New ();
            FuneralClaimRequestWrapper_New.FuneralFNOLRequest  fnolReq =  new FuneralClaimRequestWrapper_New.FuneralFNOLRequest ();
            //ClaimDisclosure start
            FuneralClaimRequestWrapper_New.ClaimDisclosure claimDisclosure = new FuneralClaimRequestWrapper_New.ClaimDisclosure ();
            claimDisclosure.Channel = 'Branch';
            claimDisclosure.Proceed = true;
            claimDisclosure.CreatedBy = UserInfo.getName();
            fnolReq.ClaimDisclosure = claimDisclosure;
            
            //ClaimIdentification starts
            List<FuneralClaimRequestWrapper_New.ClaimIdentification> claimIdentificationList = new List<FuneralClaimRequestWrapper_New.ClaimIdentification> ();
          
            fnolReq.ClaimIdentification = claimIdentificationList;
            //PartyUniqueIdentification start
            FuneralClaimRequestWrapper_New.PartyUniqueIdentification partyUniqueIdentification = new FuneralClaimRequestWrapper_New.PartyUniqueIdentification ();
            partyUniqueIdentification.PartyIdentificationType = 'ID Number';
            partyUniqueIdentification.PartyIdentifierValue = req.ID_NUMBER_2;            
            fnolReq.PartyUniqueIdentification = partyUniqueIdentification;
            
            //DirectoryEntryDateTime start
            List<FuneralClaimRequestWrapper_New.DirectoryEntryDateTime> directoryEntryDateTimeList= new List<FuneralClaimRequestWrapper_New.DirectoryEntryDateTime> ();
            FuneralClaimRequestWrapper_New.DirectoryEntryDateTime directoryEntryDateTime = new FuneralClaimRequestWrapper_New.DirectoryEntryDateTime ();
            directoryEntryDateTime.DirectoryEntryDateType = 'Death Notification Date';
            directoryEntryDateTime.DirectoryEntryDateTime = String.valueOF(req.deathTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss'));
            directoryEntryDateTimeList.add(directoryEntryDateTime);
            
            fnolReq.DirectoryEntryDateTime = directoryEntryDateTimeList;
            FuneralClaimRequestWrapper_New.Reference reference = new FuneralClaimRequestWrapper_New.Reference ();
            reference.PartyType = 'Person';
            reference.Salutation = req.title == null ?' ' : req.title ;
            
            //PartyName start
            List<FuneralClaimRequestWrapper_New.PartyName> partyNameList_New = new List<FuneralClaimRequestWrapper_New.PartyName> ();
            FuneralClaimRequestWrapper_New.PartyName partyName1_New = new FuneralClaimRequestWrapper_New.PartyName ();
            partyName1_New.PartyNameType = 'Surname';
            partyName1_New.PartyNameValue = req.LastName;
            FuneralClaimRequestWrapper_New.PartyName partyName2_New = new FuneralClaimRequestWrapper_New.PartyName ();
            partyName2_New.PartyNameType = 'First Name';
            partyName2_New.PartyNameValue = req.FirstName;
            partyNameList_New.add(partyName1_New);
            partyNameList_New.add(partyName2_New);
            reference.PartyName = partyNameList_New;
            fnolReq.Reference = reference;
            
            FuneralClaimRequestWrapper_New.PersonReference personReference = new FuneralClaimRequestWrapper_New.PersonReference ();
            personReference.BirthDate = formatDate(String.valueOF(req.affectedLifeAssuredbirthdate.year()),String.valueOf(req.affectedLifeAssuredbirthdate.month()),String.valueOf(req.affectedLifeAssuredbirthdate.day()));            
            personReference.DeathCauseType = req.deathCause;
            personReference.DeathCircumstanceType = req.deathType;
            personReference.DeathDate = req.deathDate;
            personReference.Gender = req.gender=='1'?'Male':req.gender=='2'?'Female':'Undefined';
            fnolReq.PersonReference = personReference;
          
            FuneralClaimRequestWrapper_New.PartyRelationship partyRelationShip = new FuneralClaimRequestWrapper_New.PartyRelationship ();
            partyRelationShip.PartyRelationshipType = req.relation;
            
            FuneralClaimRequestWrapper_New.RelatedPartyIdentification relatedPartyIdentification =  new FuneralClaimRequestWrapper_New.RelatedPartyIdentification ();
            relatedPartyIdentification.PartyIdentificationType = 'ID Number';
            relatedPartyIdentification.PartyIdentifierValue = req.idNumber;
            
			FuneralClaimRequestWrapper_New.RelatedPartyReference relatedPartyReference = new FuneralClaimRequestWrapper_New.RelatedPartyReference();
            relatedPartyReference.PartyType = 'Person';
            relatedPartyReference.Salutation = req.salutation == null ?' ' : req.salutation ;
            
            //PartyName Start
            List<FuneralClaimRequestWrapper_New.PartyName> partyNameList = new List<FuneralClaimRequestWrapper_New.PartyName> ();
            FuneralClaimRequestWrapper_New.PartyName partyName1 = new FuneralClaimRequestWrapper_New.PartyName ();
            partyName1.PartyNameType = 'Surname';
            partyName1.PartyNameValue = req.fullName.containsWhitespace()?req.fullName.substringAfter(' '):' ';
            FuneralClaimRequestWrapper_New.PartyName partyName2 = new FuneralClaimRequestWrapper_New.PartyName ();
            partyName2.PartyNameType = 'First Name';
            partyName2.PartyNameValue = req.fullName.containsWhitespace()?req.fullName.substringBefore(' '):' ';    
            partyNameList.add(partyName1); 
            partyNameList.add(partyName2);
          
            //PartyName End
            relatedPartyReference.PartyName = partyNameList;
            
            List<FuneralClaimRequestWrapper_New.PartyContactPoint> partyContactPointList = new List<FuneralClaimRequestWrapper_New.PartyContactPoint> ();
            FuneralClaimRequestWrapper_New.PartyContactPoint partyContactPoint = new FuneralClaimRequestWrapper_New.PartyContactPoint ();
            FuneralClaimRequestWrapper_New.ContactPointUsage contactPointUsage = new FuneralClaimRequestWrapper_New.ContactPointUsage ();
            contactPointUsage.ContactPointUsageType = 'Phone';
            FuneralClaimRequestWrapper_New.ContactPoint contactPoint = new FuneralClaimRequestWrapper_New.ContactPoint ();
            FuneralClaimRequestWrapper_New.TelephonicAddress telephonicAddress = new FuneralClaimRequestWrapper_New.TelephonicAddress ();
            telephonicAddress.PhoneType = 'Cellphone';
            telephonicAddress.PhoneNumber =  req.phoneNo;
            contactPoint.TelephonicAddress = telephonicAddress;
            partyContactPoint.ContactPointUsage = contactPointUsage;
            partyContactPoint.ContactPoint = contactPoint;
            
            partyContactPointList.add(partyContactPoint);
            relatedPartyReference.PartyContactPoint = partyContactPointList;
            
            List<FuneralClaimRequestWrapper_New.Associations> associationList = new List<FuneralClaimRequestWrapper_New.Associations> ();
            FuneralClaimRequestWrapper_New.Associations association = new FuneralClaimRequestWrapper_New.Associations ();
            association.PartyRelationship = partyRelationShip;
            association.RelatedPartyIdentification = relatedPartyIdentification;
            association.RelatedPartyReference = relatedPartyReference;
            associationList.add(association);
            
            fnolReq.Associations = associationList;
            newWrap.FuneralFNOLRequest = fnolReq;
            String payloadJson = JSON.serialize(newWrap);
            String accessToken = CMN_Generate_Token_Helper.getAccessToken();
            String transactionID = getUUID();
            String country_header = req.headerCountry.equalsIgnoreCase('SOUTH AFRICA')?'ZA':req.headerCountry.equalsIgnoreCase('LESOTHO')?'LS':req.headerCountry.equalsIgnoreCase('NAMIBIA')?'NA':'ZA';
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:INS_InsuranceClaimsAPIPing'+'/' + REQUEST_ENV + '-sbg-exp-insurance-api/api/contracts'+'/'+ req.contractNumber+'/'+'claims/funeral/fnol');
            request.setTimeout(120000);
           
            request.setMethod(HTTP_METHOD_POST);
            request.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            request.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            request.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
            request.setHeader(HEADER_CLIENT_COUNTRY,country_header);
            request.setHeader(HEADER_TRANSACTION_ID,transactionID);
            request.setHeader('client_id', '{!$Credential.INS_MulesoftRegistration.Reg_client_id}');
            request.setHeader('client_secret', '{!$Credential.INS_MulesoftRegistration.Reg_client_secret}');
            request.setHeader('org_client_id', '{!$Credential.INS_MulesoftRegistration.Reg_client_id}');
            
            request.setBody(payloadJson);
            Http http = new Http(); 
            // Send HTTP request
            HttpResponse response = http.send(request);                      
            Response responses = new Response();          
            
            if (response.getStatusCode() == 201 || response.getStatusCode() == 200) {
                
                // Handle successful response                
                FuneralclaimResponseWrapper wrapper = (FuneralclaimResponseWrapper) JSON.deserialize( response.getBody(), FuneralclaimResponseWrapper.class);//use this to fetch value from response 
                responses.isSuccess = wrapper.FuneralFNOLResponse.Status=='Success'?true:false;
                responses.status = wrapper.FuneralFNOLResponse.Status;
                
              //API excluding these error codes
                for(FuneralclaimResponseWrapper.Messages msg : wrapper.FuneralFNOLResponse.Messages){
                	responses.claimEventNumber = wrapper.FuneralFNOLResponse.ClaimEventNumber;
                    responses.errorMessage = msg.Code=='500'?msg.Message:null;
                    responses.responseCode = msg.Code;
                }
               responseList.add(responses);
               
            } else {
                // Handle error response
                string returnError = '';
                String responseBody = response.getBody();
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            if(responseObject != null) {
                Map<String, Object> responseObjectError = (Map<String, Object>) responseObject.get('error');
                if(responseObjectError != null && responseObjectError.containsKey('errorMessage') == true) {
                	returnError = (String)responseObjectError.get('errorDescription');
                }
            }
				//Log and Throw error response for debugging purposes
				LOGGER.error('INS_Funeral_Claims.execute: No response body', new String[] {'INS_Funeral_Claims.execute', response.getBody()});
                throw new INS_CustomException(returnError);
                
            }
            return  responseList;
        } Catch(Exception ex) {
            // Log error response for debugging purposes
            LOGGER.error('INS_Funeral_Claims.execute', ex);           
            throw new INS_CustomException(ex.getMessage());  
                     
        }
    }
    
    /**
     * @description generate uuid 
     *
     * @return String representing the uuid.
     */
    public static String getUUID() {
        Blob blobVal = Crypto.GenerateAESKey(128);
        String hexcode = EncodingUtil.ConvertTohex(blobVal);
        return hexcode.SubString(0,8)+ '-' + hexcode.SubString(8,12) + '-' + hexcode.SubString(12,16) + '-' + hexcode.SubString(16,20) + '-' + hexcode.substring(20);
    }
    /**
     * @description format date in required format
     * @param year
     * @param month
     * @param dateVal
     * @return String representing the formatted date.
     */
    public static String formatDate(String year,String month,String dateVal) {
    	month = month.length()==1?'0'+month:month;
        dateVal = dateVal.length()==1?'0'+dateVal:dateVal;
        String formattedDate = year+'-'+month+'-'+dateVal;
        return formattedDate;
    }
}