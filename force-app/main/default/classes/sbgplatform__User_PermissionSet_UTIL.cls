/**
 * @description This is a utility class to determine whether the currect user contains a permission set
 *
 * @author Milica Milicevic(Milica.Milicevic@standardbank.co.za)
 * @description Utility Class for permission sets assigned to a user.
 * @UserStory  SFP-50927 
 * @date July 2025
 *
 */
public with sharing class User_PermissionSet_UTIL {

    /**
	* @description Sends a boolean value based on whether the current user has a permission set assigned to them
	* @param String permissionSetDevName
    * @return Boolean
	**/
    public static Boolean userHasPermissionSet(String permissionSetDevName) {
        Id userID = UserInfo.getUserId();

        for (PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :userID]) {
            if (psa.PermissionSet.Name == permissionSetDevName) {
                return true;
            }
        }
        return false;
    }

}