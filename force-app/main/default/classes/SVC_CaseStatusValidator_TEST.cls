/**
 * @description Tests the SVC_CaseStatusValidator class.
 *              Covers preventManualCaseClose, preventClosedCaseEdit, bypassValidation,
 *              isAutomatedContext, isRestricted (via Custom Permission assignment).
 *
 * @see SVC_CaseStatusValidator
 *
 * @author Raymond Magezi
 * @date February 2026
 *
 * @userStory SFP-58840
 */
@IsTest(SeeAllData = false)
private class SVC_CaseStatusValidator_TEST
{
	private static final String CLOSED = 'Closed';
	private static final String IN_PROGRESS = 'In Progress';
	private static final String COUNTRY_UG = 'UG';
	private static final String COUNTRY_ZA = 'ZA';
	private static final String ASSERT_BLOCKED = 'Case update should be blocked';
	private static final String ASSERT_ALLOWED = 'Case update should succeed';
	private static final String PERM_SET_NAME = 'SVC_PreventManualCaseClosure';

	/**
	 * @description DTO to encapsulate test scenario parameters
	 */
	private class TestScenario
	{
		String oldStatus;
		String newStatus;
		String country;
		Boolean bypass;
		Boolean expectError;

		TestScenario(String oldStatus, String newStatus, String country, Boolean bypass, Boolean expectError)
		{
			this.oldStatus = oldStatus;
			this.newStatus = newStatus;
			this.country = country;
			this.bypass = bypass;
			this.expectError = expectError;
		}
	}

	/**
	 * @description Creates a pair of old/new Case records for unit testing
	 *
	 * @param scenario The test scenario DTO
	 * @return List containing [oldCase, newCase]
	 */
	private static List<Case> buildCasePair(TestScenario scenario)
	{
		Case oldCase = new Case(Status = scenario.oldStatus, Case_Owner_Country__c = scenario.country);
		Case newCase = new Case(Status = scenario.newStatus, Case_Owner_Country__c = scenario.country);
		SVC_TRH_Case.bypassClosedValidation = scenario.bypass;
		return new List<Case>{ oldCase, newCase };
	}

	/**
	 * @description Creates and inserts a restricted user with the custom permission assigned.
	 *              Uses CMN_DAL_DataFactory (DAL) and SEL_PermissionSet (fflib selector).
	 *
	 * @param profileName The profile to assign to the user
	 * @return User with permission set assigned
	 */
	private static User createRestrictedUser(String profileName)
	{
		User testUser = CMN_DAL_DataFactory.newUser(profileName);
		insert testUser;

		List<PermissionSet> permSets = new SEL_PermissionSet().selectByPermissionSetNames(
			new List<String>{ PERM_SET_NAME }
		);
		insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = permSets[0].Id);

		return testUser;
	}

	/**
	 * @description Restricted user (with custom permission) is prevented from manually closing
	 *              and editing closed UG cases.
	 *              Covers: preventManualCaseClose (addError path), preventClosedCaseEdit (addError path),
	 *              isRestricted (returns true)
	 */
	@IsTest
	private static void testRestrictedUserCannotCloseOrEditUGCase()
	{
		User restrictedUser;
		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			restrictedUser = createRestrictedUser(CMN_DAL_Profile.PROFILE_BANKER_USER);
		}

		System.runAs(restrictedUser)
		{
			TestScenario closeScenario = new TestScenario(IN_PROGRESS, CLOSED, COUNTRY_UG, false, true);
			List<Case> closePair = buildCasePair(closeScenario);

			TestScenario editScenario = new TestScenario(CLOSED, CLOSED, COUNTRY_UG, false, true);
			List<Case> editPair = buildCasePair(editScenario);

			Test.startTest();
			SVC_CaseStatusValidator.preventManualCaseClose(closePair[0], closePair[1]);
			SVC_CaseStatusValidator.preventClosedCaseEdit(editPair[0], editPair[1]);
			Test.stopTest();

			Assert.isTrue(closePair[1].hasErrors(), ASSERT_BLOCKED);
			Assert.isTrue(editPair[1].hasErrors(), ASSERT_BLOCKED);
		}
	}

	/**
	 * @description Non-restricted user (without custom permission) is allowed to close and edit
	 *              closed UG cases.
	 *              Covers: preventManualCaseClose (non-restricted path), preventClosedCaseEdit (non-restricted path),
	 *              isRestricted (returns false)
	 */
	@IsTest
	private static void testNonRestrictedUserAllowedToCloseAndEditUGCase()
	{
		User adminUser = CMN_DAL_DataFactory.newUser(CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN);
		System.runAs(adminUser)
		{
			TestScenario closeScenario = new TestScenario(IN_PROGRESS, CLOSED, COUNTRY_UG, false, false);
			List<Case> closePair = buildCasePair(closeScenario);

			TestScenario editScenario = new TestScenario(CLOSED, CLOSED, COUNTRY_UG, false, false);
			List<Case> editPair = buildCasePair(editScenario);

			Test.startTest();
			SVC_CaseStatusValidator.preventManualCaseClose(closePair[0], closePair[1]);
			SVC_CaseStatusValidator.preventClosedCaseEdit(editPair[0], editPair[1]);
			Test.stopTest();

			Assert.isFalse(closePair[1].hasErrors(), ASSERT_ALLOWED);
			Assert.isFalse(editPair[1].hasErrors(), ASSERT_ALLOWED);
		}
	}

	/**
	 * @description Bypass flag allows restricted user to close and edit closed UG cases.
	 *              Also tests bypassValidation invocable sets the flag correctly.
	 *              Covers: preventManualCaseClose (bypass path), preventClosedCaseEdit (bypass path),
	 *              bypassValidation()
	 */
	@IsTest
	private static void testBypassFlagAllowsRestrictedUserActions()
	{
		User restrictedUser;
		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			restrictedUser = createRestrictedUser(CMN_DAL_Profile.PROFILE_BANKER_USER);
		}

		System.runAs(restrictedUser)
		{
			Test.startTest();
			SVC_CaseStatusValidator.bypassValidation();
			Assert.isTrue(SVC_TRH_Case.bypassClosedValidation, 'Invocable should set bypass to true');

			TestScenario closeScenario = new TestScenario(IN_PROGRESS, CLOSED, COUNTRY_UG, true, false);
			List<Case> closePair = buildCasePair(closeScenario);

			TestScenario editScenario = new TestScenario(CLOSED, CLOSED, COUNTRY_UG, true, false);
			List<Case> editPair = buildCasePair(editScenario);

			SVC_CaseStatusValidator.preventManualCaseClose(closePair[0], closePair[1]);
			SVC_CaseStatusValidator.preventClosedCaseEdit(editPair[0], editPair[1]);
			Test.stopTest();

			Assert.isFalse(closePair[1].hasErrors(), ASSERT_ALLOWED);
			Assert.isFalse(editPair[1].hasErrors(), ASSERT_ALLOWED);
		}
	}

	/**
	 * @description Validation skips when: non-UG country, status unchanged, non-Closed target status,
	 *              old status not Closed (for edit prevention).
	 *              Covers: preventManualCaseClose (country mismatch, status unchanged, non-Closed status),
	 *              preventClosedCaseEdit (old status not Closed, country mismatch)
	 */
	@IsTest
	private static void testValidationSkipsForNonApplicableScenarios()
	{
		User restrictedUser;
		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			restrictedUser = createRestrictedUser(CMN_DAL_Profile.PROFILE_BANKER_USER);
		}

		System.runAs(restrictedUser)
		{
			List<TestScenario> scenarios = new List<TestScenario>{
				new TestScenario(IN_PROGRESS, CLOSED, COUNTRY_ZA, false, false),
				new TestScenario(IN_PROGRESS, IN_PROGRESS, COUNTRY_UG, false, false),
				new TestScenario('New', IN_PROGRESS, COUNTRY_UG, false, false)
			};

			Test.startTest();
			for(TestScenario scenario : scenarios)
			{
				List<Case> pair = buildCasePair(scenario);
				SVC_CaseStatusValidator.preventManualCaseClose(pair[0], pair[1]);
				Assert.isFalse(pair[1].hasErrors(), ASSERT_ALLOWED);
			}

			TestScenario notClosedOld = new TestScenario(IN_PROGRESS, IN_PROGRESS, COUNTRY_UG, false, false);
			List<Case> notClosedPair = buildCasePair(notClosedOld);
			SVC_CaseStatusValidator.preventClosedCaseEdit(notClosedPair[0], notClosedPair[1]);
			Assert.isFalse(notClosedPair[1].hasErrors(), ASSERT_ALLOWED);

			TestScenario nonUGClosed = new TestScenario(CLOSED, CLOSED, COUNTRY_ZA, false, false);
			List<Case> nonUGPair = buildCasePair(nonUGClosed);
			SVC_CaseStatusValidator.preventClosedCaseEdit(nonUGPair[0], nonUGPair[1]);
			Assert.isFalse(nonUGPair[1].hasErrors(), ASSERT_ALLOWED);
			Test.stopTest();
		}
	}

	/**
	 * @description Full DML integration test: restricted user attempts to close UG case via trigger.
	 *              Covers: Full trigger path through SVC_TRG_Case -> SVC_TRH_Case -> SVC_CaseStatusValidator
	 */
	@IsTest
	private static void testDMLCloseBlockedAndBypassAllowed()
	{
		User restrictedUser;
		System.runAs(new User(Id = UserInfo.getUserId()))
		{
			restrictedUser = createRestrictedUser(CMN_DAL_Profile.PROFILE_BANKER_USER);
		}

		Account personAcc = CMN_DAL_DataFactory.newPersonAccount();
		insert personAcc;
		Id contactId = [SELECT PersonContactId FROM Account WHERE Id = :personAcc.Id].PersonContactId;

		Case testCase = CMN_DAL_DataFactory.newCase(contactId);
		testCase.Case_Owner_Country__c = COUNTRY_UG;
		testCase.Origin = 'Phone';
		testCase.OwnerId = restrictedUser.Id;
		insert testCase;

		System.runAs(restrictedUser)
		{
			Test.startTest();

			testCase.Status = CLOSED;
			SVC_TRH_Case.bypassClosedValidation = false;
			Database.SaveResult sr = Database.update(testCase, false);
			Assert.isFalse(sr.isSuccess(), ASSERT_BLOCKED);

			SVC_CaseStatusValidator.bypassValidation();
			testCase = [SELECT Id, Status, Case_Owner_Country__c FROM Case WHERE Id = :testCase.Id];
			testCase.Status = CLOSED;
			Database.SaveResult srBypass = Database.update(testCase, false);
			Assert.isTrue(srBypass.isSuccess(), ASSERT_ALLOWED);

			Test.stopTest();
		}
	}
}