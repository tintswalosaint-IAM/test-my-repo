/**
 * @description       : Class for performing account team updates as part of account maintenance process
 * @author            : Dhiraj Prajapati
 * @group             : Account Maintenance
 * @last modified on  : 08-02-2024
 * @last modified by  : Derek Hughes
**/
public without sharing class CMN_SRV_AccountTeamUpdate {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_SRV_AccountTeamUpdate.class.getName());

    private List<AccountTeamMember> membersToAdd = new List<AccountTeamMember>();
    private List<AccountTeamMember> membersToDelete = new List<AccountTeamMember>();
    private Map<String, Set<Id>> codeToUserIds;

    private Result result;

    private Class MyException extends Exception {}
   
    /**
    * @description Setter method to set Users by Key (portfolio code) and Id
    * Users must be set before process can be executed.  The caller can optimise the number of users to be included
    * based on its context (batch or trigger)
    * @author Dhiraj Prajapati | 30-01-2024 
    * @param codeToUserIds 
    * @return CMN_SRV_AccountTeamUpdate 
    **/
    public CMN_SRV_AccountTeamUpdate setUsers(Map<String, Set<Id>> codeToUserIds) {
        this.codeToUserIds = codeToUserIds;
        LOGGER.debug('setUsers: codeToUserIds.size='+codeToUserIds.size());
        LOGGER.trace('setUser: codeToUserIds: '+codeToUserIds);
        return this;
    }

    /**
     * @description Entry method to process Account(s) top update Owner on Account and create/delete
     * AccountTeamMembers baed on Settings in Relationship_Management_Settings__mdt
     * @author Dhiraj Prajapati | 30-01-2024 
     * @param scope - List<Account>
     *
     * @return result - Result Object
     */
    public Result process(List<Account> scope) {

        LOGGER.info('process: scope.size='+scope.size());

        // Check if users have been set
        if (this.codeToUserIds == null) {
            throw new MyException('FATAL ERROR: Users have not been set before processing account maintenance');
        }

        this.result = new Result();
        Set<String> countryCodes = DMN_RelationshipManagementSettings.getCountriesForOwnerAndTeams();

        scope = new CMN_SEL_Account().selectWithAccountTeamsByCountries(new Map<Id, Account>(scope).keySet(), countryCodes);

        this.updateAccountTeamMembers(scope);

        LOGGER.info('process: result: '+result);

        return this.result;
    }

    /**
     * @description Update/Delete AccountTeamMember based on Portfolio code
     * @author Dhiraj Prajapati | 30-01-2024 
     * @param scope
     *
     */
    public Void updateAccountTeamMembers(List<Account> scope) {

        this.processMembers(scope);
        
        if (!this.membersToDelete.isEmpty()) {
            List<Database.DeleteResult> dmlResults = Database.delete(membersToDelete, false);
            Result deleteResult = generateResult(dmlResults);
            this.result.errors += deleteResult.errors;
            this.result.errorMessages += deleteResult.errorMessages;
            this.result.teamMembersDeleted += this.membersToDelete.size();
        }
        if (!this.membersToAdd.isEmpty()) {
            List<Database.UpsertResult> dmlResults = Database.upsert(membersToAdd, false);
            Result addResult = generateResult(dmlResults);
            this.result.errors += addResult.errors;
            this.result.errorMessages += addResult.errorMessages;
            this.result.teamMembersAdded += this.membersToAdd.size();
        }
    }

    /**
     * @description Process Account and Create AccountTeamMember records
     * @author Dhiraj Prajapati | 30-01-2024 
     * @param accounts
     *
     */
    private Void processMembers(List<Account> accounts) {

        Set<Id> membersToKeep = new Set<Id>();

        for (Account acc: accounts) {
            LOGGER.trace('processMembers: acc.Name='+acc.Name+' acc.RelationshipMgrCode__c='+acc.RelationshipMgrCode__c);
            String code = acc.RelationshipMgrCode__c?.trim().toUpperCase();
            Set<Id> userIds = this.codeToUserIds.containsKey(code) ? this.codeToUserIds.get(code) : new Set<Id>();

            for (AccountTeamMember member : acc.AccountTeamMembers) {
                // Is the account team member still assigned to the portfolio code?  
                if (!userIds.contains(member.UserId)) { //If not it must be deleted
                    this.membersToDelete.add(new AccountTeamMember(Id = member.Id));
                }
                else {  // otherwise it will be retained.
                    membersToKeep.add(member.UserId);
                }
            }

            for (Id user :userIds) {
                // Is the user already a member?
                if (!membersToKeep.contains(user)) { // If not then it must be added to the account team.
                    this.addMembers(acc.Id, user);
                }
            }
        }
    }

    /**
     * @description Create AccountTeamMember record in memory for Account and User
     * @author Dhiraj Prajapati | 30-01-2024 
     * @param accountId - Account
     * @param user - User
     *
     */
    private Void addMembers(Id accountId, Id user) {
        this.membersToAdd.add(
            new AccountTeamMember(
                AccountId = accountId,
                UserId = user,
                TeamMemberRole = 'RM Assistant',
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'Edit',
                CaseAccessLevel = 'Edit',
                ContactAccessLevel = 'Edit'
            )
        );
    }

   
    /**
    * @description Log error from Upsert operation
    * @author Derek Hughes | 30-01-2024 
    * @param dmlResults 
    * @return Result 
    **/
    private Result generateResult(List<Database.UpsertResult> dmlResults) {
        Result result = new Result();
        for (Database.UpsertResult dmlResult : dmlResults) {
            if (!dmlResult.isSuccess()) {
                result.errors++;
                result.errorMessages += dmlResult.getErrors() + '\n';
                this.logError(dmlResult.getId(), dmlResult.getErrors());
            }
        }
        return result;
    }

    /**
     * @description Log error from Delete operation
     * @author Dhiraj Prajapati | 30-01-2024 
     * @param dmlResults 
     * @return Result
     */
    private Result generateResult(List<Database.DeleteResult> dmlResults) {
        Result result = new Result();
        for (Database.DeleteResult dmlResult : dmlResults) {
            if (!dmlResult.isSuccess()) {
                result.errors++;
                result.errorMessages += dmlResult.getErrors() + '\n';
                this.logError(dmlResult.getId(), dmlResult.getErrors());
            }
        }
        return result;
    }

    /**
    * @description Handle and error on a save result
    * @author Derek Hughes | 14-06-2023
    * @param recordId
    * @param errors
    * 2023-08-21  Karabo Machubeni   Core logic from the execute method of the CMN_BATCH_AccountMaintenance
    **/
    @TestVisible
    private void logError(Id recordId, List<Database.Error> errors) {
        LOGGER.error(
            'Error inserting/updating record : ' + recordId + ': ' + this.getErrorMessage(errors)
        );
    }

    /**
    * @description Estracts error message from Database.Error object
    * @author Derek Hughes | 30-01-2024 
    * @param errors 
    * @return String 
    **/
    @TestVisible
    private String getErrorMessage(List<Database.Error> errors) {
        String errorMessage = 'Unknown error';
        if (!errors.isEmpty()) {
            errorMessage = errors[0].getMessage();
        }
        return errorMessage;
    }

    public class Result {

        public Integer teamMembersAdded = 0;
        public Integer teamMembersDeleted = 0;
        public Integer errors = 0;
        public String errorMessages = '';

    }

}