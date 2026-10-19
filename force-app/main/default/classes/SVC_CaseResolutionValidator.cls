/**
 * @description Case resolution comments validation helper.
 *              Enforces minimum character length and blocks generic phrases
 *              for Resolution_Comments_to_Client__c.
 *              Used by SVC_TRH_Case trigger handler for Uganda cases.
 *              Configuration is driven by SVC_UGCaseSetting__mdt.
 *
 * @see SVC_TRH_Case
 *
 * @author Raymond Magezi
 *
 * @date February 2026
 *
 * @userStory SFP-56268
 */
public with sharing class SVC_CaseResolutionValidator {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CaseResolutionValidator');

    private static final SVC_UGCaseSetting__mdt SETTINGS {
        get {
            if (SETTINGS == null) {
                SETTINGS = SVC_UGCaseSetting__mdt.getInstance('SVC_CaseResolutionValidator');
            }
            return SETTINGS;
        }
        set;
    }

    @TestVisible
    private SVC_CaseResolutionValidator() {
    }

    /**
     * @description Validates Resolution_Comments_to_Client__c for a Case.
     *              Enforces required field, minimum character length,
     *              and blocks generic phrases. Config sourced from SVC_UGCaseSetting__mdt.
     * @param newCase Case record to validate
     */
    public static void validate(Case newCase) {
        if (newCase == null) {
            LOGGER.warn('validate: Received null Case record');
            return;
        }

        if (String.isBlank(newCase.Resolution_Comments_to_Client__c)) {
            LOGGER.warn('validate: Resolution comments blank for Case {0}', new Object[]{ newCase.Id });
            newCase.addError(SETTINGS.SVC_ErrorResolutionRequired__c);
            return;
        }

        String cleanText = newCase.Resolution_Comments_to_Client__c.stripHtmlTags().trim();
        Integer minLength = Integer.valueOf(SETTINGS.SVC_MinimumCommentLength__c);

        LOGGER.info('validate: Evaluating resolution comments for Case {0}, length={1}',
            new Object[]{ newCase.Id, cleanText.length() });

        if (cleanText.length() < minLength) {
            String errorMsg = String.format(SETTINGS.SVC_ErrorMinLength__c, new List<String>{
                String.valueOf(minLength)
            });
            LOGGER.warn('validate: Comment too short ({0} chars) for Case {1}',
                new Object[]{ cleanText.length(), newCase.Id });
            newCase.addError(errorMsg);
            return;
        }

        if (Pattern.compile(SETTINGS.SVC_BlockedPhrasesPattern__c).matcher(cleanText).matches()) {
            LOGGER.warn('validate: Blocked phrase detected for Case {0}: "{1}"',
                new Object[]{ newCase.Id, cleanText });
            newCase.addError(SETTINGS.SVC_ErrorBlockedPhrase__c);
        }
    }
}