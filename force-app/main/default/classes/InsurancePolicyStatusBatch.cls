/**
* @author            : Ihtishaam Mohammoodally
* @description       : A batch class to run for polices upon expiry date. [SFP-29010]
* @date 			 : 10-01-2024
* @testclass 		 : InsurancePolicyStatusBatchTest
**/
@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it uses the batch job base class
global without sharing class InsurancePolicyStatusBatch extends sbgbase.BatchJobBase implements Database.Batchable <sObject>,Database.Stateful { 
    
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('InsurancePolicyStatusBatch');
    private static Map<String,IAC_Insurance_Global_Setting__mdt> insuranceGlobalSetting = IAC_Insurance_Global_Setting__mdt.getAll(); //Get custom metadatas
       
    
    private Integer totalRecordProcessed = 0; // number of record processed by batch
    private Integer totalBatches = 0; // number of batches executed.
    
    
/**
* @description Default contructor is required for the batch manager to instantiate this class
* @author Ihtishaam Mohammoodally
**/
    global InsurancePolicyStatusBatch() {
        super();
    }
    
/**
* @purpose       : Start method to query insurance policies that have passed expiry date.
* @parameter     : Database.BatchableContext BC
* @returns 	  : List ofinsurance policies that have passed expiry date.
**/
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,ExpirationDate,Status,RenewalDate,ExternalCountry__c,RecordType.DeveloperName,DateRenewed,(Select Id,DateRenewed,Status From RenewedInsurancePolicies) From InsurancePolicy where ExpirationDate = YESTERDAY AND ExternalSystemId__c = \'00\' AND Status  = \'In Force\'');
    }
    
/**
* @purpose       : Execute method to process queried insurance policies
* @parameter     : Database.BatchableContext BC & List<InsurancePolicy> scope
**/
    
    public void execute(Database.BatchableContext BC, List<InsurancePolicy> scope){
        List<Database.SaveResult> resultList = new List<Database.SaveResult>(); // To save DML results
        totalBatches ++;
        totalRecordProcessed += scope.size();
        
        try {
            resultList = Database.update(updateInsurancePolicyList(scope),false);
        }
        
        catch(Exception ex){
            Super.finishBatch(bc, scope.size(),scope.size(), 
                        'Unhandled Exception '+ ex.getMessage() + ' Line Exception'+ ex.getLineNumber() + 'Stack trace:' + ex.getStackTraceString());   
            logger.error('InsurancePolicyStatusBatch : execute : Unhandled Exception '+ ex.getMessage() + ' Line Exception '+ ex.getLineNumber() + ' Stack trace: ' + ex.getStackTraceString());
        }
        
        finally {
            if(!resultList.isEmpty()){
                
                Integer errorCount = 0;
                String errorMessage = '';
                
                
                for(Database.SaveResult result : resultList){
                    if(!result.isSuccess()){
                        errorCount += errorCount;
                        errorMessage = errorMessage +'\n'+result.getErrors() ;
                        
                    }
                    
                }
                
                super.finishBatch(bc, scope.size(),errorCount, errorMessage); //Log Error               
            }
            
        }
        
    }
    
/**
* @purpose       : Finish method of batch
* @parameter     : Database.BatchableContext BC 
**/
    public void finish(Database.BatchableContext bc){
        String infoMessage = 'InsurancePolicyStatusBatch Processed '+totalRecordProcessed+' records in '+totalBatches+' batches';       
        logger.info(infoMessage);
        super.finishJob(bc,infoMessage);
        
    }
    
 /**
* @purpose       : To update insurance policy status based on criteria
* @parameter     : List<InsurancePolicy> scopeList
* @returns 	  : updateInsurancePolicyList
**/
       
    public static List<InsurancePolicy> updateInsurancePolicyList (List<InsurancePolicy> scopeList){
        List<InsurancePolicy> updateInsurancePolicyList = new List<InsurancePolicy>();
        
        for(InsurancePolicy currentInsurancePolicy : scopeList){
            IAC_Insurance_Global_Setting__mdt  countrySpecificDetails = insuranceGlobalSetting
                                                                        .get(currentInsurancePolicy.ExternalCountry__c + '_' + currentInsurancePolicy.RecordType.DeveloperName);
            
            if(!currentInsurancePolicy.RenewedInsurancePolicies.isEmpty()){
                                
                if(currentInsurancePolicy.RenewedInsurancePolicies?.get(0)?.Status.equals('In Force')
                       && currentInsurancePolicy.RenewedInsurancePolicies?.get(0)?.DateRenewed != null){
                           
                    currentInsurancePolicy.Status = countrySpecificDetails.Original_Renewed_Insurance_Policy_Status__c; // Update Sucessfully renewed policy to correct status
                }
                         
            }
            else{
                currentInsurancePolicy.Status = countrySpecificDetails.Expired_Insurance_Policy_Status__c; //Update policies to expired
            }

            updateInsurancePolicyList.add(currentInsurancePolicy);
            
        }
        
        return updateInsurancePolicyList;
    }
    
    
    
}