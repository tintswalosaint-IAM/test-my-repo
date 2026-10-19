/**
 * @description Validates that the Awaiting Customer Feedback Reason field is
 *              populated when a UG user changes Sub-Status to Awaiting Customer Feedback.
 *              Only fires on sub-status change, bypasses automated processes.
 *              All configuration is driven by SVC_UGCaseSetting__mdt.
 *              <br/>SFP-58599
 *
 * @see SVC_UGCaseSetting__mdt Custom metadata storing validation config (country, min length, regex, error message)
 * @see SVC_TRH_Case Trigger handler that invokes this validator in beforeUpdate
 * @see SEL_User Selector used to query the current user profile
 *
 * @author Raymond Magezi
 * @date June 2026
 */
public inherited sharing class SVC_AwaitingFeedbackValidator {

    private SVC_AwaitingFeedbackValidator() {}

    private static final Set<String> ENFORCED_PROFILES = new Set<String>{'SVC Agent Banker', 'Relationship Manager'};

    /**
     * @description Lazy-loaded custom metadata record holding all validation configuration.
     *              Record name: SVC_AwaitingFeedbackValidator
     */
    private static final SVC_UGCaseSetting__mdt SETTINGS {
        get {
            if (SETTINGS == null) {
                SETTINGS = SVC_UGCaseSetting__mdt.getInstance('SVC_AwaitingFeedbackValidator');
            }
            return SETTINGS;
        }
        set;
    }

    /**
     * @description Validates the awaiting feedback reason field on sub-status change.
     *              Reads min length, regex pattern, and error message from SVC_UGCaseSetting__mdt.
     *
     * @param oldCase Old Case record
     * @param newCase New Case record
     */
    public static void validate(Case oldCase, Case newCase) {
        if (SETTINGS == null || !shouldValidate(oldCase, newCase)) {
            return;
        }
        String reason = newCase.SVC_AwaitingCustomerFeedbackReason__c;
        Integer minLength = Integer.valueOf(SETTINGS.SVC_MinimumCommentLength__c);
        if (String.isBlank(reason) || reason.length() < minLength || !Pattern.matches(SETTINGS.SVC_ValidPattern__c, reason)) {
            newCase.addError(SETTINGS.SVC_ErrorReasonRequired__c);
        }
    }

    /**
     * @description Determines whether validation should run based on sub-status change,
     *              country, and user context. Bypasses automated processes.
     *
     * @param oldCase Old Case record
     * @param newCase New Case record
     *
     * @return Boolean true if validation should be enforced
     */
    private static Boolean shouldValidate(Case oldCase, Case newCase) {
        if (oldCase.SVC_SubStatus__c == newCase.SVC_SubStatus__c) {
            return false;
        }
        if (newCase.SVC_SubStatus__c != SETTINGS.SVC_SubStatusValue__c) {
            return false;
        }
        if (newCase.Case_Owner_Country__c != SETTINGS.SVC_CaseOwnerCountry__c) {
            return false;
        }
        if (UserInfo.getName() == 'Automated Process') {
            return false;
        }
        return isEnforcedProfile();
    }

    /**
     * @description Checks if the current user has a profile that should be enforced.
     *              Uses SEL_User selector to query user profile name.
     *
     * @return Boolean true if user has an enforced profile
     */
    private static Boolean isEnforcedProfile() {
        try {
            List<User> users = SEL_User.newInstance().selectUsersByIds(new Set<Id>{ UserInfo.getUserId() });
            return !users.isEmpty() && ENFORCED_PROFILES.contains(users[0].Profile.Name);
        } catch (Exception e) {
            return true;
        }
    }
}