/**
* @author            : Ihtishaam Mohammoodally
* @description       : A batch class to run and automate renewals of polices upon renewal date. [SFP-29010]
* @date 			 : 10-01-2024
* @testclass 		 : InsRenewalOpportunityBatchTest
* @Last Modified On  : 07-06-2024
* @Modification Description :  SFP-38808 :- add additional mapping field to opportunity
**/
@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it uses the batch job base class
global without sharing class InsRenewalOpportunityBatch extends sbgbase.BatchJobBase implements Database.Batchable <sObject>,Database.Stateful { 
    
    
    
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('InsRenewalOpportunityBatch');
    private static Map<String,List<Database.SaveResult>> resultListMap = new Map<String,List<Database.SaveResult>>(); // To save DML results
    private static Map<String,IAC_Insurance_Global_Setting__mdt> insuranceGlobalSetting = IAC_Insurance_Global_Setting__mdt.getAll(); //Get custom metadatas
    
    private Integer totalScopeRecords = 0; // number of record in scope
    private Integer totalRecordProcessed = 0; // number of record processed by batch
    private Integer totalBatches = 0; // number of batches executed.

    
/**
* @description Default contructor is required for the batch manager to instantiate this class
* @author Ihtishaam Mohammoodally
**/
    global InsRenewalOpportunityBatch() {
        super();
    }
    
/**
* @purpose       : Start method to query insurance policies that are due to renewals.
* @parameter     : Database.BatchableContext BC
* @returns 	  : List ofinsurance policies to be renewed.
**/
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        super.startJob(bc);
        
        String insurancePolicyQueryString = 'Select ' + String.join(InsurancePolicy.getSObjectType()
                                                                    .getDescribe().fields.getMap().keySet(), ',');
        
        
        String insurancePolicyAssetsQueryString = '(Select '+String.join(InsurancePolicyAsset.getSObjectType()
                                                                         .getDescribe().fields.getMap().keySet(), ',') + ' FROM InsurancePolicyAssets)';
        
        String insurancePolicyParticipantsQueryString = '(Select '+String.join(InsurancePolicyParticipant.getSObjectType()
                                                                               .getDescribe().fields.getMap().keySet(), ',') + ' FROM InsurancePolicyParticipants)';
        
        String insurancePolicyCoveragesQueryString = '(Select '+String.join(InsurancePolicyCoverage.getSObjectType()
                                                                            .getDescribe().fields.getMap().keySet(), ',') + ' FROM InsurancePolicyCoverages)';
        
        
        String query = insurancePolicyQueryString + ',' + insurancePolicyAssetsQueryString + ',' 
            			+ insurancePolicyParticipantsQueryString + ',' + insurancePolicyCoveragesQueryString;
        
        logger.info('InsRenewalOpportunityBatch : start : query '+query);
        
        Integer upperLimitPeriod = 0; //variable to store the maximum number of days to be queried.
        String filter = '';
        
        for(IAC_Insurance_Global_Setting__mdt  currentCountryDetails : insuranceGlobalSetting.Values()){           
            upperLimitPeriod = currentCountryDetails.N_Days__c > upperLimitPeriod ? Integer.ValueOf(currentCountryDetails.N_Days__c) : upperLimitPeriod;
            
            if(String.IsNotBlank(currentCountryDetails.Query_Filter__c)){
                filter = currentCountryDetails.Query_Filter__c;
            }
            
        }
                
        return Database.getQueryLocator(query + filter + upperLimitPeriod); //Contactenate query with maximum n_days.
     
    }
    
    /**
* @purpose       : Execute method to process queried insurance policies
* @parameter     : Database.BatchableContext BC & List<InsurancePolicy> scope
**/
    public void execute(Database.BatchableContext bc, List<InsurancePolicy> scope){
        totalBatches ++;
        totalScopeRecords += scope.size();
        
        try {
                List<InsurancePolicy> filteredInsurancePolicyList = filterInsurancePoliciesByCountry(scope); // Filtered record by country
                totalRecordProcessed += filteredInsurancePolicyList.size();
                
                    if(!filteredInsurancePolicyList.IsEmpty()){
                        createRenewedPolicy(filteredInsurancePolicyList);                
                    }            
        }
        
        catch(Exception ex){
            Super.finishBatch(bc, scope.size(),scope.size(), 
                        'Unhandled Exception '+ ex.getMessage() + ' Line Exception'+ ex.getLineNumber() + 'Stack trace:' + ex.getStackTraceString());   
            logger.error('InsRenewalOpportunityBatch : execute : Unhandled Exception '+ ex.getMessage() + ' Line Exception '+ ex.getLineNumber() + ' Stack trace: ' + ex.getStackTraceString());
        }
        
        finally {
            
            Integer errorCount = 0;
            String errorMessage = '';
            
            if(!resultListMap.isEmpty()){
                    for(String objectName : resultListMap.keySet()){
                        
                        for(Database.SaveResult result : resultListMap.get(objectName)){
                                if(!result.isSuccess()){
                                    errorCount += errorCount;
                                    errorMessage = errorMessage +'\n'+ objectName + ' : '+result.getErrors() ;
                                    
                                }
                            
                        }
                        
                    }
                
                               
            }
            
            super.finishBatch(bc, scope.size(),errorCount, errorMessage); //Log Error
            
        }
        
    }
    
    
    /**
* @purpose       : Finish method of batch
* @parameter     : Database.BatchableContext BC 
**/
    
    public void finish(Database.BatchableContext bc){
        String infoMessage = 'InsRenewalOpportunityBatch Processed '+totalRecordProcessed+' records in scope of '+totalScopeRecords+' records in '+totalBatches+' batches';       
        logger.info(infoMessage);
        super.finishJob(bc,infoMessage);
    }
    
    /**
* @purpose       : To filter policies upon n_days per country and to filter duplicate policies up for renewals
* @parameter     : List<InsurancePolicy> currentInsurancePolicyList
* @returns 	  : newInsurancePolicyList
**/
    public static List<InsurancePolicy> filterInsurancePoliciesByCountry(List<InsurancePolicy> currentInsurancePolicyList){
        List<InsurancePolicy> newInsurancePolicyList = new List<InsurancePolicy>(); //New List for filtered insurance policies.
        
        for(InsurancePolicy insurancePolicy : currentInsurancePolicyList){
            IAC_Insurance_Global_Setting__mdt  countrySpecificDetails = insuranceGlobalSetting
                                                                        .get(insurancePolicy.ExternalCountry__c + '_' + insurancePolicy.RecordType.DeveloperName);
                        
            if(countrySpecificDetails != null){
                
                Date countrySpecificDate = System.today()
                					   			.addDays(Integer.ValueOf(countrySpecificDetails.N_Days__c));
            
                if(insurancePolicy.RenewalDate < countrySpecificDate && insurancePolicy.RenewedInsurancePolicies.isEmpty()){
                            
                    newInsurancePolicyList.add(insurancePolicy); // Add to list records that needs to be processed
                }
                
            } else{
                logger.warn('InsRenewalOpportunityBatch : filterInsurancePoliciesByCountry : countrySpecificDetails is null ');
            }
            
        }
        
        
        return newInsurancePolicyList; 
    }
    
    /**
* @purpose       : Method to clone existing insurance policies and related records for renewals && opportunity
* @parameter     : List<InsurancePolicy> insurancePolicyRecordList
**/   
    public static void createRenewedPolicy(List<InsurancePolicy> insurancePolicyRecordList){
        String opportunityRecordTypeId = Opportunity.getSObjectType().getDescribe()
                                        .getRecordTypeInfosByDeveloperName()
                                        .get('Insurance_Renewal').getRecordTypeId(); //Get RecordType Id
        
        List<Database.SaveResult> resultList = new List<Database.SaveResult>(); //Capture temporary result list
        List <ActionPlan> newActionPlanList = new List<ActionPlan>(); //Initiate action plan list
        
        Map <InsurancePolicy,Opportunity> mapOldInsurancePolicyNewOpportunityMap = new Map <InsurancePolicy,Opportunity>();
        Map <InsurancePolicy,InsurancePolicy> mapOldNewInsurancePolicy = new Map <InsurancePolicy,InsurancePolicy>();
        Map <InsurancePolicy,InsurancePolicy> mapOldNewInsurancePolicyOpportunityId = new Map <InsurancePolicy,InsurancePolicy>();
        
        //Map Old Id to New values Starts
        Map <String,InsurancePolicyAsset> mapOldNewInsurancePolicyAsset = new Map <String,InsurancePolicyAsset>();
        Map <String,InsurancePolicyCoverage> mapOldNewInsurancePolicyCoverage = new Map <String,InsurancePolicyCoverage>();
        Map <String,InsurancePolicyParticipant> mapOldNewInsurancePolicyParticipant = new Map <String,InsurancePolicyParticipant>();
        //Map Old Id to New values Starts
        
        
        for(InsurancePolicy currentInsurancePolicy : insurancePolicyRecordList){ //Loop to Map OldInsurance Policy to New Insurance Policy
            
            Opportunity newRenewalOpportunity = createOpportunity(currentInsurancePolicy,opportunityRecordTypeId);            
            InsurancePolicy newInsurancePolicy = createInsurancePolicyRecord(currentInsurancePolicy,
                                                                             insuranceGlobalSetting.get(currentInsurancePolicy.ExternalCountry__c + '_' + currentInsurancePolicy.RecordType.DeveloperName));
            
            mapOldInsurancePolicyNewOpportunityMap.put(currentInsurancePolicy,newRenewalOpportunity);    
            mapOldNewInsurancePolicy.put(currentInsurancePolicy,newInsurancePolicy); 
        }
        
        resultList = Database.insert(mapOldInsurancePolicyNewOpportunityMap.Values(),false); //Insert Opportunities
        resultListMap.put('Opportunity',resultList); //Assign result to map
        
        
        for(InsurancePolicy oldInsurancePolicy : insurancePolicyRecordList){ // Loop to add action plan to opportunity & to update sourceOpportunityId in new Insurance Policy Record
            Opportunity newOpportunityCreated = mapOldInsurancePolicyNewOpportunityMap.get(oldInsurancePolicy);
            InsurancePolicy newInsurancePolicy = mapOldNewInsurancePolicy.get(oldInsurancePolicy);
            
            newInsurancePolicy.SourceOpportunityId = newOpportunityCreated?.Id;
            mapOldNewInsurancePolicyOpportunityId.put(oldInsurancePolicy,newInsurancePolicy);
            //newActionPlanList.add(createActionPlan(newOpportunityCreated,actionPlantemplate)); 
            newActionPlanList.add(createActionPlan(newOpportunityCreated,
                                                   insuranceGlobalSetting.get(oldInsurancePolicy.ExternalCountry__c + '_' + oldInsurancePolicy.RecordType.DeveloperName))); 
        }
        
        resultList = Database.insert(newActionPlanList,false);     
        resultListMap.put('ActionPlan',resultList); //Insert Action plan to linked to opportunities
        lauchActionPlanTaskFlow(newActionPlanList); // Launch Flow
        
        resultList = Database.insert(mapOldNewInsurancePolicyOpportunityId.Values(),false);
        resultListMap.put('InsurancePolicy',resultList); //Insert renewed insurance policy
               
        
        for(InsurancePolicy oldInsurancePolicy : insurancePolicyRecordList){ // Loop for related participants
            
            if(!oldInsurancePolicy.InsurancePolicyParticipants.isEmpty()){
                
                for(InsurancePolicyParticipant currentInsurancePolicyParticipants : oldInsurancePolicy.InsurancePolicyParticipants){
                    InsurancePolicyParticipant newInsurancePolicyParticipant = currentInsurancePolicyParticipants.clone();
                    newInsurancePolicyParticipant.ExternalIdentifier__c = null;  
                    newInsurancePolicyParticipant.InsurancePolicyId = mapOldNewInsurancePolicyOpportunityId.get(oldInsurancePolicy).Id;
                    mapOldNewInsurancePolicyParticipant.put(currentInsurancePolicyParticipants.Id,newInsurancePolicyParticipant);
                    
                }      
            }
        }
        
        resultList = Database.insert(mapOldNewInsurancePolicyParticipant.Values(),false); //Insert related insurancePolicyparticipant
        resultListMap.put('InsurancePolicyParticipant',resultList);
        
        for(InsurancePolicy oldInsurancePolicy : insurancePolicyRecordList){
            
            if(!oldInsurancePolicy.InsurancePolicyAssets.isEmpty()){
                
                for(InsurancePolicyAsset currentInsurancePolicyAsset : oldInsurancePolicy.InsurancePolicyAssets){ // Loop for related insured items
                    
                    InsurancePolicyAsset newInsurancePolicyAsset = currentInsurancePolicyAsset.clone();
                    newInsurancePolicyAsset.ExternalIdentifier__c = null; 
                    newInsurancePolicyAsset.InsurancePolicyId = mapOldNewInsurancePolicyOpportunityId.get(oldInsurancePolicy).Id;
                    
                    newInsurancePolicyAsset.PrimaryPolicyParticipantId = mapOldNewInsurancePolicyParticipant.get(currentInsurancePolicyAsset.PrimaryPolicyParticipantId)!= null 
                                                                            ? mapOldNewInsurancePolicyParticipant.get(currentInsurancePolicyAsset.PrimaryPolicyParticipantId)?.Id 
                                                                            : null;
                    
                    mapOldNewInsurancePolicyAsset.put(currentInsurancePolicyAsset.Id,newInsurancePolicyAsset);
                }
            }
            
        }
        
        resultList = Database.insert(mapOldNewInsurancePolicyAsset.Values(),false); //Insert insured item
        resultListMap.put('InsurancePolicyAsset',resultList);
        
        
        for(InsurancePolicy oldInsurancePolicy : insurancePolicyRecordList){
            
            if(!oldInsurancePolicy.InsurancePolicyCoverages.isEmpty()){
                
                for(InsurancePolicyCoverage currentInsurancePolicyCoverage : oldInsurancePolicy.InsurancePolicyCoverages){ //Loop for related insurance policy coverages.
                    
                    InsurancePolicyCoverage newInsurancePolicyCoverage = currentInsurancePolicyCoverage.clone();
                    newInsurancePolicyCoverage.ExternalIdentifier__c = null; 
                    newInsurancePolicyCoverage.InsurancePolicyId = mapOldNewInsurancePolicyOpportunityId.get(oldInsurancePolicy).Id;
                    
                    newInsurancePolicyCoverage.InsurancePolicyAssetId  = mapOldNewInsurancePolicyAsset.get(currentInsurancePolicyCoverage.InsurancePolicyAssetId) != null
                        												? mapOldNewInsurancePolicyAsset.get(currentInsurancePolicyCoverage.InsurancePolicyAssetId)?.Id 
                        												: null;
                    
                    newInsurancePolicyCoverage.InsurancePolicyParticipantId   = mapOldNewInsurancePolicyParticipant.get(currentInsurancePolicyCoverage.InsurancePolicyParticipantId) != null 
                        														 ? mapOldNewInsurancePolicyParticipant.get(currentInsurancePolicyCoverage.InsurancePolicyParticipantId)?.Id 
                        														 : null;
                    mapOldNewInsurancePolicyCoverage.put(currentInsurancePolicyCoverage.Id,newInsurancePolicyCoverage);
                }
                
            }
            
        }
        
        resultList = Database.insert(mapOldNewInsurancePolicyCoverage.Values(),false); 
        resultListMap.put('InsurancePolicyCoverages',resultList); //Insert insurance policy coverages
        
        
    }
    
    /**
* @purpose       : Method to provide to map fields & recordtype id to create opportunity that is up for renewals.
* @parameters    : InsurancePolicy currentInsurancePolicy,String opportunityRecordTypeId
* @returns 	  : Opportunity newOpportunity
**/  
    public static Opportunity createOpportunity (InsurancePolicy currentInsurancePolicy,String opportunityRecordTypeId ){
        IAC_Insurance_Global_Setting__mdt currentInsuranceSetting = insuranceGlobalSetting.get(currentInsurancePolicy.ExternalCountry__c + '_' + currentInsurancePolicy.RecordType.DeveloperName);
        String postFixName = '';
        
        if(String.isNotBlank(currentInsuranceSetting.Opportunity_PostFix_Name__c)){
            postFixName = currentInsuranceSetting.Opportunity_PostFix_Name__c;
        }
        
        Opportunity newOpportunity = new Opportunity(
                        CreatedById = currentInsurancePolicy.OwnerId,
                        OwnerId = currentInsurancePolicy.OwnerId,
                        AccountId = currentInsurancePolicy.NameInsuredId,
                        Name = setPolicyNumber(currentInsurancePolicy.Name,currentInsuranceSetting) + ' ' + postFixName,
                        StageName = currentInsuranceSetting.Renewal_Opportunity_Status__c,
                        CloseDate =  System.today(),
                        Country__c  = currentInsurancePolicy.ExternalCountry__c,
                        RecordTypeId  = opportunityRecordTypeId,
            			CurrencyIsoCode = currentInsurancePolicy.CurrencyIsoCode //SFP-38808
            
        );
        return newOpportunity;
        
    }
    
    /**
* @purpose       : Method to provide to map fields & recordtype id to create opportunity that is up for renewals.
* @parameters    : InsurancePolicy currentInsurancePolicy,String opportunityRecordTypeId
* @returns 	  : Opportunity newOpportunity
**/  
    public static InsurancePolicy createInsurancePolicyRecord (InsurancePolicy originalInsurancePolicy,IAC_Insurance_Global_Setting__mdt insuranceSetting){
        InsurancePolicy newInsurancePolicy = originalInsurancePolicy.clone();
        
        newInsurancePolicy.Status = insuranceSetting.Renewal_InsurancePolicy_Status__c;
        newInsurancePolicy.RenewedFromPolicyId = originalInsurancePolicy.Id;       
        newInsurancePolicy.IsRenewedPolicy = true;
        newInsurancePolicy.CreatedById = originalInsurancePolicy.OwnerId;
        newInsurancePolicy.OwnerId = originalInsurancePolicy.OwnerId;
        
        
        newInsurancePolicy.OriginalEffectiveDate  = originalInsurancePolicy.OriginalEffectiveDate != null 
                                                    ? originalInsurancePolicy.OriginalEffectiveDate 
                                                    : originalInsurancePolicy.EffectiveDate ;
        
        newInsurancePolicy.OriginalPolicyId	= originalInsurancePolicy.OriginalPolicyId != null 
                                                ? originalInsurancePolicy.OriginalPolicyId 
                                                : originalInsurancePolicy.Id;
        
        
        newInsurancePolicy.ExpirationDate  = originalInsurancePolicy.ExpirationDate  != null 
                                                ? originalInsurancePolicy.ExpirationDate.date().addYears(1) 
                                                : null ;
        
        newInsurancePolicy.RenewalDate = checkPolicyTermDateTime(originalInsurancePolicy.RenewalDate,originalInsurancePolicy);
              
        newInsurancePolicy.EffectiveDate = DateTime.newInstance(originalInsurancePolicy.RenewalDate.date().addDays(1),
                                                                originalInsurancePolicy.RenewalDate.time()) ;
                
        
        newInsurancePolicy.Inception_Date__c = originalInsurancePolicy.RenewalDate.date().addDays(1);
        
        
        newInsurancePolicy.ExternalIdentifier__c   = null;
        newInsurancePolicy.Name   = setPolicyNumber(originalInsurancePolicy.Name,insuranceSetting);    
        
        return newInsurancePolicy;        
    }
    
    /**
* @purpose       : Method to create action plan and to associate it with renewal opportunity
* @parameters    : Opportunity relatedOpportunity,ActionPlanTemplateVersion actionPlanTemplateVersion
* @returns 	  : ActionPlan newActionPlan
**/  
    
    public static ActionPlan createActionPlan(Opportunity relatedOpportunity,IAC_Insurance_Global_Setting__mdt insuranceSetting){
        ActionPlan newActionPlan = new ActionPlan();
        newActionPlan.ActionPlanType = insuranceSetting.ActionPlanType__c;
        newActionPlan.ActionPlanTemplateVersionId  = insuranceSetting.ActionPlanTemplateId__c;
        newActionPlan.TargetId  = relatedOpportunity.Id;
        newActionPlan.OwnerId = relatedOpportunity.OwnerId;
        newActionPlan.StartDate =  Date.newInstance(System.today().year(), System.today().month(), System.today().day());
        newActionPlan.EndDate = relatedOpportunity.CloseDate;
        newActionPlan.Name  = relatedOpportunity.Name + newActionPlan.StartDate;
        newActionPlan.CreatedById = relatedOpportunity.OwnerId;
        return newActionPlan;
        
        
    }
        
    /**
* @purpose       : Method to contactenate number to renewed Insurance Policy.
* @parameters    : policyNumber,insuranceSetting
* @returns 	  : policyNumber
**/  
    
    public static String setPolicyNumber (String policyNumber,IAC_Insurance_Global_Setting__mdt insuranceSetting){
        
        if(String.IsNotBlank(insuranceSetting.Policy_Renewal_Number_Postfix__c )){
            
            if(policyNumber.Contains(insuranceSetting.Policy_Renewal_Number_Postfix__c)){
                
                List<String> policyNumbersplitStringList = policyNumber.split(insuranceSetting.Policy_Renewal_Number_Postfix__c);
                Integer counter = Integer.ValueOf(policyNumbersplitStringList.get(1));
                policyNumber = policyNumbersplitStringList.get(0) + insuranceSetting.Policy_Renewal_Number_Postfix__c + String.Valueof(counter + 1);
                
            }
            else {
                policyNumber = policyNumber + insuranceSetting.Policy_Renewal_Number_Postfix__c + String.Valueof(1);
            }
            
        }
        
        return policyNumber;
    }
    
/**
* @purpose       : Method to update the recordtype on Task record of the Action Plan.
* @parameters    : actionPlanList
**/
    public static void lauchActionPlanTaskFlow(List<ActionPlan> actionPlanList ){
        
        Map<String, Object> params = new Map<String, Object>();
        params.put('ActionPlanList', actionPlanList);
        params.put('InsuranceRenewalRecordTypeId',Task.getSObjectType().getDescribe()
                                        .getRecordTypeInfosByDeveloperName()
                                        .get('Insurance_Renewal').getRecordTypeId()); //Get RecordType Id;
        
        Flow.Interview.IAC_ActionPlanTaskUpdate actionPlanTaskFlow = new Flow.Interview.IAC_ActionPlanTaskUpdate(params);
        actionPlanTaskFlow.start();
    }
    
/**
* @purpose       : Method to contactenate number to renewed Insurance Policy.
* @parameters    : renewedInsurancePolicyFieldDateTime,originalInsurancePolicy
* @returns 	  : renewedInsurancePolicyFieldDateTime
**/  
    
    public static DateTime checkPolicyTermDateTime(DateTime renewedInsurancePolicyFieldDateTime, InsurancePolicy originalInsurancePolicy){
        
        if(renewedInsurancePolicyFieldDateTime != null && String.isNotBlank(originalInsurancePolicy.PolicyTerm)){
            
            switch on originalInsurancePolicy.PolicyTerm {
                
                when 'Semi-Annual' {
                    renewedInsurancePolicyFieldDateTime = DateTime.newInstance(renewedInsurancePolicyFieldDateTime.date().addmonths(6),
                                                                               renewedInsurancePolicyFieldDateTime.time());
                }
                when 'Quarterly' {
                    renewedInsurancePolicyFieldDateTime = DateTime.newInstance(renewedInsurancePolicyFieldDateTime.date().addmonths(3),
                                                                               renewedInsurancePolicyFieldDateTime.time());
                }
                when else {
                     renewedInsurancePolicyFieldDateTime = DateTime.newInstance(renewedInsurancePolicyFieldDateTime.date().addYears(1),
                                                                               renewedInsurancePolicyFieldDateTime.time());
                }                
                
            }
            
        }
        
        else {
            
            renewedInsurancePolicyFieldDateTime = DateTime.newInstance(renewedInsurancePolicyFieldDateTime.date().addYears(1),
                                                         renewedInsurancePolicyFieldDateTime.time());
        }
        
        return renewedInsurancePolicyFieldDateTime;
    }
}