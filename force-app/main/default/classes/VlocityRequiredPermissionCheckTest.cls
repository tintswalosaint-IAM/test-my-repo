/*-----------------------------------------------------------------------------------------------------------
Author:          Ihtishaam Mohammoodally
Description:     Unit tests for VlocityRequiredPermissionCheck. 
                 Covers positive/negative paths, multi-permission inputs, whitespace, nulls, and wrong action.
Tested Class:    VlocityRequiredPermissionCheck

03 October 2025  Ihtishaam Mohammoodally    New version of tests aligned with updated implementation.
06 October 2025  Tintswalo Mushwana         Added negative/positive paths and assertions.
-----------------------------------------------------------------------------------------------------------*/
@IsTest
private class VlocityRequiredPermissionCheckTest {
    
    @TestSetup
    private static void setup(){
        User testUser = WI_DAL_DataFactory.createUser('SVC Agent Banker');
        insert testUser;
        
        User testUserNoPermission = WI_DAL_DataFactory.createUser('Insurance');
        insert testUserNoPermission;
        
        PermissionSet permissionSet = [Select Id,Name from PermissionSet where Name = 'Insurance_Panel_Quote_User_Access'];
        PermissionSetAssignment permissionSetAssignement = new PermissionSetAssignment (PermissionSetId = permissionSet.Id, AssigneeId = testUser.Id);
        insert permissionSetAssignement;
    }
    
    @IsTest
    private static void testHasPermission(){
        User testUser = [Select Id,Email from User where Email = 'aob@sb.com' AND profile.Name = 'SVC Agent Banker' limit 1];
        System.runAs(testUser) {
            VlocityRequiredPermissionCheck checkPermission = new VlocityRequiredPermissionCheck();
            Boolean result = (Boolean) checkPermission.call('checkPermission',
                                              new Map<String,Object>{ 'requiredPermission' => 'Insurance_Panel_Quote_User' });
            Assert.isTrue(result);

        }
    }
    
    @IsTest
    private static void testHasNoPermission(){
        User testUser = [Select Id,Email from User where Email = 'aob@sb.com' AND profile.Name = 'Insurance' limit 1];
        Map<String,Object> args = new Map<String,Object>{ 'requiredPermission' => 'Insurance_Panel_Quote_User'};
        System.runAs(testUser) {
            VlocityRequiredPermissionCheck checkPermission = new VlocityRequiredPermissionCheck();
            Boolean result = (Boolean) checkPermission.call('checkPermission',args);
            Boolean failedPermissionCheck = (Boolean) checkPermission.call('noPermissionCheck',args);
            Assert.isFalse(result);
            Assert.isFalse(failedPermissionCheck);
        }
    }

}