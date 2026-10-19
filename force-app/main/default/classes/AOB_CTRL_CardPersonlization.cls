/**
 * Controller to prepare data that will be displayed in protect your card and personalize your card
 * 
 * <p>DPB-1285 and DPB-1286</p> 
 * 
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 * 
 * @date Nov 20th 2020 
 */
public with sharing class AOB_CTRL_CardPersonlization { 
    public static final String SERVICE_NAME = AOB_CTRL_CardPersonlization.class.getName();
    /** 
    * Method used to call API to get an access token to be able to call APIs
    * @return   String
    */
    @auraEnabled
    public static String callAccessToken(){
        try{
            return AOB_SRV_OpenApplications.callGetToken();
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, 'AOB_CTRL_CardPersonlization.callAccessToken');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /** 
    * @param    token the token to authenticate to the findOpenApps API
    * @return   json response from the API
    */
    @auraEnabled
    public static String callFindOpenApplications(){
        try{
            string json = AOB_SRV_OpenApplications.callOpenApplications();
            return json;
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, 'AOB_CTRL_CardPersonlization.callFindOpenApplications');
            throw new AuraHandledException(error.getMessage());
        }
    }
    /**
    * Method used to get data related to card personalisation & protect your card screens from find open App API
    * @param    applicationId
    * @return   dto class with all details about both screens
    */
    @AuraEnabled
    public static AOB_DTO_CardPersonalization getCardPersonalization(Id applicationId){
        AOB_DTO_CardPersonalization cardPersonalisation;
        try{
            cardPersonalisation = AOB_SRV_FlowScreen.getCardPersonalization(applicationId);                       
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, 'AOB_CTRL_CardPersonlization.getCardPersonalization');
            throw new AuraHandledException(error.getMessage());
        }
        return cardPersonalisation;
    }
    /**
     * Method used to save the wanted value and the contract Duration
     * @param	wantedAmount
     * @param	contractDuration
     * @param	applicationId
     */
    @AuraEnabled
    public static void updateAppLineItem(Decimal wantedAmount,Decimal contractDuration,Decimal estimatedMonthlyRepayment,String productId,Id applicationId){
        try{
            List<AOB_ApplicationLineItem__c> appLineItem = [SELECT Id,
                                                            AOB_HasInsurance__c,
                                                            AOB_RequestedValue__c,
                                                            AOB_ProductOption__c,
                                                            AOB_InsuranceMonthlyRepayment__c,
                                                            AOB_MonthlyServiceFee__c,
                                                            AOB_VariableInterestRate__c,
                                                            AOB_TECH_CCInsuranceID__c,
                                                            AOB_TECH_CCProductID__c
                                                            FROM AOB_ApplicationLineItem__c
                                                            WHERE AOB_Application__c = :applicationId AND AOB_Product__r.ExternalId = :productId];
            if(!appLineItem.isEmpty()){
                appLineItem[0].AOB_RequestedValue__c = wantedAmount!=null?wantedAmount:0;
                appLineItem[0].AOB_ContractDuration__c = contractDuration!=null?contractDuration:0; 
                appLineItem[0].AOB_EstimatedMonthlyRepayment__c = estimatedMonthlyRepayment!=null?estimatedMonthlyRepayment:0;    
            }
            update appLineItem;
        } 
        catch (Exception error){
        	throw new AuraHandledException(error.getMessage());
        }
    } 
    /**
    * Method used to save the wanted value and the insurance chosen by the customer in Salesforce
    * @param    wantedAmount
    * @param    chosenInsurance
    * @param    applicationId
    */
    @AuraEnabled 
    public static void setDataToSalesforce(String token, Decimal wantedAmount, Decimal initiationFee, String estimatedMonthlyRepayment, Boolean newInsurance, String productInsuranceId, 
                                            String productId, Id applicationId, String monthlyRepayment, String estimatedMonthlyRepaymentWithoutIns, String currentInsurance){
        
        //gets the right application line item related to the parent product
        List<AOB_ApplicationLineItem__c> appLineItem = [SELECT Id,AOB_HasInsurance__c,AOB_RequestedValue__c, AOB_ProductOption__c ,AOB_InsuranceMonthlyRepayment__c,
                                                        AOB_MonthlyServiceFee__c,AOB_VariableInterestRate__c,AOB_TECH_CCInsuranceID__c,AOB_TECH_CCProductID__c
                                                        FROM  AOB_ApplicationLineItem__c 
                                                        WHERE AOB_Application__c =:applicationId 
                                                        AND AOB_Product__r.ExternalId =:productId];
        Map<String,Object> insurance = new Map<String,Object>();
        if(!appLineItem.isEmpty()){
            AOB_DTO_CommerceCloudConnector.Insurance product = new AOB_DTO_CommerceCloudConnector.Insurance();
            List<AOB_DTO_CommerceCloudConnector.Insurance> products = new List<AOB_DTO_CommerceCloudConnector.Insurance>();
            // product id is the insurance Id "productInsuranceId"
            Decimal decimalEstimatedMonthlyRepayment = Decimal.valueOf(!String.isEmpty(estimatedMonthlyRepayment)?estimatedMonthlyRepayment.replace(',','.'):'0');
            Decimal decimalEstimatedMonthlyRepaymentWithoutIns = Decimal.valueOf(!String.isEmpty(estimatedMonthlyRepaymentWithoutIns)?estimatedMonthlyRepaymentWithoutIns.replace(',','.'):'0');
            Decimal decimalMonthlyRepayment = Decimal.valueOf(!String.isEmpty(monthlyRepayment)?monthlyRepayment.replace(',','.'):'0');

            product.product_id = productInsuranceId;
            product.c_monthlyRepaymentAmount = decimalMonthlyRepayment;      
            if(currentInsurance != null){
                insurance = (Map<String,Object>)System.JSON.deserializeUntyped(currentInsurance);
                List<AOB_ProductOption__c> productOption = [SELECT Id 
                                                            FROM  AOB_ProductOption__c 
                                                            WHERE AOB_InsurancePlanID__c =:(String)insurance.get('insuranceId')
                                                            AND AOB_Product__r.ExternalId =:productInsuranceId];
                product.c_productDescription = (String)insurance.get('insuranceProductDesc');
                product.c_insuranceDisplayName = (String)insurance.get('insuranceName');
                product.c_insurancePlanId = (String)insurance.get('insuranceId');
                if(!productOption.isEmpty()){
                    appLineItem[0].AOB_ProductOption__c = productOption[0].Id;
                } 
            }
            products.add(product); 
            appLineItem[0].AOB_EstimatedMonthlyRepayment__c  = decimalEstimatedMonthlyRepayment;
            appLineItem[0].AOB_RequestedValue__c = wantedAmount; 
            appLineItem[0].AOB_InitiationFee__c = initiationFee;
            try{
                if(currentInsurance != null){
                    if(newInsurance == true){
                        appLineItem[0].AOB_HasInsurance__c = true; 
                        appLineItem[0].AOB_InsuranceMonthlyRepayment__c = decimalMonthlyRepayment;
                        // add new insurance
                        String response = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC(token,products,'',false);
                        Map<String, Object> jsonMAp = (Map<String, Object>)System.JSON.deserializeUntyped(response);
                        for(Object obj:(List<Object>)jsonMAp.get('product_items')){
                            Map<String,Object> CCInsurance = (Map<String,Object>)obj;
                            if((String)CCInsurance.get('c_productType') == 'insurance'){
                                appLineItem[0].AOB_TECH_CCInsuranceID__c = (String)CCInsurance.get('item_id');
                            }
                        }
                    }else{ 
                        // update existing insurance
                        if(String.IsNotBlank(appLineItem[0].AOB_TECH_CCInsuranceID__c)){
                            String response = AOB_SRV_CommerceCloudConnector.addOUpdateInsuranceCC(token,products,appLineItem[0].AOB_TECH_CCInsuranceID__c,false);
                        }
                    }   
                }
                update appLineItem; 
                AOB_SRV_CommerceCloudConnector.updateBasket(token,initiationFee,wantedAmount,decimalEstimatedMonthlyRepayment,decimalEstimatedMonthlyRepaymentWithoutIns,appLineItem[0].AOB_TECH_CCProductID__c);               
            }catch(Exception error){
                CMN_UTIL_Logger.error(error, 'AOB_CTRL_CardPersonlization.setDataToSalesforce');
                if(error instanceof AuraHandledException){
                    throw error;
                }
                throw new AuraHandledException(error.getMessage());
            }
        }
    }

    /**
    * Method used to update application line item when a userdeselects an insurance
    * @param    chosenProduct
    * @param    applicationId
    */
    @AuraEnabled 
    public static void deselectInsurance(String token,Id applicationId, String productId){

        List<AOB_ApplicationLineItem__c> appLineItem = [SELECT Id,AOB_HasInsurance__c,AOB_RequestedValue__c, AOB_ProductOption__c,AOB_TECH_CCInsuranceID__c  
                                                        FROM  AOB_ApplicationLineItem__c 
                                                        WHERE AOB_Application__c =:applicationId 
                                                        AND AOB_Product__r.ExternalId =:productId];
        
        List<AOB_Application__c> apps =[SELECT Id,AOB_TECH_FlowNames__c 
                                  FROM AOB_Application__c 
                                  WHERE Id=:applicationId];
        
        if(!appLineItem.isEmpty()){
            appLineItem[0].AOB_ProductOption__c = null;//Emptying insurance 
            appLineItem[0].AOB_HasInsurance__c = false;
        }
        try{
            AOB_SRV_CommerceCloudConnector.deleteInsuranceCC(token, appLineItem[0].AOB_TECH_CCInsuranceID__c);
            update appLineItem;
        }catch(Exception error){
            CMN_UTIL_Logger.error(error, 'AOB_CTRL_CardPersonlization.deselectInsurance');
            if(error instanceof AuraHandledException){
                throw error;
            }
            throw new AuraHandledException(error.getMessage());
        }  
        
    }  
}