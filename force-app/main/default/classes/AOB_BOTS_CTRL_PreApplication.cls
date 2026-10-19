/**
 * @description Controller to save  send OTP ,resend OTP , save lead using fflib framework 
 * @author Dayakar Deekondas
 * @date Jan 3rd 2023
 */
public without sharing class AOB_BOTS_CTRL_PreApplication {
    /**
    * @description method used to save applicationParticipants based on given input
    * @param iString
    * @return String
    */
    @AuraEnabled
    public static String saveParticipants(String iString){
        try{
            List<Application_Participant__c> participants = (List<Application_Participant__c>)JSON.deserialize(iString,List<Application_Participant__c>.class);
            sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { Application_Participant__c.SObjectType });
            AOB_BOTS_SRV_Application.newInstance().saveApplnParticipants(participants, uow);
            uow.commitWork();
            return JSON.serialize(participants);
        }
        catch(exception ex){
            AuraHandledException exc = new AuraHandledException(ex.getMessage());
            exc.setMessage(ex.getMessage());
            throw exc;
        }
    } 
 
}