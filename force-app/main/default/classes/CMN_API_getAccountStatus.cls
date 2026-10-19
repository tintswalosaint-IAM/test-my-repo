/**
 * @description APEX REST inbound endpoint for Account enquiry API and Delete
 * 
 * <p></p>
 * 
 * @author muvhuso.nekhubvi@standardbank.co.za
 *
 * @date October 2022
 */

@RestResource(urlMapping='/Accounts/v1/*')

global class CMN_API_getAccountStatus {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_getAccountStatus');

    private static final String ENQUIRE_STATUS = 'enquire';
    private static final String DELETE_STATUS = 'delete';
    private static final String SUCCESS_STATUS = 'Success';
    private static final String NOTFOUND_STATUS = 'Not Found';
    private static final String NOTELIGIBLE_STATUS = 'Not eligible for deletion';

    global class AccountInfo{
        public string externalIdentifier;
        public Date retentionDate;
        public boolean eligibleForDeletion;
        public string results;
    } 
 
   /**
   * @description Will process enquiry results
   * 
   * @param accountBPStatusRequest
   * @return List<AccountInfo> 
   */
 @HttpPost
 global static List<AccountInfo> getAccountStatus(EnquireRequest AccountBPStatusRequest){
        List<AccountInfo> accInfObjList = new List<AccountInfo>();
        List<Account> accounts = new List<Account>();
        
        try{
         if(!accountBPStatusRequest.customerInfo.isEmpty()){
            AccountInfo request = new AccountInfo();
         	List<Account> accObjList = [Select Id , ExternalIdentifier__pc,DR_Retain_Until__c, DR_Retain_Until_Date__pc ,(select Id from contacts) from Account where ExternalIdentifier__pc =:accountBPStatusRequest.customerInfo[0].externalIdentifier];
            if(!accObjList.isEmpty()){
                set<String> accountSet = new set<String>();
                accountSet.add(accObjList[0].Id);
                if(accountBPStatusRequest.operation == ENQUIRE_STATUS){
                	request.externalIdentifier = accObjList[0].ExternalIdentifier__pc;
         			request.retentionDate = accObjList[0].DR_Retain_Until_Date__pc;
                	request.results = SUCCESS_STATUS;
         			if(accObjList[0].DR_Retain_Until_Date__pc != null && accObjList[0].DR_Retain_Until_Date__pc <=  system.today()){
                		request.eligibleForDeletion = true;
         			}else{
                		request.eligibleForDeletion = false;
          	    	}
                }else if(accountBPStatusRequest.operation == DELETE_STATUS){
                    List<IdentityDocument> foundDocuments = [Select Id , RelatedLegalEntityId from IdentityDocument where RelatedLegalEntityId IN:accObjList[0].contacts OR RelatedLegalEntityId IN:accountSet];
                    if(accObjList[0].DR_Retain_Until_Date__pc <= system.today()){
                         accounts.add(accObjList[0]);
                        request.results = SUCCESS_STATUS;
                    }else{
                        request.results = NOTELIGIBLE_STATUS;
                    }
                    if(!foundDocuments.isEmpty()){
                       delete foundDocuments; 
                    }
                }   
            }else{
                request.results = NOTFOUND_STATUS;
                request.externalIdentifier = accountBPStatusRequest.customerInfo[0].externalIdentifier;
            }
         	accInfObjList.add(request);
         }
     	
     if(!accounts.isEmpty()){
        doDelete(accounts); 
     } 
     //Results     
     return accInfObjList;
            
    }catch(Exception error){
       LOGGER.fatal('CMN_API_getAccountStatus.getAccountStatus' , error);
       throw new AuraHandledException(error.getMessage());     
    }
 } 
   /**
   * @description EnquireRequest class
   */
    
  global class EnquireRequest{
      global string operation;
      global List<CustomerInfo> customerInfo;      
  }
   /**
   * @description account information class
   */
  global class CustomerInfo{
         global string externalIdentifier;  
  }  
  /**
   * @description delete mothod to delete account
   */
  public static void doDelete(List<Account> accounts) {
        delete accounts;
    }
    
}