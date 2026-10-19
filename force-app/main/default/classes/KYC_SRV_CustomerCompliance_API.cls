/** 
 * Created by: Irshad as part of US:SFP-51839
 * Purpose: This class is used to call the KYC_SRV_GET_CustomerCompliance_API class to get the compliance status of a customer.
 * 
 */

public without sharing class KYC_SRV_CustomerCompliance_API {
    public static final String SERVICE_NAME = KYC_SRV_CustomerCompliance_API.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    public KYC_SRV_CustomerCompliance_API() {

    }

    public class Input {
        @InvocableVariable(required=true)
        public String partyScreeningSummaryId;
    }
    public class Output {
        
        @InvocableVariable public String message; 
        @InvocableVariable public String partyProfileId;
        @InvocableVariable public String quoteNumber;   
        @InvocableVariable public String screeningDecision;  
        @InvocableVariable public boolean isError = false; 

    }
    @InvocableMethod(label='Get KYC Status' description='Calls KYC service for a Party Profile')
    public static List<Output> GET_KYCStatus(List<Input> inputs){
        input inReq = inputs[0]; 
        List<Output> OutputList = new List<Output>();
        Output out = new Output();
        String returnStatus ='Screening Decision updated with status:';
        String transactionId = UUID.randomUUID().toString();        
        PartyScreeningSummary partyScreeningSummary = new SEL_PartyScreeningSummary().selectById(inReq.partyScreeningSummaryId);
        if(partyScreeningSummary.Status != 'In Progress'){
            out.message = 'PartyScreeningSummary status is not In Progress.';
            out.isError = true;
            OutputList.add(out);
            return OutputList;
        }
        string ppId = partyScreeningSummary.PartyProfileId;
        string assessmentId = partyScreeningSummary.ThirdPartySreeningIdentifier;
        out.partyProfileId = ppId;
       
        
        //KYC_DTO_Response response;
        PartyProfile pProfile = new SEL_PartyProfile().selectById(ppId);
        Id opportunityId = pProfile.Opportunity__c;       
        Opportunity opp = new SEL_Opportunity().selectById(opportunityId);
        if(opp != null){
            out.QuoteNumber = opp.Quote_Id__c;
        }
        
       
        KYC_SRV_GET_CustomerCompliance_API CustomerComplianceService = new KYC_SRV_GET_CustomerCompliance_API(pProfile,assessmentId);    

        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_SRV_GET_CustomerCompliance_API.SERVICE_NAME);
        CustomerComplianceService.process(obj);
        insert obj;
        Integer statusCode = CustomerComplianceService.getResponseStatusCode();
        String body = CustomerComplianceService.getResponseBody();
        
        if (statusCode == 200 || statusCode == 201) {
            KYC_SRV_CustomerCompliance_Response response;
            try {
                    response = KYC_SRV_CustomerCompliance_Response.parse(body);
             }catch (Exception e) {
                    LOGGER.error('Failed to parse KYC response', new String[]{SERVICE_NAME, e.getMessage()}, null);
                    out.isError = true;
                    out.message =  'Failed to parse KYC response';
                    OutputList.add(out);
                    return  OutputList;
            }
            if (response == null || response.assessmentResult == null) {
                out.isError = true;
                out.message =  'Error: Empty or incomplete KYC response.';
                OutputList.add(out);
                return  OutputList;
            }
            
                
            if(response != null){
                    if(!string.isBlank(response.customerId)){
                        pProfile.CMN_RelyComplyCustomerId__c= response.customerId;
                }
                KYC_SRV_CustomerCompliance_Response.cls_assessmentResult assessmentResult = response.assessmentResult;
                if(assessmentResult.result == 'AcceptableRisk'){
                    pProfile.CMN_DocTypesReqd__c='Proof of address';                
                }
                try{
                    update pProfile; 
                    updatepartyScreeningSummary(partyScreeningSummary,assessmentResult);
                    out.message = returnStatus + partyScreeningSummary.ScreeningDecision;
                    out.screeningDecision = partyScreeningSummary.ScreeningDecision;
                    OutputList.add(out);
                    
                    
                }catch(Exception e){
                    LOGGER.error('Update PartyProfile failed', new String[]{SERVICE_NAME, e.getMessage()}, null);
                }
                
                return OutputList;
                    
            }
                
               
        }else if(CustomerComplianceService.getResponseStatusCode() >= 400 && CustomerComplianceService.getResponseStatusCode() <=499){
            Map<String,Object> jsonRes=(Map<String,Object>)JSON.deserializeUntyped(CustomerComplianceService.getResponseBody());
            if(jsonRes.containsKey('error')){
                Map<String, Object> errorMap = (Map<String, Object>) jsonRes.get('error');
                String errorMessage = (String) errorMap.get('errorDescription');
                LOGGER.error('Client Error: ' + errorMessage, new String[] {SERVICE_NAME,errorMessage}, null);
                out.message =  'Client Error: ' + errorMessage;
                OutputList.add(out);
                return OutputList;
                
            }

        }else{
            LOGGER.error('Server Error: ' + statusCode, new String[]{SERVICE_NAME, String.valueOf(statusCode)}, null);
            out.message =  'Server Error: ' + statusCode;
                OutputList.add(out);
                return OutputList;
            
        }
        return OutputList;
       
    }

    /**
     * @description method used to  update partyScreeningSummary 
     * @param partyScreeningSummary 
     * @param assessmentResult 
     */
    
     public static void updatepartyScreeningSummary(PartyScreeningSummary partyScreeningSummary, KYC_SRV_CustomerCompliance_Response.cls_assessmentResult assessmentResult){

        String resultValue = assessmentResult.result;
        String statusValue = assessmentResult.status;
        String assessmentIdValue = assessmentResult.assessmentId;
        
        partyScreeningSummary.ThirdPartySreeningIdentifier = assessmentIdValue;
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
        
        List<KYC_SRV_CustomerCompliance_Response.cls_screeningResults> screeningResults = assessmentResult.screeningResults == null
        ? new List<KYC_SRV_CustomerCompliance_Response.cls_screeningResults>()
        : assessmentResult.screeningResults;
        List<Object> srsAsObjects = new List<Object>();
        if(screeningResults != null){
            for (KYC_SRV_CustomerCompliance_Response.cls_screeningResults sr : screeningResults) {
            srsAsObjects.add(new Map<String,Object>{
                'screeningId'   => sr.screeningId,
                'screeningType' => sr.screeningType,
                'screeningName' => sr.screeningName,
                'result'        => sr.result
            });
        }
        }       
         updatePartyScreeningStep(partyScreeningSummary.id,KYC_SRV_RAASCustomer.getRassResults(srsAsObjects),KYC_SRV_RAASCustomer.checkPartyprofileVerification(partyScreeningSummary.PartyProfileId));
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
}