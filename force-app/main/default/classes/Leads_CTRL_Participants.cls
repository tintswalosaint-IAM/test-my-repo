/**
 * @description Controller class for Lead Participants
 *
 * Email is an encrypted field so this method allows to retrieve those participants that have an email
 * 
 * @author Facu
 *
 * @date December 2022
 */

@SuppressWarnings('PMD.ApexCrudViolation')
public inherited sharing class Leads_CTRL_Participants {
    
    @InvocableMethod(callout=true label='Get Participants by email')    
    public static List<Result> getParticipantsByEmail(List<Request> requests) {
        
        List<Result> responseWrapper = new List<Result>();

        for(Request req: requests){

            Result response = new Result();

            response.accounts =    [SELECT Id, Name, PersonEmail, PersonMobilePhone, PersonHomePhone, PersonOtherPhone FROM Account WHERE PersonEmail    in :req.emails LIMIT 100];
            response.users =       [SELECT Id, Name, Email       FROM User    WHERE Email          in :req.emails  LIMIT 100];
            response.leads =       [SELECT Id, Name, Email       FROM Lead    WHERE Email          in :req.emails  LIMIT 100];
            response.contacts    = [SELECT Id, Name, Email, Phone, MobilePhone, HomePhone, OtherPhone       FROM Contact WHERE Email          in :req.emails  LIMIT 100];
            //response.individuals = [SELECT Id, Name, Email       FROM Individual WHERE Email       in :req.emails];

            //response.NumberOfResults = response.accounts.size() + response.users.size() + response.leads.size() + response.contacts.size()+ response.individuals.size();
            response.NumberOfResults = response.accounts.size() + response.users.size() + response.leads.size() + response.contacts.size();
            response.MatchesFound = (response.NumberOfResults != 0);
            responseWrapper.add(response);

            }
            

            return responseWrapper;
        
    } 
    
    public class Result{
        @InvocableVariable
        public List<Contact> contacts;
        @InvocableVariable
        public List<Account> accounts;
        @InvocableVariable
        public List<User> users;
        @InvocableVariable
        public List<Lead> leads;
        //@InvocableVariable
        //public List<Individual> individuals;

        @InvocableVariable (label='Total numnber of results')   
        public Integer NumberOfResults;
        public Boolean MatchesFound;
    }
    
    public class Request{
        @InvocableVariable
        public List<String> emails;
    }

}