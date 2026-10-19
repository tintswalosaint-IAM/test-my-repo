/**
 * @description       : Tests the Data Access Layer class SVC_DAL_Case
 * @author            : Aliaksei Koval
 * @last modified on  : 04-03-2026
 * @last modified by  : Aliaksei Koval
**/

@isTest
private class SVC_DAL_Case_Test {

    /**
	 * @description Creates test data (Contact, Account, Case)
	 * @see CMN_DAL_DataFactory
	 * @see SVC_DAL_DataFactory
	 */
	@TestSetup
	public static void setupScenario()
	{
        Contact c = SVC_DAL_DataFactory.newContact();
        insert c;
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Case testCase = SVC_DAL_DataFactory.newCase(c.Id);
        testCase.AccountId = acc.Id;
        testCase.Subject = 'Test Case';
        testCase.Status = 'In Progress';
        insert testCase;
	}

    /**
     * @description Test findById method functionality
     */
    @isTest
    private static void findByIdPositiveOutcome() {
        Case tstCase = [SELECT Id FROM Case WHERE Subject = 'Test Case'];
        Test.startTest();
        Case foundCase = SVC_DAL_Case.findById(tstCase.Id);
        Test.stopTest();
        Assert.areEqual(tstCase.Id, foundCase.Id, 'Case not found');
    }

    /**
     * @description Test getAll method functionality
     */
    @isTest
    private static void getAllPositiveOutcome() {
        Test.startTest();
        List<Case> foundCases = SVC_DAL_Case.getAll();
        Test.stopTest();
        Assert.isFalse(foundCases.isEmpty(), 'No cases found');
    }

    /**
     * @description Test findByAccountId method functionality
     */
    @isTest
    private static void findByAccountIdPositiveOutcome() {
        Case cs = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test Case'];
        Test.startTest();
        List<Case> foundCases = SVC_DAL_Case.findByAccountId(cs.AccountId);
        Test.stopTest();
        Assert.isFalse(foundCases.isEmpty(), 'No cases found');
    }

    /**
     * @description Test findLatestByAccountId method functionality
     */
    @isTest
    private static void findLatestByAccountIdPositiveOutcome() {
        Case cs = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test Case'];
        Test.startTest();
        Case foundCase = SVC_DAL_Case.findLatestByAccountId(cs.AccountId);
        Test.stopTest();
        Assert.areEqual(cs.Id, foundCase.Id, 'Case not found');
    }

}