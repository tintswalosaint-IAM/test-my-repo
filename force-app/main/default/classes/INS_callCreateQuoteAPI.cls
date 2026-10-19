public with sharing class INS_callCreateQuoteAPI {

	
	@AuraEnabled(cacheable=false)
    public static Map<String,Object> callCreateQuoteAPI(Map<String, Object> input, Map<String, Object> output, String accountId) {       
        
        INS_Quick_Quote_Wrapper.QuotePayload payload = generateRequestPayload(input, accountId);       
        String payloadJson = JSON.serialize(payload);
        System.debug('payloadJson=='+JSON.serialize(payloadJson));
        INS_SRV_Create_QuickQuote CreateQuickQuoteService = new INS_SRV_Create_QuickQuote(payloadJson);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_SRV_Create_QuickQuote.SERVICE_NAME);
        CreateQuickQuoteService.process(obj);
        insert obj;
        Map<String,Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(CreateQuickQuoteService.getResponseBody());
        System.debug('jsonResponse=='+JSON.serialize(jsonResponseMap));

        Integer statusCode = CreateQuickQuoteService.getResponseStatusCode();
        Map<String,Object> createQuoteResponseMap = new Map<String,Object>();

        if(statusCode == 201 || statusCode == 200){ 
            Map<String, Object> validation =
                (Map<String, Object>) jsonResponseMap.get('ValidationResult');
            String resultStatus = (String) validation.get('ResultStatus');
            if(validation != null){
                if('Failed'.equalsIgnoreCase(resultStatus)){
                    createQuoteResponseMap.put('hasError','true'); 
                    createQuoteResponseMap.put('CreateQuoteResponse', validation.get('Message')); 
                    }else if('Success'.equalsIgnoreCase(resultStatus)){
                        String quoteId = (String) jsonResponseMap.get('quoteId');
                        List<Object> responseMembers = (List<Object>) jsonResponseMap.get('members');
                        Object responseMember = (responseMembers != null && !responseMembers.isEmpty()) ? responseMembers[0] : null;                            
                        String memberId;                            
                        if (responseMembers != null && !responseMembers.isEmpty()){
                            Map<String, Object> memberMap = (Map<String, Object>) responseMember;
                            List<Object> memberBenefits = (List<Object>) memberMap.get('benefits');
                            if (memberBenefits != null && !memberBenefits.isEmpty()){
                                Map<String, Object> benefitMap = (Map<String, Object>) memberBenefits[0];
                                memberId = (String) benefitMap.get('memberId');

                                createQuoteResponseMap.put('memberId', memberId);
                                createQuoteResponseMap.put('benefitAmountValue', (String) benefitMap.get('benefitAmountValue'));
                                createQuoteResponseMap.put('coverAmount', (Decimal) benefitMap.get('coverAmount'));
                                createQuoteResponseMap.put('duration', (String) benefitMap.get('duration'));
                                createQuoteResponseMap.put('benefitKey', (String) benefitMap.get('benefitKey'));
                            }

                        }

                        createQuoteResponseMap.put('hasError','false');
                        createQuoteResponseMap.put('quoteId',quoteId);
                    }
                
                }else{
                    createQuoteResponseMap.put('hasError','false');       
                    createQuoteResponseMap.put('CreateQuoteResponse',JSON.deserializeUntyped(CreateQuickQuoteService.getResponseBody()));
                }           


        }else{ 
            createQuoteResponseMap.put('hasError','true');
            createQuoteResponseMap.put('CreateQuoteResponse',JSON.deserializeUntyped(CreateQuickQuoteService.getResponseBody()));
        } 
        
        output.put('CreateQuoteResponse', createQuoteResponseMap);
        return output;

    }
	
	public Static INS_Quick_Quote_Wrapper.QuotePayload  generateRequestPayload(Map<String, Object> input, String accountId){
        Map<String, Object> membersWrapper = (Map<String, Object>) input.get('PersonalInformation');        
        System.debug('INPUT JSON2 == ' + JSON.serializePretty(input));
        Map<String, Object> productsMetadata = (Map<String, Object>) input.get('INS_Products');
        //String accountId = (String) input.get('accountId');

        INS_Quick_Quote_Wrapper.QuotePayload payload = new INS_Quick_Quote_Wrapper.QuotePayload();
        payload.members = new List<INS_Quick_Quote_Wrapper.Member> ();
        // Members Details
        INS_Quick_Quote_Wrapper.Member member = new INS_Quick_Quote_Wrapper.Member();        
        member.firstName   = (String) membersWrapper.get('FirstName');
        member.lastName    = (String) membersWrapper.get('LastName');
        member.identityNumber    = (String) membersWrapper.get('IdNumber');
        member.gender      = (String) membersWrapper.get('Gender');
        member.email       = (String) membersWrapper.get('Email');
        if((String) productsMetadata.get('Country__c') == 'KE'){
            member.contactNumber ='+254' + (String) membersWrapper.get('PhoneNumber');
        }
               
        String dobStr = (String)membersWrapper.get('OS_DateOfBirth');
        Date dobDate = Date.valueOf(dobStr);
        Datetime dobDateTime = Datetime.newInstanceGMT(
            dobDate.year(), dobDate.month(), dobDate.day(), 0, 0, 0
        );
       
        member.dateOfBirth = dobDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
        System.debug('member.dateOfBirth=='+member.dateOfBirth);
        member.identityDocumentType = 'SAIDENTITYDOCUMENT';
        member.idCountryOfIssue =(String) productsMetadata.get('Country__c');
        member.customerExternalId = accountId;
        member.memberType = 'MAININSURED';

         INS_Quick_Quote_Wrapper.Beneficiaries beneficiaries = new INS_Quick_Quote_Wrapper.Beneficiaries();
        beneficiaries.allocationAmount = 100;
        beneficiaries.allocationType = 'PERCENTAGE';

        INS_Quick_Quote_Wrapper.Benefit benefit = new INS_Quick_Quote_Wrapper.Benefit();
        benefit.benefitType = 'MAINFUNERAL';
        benefit.benefitKey = '1.MAINFUNERAL';
        benefit.coverAmount = (Double) productsMetadata.get('Default_Cover_Amount__c');
        benefit.duration = 'Monthly';
        benefit.beneficiaries = new List<INS_Quick_Quote_Wrapper.Beneficiaries>{
            beneficiaries
        };

        member.benefits = new List<INS_Quick_Quote_Wrapper.Benefit>{
            benefit
        };

        payload.members.add(member);

        payload.quoteId = '';
        payload.channel = 'Salesforce';
        payload.consultantCode = [Select id,EmployeeNumber from User where id=:userInfo.getUserID()].EmployeeNumber;
        payload.annualBenefitIncrease = 0;
        payload.requestId = '';
        payload.cashBackOption = false;

        INS_Quick_Quote_Wrapper.ProductRules productRules = new INS_Quick_Quote_Wrapper.ProductRules();
        productRules.productId =  (String) productsMetadata.get('Product_Code__c');
        productRules.annualBenefitIncrease = 0;
        productRules.waiveWaitingPeriod = false;
        payload.productRules = productRules;        
        
        return payload;

    }

}