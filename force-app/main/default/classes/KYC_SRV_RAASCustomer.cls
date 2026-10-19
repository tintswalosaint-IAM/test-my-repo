/***************************************************************************************
@Name of the Class :KYC_SRV_RAASCustomer
@Description : SFP-40754 Class used for calling RAAS API for screening Customer Profile.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date oct 08 2024
* Last Modified Description: Initital Version
* Last Modified By: SFP-51843: Added CustomerId to get the data from response, added
    by Irshad
****************************************************************************************/
public without sharing class KYC_SRV_RAASCustomer {
    public static final String SERVICE_NAME = KYC_SRV_RAASCustomer.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    private static String quoteIdParam;
    
    private KYC_SRV_RAASCustomer(){
        
    }

    /**
     * @description method used to call RAASCustomer API
     * @param ppId 
     * @return KYC_DTO_Response
     */
    public static KYC_DTO_Response callRAASCustomer(String ppId){
        return callRAASCustomer(ppId,null);
    }

    /**
     * @description method used to call RAASCustomer API
     * @param ppId 
     * @param partyScreeningSummary 
     * @param quoteId 
     * @return KYC_DTO_Response
     */
    public static KYC_DTO_Response callRAASCustomer(String ppId, PartyScreeningSummary partyScreeningSummary, String quoteId) {
        quoteIdParam = quoteId;
        return callRAASCustomer(ppId,null);
    }

    /**
     * @description method used to call RAASCustomer API
     * @param ppId 
     * @return KYC_DTO_Response
     */
    public static KYC_DTO_Response callRAASCustomer(String ppId,PartyScreeningSummary partyScreeningSummary){
        try{
            String transactionId=UUID.randomUUID().toString();
            
            KYC_DTO_Response response;
            PartyProfile pProfile = new SEL_PartyProfile().selectById(ppId);
            KYC_DTO_RAASCustomer krc = new KYC_DTO_RAASCustomer();
            PLI_DTO_RAASCustomer krcPli = new PLI_DTO_RAASCustomer();
            krc.identificationType = 'IdentityNumber';
            krc.countryOfIssue = pProfile.WI_IdentificationDocumentIssuingCountry__c;
            krc.partySourceIdentifier = transactionId;
            krc.partyType = 'Individual';
            krc.firstName = pProfile.FirstName;
            krc.middleName='';
            krc.lastName=pProfile.LastName;
            krc.dateOfBirth=String.ValueOF(pProfile.DateOfBirth);
            krc.countryOfBirth=pProfile.WI_IdentificationDocumentIssuingCountry__c;
            krc.countryOfResidence=pProfile.WI_IdentificationDocumentIssuingCountry__c;
            krc.occupationLevel=getRaasCode(pProfile.CMN_OccupationLevel__c);
            if(pProfile.WI_IdentificationDocumentIssuingCountry__c != null && pProfile.DateOfBirth != null){
                krc.employmentType=getRaasCodeEmpolymentType(pProfile.DateOfBirth,pProfile.CMN_FICPIP__c,pProfile.CMN_FICPIPREL__c,pProfile.WI_IdentificationDocumentIssuingCountry__c);
            }
            
            krc.initials=pProfile.CMN_Initials__c;
            krc.gender=pProfile.Gender;
            krc.countryOfCitizenship=pProfile.WI_CountryOfCitizenship__c;
            krc.passportIssuingCountry=pProfile.WI_PassportIssuingCountry__c;
            krc.passportIssuingCountry=pProfile.WI_IdentificationDocumentIssuingCountry__c;
            krc.address=pProfile.WI_IdentificationDocumentIssuingCountry__c;
            krc.employmentIndicator=true;
            krc.ficPip=pProfile.CMN_FICPIP__c;
            krc.ficPipRel=pProfile.CMN_FICPIPREL__c;
            krc.ficPipRelFirstName=pProfile.CMN_FICPIPRELFIRSTNAME__c;
            krc.ficPipRelLastName=pProfile.CMN_FICPIPRELLASTNAME__c;
            if (quoteIdParam != null) {
                krcPli = (PLI_DTO_RAASCustomer)JSON.deserialize(JSON.serialize(krc), PLI_DTO_RAASCustomer.class);
                krcPli.partySourceIdentifier = quoteIdParam;
                krcPli.salesId = quoteIdParam;
                krcPli.productId = 'PlatinumLife';
            }
            KYC_API_RAAS customerServiceCall = new KYC_API_RAAS(JSON.serialize(quoteIdParam == null ? krc : krcPli) ,pProfile, quoteIdParam == null ? transactionID : quoteIdParam);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_RAAS.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            
            if (customerServiceCall.getResponseStatusCode()== 201 || customerServiceCall.getResponseStatusCode() == 200) {
                if(partyScreeningSummary ==null){
                    partyScreeningSummary = new SEL_PartyScreeningSummary().selectByPartyProfileIdandStatus(ppId,'In Progress'); 
                }
                Map<String,Object> jsonRes=(Map<String,Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                string customerId = (String) jsonRes.get('customerId');
                
                pProfile.RelyComply_CustomerId__c = customerId;
                Map<String, Object> assessmentResult = (Map<String, Object>) jsonRes.get('assessmentResult');
                if((String) assessmentResult.get('result')=='AcceptableRisk'){
                    pProfile.CMN_DocTypesReqd__c='Proof of address';
                    
                }
                update pProfile; 
                updatepartyScreeningSummary(partyScreeningSummary,assessmentResult);
                response = ((String) assessmentResult.get('result')=='AcceptableRisk') ? new KYC_DTO_Response(jsonRes,'docRequired'):new KYC_DTO_Response(jsonRes, 'Success')  ;
                return response;
            }else{
                response = new KYC_DTO_Response('Failed',customerServiceCall.getResponseStatusCode());
                return response;
            }
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new KYC_SRV_RAASException(ex.getMessage());
        }
    }

    /**
     * @description method used to  pars the Raas API Response
     * @param screeningResults 
     * @return  Map<String ,String>
     */
    public static  Map<String ,String> getRassResults(List<object> screeningResults){
        Map<String ,String> rassResults= new Map<String ,String>();
        for (object  screeningResult : screeningResults) {
            Map<String, Object> results = (Map<String, Object>)screeningResult;
            if((String) results.get('screeningType')=='Sanction Status'){
                rassResults.put('Sanction Screening',(String) results.get('result'));
            }
            if((String) results.get('screeningType')=='Prominent Influential Persons (PIP)'){
                rassResults.put('PIP/FPPO',(String) results.get('result'));
            }
            if((String) results.get('screeningType')=='CRA High Risk Review' || (String) results.get('screeningType')=='Enhanced Due Diligence (EDD) Screening'){
                rassResults.put('Credit Risk Assessment',(String) results.get('result'));
            }
        }
        return rassResults;
    }
    
    /**
     * @description method used to  update partyScreeningSummary 
     * @param partyScreeningSummary 
     * @param assessmentResult 
     */
    public static void updatepartyScreeningSummary(PartyScreeningSummary partyScreeningSummary, Map<String, Object> assessmentResult){

        String resultValue = (String) assessmentResult.get('result');
        String statusValue = (String) assessmentResult.get('status');
        String assessmentIdValue = (String) assessmentResult.get('assessmentId');
        
        partyScreeningSummary.ThirdPartySreeningIdentifier=assessmentIdValue;
        partyScreeningSummary.Status='Completed';
        if(statusValue == 'Completed' && resultValue == 'Fulfilled'){
            partyScreeningSummary.ScreeningDecision  = 'Clear';
        } else if(statusValue == 'Completed' && ((resultValue == 'AcceptableRisk') || resultValue == 'Acceptable')){
            partyScreeningSummary.ScreeningDecision  = 'AcceptableRisk';
        } else if(statusValue == 'In Progress' && resultValue == 'pending'){
            partyScreeningSummary.ScreeningDecision  = 'On Hold';
        } else {
            partyScreeningSummary.ScreeningDecision  = 'Rejected';
        }
        update partyScreeningSummary;
        List<object> screeningResults = (List<object>)System.JSON.deserializeUntyped( JSON.serialize(assessmentResult.get('screeningResults')));
        updatePartyScreeningStep(partyScreeningSummary.id,getRassResults(screeningResults),checkPartyprofileVerification(partyScreeningSummary.PartyProfileId));
    }
    
    /**
     * @description method used to  update PartyScreeningStep 
     * @param rassResults
     * @param isVerificationCheck
     */
    public static void updatePartyScreeningStep(String screeningSummaryId,Map<String ,String> rassResults,Boolean isVerificationCheck){

        List<PartyScreeningStep> partyScreeningStepsList = new SEL_PartyScreeningStep().fetchPartyScreeningStepFromVerification(screeningSummaryId);
        List<PartyScreeningStep> updatePartyScreeningStepsList= new List<PartyScreeningStep>();

        for(PartyScreeningStep ps:partyScreeningStepsList){
            if(isVerificationCheck==false){
                for (String key : rassResults.keySet()) {
                    if(key==ps.Type){
                        ps.status = 'Completed';
                        ps.ResultCode=(String)rassResults.get(ps.Type);
                        updatePartyScreeningStepsList.add(ps);
                    }
                }
            }else if(isVerificationCheck==true){
                for (String key : rassResults.keySet()) {
                    if(key=='Sanction Screening'){
                        ps.status = 'Completed';
                        ps.ResultCode=(String)rassResults.get(ps.Type);
                        updatePartyScreeningStepsList.add(ps);
                    }
                }
            }
        }
        if(!updatePartyScreeningStepsList.IsEmpty()){
            update updatePartyScreeningStepsList;
        }
        
    }
    
    /**
     * @description method used to check Existing Customer verification Check
     * @param partyProfileId 
     * @return Boolean
     */
    public Static Boolean checkPartyprofileVerification(String partyProfileId){ 
        Boolean isVerification;
        List<PartyIdentityVerification>  pIdentitylist= new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>{partyProfileId});
        for(PartyIdentityVerification piv:pIdentitylist){
            if(piv.status=='Completed' && piv.Result=='Accepted'){
                isVerification=true;
            }else{
                isVerification=false;
            }
        }
        return isVerification;
    }
    
    /**
     * @description method used to To check if a customer is a major based on their date of birth:
     * @param dateOfBirth 
     * @return Boolean
     */
    public static Boolean isMajor(Date dateOfBirth) {
        Integer age = Date.today().year() - dateOfBirth.year();
        if (Date.today().addYears(-age) < dateOfBirth) {
            age -= 1;
        }
        return age > 17;
    }
    
    /**
     * @description method used to get RaasCode value
     * @param dateOfBirth 
     * @param isPIP 
     * @param isPIPREL 
     * @param country
     * @return String 
     */
    public static String getRaasCodeEmpolymentType(Date dateOfBirth,Boolean isPIP,Boolean isPIPREL,String country){
        String accountHolderType;
        Boolean isResident;
        accountHolderType=isMajor(dateOfBirth) ? 'Adult - citizen' : 'Minor - citizen';
        isResident=(country=='UG')? true : false;
        CMN_KYC_Rasscode__mdt raasCode =[SELECT Id,Account_Holder_Type__c,CMN_Raas_Code__c,IS_FIC_PIP_REL__c,IS_PIP__c,IsResident__c FROM CMN_KYC_Rasscode__mdt where Account_Holder_Type__c=:accountHolderType And IS_FIC_PIP_REL__c=:isPIPREL and IS_PIP__c =:isPIP and IsResident__c =:isResident Limit 1]; 
        return raasCode.CMN_Raas_Code__c;
    }
    
    
    /**
     * @description method used to get RaasCode value
     * @param raasValue 
     * @return String 
     */
    public static String getRaasCode(String raasValue){
        try{
            raasValue=raasValue.replaceAll('[\\s,-/]+', '_');  
            return CMN_KYC_Rasscode__mdt.getInstance(Raasvalue).CMN_Raas_Code__c;
        }
        catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_Integration',ex.getMessage()}, ex);
            throw new KYC_SRV_RAASException(ex.getMessage());  
        }
    }

   /**
    * @description custom Exception 
    */  
   public class KYC_SRV_RAASException extends Exception {}
    
    /***************************************************************************************
    @Name of the Class :KYC_DTO_RAASCustomer
    @Description : This is wrapper class for converting Salesforce Object into parameter for api
    @Author :Dayakar 
    @Created Date :sept 09 2024
    ***************************************************************************************/
    public virtual class  KYC_DTO_RAASCustomer {
        public String identificationType;
        public String countryOfIssue;
        public String partySourceIdentifier;
        public String partyType;
        public String firstName;
        public String middleName;
        public String lastName;
        public String dateOfBirth;
        public String countryOfBirth;
        public String countryOfResidence;
        public String occupationLevel;
        public String employmentType;
        public String initials;
        public String gender;
        public String countryOfCitizenship;
        public String passportIssuingCountry;
        public String address;
        public Boolean employmentIndicator;
        public Boolean ficPip;
        public Boolean ficPipRel;
        public String ficPipRelFirstName;
        public String ficPipRelLastName;
    }

    public class PLI_DTO_RAASCustomer extends KYC_DTO_RAASCustomer {
        public String salesId;
        public String productId;
    }

}