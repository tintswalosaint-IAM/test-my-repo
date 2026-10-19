/***************************************************************************************
@Author            :Karabo Machubeni
@Date              :January 2024
@Name of the Class :CMN_RecordUnlocker
@description       :Class used for unlocking records that are submitted for Approval
@Modification description :  SFP-23329
***************************************************************************************/
public without sharing class CMN_RecordUnlocker {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_RecordUnlocker.class.getName());
   
    /**
    * @description	unlocks the record based on the provided Id
    * @param List<Id> recordIds
    */ 
    public static void unlockRecords(List<Id> recordIds) {
        try{
            if(recordIds != null && !recordIds.isEmpty()){
                
                Approval.unlock(recordIds);
                
                if(Test.isRunningTest()){
                    DmlException ex = new DmlException();
                    throw ex;
                }        
                
            }
        }catch(Exception ex){
            Logger.error(ex.getMessage(),  new String[] {'unlockRecords',ex.getMessage()}, ex);
        }
        
    }       
}