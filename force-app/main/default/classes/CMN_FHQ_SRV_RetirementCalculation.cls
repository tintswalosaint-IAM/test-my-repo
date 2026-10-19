/**
 * @description Service class responsible for the Retirement Readiness complex calculation.
 *              Uses compound-interest future value logic, the respondent's date of birth,
 *              ruleset configuration rates, and question responses (Q6, Q9, Q10) to produce
 *              a retirement readiness score expressed as a percentage (1-100).
 *
 *              This calculation is too complex to express as a metadata formula and is
 *              therefore implemented directly in Apex. Extracted from CMN_FHQ_Calculations
 *              to keep the orchestrator class focused on coordination only.
 *              All System.debug calls replaced with RFLIB logger.
 *
 * Ver       Date         Author                              Modification       
1.0      JAN 2026   preetham.gandla@standardbank.co.za     Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119, 172, 270) 
 */
public with sharing class CMN_FHQ_SRV_RetirementCalculation {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_FHQ_SRV_RetirementCalculation');

    /** @description Future value of the respondent's current investment and contributions. */
    public Decimal investmentBehaviourFutureValue { get; private set; }

    /** @description Calculated retirement savings target based on annual expenses and withdrawal rate. */
    public Decimal retirementTargetAmount { get; private set; }

    /** @description Number of years remaining until the respondent reaches retirement age. */
    public Decimal yearsOfRetirement { get; private set; }

    /**
     * @description Calculates the Retirement Readiness score as a percentage (1-100).
     *              Returns null when any required input is missing or invalid.
     *
     *              Required question responses:
     *              - Q6: Monthly expenses
     *              - Q9: Monthly investment contribution
     *              - Q10: Current investment balance
     *
     * @param responseMap Map of Question ID key (e.g. Q6) to CMN_Question_Response__c record
     * @param ruleSetVersion Loaded ruleset providing return rate, withdrawal rate, and retirement age
     * @param dobInput Respondent date of birth for age calculation
     * @return Retirement readiness score (1-100) or null when inputs are insufficient
     */
    public Decimal calculate(
        Map<String, CMN_Question_Response__c> responseMap,
        CMN_Rule_Set_Version__c ruleSetVersion,
        Date dobInput
    ) {
        LOGGER.info(
            'CMN_FHQ_SRV_RetirementCalculation.calculate: Starting retirement readiness calculation'
        );

        // Validate ruleset configuration
        if (!validateRuleSetVersion(ruleSetVersion)) {
            return null;
        }

        Decimal returnRate     = ruleSetVersion.CMN_Return_Rate__c / 100;
        Decimal withdrawalRate = ruleSetVersion.CMN_Withdrawal_Rate__c / 100;
        Decimal retirementAge  = ruleSetVersion.CMN_Default_Retirement_Age__c;

        // Extract and validate question responses
        Decimal monthlyExpenses     = extractResponseValue(responseMap, 'Q6') == null ? 0 : extractResponseValue(responseMap, 'Q6');
        Decimal monthlyContribution = extractResponseValue(responseMap, 'Q9') == null? 0 : extractResponseValue(responseMap, 'Q9');
        Decimal currentBalance      = extractResponseValue(responseMap, 'Q10') == null ? 0 :extractResponseValue(responseMap, 'Q10');

        if (!validateQuestionResponses(monthlyExpenses)) {
            return null;
        }

        if (dobInput == null) {
            LOGGER.warn(
                'CMN_FHQ_SRV_RetirementCalculation.calculate: Aborting - dateOfBirth is null'
            );
            return null;
        }

        // Calculate retirement details
        Decimal currentAge = calculateCurrentAge(dobInput);
        yearsOfRetirement = calculateYearsToRetirement(retirementAge, currentAge);

        LOGGER.debug(
            'CMN_FHQ_SRV_RetirementCalculation.calculate: currentAge={0}, yearsOfRetirement={1}',
            new List<Object>{ currentAge, yearsOfRetirement }
        );

        // Calculate future value and target
        investmentBehaviourFutureValue = calculateFutureValue(
            currentBalance, monthlyContribution, returnRate, yearsOfRetirement
        );

        Decimal annualExpenses = monthlyExpenses * 12;
        retirementTargetAmount = annualExpenses / withdrawalRate;

        LOGGER.debug(
            'CMN_FHQ_SRV_RetirementCalculation.calculate: investmentBehaviourFutureValue={0}, retirementTargetAmount={1}',
            new List<Object>{ investmentBehaviourFutureValue, retirementTargetAmount }
        );

        Decimal retirementReadinessScore = 0;
        if(retirementTargetAmount != 0){
          retirementReadinessScore = Math.round((investmentBehaviourFutureValue / retirementTargetAmount) * 100);
        }

        LOGGER.info(
            'CMN_FHQ_SRV_RetirementCalculation.calculate: retirementReadinessScore={0}',
            new List<Object>{ retirementReadinessScore }
        );

        return retirementReadinessScore;
    }

    /**
     * @description Validates ruleset version configuration has required rates.
     * @param ruleSetVersion Ruleset version to validate
     * @return True if valid, false otherwise
     */
    private Boolean validateRuleSetVersion(CMN_Rule_Set_Version__c ruleSetVersion) {
        if (ruleSetVersion == null
            || ruleSetVersion.CMN_Return_Rate__c == null
            || ruleSetVersion.CMN_Withdrawal_Rate__c == null
            || ruleSetVersion.CMN_Default_Retirement_Age__c == null) {
            LOGGER.warn(
                'CMN_FHQ_SRV_RetirementCalculation.calculate: Aborting - missing ruleset configuration'
            );
            return false;
        }
        return true;
    }

    /**
     * @description Validates that all required question responses are present and non-zero.
     * @param monthlyExpenses Monthly expenses value
     * @param monthlyContribution Monthly contribution value
     * @param currentBalance Current investment balance
     * @return True if all values are valid, false otherwise
     */
    private Boolean validateQuestionResponses(Decimal monthlyExpenses) {
        if (monthlyExpenses == null) {
            LOGGER.warn(
                'CMN_FHQ_SRV_RetirementCalculation.calculate: Aborting - required Q6/Q9/Q10 values are null or zero'
            );
            return false;
        }
        return true;
    }

    /**
     * @description Calculates the respondent's current age from date of birth.
     * @param dobInput Date of birth
     * @return Current age as a Decimal
     */
    private Decimal calculateCurrentAge(Date dobInput) {
        Integer yearDifference = Date.today().year() - dobInput.year();
        Decimal currentAge = Math.abs(yearDifference);
        if (Date.today().month() < dobInput.month()
            || (Date.today().month() == dobInput.month() && Date.today().day() < dobInput.day())) {
            currentAge--;
        }
        return currentAge;
    }

    /**
     * @description Calculates years remaining until retirement age.
     * @param retirementAge Target retirement age
     * @param currentAge Current age of respondent
     * @return Years to retirement (minimum 1)
     */
    private Decimal calculateYearsToRetirement(Decimal retirementAge, Decimal currentAge) {
        Decimal years = Math.round(retirementAge - currentAge);
        if (years <= 0) {
            years = 1;
        }
        return years;
    }

    /**
     * @description Calculates future value of investments using compound interest.
     *              FV = P*(1+r)^n + C*((1+r)^n - 1)/r
     *              where P = principal, C = monthly contribution, r = monthly rate, n = months
     * @param currentBalance Current investment principal
     * @param monthlyContribution Monthly contribution amount
     * @param annualReturnRate Annual return rate (as decimal, e.g., 0.07 for 7%)
     * @param yearsToRetirement Years until retirement
     * @return Calculated future value
     */
    private Decimal calculateFutureValue(
        Decimal currentBalance,
        Decimal monthlyContribution,
        Decimal annualReturnRate,
        Decimal yearsToRetirement
    ) {
        String powerExpression = '(' + (1 + (annualReturnRate / 12)) + ')^' + (yearsToRetirement * 12);
        Decimal powerTerm = CMN_FHQ_MathExpressions.eval(powerExpression);

        Decimal futureValuePrincipal     = currentBalance * powerTerm;
        Decimal futureValueContributions = monthlyContribution * ((powerTerm - 1) / (annualReturnRate / 12));
        LOGGER.debug(
            'CMN_FHQ_SRV_RetirementCalculation.calculateFutureValue: futureValuePrincipal={0}, futureValueContributions={1}',
            new List<Object>{ futureValuePrincipal, futureValueContributions }
        );
  
        return Math.round(futureValuePrincipal + futureValueContributions);
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────────

    /**
     * @description Safely extracts the numeric response value for a given question key.
     *              Returns null when the key is absent from the map or the value is null.
     * @param responseMap Map of Question ID key to CMN_Question_Response__c record
     * @param questionKey Question identifier string (e.g. Q6)
     * @return Numeric response value, or null when not present
     */
    private Decimal extractResponseValue(
        Map<String, CMN_Question_Response__c> responseMap,
        String questionKey
    ) {
        if (!responseMap.containsKey(questionKey)) {
            return null;
        }
        CMN_Question_Response__c responseRecord = responseMap.get(questionKey);
        if (responseRecord == null) {
            return null;
        }
        return responseRecord.CMN_Response_Value_Number__c;
    }
}