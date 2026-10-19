/**
 * Controller for aob_cmp_personalDetails component
 * 
 * <p>DPB-1159  DPB-1160</p> 
 * 
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 * 
 * @date Nov 4th 2020
 */
public with sharing class AOB_CTRL_AppRedirection {

   /**
    * Method used to update flow names for the current application
    * @param  label
    * @return String
    */
    @auraEnabled
    public static string getApplicationId(){
        try{
            if (Account.sObjectType.getDescribe().isAccessible()  && Contact.sObjectType.getDescribe().isAccessible() 
                && AOB_application__c.sObjectType.getDescribe().isAccessible() ){
                Account acc=[SELECT id 
                             FROM Account 
                             WHERE id IN (SELECT AccountId 
                                          FROM user 
                                          WHERE id=:UserInfo.getUserId())];
                Contact con=[SELECT id 
                             FROM Contact 
                             WHERE accountId=:acc.id LIMIT 1];
                List<AOB_application__c> existingApplications=[SELECT id 
                                                               FROM AOB_application__c 
                                                               WHERE AOB_Contact__c=:con.id];
                if(!existingApplications.isEmpty()){
                    return existingApplications[0].id;
                }
                else{
                  AOB_application__c newApp=new AOB_application__c();
                  newApp.AOB_Customer__c=acc.id;
                  newApp.AOB_Contact__c=con.id;
                  insert newApp;
                  AOB_ApplicationLineItem__c newAppLI=new AOB_ApplicationLineItem__c();
                  newAppLI.AOB_Application__c=newApp.id;
                  List<Product2> products=[SELECT id 
                                       FROM Product2 
                                       WHERE Name=:AOB_Constants.CREDITCARD];
                  if(!products.isEmpty())
                    newAppLI.AOB_Product__c=products[0].id;
                  insert newAppLI;
               }
            } 
          return '';
        }
        catch(Exception error)
    {
      CMN_UTIL_Logger.error(error, 'AOB_CTRL_AppRedirection.getApplicationId');
      throw new AuraHandledException(error.getMessage());
    }
    }
}