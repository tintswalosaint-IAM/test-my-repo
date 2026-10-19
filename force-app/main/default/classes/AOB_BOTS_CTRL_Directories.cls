/**
* @description This class is used as call the AOB_BOTS_CTRL_Directories
* @author Dayakar 
* @date Jan 5th 2021
* @last modified on  : 03-08-2023
* @last modified by  : Ramya Gurram
* @ Modification Description : Used  External_Id__c for document name and added new mthod to check key contact person
*/
public class AOB_BOTS_CTRL_Directories {
      /**
* @description This method is used as call the isSignatory
* @return Boolean
* @param String partcipantId
*/
    @AuraEnabled
    public static Boolean isSignatory(String partcipantId){
        Boolean checkisSignatory;
        List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(partcipantId);
        for(Application_Participant__c app:appParticpant){
            if(app.AOB_Signatory__c==true){
                checkisSignatory=true;
                break;
            }else{
                
                checkisSignatory=false;
            }
        }
        return checkisSignatory;
    }
/**
* @description This method is used to check new director
* @return Boolean
* @param String partcipantId
*/ 
    
    @AuraEnabled
    public static Boolean isNewDirector(String partcipantId){
        Boolean checkisNewDirector;
        String checkdirector=AOB_BOTS_SRV_SigningHUB.getInflight(partcipantId,'SigningHUBDocumnetLINK');
        if(checkdirector!=null){
            checkisNewDirector=false;
        }else{
            
           checkisNewDirector=true;            
        }
  
        return checkisNewDirector;
    }
 /**
* @description This method is used to check key contact person
* @return Boolean
* @param String partcipantId
*/  
    @AuraEnabled
    public static Boolean checkKeyContact(String partcipantId){
         Boolean checkisKeyContact=false;
         Application_Participant__c apps=new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticipant(partcipantId);
        if(apps.AOB_KeyContactPerson__c==true){
            checkisKeyContact = true;
        }
         return checkisKeyContact;
    }

}