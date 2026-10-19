/*-----------------------------------------------------------------------------------------------------------
Author:          Ihtishaam Mohammoodally
Description:     Implements the VlocityRequiredPermissionCheck class as per Salesforce OmniStudio guidelines.
Test Class:      VlocityRequiredPermissionCheckTest

03 October 2025  Ihtishaam Mohammoodally    Initial version of the class implemented following Salesforce guidelines.
-----------------------------------------------------------------------------------------------------------*/
global class VlocityRequiredPermissionCheck implements Callable{
    
    global Boolean call(String action, Map<String, Object> args){
        if (action == 'checkPermission'){
            return checkPermission((String)args.get('requiredPermission'));
        }
        return false;
    }

    private Boolean checkPermission(String requiredPermission){
        Boolean hasCustomPermission = false;
        List<String> customPermissionsName = requiredPermission.split(',');
        for (String permissionName : customPermissionsName){
            Boolean hasPermission = FeatureManagement.checkPermission(permissionName.normalizeSpace());
            if (hasPermission == true){
                hasCustomPermission = true;
                break;
            }
        }
        return hasCustomPermission;
    }
}