/***************************************************************************************
@Name of the Component : SEL_BranchUnit
@Description : Selector class for retrieving active picklist values from
               SurveyInvitation custom picklist fields (SVC_BranchName__c, SVC_DepartmentName__c).
               Follows SBG layered architecture (Section 13.2).
@Author : Raymond Magezi
@Created Date : 15-04-2026
User Story: SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 22-04-2026
@Modification description: Converted from static to instance-based class to support
    fflib_ApexMocks mocking in test classes.
 User Story: SFP-57596
***************************************************************************************/
public virtual inherited sharing class SEL_BranchUnit {

    /**
     * @description Creates a new instance of the selector.
     * @return SEL_BranchUnit
     */
    public static SEL_BranchUnit newInstance() {
        return new SEL_BranchUnit();
    }

    /**
     * @description Returns active branch names from the SVC_BranchName global value set.
     * @return List of maps each containing 'label' and 'value' keys
     */
    public virtual List<Map<String, String>> selectActiveBranches() {
        return getActivePicklistValues(SurveyInvitation.SVC_BranchName__c);
    }

    /**
     * @description Returns active department names from the SVC_DepartmentName global value set.
     * @return List of maps each containing 'label' and 'value' keys
     */
    public virtual List<Map<String, String>> selectActiveDepartments() {
        return getActivePicklistValues(SurveyInvitation.SVC_DepartmentName__c);
    }

    private List<Map<String, String>> getActivePicklistValues(Schema.SObjectField field) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : field.getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                options.add(new Map<String, String>{ 'label' => entry.getLabel(), 'value' => entry.getValue() });
            }
        }
        return options;
    }
}