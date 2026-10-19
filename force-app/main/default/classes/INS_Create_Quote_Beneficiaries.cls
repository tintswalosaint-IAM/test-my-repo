/**
* @description Class is used to add,update and delete beneficiaries 
* @author Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Oct 2023
*/

public class INS_Create_Quote_Beneficiaries{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Create_Quote_Beneficiaries');
    /**
    * @description Handles the Response of Create and Update Beneficiary API
    * @param members
    * @param quoteNumber
    * @param mainBenefitId
    * @return returnList
    **/        
    @AuraEnabled
    public static List<InsurancePolicyParticipant> createQuoteBeneficiariesBulk(List<InsurancePolicyParticipant> members, String quoteNumber, String mainBenefitId, String userCountry){
        List<InsurancePolicyParticipant> returnList = new List<InsurancePolicyParticipant>();   
        
        String memberbenefitId;
        try{
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            for (InsurancePolicyParticipant member : members){
                HttpRequest httpRequest = new HttpRequest();
                HttpResponse response = new HttpResponse();
                
                INS_Create_Quote_Beneficiaries_Json beneficiaryPayload = new INS_Create_Quote_Beneficiaries_Json();
                beneficiaryPayload.referenceNumber = quoteNumber;
                Datetime dateOfBirth1 = member.BirthDate__c;
                INS_Create_Quote_Beneficiaries_Json.Beneficiary beneficiary = new INS_Create_Quote_Beneficiaries_Json.Beneficiary();
                beneficiary.AllocationAmount = Integer.valueOf(member.Allocation__c);
                beneficiary.AllocationType = 'PERCENTAGE';
                beneficiary.BenefitId = mainBenefitId;
                
                beneficiary.PersonId = (member.Person_Id__c == null) ? '' : member.Person_Id__c;
                beneficiary.BeneficiaryId = (member.Beneficiary_Id__c == null) ? '' : member.Beneficiary_Id__c;        
                beneficiary.Initials = member.Initial__c;
                beneficiary.Title = '';
                beneficiary.FirstName = member.FirstName__c;
                beneficiary.Surname = member.LastName__c;
                beneficiary.Gender = member.Gender__c;
                beneficiary.IdentityType = 'SAIDENTITYDOCUMENT';
                beneficiary.IdCountryOfIssue = userCountry;
                beneficiary.IdentityNumber = String.valueOf(member.IdentityNumber__c);
                beneficiary.DateOfBirth = dateOfBirth1.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
                beneficiary.Relationship = (member.RelationshipToInsured == 'Main Member') ? 'PREMIUMPAYER' : member.RelationshipToInsured;
                beneficiaryPayload.beneficiaries.add(beneficiary);
                
                if (String.isBlank(member.Beneficiary_Id__c)){
                    httpRequest.setMethod('POST');
                } else{
                    httpRequest.setMethod('PUT');
                }
                
                // Send HTTP request
                Http http = new Http();
                httpRequest.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes/' + quoteNumber + '/beneficiaries');
                httpRequest.setHeader('Content-Type', 'application/json');
                httpRequest.setHeader('Accept', 'application/json');
                httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
                httpRequest.setHeader('x-iam-country', 'SA');
                httpRequest.setTimeout(60000);
                httpRequest.setBody(JSON.serialize(beneficiaryPayload));

                system.debug ('INS_Create_Quote_Beneficiaries Payload : ' + JSON.serialize(beneficiaryPayload));

                response = http.send(httpRequest);
                
                if (response.getStatusCode() == 200){
                    InsurancePolicyParticipant processedMember = handleSuccessfulResponse(response, member);
                    returnList.add(processedMember);
                } else{
                    
                    throw new INS_CustomException(response.getBody());
                }
            }
        } catch (Exception ex){
            LOGGER.error('INS_Create_Quote_Beneficiaries.createQuoteBeneficiariesBulk', ex);
            throw new INS_CustomException(ex.getMessage());
        }
        
        return returnList;
    }  
    
    /**
    * @description Handles the Response of Create and Update Beneficiary API
    * @param beneficiaryIds
    * @param quoteNumber
    **/    
    @AuraEnabled
    public static void deleteQuoteBeneficiaries(List<String> beneficiaryIds, String quoteNumber){

        // Create a list to store INS_Quick_Quote_Wrapper.AddMember objects
        List<INS_Create_Quote_Beneficiaries_Json.itemKey> memberKeysList = new List<INS_Create_Quote_Beneficiaries_Json.itemKey>();
        
        // Create the request payload using INS_Quick_Quote_Wrapper
        INS_Create_Quote_Beneficiaries_Json.DeleteBeneficiaryPayload payload = new INS_Create_Quote_Beneficiaries_Json.DeleteBeneficiaryPayload();
        payload.referenceNumber = quoteNumber;
        
        for(String beneficiaryId : beneficiaryIds){
            // Create the ItemKey object and add it to the list
            INS_Create_Quote_Beneficiaries_Json.itemKey itemKey = new INS_Create_Quote_Beneficiaries_Json.itemKey();
            itemKey.id = beneficiaryId; // need to pass beneficiary Id
            itemKey.key = beneficiaryId; // // need to pass beneficiary Id
            memberKeysList.add(itemKey);
        }
        
        // Serialize the payload to JSON
        if (!memberKeysList.isEmpty()){
            payload.itemKeys = memberKeysList;
            String payloadJson = JSON.serialize(payload);
            
            // Get OAuth access token from OAuthHelper class
            try{
                String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
                
                HttpRequest httpRequest = new HttpRequest();
                HttpResponse response = new HttpResponse();
                httpRequest.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes/' + quoteNumber + '/beneficiaries');
                httpRequest.setMethod('PATCH');
                httpRequest.setHeader('Content-Type', 'application/json');
                httpRequest.setHeader('Accept', 'application/json');
                httpRequest.setHeader('Authorization', 'Bearer ' + accessToken);
                httpRequest.setTimeout(60000);
                httpRequest.setHeader('x-iam-country', 'SA');
                httpRequest.setBody(payloadJson);
                
                // Send HTTP request
                Http http = new Http();
                response = http.send(httpRequest);
                
                if (response.getStatusCode() != 200){
                    
                    throw new INS_CustomException(response.getBody());
                }
            }
            catch(exception ex){
                LOGGER.error('INS_Create_Quote_Beneficiaries.deleteQuoteBeneficiaries', ex);
               // throw new Exception(ex.getMessage());
                throw ex;
            }
        }         
    }    
    
    /**
    * @description Handles the Response of Create and Update Beneficiary API
    * @param response
    * @param member
    * @return member
    **/ 
    public static InsurancePolicyParticipant handleSuccessfulResponse(HttpResponse response, InsurancePolicyParticipant member){
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        
        if (responseData.containsKey('validationResult')){
            Map<String, Object> validationResult = (Map<String, Object>) responseData.get('validationResult');
            Boolean isValid = (Boolean) validationResult.get('isValid');
            
            if (!isValid){
                List<String> validationMessages = (List<String>) validationResult.get('validationMessages');
                String errorMessage = '';
                for (String message : validationMessages){
                    errorMessage += message + ', ';
                }
                errorMessage = errorMessage.removeEnd(', '); // removing the last trailing comma and space
                throw new AuraHandledException('Validation failed with the following messages: ' + errorMessage);
                
            }
        } 
        if (responseData.containsKey('beneficiaries')) {
            List<Object> beneficiaries = (List<Object>) responseData.get('beneficiaries');
            for (Object item : beneficiaries) {
                Map<String, Object> dataItem = (Map<String, Object>) item;
                member.Funeral_Benefit_Id__c = (String) dataItem.get('benefitId');
                member.Beneficiary_Id__c = (String) dataItem.get('beneficiaryId');
                member.Person_Id__c = (String) dataItem.get('personId');
                member.Allocation__c = (Integer) dataItem.get('allocationAmount');
            }
        }

        return member;
    }
}