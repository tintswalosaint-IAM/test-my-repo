/**
 * @description       : Domain Class for User
 * @author            : Dhiraj Kumar (CloudSmiths)
 * @group             : Domain
 * @last modified on  : 15-02-2024
 * @last modified by  : Derek Hughes
**/
public inherited sharing class DMN_User {

    /**
     * Populate a map of Portfolio code to User record Id (RM Assistant)
     *
     * @param List<User>
     *
     * @return Map<String, Set<Id>>
     */
    public Map<String, Set<Id>> getCodeToUserIds(List<User> users) {
        Map<String, Set<Id>> codeToUserIds = new Map<String, Set<Id>>();
        for (User user: users) {
            if (String.IsNotBlank(user.Portfolio_Codes__c) && String.IsNotBlank(user.Portfolio_Role_Name__c) && user.Portfolio_Role_Name__c?.equalsIgnoreCase('RM Assistant')) {
                for (String code : user.Portfolio_Codes__c.split(',')) {
                    code = code.trim().toUpperCase();
                    if (codeToUserIds.containsKey(code)) {
                        codeToUserIds.get(code).add(user.Id);
                    }
                    else {
                        codeToUserIds.put(code, new Set<Id>{user.Id});
                    }
                }
            }
        }
        return codeToUserIds;
    }
}