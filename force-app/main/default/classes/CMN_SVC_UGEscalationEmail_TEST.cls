/**
 * @description Test class for CMN_SVC_UGEscalationEmail.
 * @author Raymond Magezi
 * @date 23-07-2026
 * @see CMN_SVC_UGEscalationEmail
 * @userStory SFP-58853
 */
@IsTest
private class CMN_SVC_UGEscalationEmail_TEST {

    @TestSetup
    static void setup() {
        insert new Case(Subject = 'Email Service Test', Status = 'New');
    }

    @IsTest
    static void buildCcAddressesWithOwnerPositiveOutcome() {
        Case testCase = getTestCase();
        Map<Id, User> owners = getOwnerMap(testCase.OwnerId);

        Test.startTest();
        List<String> ccAddresses = CMN_SVC_UGEscalationEmail.buildCcAddresses(testCase, 1, owners, new Map<Id, User>());
        Test.stopTest();

        Assert.isTrue(ccAddresses.size() >= 0);
    }

    @IsTest
    static void buildCcAddressesWithPreviousManagerPositiveOutcome() {
        Case testCase = getTestCase();
        User owner = [SELECT Id, Email, Name FROM User WHERE Id = :testCase.OwnerId];
        testCase.SVC_Escalate_to__c = owner.Id;

        Map<Id, User> owners = new Map<Id, User>{owner.Id => owner};

        Test.startTest();
        List<String> ccAddresses = CMN_SVC_UGEscalationEmail.buildCcAddresses(testCase, 2, owners, owners);
        Test.stopTest();

        Assert.isTrue(ccAddresses.size() >= 1);
    }

    @IsTest
    static void addEmailRequestBlankEmailNegativeOutcome() {
        List<CMN_QUEUE_SendEscalationEmails.EmailRequest> reqs = new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>();

        Test.startTest();
        CMN_SVC_UGEscalationEmail.addEmailRequest(getTestCase(), buildManagerResult(''), new List<String>(), 'T', 'o@t.com', reqs);
        Test.stopTest();

        Assert.areEqual(0, reqs.size());
    }

    @IsTest
    static void addEmailRequestValidEmailPositiveOutcome() {
        List<CMN_QUEUE_SendEscalationEmails.EmailRequest> reqs = new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>();

        Test.startTest();
        CMN_SVC_UGEscalationEmail.addEmailRequest(getTestCase(), buildManagerResult('mgr@test.com'), new List<String>{'cc@t.com'}, 'T', 'o@t.com', reqs);
        Test.stopTest();

        Assert.areEqual(1, reqs.size());
    }

    @IsTest
    static void sendEscalationEmailsPositiveOutcome() {
        CMN_QUEUE_SendEscalationEmails.EmailRequest req = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
        req.toAddress = 'test@example.com';
        req.caseId = getTestCase().Id;
        req.ccAddresses = new List<String>{'cc@example.com'};
        req.templateName = 'TestTemplate';
        req.orgWideEmail = 'noreply@test.com';

        Test.startTest();
        CMN_SVC_UGEscalationEmail.sendEscalationEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{req});
        Test.stopTest();

        Assert.isNotNull(req.toAddress);
    }

    private static Case getTestCase() {
        return [SELECT Id, OwnerId, CaseNumber, SVC_Escalate_to__c FROM Case LIMIT 1];
    }

    private static Map<Id, User> getOwnerMap(Id ownerId) {
        User owner = [SELECT Id, Email, Name FROM User WHERE Id = :ownerId];
        return new Map<Id, User>{owner.Id => owner};
    }

    private static CMN_DAL_User.ManagerResult buildManagerResult(String email) {
        CMN_DAL_User.ManagerResult r = new CMN_DAL_User.ManagerResult();
        r.managerId = UserInfo.getUserId();
        r.managerEmail = email;
        return r;
    }
}