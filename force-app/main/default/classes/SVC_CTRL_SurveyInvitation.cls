/***************************************************************************************
@Name of the Component : SVC_CTRL_SurveyInvitation
@Description : Controller for Survey QR code generation.
               Supports both Branch Feedback and Head Office Department surveys.
               Delegates data access to SEL_BranchUnit and SEL_SurveyInvitation selectors.
               Configuration values sourced from SVC_SurveyConfiguration__mdt.
@Author : Raymond Magezi
@Created Date : 15-04-2026
User Story: SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 22-04-2026
@Modification description: Updated to handle List returns from selector methods.
    Replaced negated null checks with positive equality checks.
    Extracted duplicate string literals into constants.
    Added getQRCodeBaseUrl method with proper error handling.
    Moved selectNetworkId from SEL_SurveyInvitation into this controller.
 User Story: SFP-57596
***************************************************************************************/
public with sharing class SVC_CTRL_SurveyInvitation {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CTRL_SurveyInvitation');

    private static final String CONFIG_DEVELOPER_NAME = 'SVC_Branch_Feedback_QR_Configuration';

    @TestVisible
    private static String mockInvitationLink;
    @TestVisible
    private static SEL_BranchUnit mockBranchUnitSelector;
    @TestVisible
    private static SEL_SurveyInvitation mockSurveyInvitationSelector;

    private SVC_CTRL_SurveyInvitation() {}

    /**
     * @description Returns active branch names from the SVC_BranchName global value set.
     * @return List of maps with label and value keys
     * @throws AuraHandledException If an error occurs
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getBranchOptions() {
        try {
            return getBranchUnitSelector().selectActiveBranches();
        } catch (Exception e) {
            LOGGER.error('Failed to retrieve branch options: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns active department names from the SVC_DepartmentName global value set.
     * @return List of maps with label and value keys
     * @throws AuraHandledException If an error occurs
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getDepartmentOptions() {
        try {
            return getBranchUnitSelector().selectActiveDepartments();
        } catch (Exception e) {
            LOGGER.error('Failed to retrieve department options: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns the QR code base URL from SVC_SurveyConfiguration__mdt.
     * @return QR code base URL string
     */
    @AuraEnabled(cacheable=true)
    public static String getQRCodeBaseUrl() {
        try {
            SVC_SurveyConfiguration__mdt config = SVC_SurveyConfiguration__mdt.getInstance(CONFIG_DEVELOPER_NAME);
            return config == null ? '' : config.SVC_QRCodeBaseUrl__c;
        } catch (Exception e) {
            LOGGER.error('Failed to retrieve QR code base URL: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns the SurveyInvitation link for a given branch name.
     * @param branchUnitId The branch name
     * @return InvitationLink URL string, or null
     * @throws AuraHandledException If an error occurs
     */
    @AuraEnabled
    public static String getInvitationLinkByBranch(String branchUnitId) {
        try {
            if (String.isBlank(branchUnitId)) { return null; }
            List<SurveyInvitation> results = getSurveyInvitationSelector().selectByBranchName(branchUnitId);
            return results.isEmpty() ? null : results[0].InvitationLink;
        } catch (Exception e) {
            LOGGER.error('Failed to get invitation link for branch: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns the SurveyInvitation link for a given department name.
     * @param departmentName The department name
     * @return InvitationLink URL string, or null
     * @throws AuraHandledException If an error occurs
     */
    @AuraEnabled
    public static String getInvitationLinkByDepartment(String departmentName) {
        try {
            if (String.isBlank(departmentName)) { return null; }
            List<SurveyInvitation> results = getSurveyInvitationSelector().selectByDepartmentName(departmentName);
            return results.isEmpty() ? null : results[0].InvitationLink;
        } catch (Exception e) {
            LOGGER.error('Failed to get invitation link for department: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Creates a SurveyInvitation for a branch if one doesn't exist.
     * @param surveyId The Survey record Id
     * @param branchUnitId The branch name (used as identifier)
     * @param branchName The branch name to stamp on the invitation
     * @return The InvitationLink of the created or existing invitation
     * @throws AuraHandledException If an error occurs during invitation creation
     */
    @AuraEnabled
    public static String createInvitationForBranch(String surveyId, String branchUnitId, String branchName) {
        try {
            String existingLink = getInvitationLinkByBranch(branchUnitId);
            if (String.isBlank(existingLink)) {
                if (String.isBlank(surveyId) || String.isBlank(branchName)) { return null; }

                SVC_SurveyConfiguration__mdt config = SVC_SurveyConfiguration__mdt.getInstance(CONFIG_DEVELOPER_NAME);
                String prefix = config == null ? '' : config.SVC_BranchInvitationPrefix__c;

                SurveyInvitation inv = new SurveyInvitation(
                    SurveyId = surveyId,
                    Name = prefix + branchName,
                    SVC_BranchName__c = branchName,
                    OptionsAllowGuestUserResponse = true,
                    CommunityId = selectNetworkId()
                );
                return insertAndReturnLink(inv);
            }
            return existingLink;
        } catch (Exception e) {
            LOGGER.error('Failed to create invitation for branch: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Creates a SurveyInvitation for a department if one doesn't exist.
     * @param surveyId The Survey record Id
     * @param departmentName The department name to stamp on the invitation
     * @return The InvitationLink of the created or existing invitation
     * @throws AuraHandledException If an error occurs during invitation creation
     */
    @AuraEnabled
    public static String createInvitationForDepartment(String surveyId, String departmentName) {
        try {
            String existingLink = getInvitationLinkByDepartment(departmentName);
            if (String.isBlank(existingLink)) {
                if (String.isBlank(surveyId) || String.isBlank(departmentName)) { return null; }

                SVC_SurveyConfiguration__mdt config = SVC_SurveyConfiguration__mdt.getInstance(CONFIG_DEVELOPER_NAME);
                String prefix = config == null ? '' : config.SVC_DepartmentInvitationPrefix__c;

                SurveyInvitation inv = new SurveyInvitation(
                    SurveyId = surveyId,
                    Name = prefix + departmentName,
                    SVC_DepartmentName__c = departmentName,
                    OptionsAllowGuestUserResponse = true,
                    CommunityId = selectNetworkId()
                );
                return insertAndReturnLink(inv);
            }
            return existingLink;
        } catch (Exception e) {
            LOGGER.error('Failed to create invitation for department: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Returns the SEL_SurveyInvitation instance, allowing test injection.
     * @return SEL_SurveyInvitation instance
     */
    private static SEL_SurveyInvitation getSurveyInvitationSelector() {
        return mockSurveyInvitationSelector == null ? SEL_SurveyInvitation.newInstance() : mockSurveyInvitationSelector;
    }

    /**
     * @description Returns the SEL_BranchUnit instance, allowing test injection.
     * @return SEL_BranchUnit instance
     */
    private static SEL_BranchUnit getBranchUnitSelector() {
        return mockBranchUnitSelector == null ? SEL_BranchUnit.newInstance() : mockBranchUnitSelector;
    }

    /**
     * @description Inserts a SurveyInvitation using fflib Unit of Work and returns the InvitationLink.
     * @param inv The SurveyInvitation to insert
     * @return The InvitationLink of the created invitation
     */
    private static String insertAndReturnLink(SurveyInvitation inv) {
        if (Test.isRunningTest() && mockInvitationLink != null) { return mockInvitationLink; }
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE, new List<SObject>{ inv }
        );
        try {
            sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            uow.registerNew(decision.getRecords()[0]);
            uow.commitWork();
        } catch (Exception e) {
            LOGGER.error('Failed to insert SurveyInvitation: ' + e.getMessage(), new Object[]{});
            throw new AuraHandledException(e.getMessage());
        }
        List<SurveyInvitation> created = SEL_SurveyInvitation.newInstance().selectById(decision.getRecords()[0].Id);
        return created.isEmpty() ? null : created[0].InvitationLink;
    }

    /**
     * @description Selects the Network Id for the Experience Cloud site configured in SVC_SurveyConfiguration__mdt.
     * @return Network Id as String, or null
     */
    private static String selectNetworkId() {
        if (!Schema.SObjectType.Network.isAccessible()) {
            return null;
        }
        SVC_SurveyConfiguration__mdt config = SVC_SurveyConfiguration__mdt.getInstance(CONFIG_DEVELOPER_NAME);
        if (config == null || String.isBlank(config.SVC_ExperienceCloudSiteName__c)) {
            return null;
        }
        String siteName = config.SVC_ExperienceCloudSiteName__c;
        List<Network> networks = [
            SELECT Id FROM Network WHERE Name = :siteName LIMIT 1
        ];
        return networks.isEmpty() ? null : networks[0].Id;
    }
}