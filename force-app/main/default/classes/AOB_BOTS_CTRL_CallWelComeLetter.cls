/**
* @description Test class for AOB_BOTS_CTRL_CallWelComeLetter
* 
* @author Dayakar Deekaonda
* 
* @date June 30th 2023 
*/
public class AOB_BOTS_CTRL_CallWelComeLetter implements Queueable, Database.AllowsCallouts{
    
    Public String applicationId;
    private static final String WELCOME_LETTER = 'Welcome Letter';
    private static final String TEMPLATE_GUID = '{"templateGUID":"';
    private static final String APPLICATION_ID = '","applicationId":"';
    private static final String CLOSING_STRING = '"}';
    
    /**
    * @description constructor for AOB_BOTS_CTRL_CallWelComeLetter
    * 
    * @param  applicationIds
    */
    public AOB_BOTS_CTRL_CallWelComeLetter(String applicationIds){
        
        this.applicationId=applicationIds;
    }

    /**
    * @description  method  for execute Queueable context
    * 
    * @param  context
    */
    public  void execute(QueueableContext context){
        
        List<Application_Participant__c> appParticpant = new AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantByApplicationId(applicationId);
        DocFusionTemplates__mdt docmd=[select id,GUID__c,Template_Name__c from DocFusionTemplates__mdt where Template_Name__c=:WELCOME_LETTER LIMIT 1];
        String appData=TEMPLATE_GUID + docmd.GUID__c + APPLICATION_ID + appParticpant[0].id + CLOSING_STRING;
        AOB_BOTS_SRV_SigningHUB.docFusionCallout(appData);
        
    }
    
}