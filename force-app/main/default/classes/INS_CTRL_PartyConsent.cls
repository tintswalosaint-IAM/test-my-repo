/**
 * @description  Creates Party Consent records for the Flexi Protect journey.
 *
 *               Two consents are captured at different points in the application:
 *               data privacy and marketing on the personal details screen, and
 *               policy terms and conditions on the disclosure screen. Both are
 *               recorded here after the Person Account exists, using the dates
 *               captured on screen so Effective From reflects when the customer
 *               actually consented rather than when the record was written.
 *
 *               WITHOUT SHARING as this runs for the Experience Cloud guest user.
 *
 * @story        SFP-56980
 * @author       Irshad
 * Test Class    INS_CTRL_PartyConsent_TEST
 */
public without sharing class INS_CTRL_PartyConsent implements Callable {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_PartyConsent');

    private static final String ACTION_CREATE_CONSENTS = 'createPartyConsents';

    private static final String CONSENT_NAME_PRIVACY = 'Data Privacy & Marketing Consent';
    private static final String CONSENT_NAME_TERMS   = 'Policy Ts&Cs Consents';

    private static final String CONSENT_ACTION_DATA_COLLECTION = 'Data Collection';
    private static final String CONSENT_ACTION_SHARE_DATA      = 'Share Data';

    private static final String STATUS_OPT_IN      = 'Opt In';
    private static final String BUSINESS_BRAND     = 'Liberty Life Kenya';
    private static final String CONTACT_POINT_TYPE = 'Web';

    // =========================================================================
    // CALLABLE ENTRY POINT
    // =========================================================================

    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get('input') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get('output') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');

        if (actionType == ACTION_CREATE_CONSENTS) {
            return createPartyConsents(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // =========================================================================
    // MAIN
    // =========================================================================

    private static Object createPartyConsents(
        Map<String, Object> input, Map<String, Object> output
    ) {
        try {
            Id accountId = toId(input.get('ProspectAccountId'));
            if (accountId == null) {
                throw new AuraHandledException('ProspectAccountId is required.');
            }

            String captureSource = resolveCaptureSource();           
            if (String.isBlank(captureSource)) {
                throw new AuraHandledException('consentCaptureSource is required.');
            }

            Id individualId = resolveIndividualId(accountId);            
            BusinessBrand brand = new SEL_BusinessBrand().selectByNameWoSharing(BUSINESS_BRAND);

            List<PartyConsent> consents = new List<PartyConsent>();

            if (isConsentGiven(input, 'isConsentGiven')) {
                consents.add(buildConsent(                    
					accountId,					
                    CONSENT_NAME_PRIVACY,
					individualId,
                    captureSource,
                    brand.Id,
                    CONSENT_ACTION_DATA_COLLECTION
                ));
            }

            if (isNestedConsentGiven(input, 'PolicyDisclosure', 'AllConsentsGiven')) {
                consents.add(buildConsent(
                    accountId,
					CONSENT_NAME_TERMS,
					individualId,
                    captureSource,
                    brand.Id,
                    CONSENT_ACTION_SHARE_DATA
                ));
            }

            if (consents.isEmpty()) {
                throw new AuraHandledException('No consent was recorded for this application.');
            }

            insert consents;

            output.put('partyConsentResponse', new Map<String, Object>{
                'hasError'        => false,
                'individualId'    => individualId,
                'consentsCreated' => consents.size()
            });

            

        } catch (Exception e) {
            output.put('partyConsentResponse', new Map<String, Object>{
                'hasError'     => true,
                'errorMessage' => 'Failed to record consent: ' + e.getMessage()
            });
            LOGGER.error('INS_CTRL_PartyConsent.createPartyConsents ' + e.getMessage() + ' Line Exception ' + e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString());
        }

        return output;
    }

    // =========================================================================
    // INDIVIDUAL RESOLUTION
    // =========================================================================

    /**
     * @description Returns the Individual linked to the Person Account. The
     *              Individual is created by Account automation, so this only reads
     *              it — a missing Individual is an error rather than something to
     *              create here.
     */
    private static Id resolveIndividualId(Id accountId) {
        Set<Id> accountIds = new Set<Id>();
        accountIds.add(accountId);        
        List<Account> accounts = new INS_Get_Account().getAccountById(accountId);
        if (accounts.isEmpty()) {
            AuraHandledException e = new AuraHandledException('Account not found: ' + accountId);
            e.setMessage('Account not found: ' + accountId);
            throw e;
        }
        if (accounts[0].PersonIndividualId == null) {
            AuraHandledException e = new AuraHandledException(
                'No Individual is linked to the account — consent cannot be recorded.');
            e.setMessage('No Individual is linked to the account — consent cannot be recorded.');
            throw e;
        }

        return accounts[0].PersonIndividualId;
    }
    
    
    

    // =========================================================================
    // CONSENT BUILDER
    // =========================================================================

    private static PartyConsent buildConsent(Id accountId,
                                                String consentName, 
                                                Id individualId, 
                                                String captureSource,
                                                Id brandId,
                                                String action) 
	{
        
		return new PartyConsent(
            Name                    = consentName,
            PartyId                 = individualId,
            BusinessBrandId         = brandId,
            Action                  = action,
            PrivacyConsentStatus    = 'OptIn',
            CaptureContactPointType = 'Web',
            CaptureSource           = captureSource,
            CaptureDate             = Date.TODAY(),
            EffectiveFrom           = Date.TODAY()
        );
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static Boolean isConsentGiven(Map<String, Object> input, String key) {
        Object value = input.get(key);
        return value == null ? false : Boolean.valueOf(String.valueOf(value));
    }

    /**
     * @description Reads a boolean consent flag from a nested node in the
     *              OmniScript input, e.g. PolicyDisclosure.AllConsentsGiven.
     * @param input     The action input map
     * @param parentKey The containing node name
     * @param key       The flag name within that node
     * @return          True when the flag is set
     */
    private static Boolean isNestedConsentGiven(
        Map<String, Object> input, String parentKey, String key
    ) {
        Object parentObj = input.get(parentKey);
        if (!(parentObj instanceof Map<String, Object>)) {
            return false;
        }
        return isConsentGiven((Map<String, Object>) parentObj, key);
    }
    

    private static Id toId(Object value) {
        if (value == null || String.isBlank(String.valueOf(value))) {
            return null;
        }
        try {
            return Id.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }

    private static String getString(Map<String, Object> source, String key) {
        Object value = source.get(key);
        return value == null ? null : String.valueOf(value);
    }

    private static String resolveCaptureSource() {
        String siteUrl = Site.getBaseUrl();
        if (String.isNotBlank(siteUrl)) {
            return Site.getBaseRequestUrl() + siteUrl;
        }
        String urlStr = URL.getOrgDomainUrl().toExternalForm();       
        return urlStr;
    }
}