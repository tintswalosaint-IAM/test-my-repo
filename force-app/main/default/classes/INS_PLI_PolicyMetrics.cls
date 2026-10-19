/**
 * @description    : Helper class for retrieving policy metrics data for Platinum Life Insurance
 * @author         : Brendon Mahwete
 * @date           : 07-11-2025
 */
public without sharing class INS_PLI_PolicyMetrics {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PLI_PolicyMetrics');

    private static final String POLICY_STATUS_DRAFT      = 'Draft';
    private static final String STATUS_CANCELLED         = 'Cancelled';

    private static final String ERROR_INSUFFICIENT_OBJECT_ACCESS = 'Insufficient permissions to access Insurance Policy records.';
    private static final String ERROR_INSUFFICIENT_FIELD_ACCESS  = 'Insufficient permissions to access required fields.';

    // Maps each countable status to its display label — add new statuses here with zero branching impact
    private static final Map<String, String> STATUS_COUNTER_KEYS = new Map<String, String>{
        POLICY_STATUS_DRAFT => 'sold',
        STATUS_CANCELLED    => 'cancelled'
    };

    /**
     * @description   Get policy metrics data for a specific policy owner
     * @param userID  Salesforce User Id of the policy owner
     * @return        PolicyMetricsData wrapper
     */
    @AuraEnabled(cacheable=true)
    public static PolicyMetricsData getPolicyMetricsData(String userID) {
        try {
            validateFieldLevelSecurity();
            return calculateMetrics(new SEL_InsurancePolicy().selectPlatinumLifePlociesByProducerId(userID));
        } catch (Exception e) {
            LOGGER.error('exception', new String[]{'INS_PLI_PolicyMetrics.getPolicyMetricsData', e.getMessage()}, e);
            throw new AuraHandledException('Error fetching policy metrics data: ' + e.getMessage());
        }
    }

    private static void validateFieldLevelSecurity() {
        Boolean objectOk = Schema.sObjectType.InsurancePolicy.isAccessible();
        Boolean fieldsOk = Schema.sObjectType.InsurancePolicy.fields.PremiumAmount.isAccessible()
                        && Schema.sObjectType.InsurancePolicy.fields.Status.isAccessible()
                        && Schema.sObjectType.InsurancePolicy.fields.PolicyName.isAccessible();

        if (!objectOk) { throw new AuraHandledException(ERROR_INSUFFICIENT_OBJECT_ACCESS); }
        if (!fieldsOk) { throw new AuraHandledException(ERROR_INSUFFICIENT_FIELD_ACCESS);  }
    }

    private static PolicyMetricsData calculateMetrics(List<InsurancePolicy> policies) {
        PolicyMetricsData data = new PolicyMetricsData();

        for (InsurancePolicy policy : policies) {
            data.premiumOfPolicies += (policy.PremiumAmount != null ? policy.PremiumAmount : 0);
            data.platinumLifeCount++;

            String key = STATUS_COUNTER_KEYS.get(policy.Status);   // null-safe map lookup — no branch needed
            if (key == 'sold')      { data.policiesSold++;      }
            if (key == 'cancelled') { data.policiesCanceled++;  }
        }

        return data;
    }

    /**
     * @description Wrapper class used to return policy metrics data in a single response
     */
    public class PolicyMetricsData {
        @AuraEnabled public Decimal premiumOfPolicies { get; set; }
        @AuraEnabled public Integer policiesSold      { get; set; }
        @AuraEnabled public Integer policiesCanceled  { get; set; }
        @AuraEnabled public Integer platinumLifeCount { get; set; }

        public PolicyMetricsData() {
            this.premiumOfPolicies = 0;
            this.policiesSold      = 0;
            this.policiesCanceled  = 0;
            this.platinumLifeCount = 0;
        }
    }
}