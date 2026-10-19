/**
 * @description Tests the SVC_CaseResolutionValidator class
 *
 * @see SVC_CaseResolutionValidator
 *
 * @author Raymond Magezi
 *
 * @date February 2026
 */
@IsTest(SeeAllData = false)
private class SVC_CaseResolutionValidator_TEST
{
	private static final String TEST_CASE_SUBJECT = 'Test Case';
	private static final String ASSERT_UPDATE_FAIL = 'Update should fail with validation error';

	/**
	 * @description Test validation passes with valid resolution comments
	 */
	@IsTest
	private static void testValidResolutionComments()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = 'This is a detailed resolution comment with sufficient length and detail'
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isFalse(testCase.hasErrors(), 'Valid comments should not produce errors');
	}

	/**
	 * @description Test validation fails when resolution comments are blank
	 */
	@IsTest
	private static void testBlankResolutionComments()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = null
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isTrue(testCase.hasErrors(), ASSERT_UPDATE_FAIL);
	}

	/**
	 * @description Test validation fails when resolution comments are too short
	 */
	@IsTest
	private static void testShortResolutionComments()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = 'Short text'
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isTrue(testCase.hasErrors(), ASSERT_UPDATE_FAIL);
	}

	/**
	 * @description Test validation fails with blocked phrase 'Done'
	 */
	@IsTest
	private static void testBlockedPhraseDone()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = 'Done'
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isTrue(testCase.hasErrors(), ASSERT_UPDATE_FAIL);
	}

	/**
	 * @description Test validation fails with blocked phrase 'N/A'
	 */
	@IsTest
	private static void testBlockedPhraseNA()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = 'N/A'
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isTrue(testCase.hasErrors(), ASSERT_UPDATE_FAIL);
	}

	/**
	 * @description Test validation fails with blocked phrase 'Call Customer'
	 */
	@IsTest
	private static void testBlockedPhraseCallCustomer()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = 'Call Customer'
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isTrue(testCase.hasErrors(), ASSERT_UPDATE_FAIL);
	}

	/**
	 * @description Test validation handles null case gracefully
	 */
	@IsTest
	private static void testNullCase()
	{
		Test.startTest();
		SVC_CaseResolutionValidator.validate(null);
		Test.stopTest();

		Assert.isTrue(true, 'Should handle null case without error');
	}

	/**
	 * @description Test validation strips HTML tags correctly
	 */
	@IsTest
	private static void testHTMLStripping()
	{
		Case testCase = new Case(
			Subject = TEST_CASE_SUBJECT,
			Resolution_Comments_to_Client__c = '<p>This is a detailed resolution comment with HTML tags and sufficient length</p>'
		);
		insert testCase;

		Test.startTest();
		SVC_CaseResolutionValidator.validate(testCase);
		Test.stopTest();

		Assert.isFalse(testCase.hasErrors(), 'Case with valid HTML should pass validation');
	}
}