/***************************************************************************************
@Name of the Class :CMN_KYC_ExperienceUI
@Description : SFP-32973 Controller to request for KYC Process
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
***************************************************************************************
* Last Modified By  Alexandr Goryachko
* Last Modified Date 23/03/2026
* Last Modified Description: Added logic to ignore validation and sms
* User Story : SFP-53455
***************************************************************************************
* Last Modified By  Shams
* Last Modified Date 2026-06-15
* Last Modified Description: Reset static Unit of Work at the start of processKycTest to prevent
*                            INVALID_FIELD_FOR_INSERT_UPDATE when processing multiple beneficiaries
*                            in a single transaction (SFP-58522)
* User Story : SFP-58522
****************************************************************************************/
public without sharing class KYC_CTRL_PartyProfile {
    private static final String FAILED_STRING = 'Failed';
    private static final String SUCCESS_STRING = 'Success';
    private static Boolean IGNORE_VALIDATION = false;
    public static List<String> availableChecks = new List<String>{'Id Validation','WFR','RAAS','Document Upload'};
    public static Boolean IGNORE_SMS = false;
    private static sbgplatform.fflib_SObjectUnitOfWork uow = (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance(); 	
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('KYC_CTRL_PartyProfile');
    
    
    
    /**
    * @description method used to request for KYC Process for certain entity
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param iString
    * @return KYC_CTRL_PartyProfile.KYCResponse
    **/
    @AuraEnabled
    public static KYC_CTRL_PartyProfile.KYCResponse processKYC(String iString){
        KYC_CTRL_PartyProfile.KYCResponse retVal = new KYC_CTRL_PartyProfile.KYCResponse();
        try{
            KYC_DTO_ProfileRequest reqData = (KYC_DTO_ProfileRequest)JSON.deserialize(iString, KYC_DTO_ProfileRequest.class);
            if(reqData.checks==null || reqData.checks.idValidation==false && reqData.checks.idv==false && reqData.checks.raas==false){
                LOGGER.error('None of the checks are selected, aborting KYC process.');
            }
            else if (reqData != null && reqData.clientDetails != null) {
                list<PartyProfile> ppList = KYC_CTRL_PartyProfile.upsertPartyProfile(reqData.clientDetails);
                List<PartyProfileAddress> ppAList = KYC_CTRL_PartyProfile.createOrUpdateAddresses(ppList[0],reqData.clientDetails?.addresses);
                ppAList = KYC_CTRL_PartyProfile.upsertPartyProfileAddress(ppList[0], ppAList);
                List<KYC_CTRL_PartyProfile.CheckResult> chkRes = createOrUpdateChecks(ppList[0], reqData.checks);
                KYC_CTRL_PartyProfile.createOrUpdateScreeningSummary(ppList[0]);
                uow.commitWork();
                retVal.kycProfileId = ppList[0]?.Id;
                retVal.checkResults=chkRes;
            } 
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.process',ex.getMessage()}, ex);
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.process',ex.getLineNumber().toString()}, ex);
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.process',ex.getStackTraceString()}, ex);
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.process',ex.getTypeName()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return retVal;
    }
    
    /**
    * @description This method used to insert or update Party Profile record 
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param cliDetails 
    * @return list<PartyProfile> 
    **/
    private static list<PartyProfile> upsertPartyProfile(KYC_DTO_ClientDetails cliDetails) {
        list<PartyProfile> retVal = new list<PartyProfile>();
        try {
            list<PartyProfile> partyProfiles = KYC_CTRL_PartyProfile.preparePPList(cliDetails);
            KYC_SRV_PartyProfile.newInstance().savePartyProfiles(partyProfiles, uow);
            retVal=partyProfiles;
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.upsertPartyProfile',ex.getMessage()}, ex);
        }
        return retVal;
    }
    
    /**
    * @description This method used to insert or update Party Profile Addresses for given Party Profile record
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param ppRec 
    * @param lstAddress 
    * @return list<PartyProfileAddress> 
    **/
    private static list<PartyProfileAddress> upsertPartyProfileAddress(PartyProfile ppRec, List<PartyProfileAddress> lstAddress) {
        list<PartyProfileAddress> retVal = new list<PartyProfileAddress>();
        try {            
            if(!lstAddress.isEmpty()){
                KYC_SRV_PartyProfileAddress.newInstance().savePartyProfileAddress(ppRec, lstAddress, uow);
                retVal=lstAddress;
            }
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.upsertPartyProfileAddress',ex.getMessage()}, ex);
        }
        return retVal;
    }
    
    /**
    * @description This method used to create or update KYC checks as per input parameters
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param ppRec 
    * @param chks 
    * @return List<KYC_CTRL_PartyProfile.CheckResult> 
    **/
    private static List<KYC_CTRL_PartyProfile.CheckResult> createOrUpdateChecks(PartyProfile ppRec, KYC_DTO_Checks chks){
        List<KYC_CTRL_PartyProfile.CheckResult> retVal = new List<KYC_CTRL_PartyProfile.CheckResult>();
        try {
            list<String> checkList = new List<String>();
            integer pivMatchCount = 0;
            if(chks.idValidation){
                checkList.add('Id Validation');
                pivMatchCount++;
            }
            if(chks.idv){
                checkList.add('WFR');
                pivMatchCount++;
            }
            if(chks.raas){
                checkList.add('RAAS');
                checkList.add('Document Upload');
                pivMatchCount++;
                pivMatchCount++;
            }
            if(chks.documentUpload==true && !chks.raas){
                checkList.add('Document Upload');
                pivMatchCount++;
            }
            if (checkList.isEmpty()) {
                return retVal;
            }
            
            List<PartyIdentityVerification> pivList = new List<PartyIdentityVerification>();
            pivList = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{ppRec?.Id});
            if(pivList.size()== pivMatchCount){
                retVal = prepareCheckResult(pivList);
            }
            else{
                pivList = createMissingPIV(checkList, ppRec, pivList);
                retVal = prepareCheckResult(pivList);
            }
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.createOrUpdateChecks',ex.getMessage()}, ex);
        }
        return retVal;
    }
    
    /**
    * @description This method used to create or update Addresses for Party Profile record
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param ppRec 
    * @param lstAddress 
    * @return List<PartyProfileAddress> 
    **/
    private static List<PartyProfileAddress> createOrUpdateAddresses(PartyProfile ppRec, List<KYC_DTO_Address> lstAddress){
        List<PartyProfileAddress> retVal = new List<PartyProfileAddress>();
        try {
            if(lstAddress!=null){
                for(KYC_DTO_Address addRec:lstAddress){
                    PartyProfileAddress tempAddr= new PartyProfileAddress();
                    tempAddr.Street=addRec.street;
                    tempAddr.City=addRec.city;
                    tempAddr.PostalCode=addRec.postalCode;
                    tempAddr.State=addRec.stateCode;
                    tempAddr.Country=addRec.countryCode;
                    tempAddr.Latitude=addRec.latitude;
                    tempAddr.Longitude=addRec.longitude;
                    tempAddr.GeocodeAccuracy=addRec.geoCode;
                    tempAddr.AddressType=addRec.type;
                    tempAddr.Name=addRec.type;
                    tempAddr.IsPrimaryAddress=addRec.primaryAddress;
                    tempAddr.ValidityStartDate=addRec.startDate;
                    tempAddr.ValidityEndDate=addRec.endDate;
                    tempAddr.partyProfile=ppRec;
                    retVal.add(tempAddr);
                }
            }
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.createOrUpdateAddresses',ex.getMessage()}, ex);
        }
        return retVal;
    }
    
    /**
    * @description This method used for creating Party Profile records in bulk
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param cliDetails 
    * @return list<PartyProfile> 
    **/
    private static List<PartyProfile> preparePPList(KYC_DTO_ClientDetails cliDetails) {
        List<PartyProfile> retVal = new List<PartyProfile>();
        PartyProfile ppRec = new PartyProfile();
        
        setIdentificationDetails(ppRec, cliDetails);
        setPersonalDetails(ppRec, cliDetails);
        setContactDetails(ppRec, cliDetails);
        setMiscellaneousDetails(ppRec, cliDetails);
        setMappings(ppRec, cliDetails);

        retVal.add(ppRec);
        return retVal;
    }

    /**
    * @description This method used for create field mapping from KYC_DTO_ClientDetails to PartyProfie object
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param ppRec 
    * @param cliDetails 
    **/
    private static void setMappings(PartyProfile ppRec, KYC_DTO_ClientDetails cliDetails) {
        String picklistAPIValue = getPicklistAPIValue('PartyProfile', 'WI_CountryOfCitizenship__c', cliDetails.countryOfCitizenship);
        ppRec.WI_CountryOfCitizenship__c = (picklistAPIValue == null) ? cliDetails.idDocIssuingCountry : picklistAPIValue ;

        picklistAPIValue = getPicklistAPIValue('PartyProfile', 'Country_of_Residence__c', cliDetails.countryOfResidence);
        ppRec.Country_of_Residence__c = (picklistAPIValue == null) ? cliDetails.idDocIssuingCountry : picklistAPIValue ;

        picklistAPIValue = getPicklistAPIValue('PartyProfile', 'WI_PassportIssuingCountry__c', cliDetails.passportIssuingCountry);
        ppRec.WI_PassportIssuingCountry__c = picklistAPIValue;

        picklistAPIValue = getPicklistAPIValue('PartyProfile', 'EmploymentType', cliDetails.employmentType);
        ppRec.EmploymentType = picklistAPIValue;

        ppRec.CMN_DocTypesReqd__c = cliDetails.docAdd;
        ppRec.CMN_FICPIP__c = cliDetails.ficPip;
        ppRec.CMN_FICPIPREL__c = cliDetails.ficPipRel;
        ppRec.CMN_FICPIPRELFIRSTNAME__c = cliDetails.ficPipRelFirstName;
        ppRec.CMN_FICPIPRELLASTNAME__c = cliDetails.ficPipRelLastName;
    }

    /**
    * @description This method used for create field mapping from KYC_DTO_ClientDetails to PartyProfie object
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param ppRec 
    * @param cliDetails 
    **/
    private static void setIdentificationDetails(PartyProfile ppRec, KYC_DTO_ClientDetails cliDetails) {
        String picklistAPIValue = getPicklistAPIValue('PartyProfile', 'WI_IdentificationDocumentIssuingCountry__c', cliDetails.idDocIssuingCountry);
        ppRec.WI_IdentificationDocumentIssuingCountry__c = (picklistAPIValue == null) ? cliDetails.idDocIssuingCountry : picklistAPIValue ;
        ppRec.WI_PrimaryIdentificationName__c = cliDetails.idNumber;
        picklistAPIValue = getPicklistAPIValue('PartyProfile', 'PrimaryIdentifierType', cliDetails.primaryIdType);
        ppRec.PrimaryIdentifierType = picklistAPIValue;
    }
    
    /**
    * @description This method used for create field mapping from KYC_DTO_ClientDetails to PartyProfie object
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param ppRec 
    * @param cliDetails 
    **/
    private static void setPersonalDetails(PartyProfile ppRec, KYC_DTO_ClientDetails cliDetails) {
        ppRec.Person_Title__c = cliDetails.title;
        ppRec.FirstName = cliDetails.firstName;
        ppRec.MiddleName = cliDetails.middleName;
        ppRec.LastName = cliDetails.lastName;
        ppRec.Name = cliDetails.firstName + ' ' + cliDetails.lastName;
        ppRec.Gender = cliDetails.gender;
    }
    
    /**
    * @description This method used for create field mapping from KYC_DTO_ClientDetails to PartyProfie object
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param ppRec 
    * @param cliDetails 
    **/
    private static void setContactDetails(PartyProfile ppRec, KYC_DTO_ClientDetails cliDetails) {
        ppRec.PrimaryPhone = cliDetails.primaryPhone;
        ppRec.PrimaryEmail = cliDetails.primaryEmail;
    }
    
    /**
    * @description This method used for create field mapping from KYC_DTO_ClientDetails to PartyProfie object
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param ppRec 
    * @param cliDetails 
    **/
    private static void setMiscellaneousDetails(PartyProfile ppRec, KYC_DTO_ClientDetails cliDetails) {
        String picklistAPIValue = getPicklistAPIValue('PartyProfile', 'Nationality', cliDetails.nationality);
        ppRec.Nationality = picklistAPIValue;
        ppRec.DateOfBirth = Date.valueOf(cliDetails.dob);
        ppRec.CMN_IsEmployed__c = cliDetails.isEmployed;
        ppRec.CMN_OccupationLevel__c = cliDetails.occupationLevel;
        ppRec.CMN_CardNumber__c = cliDetails.cardNumber;
        if (cliDetails.kycProfileId != null) {
            ppRec.Id = cliDetails.kycProfileId;
        }
        ppRec.RecordTypeId = getPartyProfileRecordTypeId();
    }
    
    /**
    * @description This method used to get PartyProfile record type Id
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param ppRec 
    * @param cliDetails 
    **/
    private static Id getPartyProfileRecordTypeId() {
        String recordTypeName = 'Know Your Customer';
        return Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
    /**
    * @description This method is used for preparing check result
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param pivList 
    * @return List<KYC_CTRL_PartyProfile.CheckResult> 
    **/
    private static List<KYC_CTRL_PartyProfile.CheckResult> prepareCheckResult(List<PartyIdentityVerification> pivList){
        List<KYC_CTRL_PartyProfile.CheckResult> retVal = new List<KYC_CTRL_PartyProfile.CheckResult>();
        try {
            for(PartyIdentityVerification pivRec : pivList){
                KYC_CTRL_PartyProfile.CheckResult chkRes = new KYC_CTRL_PartyProfile.CheckResult();
                chkRes.name=pivRec.Name;
                chkRes.requestDate=String.valueOf(pivRec.VerificationRequestDate);
                chkRes.completionDate=String.valueOf(pivRec.RequestCompletionDate);
                chkRes.status=pivRec.Status;
                chkRes.result=pivRec.Result;
                retVal.add(chkRes);
            }
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.prepareCheckResult',ex.getMessage()}, ex);
        }
        return retVal;
    }
    /**
    * @description This method used to get next party identity name
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param checkList 
    * @param nxtPIVName 
    * @return String
    **/
    public static String getNxtPIVName(list<String> checkList,String nxtPIVName){
        if(!checkList.contains(nxtPIVName) ){
            nxtPIVName = getNxtPIVName(checkList,SVC_TRH_PartyIdentityVerification.srcToTrgPIVMap.get(nxtPIVName));
        } 
        return nxtPIVName;
	}
    /**
    * @description This method is used for chekcing missing PIC and creating new record
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param checkList 
    * @param ppRec 
    * @param pivList 
    * @return List<PartyIdentityVerification> 
    **/
    private static List<PartyIdentityVerification> createMissingPIV(List<String> checkList, PartyProfile ppRec, List<PartyIdentityVerification> pivList) {
        List<PartyIdentityVerification> retVal = new List<PartyIdentityVerification>();
        try {            
            Set<String> availableSet = new Set<String>();
            
            for (PartyIdentityVerification pivRec : pivList) {
                availableSet.add(pivRec.Name);
                retVal.add(pivRec);
            }
            String nextPivName = getNxtPIVName(checkList,new List<String>(SVC_TRH_PartyIdentityVerification.srcToTrgPIVMap.keySet())[0]);
            for (String chk : checkList) {
                if (!availableSet.contains(chk)) {
                    PartyIdentityVerification pivRec = new PartyIdentityVerification(Name = chk);                    
                    if(nextPivName.equals(pivRec.Name)){
                        pivRec.Status = 'In Progress';
                    }
                    pivRec.VerificationRequestDate = System.now();
                    retVal.add(pivRec);
                }
            }
            
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(ppRec, retVal, uow);
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.createMissingPIV',ex.getMessage()}, ex);
        }
        return retVal;
    }
    
    /**
    * @description This method used to get picklist API value based on Object,FieldName and Label
    * @author Nagendra Mylavarapu | 13-03-2024 
    * @param objectApiName 
    * @param fieldApiName 
    * @param label 
    * @return String 
    **/
    public static String getPicklistAPIValue(String objectApiName, String fieldApiName, String label) {
        try {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldApiName).getDescribe();
            
            if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry entry : picklistValues) {
                    if (entry.getLabel().equals(label)) {
                        return entry.getValue();
                    }
                }
            }                        
        } catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.getPicklistAPIValue',ex.getMessage()}, ex);
        }
        return null;
    }
    
    /**
    * @description This method used to create or update PartyScreeningSummary
    * @author Nagendra Mylavarapu | 11-03-2024 
    * @param profileRec 
    **/
    private static void createOrUpdateScreeningSummary(PartyProfile profileRec){
        try {
            if(profileRec.Id==null){
                List<PartyScreeningSummary> lstPSS = new List<PartyScreeningSummary>();
                PartyScreeningSummary oPSS = new PartyScreeningSummary(PartyProfileId=profileRec.Id,Name='KYC Summary', ScreeningRequestDate=system.now(), Status='In Progress');
                lstPSS.add(oPSS);
                KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(profileRec, lstPSS, uow);
            }
         } catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.createOrUpdateScreeningSummary',ex.getMessage()}, ex);
        }
    }
    
    /**
    * @description This method used to function overloading of process kyc test
    * @author Alexandr Goryachko | 23-03-2026 
    * @param iString 
    * @param ignoreValidation 
    * @return KYC_DTO_ClientWrapper.Response 
    **/
    public static KYC_DTO_ClientWrapper.Response processKycTest(String iString, Boolean ignoreValidation) {
        IGNORE_VALIDATION = ignoreValidation;
        return KYC_CTRL_PartyProfile.processKycTest(iString);
    }
   
    /**
    * @description This method used to process kyc test
    * @author Nagendra Mylavarapu | 11-03-2024
    * @last modified by Shams | 2026-06-15 — reset static UoW at start of each call to prevent
    *              INVALID_FIELD_FOR_INSERT_UPDATE when processing multiple beneficiaries (SFP-58522)
    * @param iString
    * @return KYC_DTO_ClientWrapper.Response
    **/
    public static KYC_DTO_ClientWrapper.Response processKycTest(String iString) {
        uow = (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        KYC_DTO_ClientWrapper.Response retVal = new KYC_DTO_ClientWrapper.Response();
        try {
            KYC_DTO_ClientWrapper clientRequestWrapper = (KYC_DTO_ClientWrapper)JSON.deserialize(iString, KYC_DTO_ClientWrapper.class);
            
            if (!IGNORE_VALIDATION && isInvalidRequest(clientRequestWrapper, retVal)) {
                return retVal;
            }

            PartyProfile pp = checkExistingPartyProfile(clientRequestWrapper);
            if (pp != null) {
                return handleExistingPartyProfile(pp);
            }

            return createNewKycProfile(clientRequestWrapper);
        } catch (Exception ex) {
            return handleException(ex);
        }
    }

    private static boolean isInvalidRequest(KYC_DTO_ClientWrapper clientRequestWrapper, KYC_DTO_ClientWrapper.Response retVal) {
        if (clientRequestWrapper.checkForNullOrEmptyFields()) {
            retVal.status = FAILED_STRING;
            retVal.responseCode = SVC_UTIL_CrossOrg.STATUS_CODE_400;
            retVal.message = String.join(clientRequestWrapper.errorFields, ';');
            return true;
        }
        return false;
    }
    
    @TestVisible
    private static KYC_DTO_ClientWrapper.Response handleExistingPartyProfile(PartyProfile pp) {
        if (KYC_CTRL_PartyProfile.checkInPendingPartyIdentityVerification(pp.Id)) {
            return createResponse(SUCCESS_STRING, SVC_UTIL_CrossOrg.STATUS_CODE_200, 'Party Profile already exists. Please proceed for Id verification process.', pp.Id);
        }
        
        if (KYC_CTRL_PartyProfile.checkInPendingPartyScreeningSummary(pp.Id)) {
            return createResponse(SUCCESS_STRING, SVC_UTIL_CrossOrg.STATUS_CODE_200, 'Please proceed for already pending screening process.', pp.Id);
        }

        createNewScreeningSummary(pp);
        return createResponse(SUCCESS_STRING, SVC_UTIL_CrossOrg.STATUS_CODE_200, 'Please proceed for a screening process.', pp.Id);
    }
    
    @TestVisible
    private static void createNewScreeningSummary(PartyProfile pp) {
        PartyScreeningSummary screeningSummary = new PartyScreeningSummary(
            PartyProfileId = pp.Id,
            Name = 'Assessment',
            ScreeningRequestDate = System.now(),
            Status = 'Initiated'
        );
        List<PartyScreeningStep> screeningSteps = new List<PartyScreeningStep>{
            new PartyScreeningStep(Name = 'Screening', Status = 'Initiated', Type = 'Sanction Screening')
        };
        
        KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(pp, new List<PartyScreeningSummary>{screeningSummary}, uow);
        KYC_SRV_PartyScreeningSummaryStep.newInstance().savePartyScreeningSummaryStep(screeningSummary, screeningSteps, uow);
        uow.commitWork();
    }
    
    @TestVisible
    private static KYC_DTO_ClientWrapper.Response createNewKycProfile(KYC_DTO_ClientWrapper clientRequestWrapper) {
        List<PartyProfile> ppList = upsertPartyProfile(clientRequestWrapper.clientDetails);
        List<PartyProfileAddress> ppAList = createOrUpdateAddresses(ppList[0], clientRequestWrapper.clientDetails?.addresses);
        ppAList = upsertPartyProfileAddress(ppList[0], ppAList);

        createOrUpdateChecks(ppList[0], clientRequestWrapper.checks);
        createOrUpdateScreeningSummary(ppList[0], clientRequestWrapper.checks.assessment);

        uow.commitWork();

        return createResponse(SUCCESS_STRING, SVC_UTIL_CrossOrg.STATUS_CODE_200, 'KYC profile created successfully', ppList[0]?.Id);
    }
    
    @TestVisible
    private static KYC_DTO_ClientWrapper.Response handleException(Exception ex) {
        LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.processKycTest', ex.getMessage()}, ex);
        return createResponse(FAILED_STRING, 500, 'KYC_CTRL_PartyProfile.processKycTest' + ex.getMessage(), null);
    }

    private static KYC_DTO_ClientWrapper.Response createResponse(String status, Integer responseCode, String message, Id kycProfileId) {
        KYC_DTO_ClientWrapper.Response response = new KYC_DTO_ClientWrapper.Response();
        response.status = status;
        response.responseCode = responseCode;
        response.message = message;
        response.kycProfileId = kycProfileId == null ?null: String.valueOf(kycProfileId) ;
        response.url=KYC_customlabel__mdt.getInstance('KYC_SIte_Url').Description__c+kycProfileId;

        if(responseCode==200 && !IGNORE_SMS){
            callSMS(new Set<Id>{kycProfileId});
        }
        return response;
    } 
    
    @Future(callout=true)
    public static void callSMS(set<Id> partyProfileIds){
        KYC_SRV_SendSMS.sendSMS(partyProfileIds);
    }

    /**
    * @description This mathod is used to check PartyIdentityVerification is completed and accepted or not
    * @author Nagendra Mylavarapu | 06-SEP-2024 
    * @param ppId 
    * @return Boolean
    **/
    @TestVisible    
    private static Boolean checkInPendingPartyIdentityVerification(Id ppId){
        List<PartyIdentityVerification> piVerificationList =  new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{ppId});
        for( PartyIdentityVerification piVerication : piVerificationList ) {
            if( !(piVerication.Status == 'Completed' && piVerication.Result == 'Accepted') ){ 
                return true;
            }
        }
        return false;
    }

    /**
    * @description This mathod is used to check PartyScreeningSummary is completed or not
    * @author Nagendra Mylavarapu | 06-SEP-2024 
    * @param ppId 
    * @return Boolean
    **/
    @TestVisible 
    private static Boolean checkInPendingPartyScreeningSummary(Id ppId){
        List<PartyScreeningSummary> pssList = 
                new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(new Set<Id>{ppId});
        for( PartyScreeningSummary pss : pssList ) {
            if(pss.Status != 'Completed'){
                return true;
            }
        }
        return false;
    }

    /**
    * @description This method used check the existing party profile
    * @author Nagendra Mylavarapu | 06-SEP-2024 
    * @param clientRequestWrapper 
    * @return PartyProfile
    **/
    public static PartyProfile checkExistingPartyProfile(KYC_DTO_ClientWrapper clientRequestWrapper) {
        if (clientRequestWrapper == null || clientRequestWrapper.clientDetails == null || clientRequestWrapper.checks == null) {
            return null;
        }

        KYC_DTO_ClientDetails clientDetails = clientRequestWrapper.clientDetails;
        List<PartyProfile> ppList = new SEL_PartyProfile().selectByFirstLastNameandDateofBirth( 
            clientDetails.firstName, 
            clientDetails.lastName, 
            Date.valueOf(clientDetails.dob), 
            clientDetails.idNumber
 
        );
        if (!ppList.isEmpty()) {
            return ppList[0];
        }
        return null;
    }
    

       
    /**
    * @description This method used to create or update KYC checks as per input parameters
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param ppRec 
    * @param chks 
    * @return List<KYC_CTRL_PartyProfile.CheckResult> 
    **/
    private static void createOrUpdateChecks(PartyProfile ppRec, KYC_DTO_ClientWrapper.Checks chks){
        List<PartyIdentityVerification> retVal = new List<PartyIdentityVerification>();
        List<String> checkList = new List<String>();
        if (chks.idValidation) {
            checkList.add('Id Validation');
        }
        if (chks.idv) {
            checkList.add('WFR');
        }
        if (!checkList.isEmpty()) {
            String nextPivName = getNxtPIVName(checkList,new List<String>(SVC_TRH_PartyIdentityVerification.srcToTrgPIVMap.keySet())[0]);
            for (String chk : checkList) {
                PartyIdentityVerification pivRec = new PartyIdentityVerification(Name = chk);                    
                if(nextPivName.equals(pivRec.Name)){
                    pivRec.Status = 'In Progress';
                }else{
                    pivRec.Status = 'Initiated';
                }
                pivRec.VerificationRequestDate = System.now();
                retVal.add(pivRec);
            }
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(ppRec, retVal, uow);
        }
    }

    /**
    * @description This method used to create or update PartyScreeningSummary 
    * and PartyScreeningStep as per input parameters
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param profileRec 
    * @param assessment 
    **/
    private static void createOrUpdateScreeningSummary(PartyProfile profileRec, KYC_DTO_ClientWrapper.Assessment assessment) {
        if (assessment != null) {
            PartyScreeningSummary screeningSummary = new PartyScreeningSummary(
                PartyProfileId = profileRec.Id,
                Name = 'Assessment',
                ScreeningRequestDate = System.now(),
                Status = 'Initiated'
            );

            List<PartyScreeningStep> screeningSteps = new List<PartyScreeningStep>();
            if (assessment.CRA) {
                screeningSteps.add(new PartyScreeningStep(Name = 'Customer Risk Assessment', Status = 'Initiated', Type = 'Credit Risk Assessment'));
            }
            if (assessment.PEP_Screening) {
                screeningSteps.add(new PartyScreeningStep(Name = 'Political Influential Person', Status = 'Initiated', Type = 'PIP/FPPO'));
            }
            if (assessment.screening) {
                screeningSteps.add(new PartyScreeningStep(Name = 'Sanction Screening', Status = 'Initiated', Type = 'Sanction Screening'));
            }
            if (!screeningSteps.isEmpty()) {
                KYC_SRV_PartyScreeningSummary.newInstance().savePartyScreeningSummary(profileRec, new List<PartyScreeningSummary>{screeningSummary}, uow);
                KYC_SRV_PartyScreeningSummaryStep.newInstance().savePartyScreeningSummaryStep(screeningSummary, screeningSteps, uow);
            }
        }
    }

    /**
    * @description This method used to upsert Party Profile record 
    * @author Nagendra Mylavarapu | 08-09-2024
    * @param partyProfiles 
    * @return list<PartyProfile> 
    **/
    @AuraEnabled
    public static list<PartyProfile> upsertPartyProfile(string partyProfiles) {
        list<PartyProfile> retVal = new list<PartyProfile>();
        try {
            List<PartyProfile> partyProfilesData =  (List<PartyProfile>)JSON.deserialize(partyProfiles,List<PartyProfile>.class);
            KYC_SRV_PartyProfile.newInstance().savePartyProfiles(partyProfilesData, uow);
            uow.commitWork();
            retVal=partyProfilesData;
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.upsertPartyProfile',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return retVal;
    }

    /**
    * @description This is wrapper class for converting input into Salesforce Object
    **/
    /***************************************************************************************
    @Name of the Class :KYC_DTO_RAASCustomer
    @Description : This is wrapper class for converting input into Salesforce Object
    @Author :Nagendra Mylavarapu 
    @Created Date :sept 09 2024
    ***************************************************************************************/
    public class KYCRequest{
        
        @InvocableVariable(label = 'Client Details')
        public KYC_DTO_ClientDetails clientDetails;
        
        @InvocableVariable(label = 'Checks')
        public KYC_DTO_Checks checks;
    }
    /**
    * @description This is wrapper class for sending output in specific format
    **/
    /***************************************************************************************
    @Name of the Class :KYC_DTO_RAASCustomer
    @Description : This is wrapper class for sending output in specific format	
    @Author :Nagendra Mylavarapu 
    @Created Date :sept 09 2024
    ***************************************************************************************/
    public class KYCResponse{
        
        @InvocableVariable(label = 'KYC Profile Id')
        public String kycProfileId;
        
        @InvocableVariable(label = 'Check Results')
        public List<KYC_CTRL_PartyProfile.CheckResult> checkResults;
    }
    /**
    * @description This is wrapper class for converting input into Salesforce Object
    **/	
    /***************************************************************************************
    @Name of the Class :KYC_DTO_RAASCustomer
    @Description : This is wrapper class for converting input into Salesforce Object
    @Author :Nagendra Mylavarapu
    @Created Date :sept 09 2024
    ***************************************************************************************/
    public class CheckResult {
        
        @InvocableVariable(label = 'Check Type')
        public String checkType;
        
        @InvocableVariable(label = 'Name')
        public String name;
        
        @InvocableVariable(label = 'Request Date')
        public String requestDate;
        
        @InvocableVariable(label = 'Completion Date')
        public String completionDate;
        
        @InvocableVariable(label = 'Status')
        public String status;
        
        @InvocableVariable(label = 'Result')
        public String result;
    }
}