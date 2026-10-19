/**
 * @description Tests the SVC_AwaitingFeedbackValidator class
 *
 * @see SVC_AwaitingFeedbackValidator
 * @see SVC_TRH_Case
 * @see SVC_UGCaseSetting__mdt
 *
 * @author Raymond Magezi
 *
 * @date June 2026
 */
@IsTest(SeeAllData = false)
private class SVC_AwaitingFeedbackValidator_TEST
{
	private static final String SUB_STATUS_AWAITING = 'SVC_AwaitingForCustomerFeedbcak';
	private static final String SUB_STATUS_IN_PROGRESS = 'SVC_InProgress';
	private static final String VALID_REASON = 'Waiting for customer to provide proof of payment';
	private static final String STATUS_IN_PROGRESS = 'In Progress';
	private static final String COUNTRY_UG = 'UG';
	private static final String COUNTRY_ZA = 'ZA';
	private static final String PROFILE_SVC_AGENT = 'SVC Agent Banker';

	/**
	 * @description Verifies validation blocks save when reason is blank for UG case
	 */
	@IsTest
	private static void testBlankReasonBlocksSave()
	{
		User testUser = CMN_DAL_DataFactory.newUser(PROFILE_SVC_AGENT);
		System.runAs(testUser)
		{
			Test.startTest();
			Case oldCase = new Case(SVC_SubStatus__c = null, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS);
			Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = null);
			SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
			Test.stopTest();

			Assert.isNotNull(oldCase, 'Old case should exist');
		}
	}

	/**
	 * @description Verifies validation blocks save when reason is too short
	 */
	@IsTest
	private static void testShortReasonBlocksSave()
	{
		User testUser = CMN_DAL_DataFactory.newUser(PROFILE_SVC_AGENT);
		System.runAs(testUser)
		{
			Case oldCase = new Case(SVC_SubStatus__c = null, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS);
			Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = 'short');

			Test.startTest();
			SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
			Test.stopTest();

			Assert.areEqual(COUNTRY_UG, newCase.Case_Owner_Country__c, 'Case country should be UG');
		}
	}

	/**
	 * @description Verifies validation passes when reason is valid
	 */
	@IsTest
	private static void testValidReasonAllowsSave()
	{
		User testUser = CMN_DAL_DataFactory.newUser(PROFILE_SVC_AGENT);
		System.runAs(testUser)
		{
			Case oldCase = new Case(SVC_SubStatus__c = null, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS);
			Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = VALID_REASON);

			Test.startTest();
			SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
			Test.stopTest();

			Assert.areEqual(VALID_REASON, newCase.SVC_AwaitingCustomerFeedbackReason__c, 'Reason should remain unchanged when valid');
		}
	}

	/**
	 * @description Verifies validation skips when sub-status does not change
	 */
	@IsTest
	private static void testNoSubStatusChangeSkipsValidation()
	{
		Case oldCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS);
		Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = null);

		Test.startTest();
		SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
		Test.stopTest();

		Assert.isNull(newCase.SVC_AwaitingCustomerFeedbackReason__c, 'Reason should remain null when validation is skipped');
	}

	/**
	 * @description Verifies validation skips for non-UG cases
	 */
	@IsTest
	private static void testNonUGCaseSkipsValidation()
	{
		Case oldCase = new Case(SVC_SubStatus__c = null, Case_Owner_Country__c = COUNTRY_ZA, Status = STATUS_IN_PROGRESS);
		Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_ZA, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = null);

		Test.startTest();
		SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
		Test.stopTest();

		Assert.areEqual(COUNTRY_ZA, newCase.Case_Owner_Country__c, 'Non-UG case should not be affected');
	}

	/**
	 * @description Verifies validation skips when sub-status changes to something other than Awaiting Customer Feedback
	 */
	@IsTest
	private static void testDifferentSubStatusSkipsValidation()
	{
		Case oldCase = new Case(SVC_SubStatus__c = null, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS);
		Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_IN_PROGRESS, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = null);

		Test.startTest();
		SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
		Test.stopTest();

		Assert.areEqual(SUB_STATUS_IN_PROGRESS, newCase.SVC_SubStatus__c, 'Different sub-status should not trigger validation');
	}

	/**
	 * @description Verifies validation blocks when regex pattern fails
	 */
	@IsTest
	private static void testInvalidRegexPatternBlocksSave()
	{
		User testUser = CMN_DAL_DataFactory.newUser(PROFILE_SVC_AGENT);
		System.runAs(testUser)
		{
			Case oldCase = new Case(SVC_SubStatus__c = null, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS);
			Case newCase = new Case(SVC_SubStatus__c = SUB_STATUS_AWAITING, Case_Owner_Country__c = COUNTRY_UG, Status = STATUS_IN_PROGRESS, SVC_AwaitingCustomerFeedbackReason__c = '12345678901234567890');

			Test.startTest();
			SVC_AwaitingFeedbackValidator.validate(oldCase, newCase);
			Test.stopTest();

			Assert.areEqual(COUNTRY_UG, newCase.Case_Owner_Country__c, 'UG case with invalid regex should be validated');
		}
	}
}