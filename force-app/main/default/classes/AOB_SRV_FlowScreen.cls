/**
 * Class service to prepare data for final offer, Protect your card and Card personalisation screens
 * 
 * <p>DBP-1499</p> 
 * 
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 * 
 * @date Feb 8th 2021 
 */
public with sharing class AOB_SRV_FlowScreen {
    public static final String DOC_TYPE = 'CONTR';
    /**
    * Method used to get data related to final offer with and without insurance screens from find open App API
    * @param    applicationId
    * @return   dto class with all details about both screens
    */
    public static AOB_DTO_FinalOffer getFinalOffer(Id applicationId){
        AOB_ApplicationLineItem__c appLineItem;
        Set<Id> finalOfferIds = new Set<Id>();
        List<AOB_FinalOffer__c> finalOffers = new List<AOB_FinalOffer__c>();
        List<AOB_Application__c> apps = [SELECT Id,AOB_TECH_FlowNames__c,AOB_TECH_OrderNo__c,AOB_OfferId__c
                                        FROM AOB_Application__c 
                                        WHERE Id=:applicationId];
        List<AOB_ApplicationLineItem__c> appLineItems = [SELECT Id,AOB_HasInsurance__c,AOB_ProductOption__c,AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c,
                                                        AOB_Product__r.ExternalId,AOB_Product__r.AOB_ProductCategory__c,AOB_Product__r.AOB_MinimumMonthlyRepayment__c, 
                                                         AOB_ProductOption__r.AOB_Product__r.Name ,AOB_TechFormattedProductName__c
                                                        FROM  AOB_ApplicationLineItem__c 
                                                        WHERE AOB_Application__c =:applicationId];
        AOB_DTO_FinalOffer finalOfferDTO = new AOB_DTO_FinalOffer();
        Map<String, String> variableMap = AOB_Utils.getAppSettingByCategory(AOB_Constants.FINAL_OFFER);
        //Get the NTU list to display in the reject popUp
        finalOfferDTO.rejectData = [SELECT Id, AOB_Code__c, Name ,AOB_Value__c
                                    FROM AOB_ReferencedData__c
                                    WHERE AOB_SAPField__c =: AOB_Constants.NTU AND AOB_isActive__c = True];
        String[] customVariables = variableMap.get(AOB_Constants.FINAL_OFFER_API_VAR).split(';');
        if(!appLineItems.isEmpty()){
            appLineItem = appLineItems[0];
        }         
        if(appLineItem.AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c != null){
            finalOfferDTO.commerceSite = AOB_Utils.getCountrySetting(appLineItem.AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c).AOB_Commerce_Cloud_URL__c;
            finalOfferDTO.currencyString = AOB_Utils.getCountrySetting(appLineItem.AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c).AOB_Currency__c;
        } 
       
        finalOfferDTO.techFormattedProductName =appLineItem.AOB_TechFormattedProductName__c;
        // Get the flow sceen records from the product
        for(AOB_ProductFinalOffer__c productFinalOffer :[SELECT Id, AOB_FinalOffer__c 
                                                        FROM AOB_ProductFinalOffer__c 
                                                        WHERE AOB_Product__c =:appLineItem.AOB_Product__c]){
            finalOfferIds.add(productFinalOffer.AOB_FinalOffer__c);
        }    
        if(appLineItem.AOB_HasInsurance__c == true){
            finalOffers = [SELECT Id,AOB_APIName__c,AOB_Is_Currency__c,AOB_Unit__c ,AOB_Is_Right__c  ,AOB_Description__c,AOB_Detail__c ,AOB_Helptext__c,         
                           AOB_Label__c ,AOB_Order__c ,AOB_ParentLevel1__c , AOB_ParentLevel2__c,AOB_Section__c ,AOB_VAT__c 
                           FROM  AOB_FinalOffer__c 
                           WHERE Id IN:finalOfferIds 
                           AND AOB_Screen__c =:AOB_Constants.SCREEN_FINAL_OFFER 
                           Order by AOB_Order__c];
        }else{
            finalOffers = [SELECT Id,AOB_APIName__c ,AOB_Is_Currency__c,AOB_Unit__c ,AOB_Is_Right__c  ,AOB_Description__c,AOB_Detail__c ,AOB_Helptext__c,
                           AOB_Label__c ,AOB_Order__c ,AOB_ParentLevel1__c , AOB_ParentLevel2__c,AOB_Section__c ,AOB_VAT__c 
                           FROM  AOB_FinalOffer__c 
                           WHERE Id IN:finalOfferIds 
                           AND AOB_InsuranceRelated__c = false 
                           AND AOB_Screen__c =:AOB_Constants.SCREEN_FINAL_OFFER 
                           Order by AOB_Order__c];
        }
        // FOA API CALL
        String response = AOB_SRV_OpenApplications.callOpenApplications();
        Map<String, Object> jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(response);
        if(jsonMAp.containskey('errorCode'))
            finalOfferDTO.errorCode=(Integer)jsonMAp.get('errorCode');
        if(jsonMAp.containskey('message'))
            finalOfferDTO.message=(String)jsonMAp.get('message');
        if(finalOfferDTO.errorCode!=50013 && finalOfferDTO.errorCode!=50015 && finalOfferDTO.errorCode!=50016 && finalOfferDTO.errorCode!=50017 && finalOfferDTO.errorCode!=50018  && finalOfferDTO.errorCode!=50019 )
        {
            Map<String, Object> offerItem = AOB_SRV_OpenApplications.getOfferFromFOA(response);
            List<Object> productConditionItems = AOB_SRV_OpenApplications.getConditionItems(offerItem);
            finalOfferDTO.productId = AOB_SRV_OpenApplications.getProductCode(offerItem);
            Boolean hasDocumentUpload = false;
            if(productConditionItems != null){
                Map<String, Object> fieldsMap;
                for(Object eachDoc : productConditionItems){
                    fieldsMap = (Map<String, Object>) eachDoc;
                    if(fieldsMap.get('showToCustomer') == true) {
                        hasDocumentUpload = true;
                    }     
                }
            }
            String categoryId=AOB_SRV_OpenApplications.getProductCategory(offerItem);
            if(!apps.isEmpty()){
                finalOfferDTO.offerId = (String)offerItem.get('offerId');
                apps[0].AOB_OfferId__c = finalOfferDTO.offerId;
                apps[0].AOB_ShowDocumentUpload__c =hasDocumentUpload;
                apps[0].AOB_CategoryId__c =categoryId;
                update apps[0];
                Map<string,object> offerLineItemDetails=(Map<String, Object>)offerItem.get('offerLineItemDetails');
                List<Object> offerLineItems  = (List<Object>)offerLineItemDetails.get('items');
                Map<String, Object> offerLineItem = (Map<String, Object>)offerLineItems[0];
                if(!String.isBlank(apps[0].AOB_TECH_OrderNo__c)){
                    finalOfferDTO.isPlaceOrder = true;
                }
            }
            finalOfferDTO.expiryDate = AOB_Utils.formatDate((String)offerItem.get('expiryDate')); 
            finalOfferDTO.remainingDays = AOB_Utils.remainingDays((String)offerItem.get('expiryDate'));
            Map<String, Object> offerItemDetails = (Map<String, Object>)offerItem.get('offerLineItemDetails');
            List<Object> offerLineItems  = (List<Object>)offerItemDetails.get('items');
            //check if we have only one or I need to get only the approved one
            Map<String, Object> offerLineItem = (Map<String, Object>)offerLineItems[0];
            String offerBusinessStatus=(String)offerLineItem.get('offerLineItemStatus');
            finalOfferDTO.offerLineItemStatus=offerBusinessStatus; 
            Map<String, Object> productDetails = (Map<String, Object>)offerLineItem.get('productTileDetails');
            // to update
            if(productDetails != null){
                finalOfferDTO.productName = (String)productDetails.get('productTitle'); 
            }
            //get the list by product : where is the product ?
            for(AOB_FinalOffer__c finalOffer:finalOffers){
                AOB_DTO_FlowScreenRecord finalOfferField = new AOB_DTO_FlowScreenRecord();                                 
                Map<String, Object> offerInfo = (Map<String, Object>)offerLineItem.get(finalOffer.AOB_ParentLevel1__c);  
                replaceVariables(finalOfferDTO.currencyString,finalOffer,appLineItem,offerInfo,customVariables);
                if(finalOffer.AOB_APIName__c != null){
                    if(finalOffer.AOB_ParentLevel2__c != null){
                        Map<String, Object> offerInfo2 = (Map<String, Object>)offerInfo.get(finalOffer.AOB_ParentLevel2__c);  
                        finalOfferField.Value = String.valueOf(offerInfo2.get(finalOffer.AOB_APIName__c));
                    }else{    
                        finalOfferField.Value = String.valueOf(offerInfo.get(finalOffer.AOB_APIName__c)); 
                    }    
                }    
                finalOfferField.finalOffer = finalOffer;  
                if(finalOffer.AOB_Section__c == AOB_Constants.FINAL_OFFER_SECTION){
                    finalOfferDTO.mainSectionFields.add(finalOfferField);
                }else{
                    finalOfferDTO.seeMoreSectionFields.add(finalOfferField);
                }
            } 
            // get info for commerce cloud place order
            AOB_DTO_CommerceCloudConnector.Order order = new AOB_DTO_CommerceCloudConnector.Order();
            order.c_salesforceReferenceId = applicationId;
            order.c_sapReferenceId = (String)offerItem.get('offerId');
            order.c_commerceStatus = (String)offerItem.get('offerStatus');
            order.c_originatingChannel = (String)offerItem.get('originatingChannel');
            order.c_expiryDate = (String)offerItem.get('expiryDate');
            finalOfferDTO.order = order;
            //getConditionCode=='CONTR'
            Map<string,object> contractConditions=(Map<String, Object>)offerLineItem.get('contractConditions');
            if(contractConditions != null){
                List<Object> ContractLineItems  = (List<Object>)contractConditions.get('items');
                Map<string,object> contractMainItem=new Map<string,object>();
                Map<string,object> contractLoopItem;
                for(Object contractLineItem:ContractLineItems){
                    contractLoopItem=(Map<String, Object>)contractLineItem;
                    if(contractLoopItem.get('conditionCode') == DOC_TYPE){
                        contractMainItem = contractLoopItem;
                    }
                }
    
                finalOfferDTO.contractId=(String)contractMainItem.get('documentGuid');
            }
        }
        return finalOfferDTO;
    } 
     /**
    * Method used to get data related to card personalisation & protect your card screens from find open App API
    * @param    token the token to authenticate to the findOpenApps API
    * @param    applicationId
    * @return   dto class with all details about both screens
    */
    @AuraEnabled
    public static AOB_DTO_CardPersonalization getCardPersonalization(Id applicationId){
        AOB_ApplicationLineItem__c appLineItem;
        List<AOB_Application__c> myApp = [SELECT Id,AOB_CategoryId__c FROM AOB_Application__c WHERE Id =:applicationId];
        Set<Id> finalOfferIds = new Set<Id>();
        List<AOB_ApplicationLineItem__c> appLineItems = [SELECT Id,AOB_CardOption__c ,AOB_CardDeliveryFee__c ,AOB_ProductOption__c,
                                                        AOB_ProductOption__r.AOB_InsurancePlanID__c,AOB_HasInsurance__c,
                                                        AOB_Product__r.ExternalId,AOB_Product__r.AOB_MinimumMonthlyRepayment__c, AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c,AOB_Product__r.AOB_ProductCategory__c,
                                                        AOB_Application__r.AOB_Customer__r.personTitle,AOB_MonthlyServiceFee__c,AOB_VariableInterestRate__c,
                                                        AOB_Application__r.AOB_Customer__r.LastName  
                                                        FROM  AOB_ApplicationLineItem__c 
                                                        WHERE AOB_Application__c =:applicationId];     
        if(!appLineItems.isEmpty()){
            appLineItem = appLineItems[0];
        }
        AOB_DTO_CardPersonalization cardPersonalization = new AOB_DTO_CardPersonalization();
        if(appLineItem.AOB_ProductOption__c != null){
                  cardPersonalization.selectedInsurance = appLineItem.AOB_ProductOption__r.AOB_InsurancePlanID__c;
        }  
        if(appLineItem.AOB_Product__r.AOB_ProductCategory__c != null){
            cardPersonalization.productName = appLineItem.AOB_Product__r.AOB_ProductCategory__c;
        }
        if(appLineItem.AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c != null){ 
            cardPersonalization.currencyString = AOB_Utils.getCountrySetting(appLineItem.AOB_Application__r.AOB_Customer__r.AOB_CommerceSiteId__c).AOB_Currency__c;
        }   
        if(appLineItem.AOB_Application__r.AOB_Customer__r.LastName != null){
            cardPersonalization.customerFirstName = appLineItem.AOB_Application__r.AOB_Customer__r.LastName;
        }
        if(appLineItem.AOB_Application__r.AOB_Customer__r.personTitle != null){
            cardPersonalization.salutation = appLineItem.AOB_Application__r.AOB_Customer__r.personTitle;
        }
        cardPersonalization.TermAndConditions = AOB_Utils.getAppSettingByCategory(AOB_Constants.LINK).get(AOB_Constants.TERM_AND_CONDITIONS);
        // FOA API call
        String response = AOB_SRV_OpenApplications.callOpenApplications(); 
        Map<String, Object> jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(response);
        if(jsonMAp.containskey('errorCode'))
            cardPersonalization.errorCode=(Integer)jsonMAp.get('errorCode');
        if(jsonMAp.containskey('message'))
            cardPersonalization.message=(String)jsonMAp.get('message');
        if(cardPersonalization.errorCode!=50015 && cardPersonalization.errorCode!=50016 && cardPersonalization.errorCode!=50017 && cardPersonalization.errorCode!=50018 && cardPersonalization.errorCode!=50019 )
        {
            Map<String, Object> quoteItem = AOB_SRV_OpenApplications.getQuoteFromFOA(response);
            Map<String, Object> productItemDetails = (Map<String, Object>)quoteItem.get('productItemDetails');
            List<Object> productItems  = (List<Object>)productItemDetails.get('items');
            Map<String, Object> productItemDetail = new Map<String, Object>();
            Map<String, Object> appProductItem = new Map<String, Object>();
            // Select the right product using the product code from the related app line item
            for(Object productItem:productItems){ 
                Map<String, Object> prdItem = (Map<String, Object>)productItem;
                Map<String, Object> prd = (Map<String, Object>)prdItem.get('productDetails');
                if(prd.get('productId') == appLineItem.AOB_Product__r.ExternalId){
                    appProductItem = prdItem;
                    cardPersonalization.productId = appLineItem.AOB_Product__r.ExternalId;
                    cardPersonalization.minimumMonthlyRepayment = appLineItem.AOB_Product__r.AOB_MinimumMonthlyRepayment__c;
                    cardPersonalization.hasInsurance = appLineItem.AOB_HasInsurance__c;
                    myApp[0].AOB_CategoryId__c = (String)prd.get('categoryId');
                }
            }  
            // Product item detail          
            Map<String, Object> affordabilityDetails = (Map<String, Object>)appProductItem.get('affordabilityDetails');
            if(affordabilityDetails!=null && affordabilityDetails.containsKey('loanTerm')){
                //Loan Term Options
                Map<String, Object> loanTerm = (Map<String, Object>)affordabilityDetails.get('loanTerm'); 
                if(loanTerm != null){
                    Map<String, Object> termValues = (Map<String, Object>)loanTerm.get('termValues'); 
                    cardPersonalization.termItems = (List<Object>)termValues.get('items');
                    if((String)loanTerm.get('minLoanTerm')==(String)loanTerm.get('maxLoanTerm')){
                        cardPersonalization.selectedTerm = Integer.valueOf(loanTerm.get('minLoanTerm'));
                    }
                    else if((String)loanTerm.get('minLoanTerm')!= '0' && (String)loanTerm.get('maxLoanTerm')!= '0'){
                        cardPersonalization.selectedTerm = (Integer)loanTerm.get('selectedTerm');
                    }
                    else{
                        cardPersonalization.selectedTerm = 0;
                    }
                    cardPersonalization.personalizeCard.loanTerm = (Integer)cardPersonalization.termItems[cardPersonalization.termItems.size()-1];
                }
            }            
            //personalizeCard 
            Integer maxAount;
            if(affordabilityDetails!=null && affordabilityDetails.containsKey('maxLoanAmount')){
                maxAount =  Math.abs((Integer)affordabilityDetails.get('maxLoanAmount'));
            }
            else{
                maxAount=0;
            }
            if(affordabilityDetails.get('maxRepaymentAmount') != null){
              cardPersonalization.maxRepaymentAmount = (Decimal)affordabilityDetails.get('maxRepaymentAmount');
            }
            cardPersonalization.personalizeCard.minAmount = (Integer)affordabilityDetails.get('minLoanAmount');
            cardPersonalization.personalizeCard.maxAmount = maxAount;
            cardPersonalization.creditLimit = maxAount; 
            // interest rate
            Map<String, Object> interestRate = (Map<String, Object>)affordabilityDetails.get('interestRate'); 
            cardPersonalization.personalizeCard.interestRate = (Decimal)interestRate.get('totalInterestRate');  
            appLineItem.AOB_VariableInterestRate__c = cardPersonalization.personalizeCard.interestRate;
            //monthlyServiceFee 
            Map<String, Object> paymentDetails = (Map<String, Object>)appProductItem.get('paymentDetails');
            cardPersonalization.personalizeCard.monthlyServiceFee = Decimal.valueOf(String.valueOf(paymentDetails.get('monthlyServiceFee')));
            appLineItem.AOB_MonthlyServiceFee__c = Decimal.valueOf(String.valueOf(paymentDetails.get('monthlyServiceFee')));
            
            for(AOB_ProductFinalOffer__c productFinalOffer :[SELECT Id, AOB_FinalOffer__c 
                                                            FROM AOB_ProductFinalOffer__c 
                                                            WHERE AOB_Product__c =:appLineItem.AOB_Product__c]){
                finalOfferIds.add(productFinalOffer.AOB_FinalOffer__c);
            }    
            // debit order info needed 
            if(appProductItem.get('creditCardDetails') != null){
                Map<String, Object> creditCardDetails = (Map<String, Object>)appProductItem.get('creditCardDetails');
                appLineItem.AOB_CardOption__c = (String)creditCardDetails.get('cardOption');
            }   
            //retreive flow records related to card personalisation page 
            for(AOB_FinalOffer__c rec :[SELECT Id,AOB_APIName__c,AOB_Is_Currency__c,AOB_Unit__c,AOB_Description__c,AOB_Detail__c ,
                                        AOB_Helptext__c, AOB_Label__c ,AOB_ParentLevel1__c,AOB_ParentLevel2__c ,AOB_VAT__c 
                                        FROM  AOB_FinalOffer__c 
                                        WHERE Id IN:finalOfferIds 
                                        AND AOB_Screen__c =:AOB_Constants.SCREEN_CARD_PERSONALIZATION 
                                        AND AOB_InsuranceRelated__c = false
                                        Order by AOB_Order__c]){
                AOB_DTO_FlowScreenRecord record = new AOB_DTO_FlowScreenRecord();
                if(appProductItem.get(rec.AOB_ParentLevel1__c) != null){
                    Map<String, Object> recordInfo = (Map<String, Object>)appProductItem.get(rec.AOB_ParentLevel1__c);  
                    if(rec.AOB_ParentLevel2__c != null){
                        Map<String, Object> recordInfo2 = (Map<String, Object>)recordInfo.get(rec.AOB_ParentLevel2__c);  
                        record.Value = String.valueOf(recordInfo2.get(rec.AOB_APIName__c));
                    }else{    
                        record.Value = String.valueOf(recordInfo.get(rec.AOB_APIName__c)); 
                    }     
                }
                record.finalOffer = rec;
                cardPersonalization.flowRecords.add(record);
            }
            //retreive flow records related to insurance page 
            List<AOB_FinalOffer__c> insuranceFlowRecords = [SELECT Id,AOB_APIName__c,AOB_Formula__c,AOB_Is_Currency__c,AOB_Unit__c,AOB_Description__c,AOB_Detail__c ,
                                                            AOB_Helptext__c, AOB_Label__c ,AOB_ParentLevel1__c,AOB_ParentLevel2__c ,AOB_VAT__c 
                                                            FROM  AOB_FinalOffer__c 
                                                            WHERE Id IN:finalOfferIds 
                                                            AND AOB_Is_Right__c = false
                                                            AND AOB_Screen__c =:AOB_Constants.SCREEN_Insurance 
                                                            Order by AOB_Order__c];  
            //retreive flow records related to insurance page 
            for(AOB_FinalOffer__c estimatedFlowRec :[SELECT Id,AOB_Formula__c,AOB_Is_Currency__c,AOB_Unit__c,AOB_Description__c,
                                                    AOB_Helptext__c, AOB_Label__c ,AOB_Is_Right__c,AOB_InsuranceRelated__c
                                                    FROM  AOB_FinalOffer__c 
                                                    WHERE Id IN:finalOfferIds 
                                                     AND AOB_Screen__c =:AOB_Constants.SCREEN_INSURANCE 
                                                    AND AOB_Is_Right__c = true
                                                    Order by AOB_Order__c]){
                AOB_DTO_FlowScreenRecord record = new AOB_DTO_FlowScreenRecord();
                record.finalOffer = estimatedFlowRec;
                if(estimatedFlowRec.AOB_InsuranceRelated__c){
                    cardPersonalization.estimatedMonthlyRepaymentWithIns = record;
                }else{
                    cardPersonalization.estimatedMonthlyRepayment = record;
                }  
            }                                                          
            Map<String, Object> productPricingConditions = (Map<String, Object>)appProductItem.get('productPricingConditions');
            List<Object> productPricingItems  = (List<Object>)productPricingConditions.get('items');
            Map<String, Object> productPricing = (Map<String, Object>)productPricingItems[0];
            Map<String, Object> conditionScales  = (Map<String, Object>)productPricing.get('conditionScales');
            List<Object> conditionItems  = (List<Object>)conditionScales.get('items');
            // Calculate the initiation fee
            for(integer i=0;i<conditionItems.size();i++){ 
                AOB_DTO_CardPersonalization.scale s = new AOB_DTO_CardPersonalization.scale();  
                Map<String, object> item = (Map<String, object>)conditionItems[i];
                if(i != 0 && i < conditionItems.size()-1){
                    Map<String, object> nextItem = (Map<String, object>)conditionItems[i+1];         
                    s.scaleMaxAmount = (Integer)nextItem.get('scaleAmount');
                }
                s.scaleAmount = (Integer)item.get('scaleAmount');
                s.scaleRate = (Decimal)item.get('scaleRate');
                cardPersonalization.scales.add(s);
            }
            // Insurance 
            Map<String, Object> insurances = (Map<String, Object>)appProductItem.get('insurance');
            if(insurances != null){
                List<Object> insuranceItems  = (List<Object>)insurances.get('items');
                if(!insuranceItems.isEmpty()){
                    appLineItem.AOB_Insurance_Eligibility__c = true;
                }
                else{
                    appLineItem.AOB_Insurance_Eligibility__c = false;
                }
                cardPersonalization.insuranceEligibility = appLineItem.AOB_Insurance_Eligibility__c;
                for(AOB_FinalOffer__c rec:insuranceFlowRecords){
                    AOB_DTO_FlowScreenRecord record = new AOB_DTO_FlowScreenRecord();
                    if(!String.isBlank(rec.AOB_Formula__c)){
                        record.finalOffer = rec;
                        record.Value = rec.AOB_Formula__c;
                        cardPersonalization.assuranceFlowRecords.add(record);
                    }else{
                        if(appProductItem.get(rec.AOB_ParentLevel1__c) != null){
                            Map<String, Object> recordInfo = (Map<String, Object>)appProductItem.get(rec.AOB_ParentLevel1__c);  
                            if(rec.AOB_ParentLevel2__c != null){
                                Map<String, Object> recordInfo2 = (Map<String, Object>)recordInfo.get(rec.AOB_ParentLevel2__c);  
                                record.Value = String.valueOf(recordInfo2.get(rec.AOB_APIName__c));
                            }else{    
                                record.Value = String.valueOf(recordInfo.get(rec.AOB_APIName__c)); 
                            }     
                        }
                        record.finalOffer = rec; 
                        cardPersonalization.assuranceFlowRecords.add(record);
                    }
                }
                // list of insurance
                for(Object ins :insuranceItems){
                    Map<String, Object> insuranceItem =(Map<String, Object>)ins;
                    Map<String, Object> insurancePlan = (Map<String, Object>)insuranceItem.get('insurancePlan'); 
                    cardPersonalization.productInsuranceId = (String)insuranceItem.get('insuranceProductId'); 
                    List<Object> insurancePlanItems  = (List<Object>)insurancePlan.get('items');
                    // list for insurance plan
                    for(Object insurancePI:insurancePlanItems){
                        AOB_DTO_CardPersonalization.insurance insurance = new AOB_DTO_CardPersonalization.insurance();
                        Map<String, Object> insurancePlanItem = (Map<String, Object>)insurancePI;
                        Map<String, Object> description = (Map<String, Object>)insurancePlanItem.get('description');
                        Map<String, Object> insuranceFeeDetails = (Map<String, Object>)insurancePlanItem.get('insuranceFeeDetails'); 
                        //insurance description 
                        List<Object> descriptionItems  = (List<Object>)description.get('items'); 
                        for(Object obj : descriptionItems){ 
                            Map<String, Object> benefit = (Map<String, Object>)obj;
                            insurance.benefits.add((String)benefit.get('insuranceDescription'));
                        }
                        insurance.insuranceName = (String)insurancePlanItem.get('insuranceDisplayName');
                        insurance.insuranceId = (String)insurancePlanItem.get('planId'); 
                        insurance.insuranceProductDesc = (String)insuranceItem.get('productDescription'); 
                        insurance.planRate = (Decimal)insuranceFeeDetails.get('planRateAmount');
                        if(insurancePlanItem.get('policyFee') != null){
                            insurance.policyFee = (String)insurancePlanItem.get('policyFee');
                        }
                        if(insurance.planRate != 0){ 
                            insurance.insuranceCoversUp = maxAount;
                        }  
                        cardPersonalization.insurances.put(insurance.insuranceId,insurance);
                        cardPersonalization.mustHaveInsurrance = (boolean)insuranceItem.get('isInsuranceMandatory');
                    }
                }
          }else{
              appLineItem.AOB_Insurance_Eligibility__c = false;
          }
        }
        update myApp[0];
        update appLineItem;
        return cardPersonalization;
    } 
    /**
    * Method used to replace dynamic variables exists in the label, section title and description fields
    * @param    currencyString
    * @param    finalOffer fields
    * @param    offerLineItem 
    * @param    customVariables
    */
    private static void replaceVariables(String currencyString, AOB_FinalOffer__c finalOffer,AOB_ApplicationLineItem__c appLineItem, Map<String, Object> offerLineItem, String[] customVariables){
        String productName = '';
        String monthlyRepayment = '3';
        monthlyRepayment = ''+appLineItem.AOB_Product__r.AOB_MinimumMonthlyRepayment__c;
        if(appLineItem.AOB_ProductOption__c != null){
            productName = appLineItem.AOB_ProductOption__r.AOB_Product__r.Name;
        }
        if(!String.isBlank(finalOffer.AOB_Description__c)){
            finalOffer.AOB_Description__c = finalOffer.AOB_Description__c.replace('{productName}',productName);
            finalOffer.AOB_Description__c = finalOffer.AOB_Description__c.replace('{currency}',currencyString);
        }    
        if(!String.isBlank(finalOffer.AOB_Label__c)){
            finalOffer.AOB_Label__c = finalOffer.AOB_Label__c.replace('{productName}',productName);
            finalOffer.AOB_Label__c = finalOffer.AOB_Label__c.replace('{currency}',currencyString);
            finalOffer.AOB_Label__c = finalOffer.AOB_Label__c.replace('{monthlyRep}',monthlyRepayment);
        }
        if(offerLineItem != null){
            for(String variable:customVariables){
                String[] var = variable.Split(':');
                String value = '';
                if(var.size() == 2){
                    Map<String, Object> offerInfo = (Map<String, Object>)offerLineItem.get(var[0]); 
                    value = String.valueOf(offerInfo.get(var[1]));
                }else{
                    value = String.valueOf(offerLineItem.get(var[0]));
                }
                if(!String.isBlank(finalOffer.AOB_Label__c) && finalOffer.AOB_Label__c.contains(variable)){
                    finalOffer.AOB_Label__c = finalOffer.AOB_Label__c.replace('{'+variable+'}',value);
                }
                if(!String.isBlank(finalOffer.AOB_Description__c) && finalOffer.AOB_Description__c.contains(variable)){
                    finalOffer.AOB_Description__c = finalOffer.AOB_Description__c.replace('{'+variable+'}',value);
                }
            }
        }
    }

/**
* Method used to see if the Customer Has Insurance
* @param	applicationId
* @return   Boolean
*/
public static Boolean isCustomerHasInsurance(String applicationId){
    return [SELECT Id,AOB_HasInsurance__c 
    FROM AOB_ApplicationLineItem__c  
    WHERE AOB_Application__c =:applicationId]?.AOB_HasInsurance__c;
    }
}