/**
 * @description COAP/POAP data collecting class by Type, Permission set and Profile
 * 
 * @userStory SFP-11931 Epic 3 MVP2 : Customer on a page (Profile)
 *
 * @author Alexei Vyrskii
 *
 * @date November 2022
 */
public class COAP_Components_Helper {
    private static final String SELECTED_FIELD_NAME = 'PermissionSet.Name';
    private static final String OBJECT_NAME = PermissionSetAssignment.SObjectType.getDescribe().getLocalName();
	private static final String FIELD_NAME = PermissionSetAssignment.AssigneeId.getDescribe().getLocalName();
    
    private static Set<String> currentUserPermissionSetNames {
      get {
      	if (currentUserPermissionSetNames == null) {
            currentUserPermissionSetNames = new Set<String>();
            
            //get PermissionSetAssignment list for current User
            List<PermissionSetAssignment> currentAssignments =
                CMN_DAL_SObjectSelector.findByField(OBJECT_NAME,
													FIELD_NAME,
                                                    new Set<String>{currentUser.Id},
                                                    new Set<String>{SELECTED_FIELD_NAME});
            if(!currentAssignments.isEmpty()) {
                for(PermissionSetAssignment item : currentAssignments) {
                    currentUserPermissionSetNames.add(item.PermissionSet.Name);
                }
            }
      	}
          
      	return currentUserPermissionSetNames;
      }
     	set;
    }
    
    private static User currentUser {
      get {
      	if (currentUser == null) {
            currentUser = CMN_DAL_User.findByUserId(UserInfo.getUserId());
      	}
          
      	return currentUser;
      }
     	set;
    }
    
    /**
     * @description Method to get COAP POAP Component setting with values
     * @param nbaResponse Response from NBA side
     * @param componentType type of component (coap or poap)
     * @return List<COAP_DTO_CoapPoapComponent>
     */
    public static List<COAP_DTO_CoapPoapComponent> getComponents(String nbaResponse, String componentType) {
        List<COAP_POAP_Component__mdt> availableComponents = SEL_COAP_CustomMetadata.getMetadataByType(componentType);
        List<COAP_DTO_CoapPoapComponent> populatedComponents = new List<COAP_DTO_CoapPoapComponent>();
        
        if(!availableComponents.isEmpty() && nbaResponse != null) {
            
            try{
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(nbaResponse);
                
                for(COAP_POAP_Component__mdt component : availableComponents) {
                    
                    if(responseMap.containsKey(component.NBA_Column_Name__c) && hasAccess(component)) {
                        COAP_DTO_CoapPoapComponent wrapper = new COAP_DTO_CoapPoapComponent();
                        wrapper.message = component.NBA_Column_Name__c;
                        wrapper.componentName = component.Component_Name__c;
                        wrapper.values = (String) JSON.serialize(responseMap.get(component.NBA_Column_Name__c));
                        populatedComponents.add(wrapper);
                    }
                }
            }
            catch (Exception ex) {
                CMN_UTIL_Logger.error(ex, 'COAP_Components_Helper.getComponents');
            }
        }
        
        return populatedComponents;
    }
    
    
    private static Boolean hasAccess(COAP_POAP_Component__mdt component) {
        Boolean hasValidProfile = true;
        Boolean hasValidPermissionSet = false;
        
        //check Profile Name in setting or blank
        if(!String.isBlank(component.Profile_Name__c)) {
            Set<String> profileNameSet = new Set<String>(component.Profile_Name__c.split(','));
            
            if(!profileNameSet.contains(currentUser.Profile.Name)) {
                hasValidProfile = false;
            }
        }
        
        //check Permission Set Name in setting or blank
        if(!String.isBlank(component.Permission_set__c)) {
            
            for(String profileName : new Set<String>(component.Permission_set__c.split(','))) {
                if(currentUserPermissionSetNames.contains(profileName)) {
                    hasValidPermissionSet = true;
                    break;
                }
            }
        }
        
        return(hasValidProfile || hasValidPermissionSet);
    }
}