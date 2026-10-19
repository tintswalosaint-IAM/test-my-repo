/**
 * @description find Person account when a voice call is routed to agent (Service cloud Voice) where ExternalCIFCountry is OS
 * @author Makepositive 
 * @date December 2023
 * User Story : SFP-29277 - Inbound call routing
 */
public class SBO_SCV_GetPersonAccountFromPhone {

  @InvocableMethod(label='Get Person Account' description='Returns the person accounts corresponding to the specified phone where ExternalCIFCountry is OS' category='Account')
    
    //this method returns a List containing one person account
    public static List<Account> getPersonAccountId (List<String> phones) {
        List<Account> accounts = new List<Account>();
         try {
             accounts = [SELECT Id,Phone,PersonMobilePhone from Account WHERE (Phone in: phones OR
                                                               PersonMobilePhone in: phones) AND ExternalCIFCountry__c = 'OS' order by lastmodifieddate Desc];
             if(!accounts.isEmpty()){
                   List <Account> returnAccs = new List <Account> ();
                   returnAccs.add(accounts.get(0)); 
                   return returnAccs ; 
             }else{
                return null;
             }
         }Catch(QueryException qe){
              System.debug('The following exception has occurred: ' + qe.getMessage());   
              return null;
         }
        
          
        
    }
}