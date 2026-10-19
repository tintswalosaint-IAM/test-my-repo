/**
* @description This class do a callout to AWS and Grax to delete relent records.
* @author Mthandeni Gumede
* @date  09/01/2024
*/ 

public class CMN_API_DeleteVoiceAndChatTranscripts {
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_DeleteVoiceAndChatTranscripts');
    
   /**
   * @description method to serialize cases to send callout to  grax and aws to delete cases.
   * @param casesToDelete
   */
    public static Boolean handleCaseDeletionWithTranscripts(List<Case> casesToDelete) {
        Boolean deleteRecords = True;
        List<String> idsSet = new List<String>();
        List<TranscriptsToDelete> TranscriptsToDeleteList = new List<TranscriptsToDelete>();
        
        for (Case cse : casesToDelete) {
            idsSet.add(cse.Id);
            
            if(!String.isBlank(cse.amazonconnect__AC_Contact_Id__c)){
                TranscriptsToDelete TranscriptsToDelete = new TranscriptsToDelete();
                TranscriptsToDelete.ContactId = cse.amazonconnect__AC_Contact_Id__c;
                TranscriptsToDelete.Timestamp = cse.CreatedDate.format('yyyy-MM-dd-HH');
                
                TranscriptsToDeleteList.add(TranscriptsToDelete); 
            }
        }
        
        if(!idsSet.IsEmpty()){
            GraxWrapper graxWrapper = new GraxWrapper();
            graxwrapper.ids = idsSet;
            
            CMN_API_DeleteCases_Grax graxCall = new CMN_API_DeleteCases_Grax(JSON.serialize(graxWrapper));
            CMN_WebserviceCallQueue__c objGrax = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_DeleteCases_Grax.SERVICE_NAME);
            graxCall.process(objGrax);
            if(graxCall.getResponseStatusCode() == 202){
                if(!TranscriptsToDeleteList.IsEmpty()){
                    ContactIdsToDeleteWrapper contactIdWrapper = new ContactIdsToDeleteWrapper();
                    contactIdWrapper.TranscriptsToDelete = TranscriptsToDeleteList;
                    
                    CMN_API_DeleteCases_AWS awsCall = new CMN_API_DeleteCases_AWS(JSON.serialize(contactIdWrapper));
                    CMN_WebserviceCallQueue__c objAws = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_DeleteCases_AWS.SERVICE_NAME);
                    awsCall.process(objAws);
                    if(awsCall.getResponseStatusCode() == 200){
                        return deleteRecords; 
                    }else{
                        return deleteRecords = false;
                    }
                }
            }else{
                return deleteRecords = false;  
            }
        }
          return deleteRecords;
    }
   
    /**
   ** @description Class Wrapper
   */   
    public class GraxWrapper {
        public List<String> ids;
    }
    
    /**
     ** @description Class Wrapper
    */  
    public class TranscriptsToDelete {
        public String ContactId;
        public String Timestamp;
    }
    
    public class ContactIdsToDeleteWrapper {
        public List<TranscriptsToDelete> TranscriptsToDelete;
    }
    
}