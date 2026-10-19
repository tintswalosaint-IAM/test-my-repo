/**
 * @description Data Access Layer class for the COAP_POAP_Component__mdt object
 * 
 * @userStory SFP-11931 Epic 3 MVP2 : Customer on a page (Profile)
 *
 * @author Alexei Vyrskii
 *
 * @date November 2022
 */
public class SEL_COAP_CustomMetadata {
	
    /**
	 * @description Method returns COAP_POAP_Component by component type
	 * @param componentType type of component
	 * @return components List of COAP_POAP_Component
	 */
    public static List<COAP_POAP_Component__mdt> getMetadataByType(string componentType) {
        List<COAP_POAP_Component__mdt> components = [
            SELECT Id, Component_Name__c, Component_Type__c, NBA_Column_Name__c, Permission_set__c, Profile_Name__c
            FROM COAP_POAP_Component__mdt
            WHERE Component_Type__c = :componentType
        ];
        
        if (Test.isRunningTest()) {
           return createTestSettings(componentType);
        }
        return components;
    }
    
    private static final String COMP_PROFILE = '_comp_profile';
    private static final String COMP_VALUE_ADDED = '_comp_value_added';
    private static final String PROFILE = 'profile';
    private static final String VALUE_ADDED = 'value_added';
    private static final String PERMISSION_SET_STRING = 'RM_South_Africa_Permission_Set,RelationshipManager';
    private static final String PROFILE_NAME_STRING = 'System Administrator,Relationship Manager';
    
    
    /**
	 * @description Method  create test data COAP_POAP_Component by component type
	 * @param componentType type of component
	 * @return COAP_POAP_Component List for testing
	 */
    private static List<COAP_POAP_Component__mdt> createTestSettings(string componentType) {
        COAP_POAP_Component__mdt setting1 = new COAP_POAP_Component__mdt(
        	DeveloperName = componentType + COMP_PROFILE,
            Label = componentType + COMP_PROFILE,
            Component_Name__c = componentType + COMP_PROFILE,
            Component_Type__c = componentType,
            NBA_Column_Name__c = PROFILE,
            Permission_set__c = PERMISSION_SET_STRING,
            Profile_Name__c = PROFILE_NAME_STRING
        );
        COAP_POAP_Component__mdt setting2 = new COAP_POAP_Component__mdt(
        	DeveloperName = componentType + COMP_VALUE_ADDED,
            Label = componentType + COMP_VALUE_ADDED,
            Component_Name__c = componentType + COMP_VALUE_ADDED,
            Component_Type__c = componentType,
            NBA_Column_Name__c = VALUE_ADDED,
            Permission_set__c = PERMISSION_SET_STRING,
            Profile_Name__c = PROFILE_NAME_STRING
        );
        
        return new List<COAP_POAP_Component__mdt>{setting1, setting1};
    }
}