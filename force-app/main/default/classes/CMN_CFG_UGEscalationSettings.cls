/**
 * @description Configuration service for UG case escalation settings.
 *              Loads active custom metadata, validates required fields,
 *              and resolves the automated user for timing checks.
 *              Returns a ready-to-use Config DTO to the batch class.
 * @author Raymond Magezi
 * @date 23-07-2026
 * @see CMN_BATCH_UG_CaseEscalation
 * @see SEL_UGCaseEscalation
 * @see UG_PB_Escalation_Setting__mdt
 * @userStory SFP-58853
 * @history 23-07-2026  Raymond Magezi  Initial creation - extracted from CMN_BATCH_UG_CaseEscalation
 * @history 08-07-2026  Raymond Magezi  Replaced User.Name lookup with Username exact match
 *                                      for stable unique key resolution - SFP-58853
 * @history 09-07-2026  Raymond Magezi  Replaced environment suffix logic with email-based
 *                                      user resolution (environment-agnostic) - SFP-58853
 * @history 12-07-2026  Raymond Magezi  Fixed duplicate email resolution: switched to username
 *                                      pattern matching via selectByBaseUsername - SFP-58853
 */
public with sharing class CMN_CFG_UGEscalationSettings {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_CFG_UGEscalationSettings.class.getName());

    private CMN_CFG_UGEscalationSettings() {}

    /**
     * @description DTO holding validated escalation configuration ready for batch use.
     */
    public class Config {
        public UG_PB_Escalation_Setting__mdt setting;
        public Id automatedUserId;
        public Decimal maxLevel;
    }

    /**
     * @description Loads, validates, and returns escalation configuration for the given country.
     *
     * @param countryCode Country code to match against CaseOwnerCountry__c (e.g. 'UG')
     * @return Config DTO with validated setting, resolved automated user Id, and max level
     * @throws CMN_BATCH_UG_CaseEscalation.BatchableException if no active setting or invalid config
     */
    public static Config loadForCountry(String countryCode) {
        try {
            List<UG_PB_Escalation_Setting__mdt> activeSettings = SEL_UGCaseEscalation.selectAllActiveSettings();

            if (activeSettings.isEmpty()) {
            throw new CMN_BATCH_UG_CaseEscalation.BatchableException('No active UG_PB_Escalation_Setting__mdt records found');
        }

        UG_PB_Escalation_Setting__mdt setting = findSettingForCountry(activeSettings, countryCode);
        validateSetting(setting);

            if (mockUnexpectedException) {
                throw new TypeException('Mock unexpected error');
            }
        Config cfg = new Config();
        cfg.setting = setting;
        cfg.maxLevel = setting.MaxEscalationLevel__c;
        cfg.automatedUserId = resolveAutomatedUser(setting.AutomatedUserName__c);
        LOGGER.info('loadForCountry: Config loaded - Country: {0}, MaxLevel: {1}, AutomatedUser: {2}',
            new Object[]{countryCode, cfg.maxLevel, cfg.automatedUserId});
        return cfg;
        } catch (CMN_BATCH_UG_CaseEscalation.BatchableException e) {
            LOGGER.error('loadForCountry: {0}', new Object[]{e.getMessage()});
            throw e;
        } catch (Exception e) {
            LOGGER.error('loadForCountry: Unexpected error - {0}', new Object[]{e.getMessage()});
            throw e;
        }
    }

    /**
     * @description Finds the setting matching the given country code.
     *
     * @param activeSettings List of active metadata records
     * @param countryCode Target country code
     * @return Matching UG_PB_Escalation_Setting__mdt
     * @throws CMN_BATCH_UG_CaseEscalation.BatchableException if no match found
     */
    private static UG_PB_Escalation_Setting__mdt findSettingForCountry(
        List<UG_PB_Escalation_Setting__mdt> activeSettings, String countryCode
    ) {
        for (UG_PB_Escalation_Setting__mdt s : activeSettings) {
            if (s.CaseOwnerCountry__c == countryCode) {
                return s;
            }
        }
        throw new CMN_BATCH_UG_CaseEscalation.BatchableException(
            'No active UG_PB_Escalation_Setting__mdt found for country: ' + countryCode
        );
    }

    /**
     * @description Validates that required fields are populated on the setting.
     *
     * @param setting The metadata record to validate
     * @throws CMN_BATCH_UG_CaseEscalation.BatchableException if config is invalid
     */
    private static void validateSetting(UG_PB_Escalation_Setting__mdt setting) {
        if (setting.MaxEscalationLevel__c == null || setting.MaxEscalationLevel__c <= 0
            || String.isBlank(setting.EmailTemplateApiName__c)) {
            throw new CMN_BATCH_UG_CaseEscalation.BatchableException(
                'Invalid config in record: ' + setting.DeveloperName
            );
        }
    }

    @TestVisible
    private static Boolean mockUserQueryException = false;
    @TestVisible
    private static Boolean mockUnexpectedException = false;

    /**
     * @description Resolves the automated user Id by querying User via base username pattern.
     *              Username is globally unique; LIKE match handles sandbox suffixes.
     *
     * @param baseUsername Base production username (e.g. 'sbgdatauser@standardbank.co.za')
     * @return Id of the user
     * @throws CMN_BATCH_UG_CaseEscalation.BatchableException if no match or multiple matches found
     */
    private static Id resolveAutomatedUser(String baseUsername) {
        if (String.isBlank(baseUsername)) {
            return null;
        }
        List<User> users;
        try {
            if (mockUserQueryException) {
                throw new QueryException('Mock query failure');
            }
            users = SEL_User.newInstance().selectByBaseUsername(baseUsername);
        } catch (Exception e) {
            LOGGER.error('resolveAutomatedUser: {0}', new Object[]{e.getMessage()});
            return null;
        }
        if (users.isEmpty()) {
            throw new CMN_BATCH_UG_CaseEscalation.BatchableException(
                'No active automation user found matching pattern: ' + baseUsername
            );
        }
        if (users.size() > 1) {
            throw new CMN_BATCH_UG_CaseEscalation.BatchableException(
                'Multiple active users matched the pattern: ' + baseUsername
            );
        }
        return users[0].Id;
    }
}