/**
 * Class Name       : SEL_ApplicationParticipant_Test
 * Description      : Test class for SEL_ApplicationParticipant. Covers getSObjectType,
 *                     getSObjectFieldList, and every selector method (findParticipantByNIN,
 *                     selectApplicationParticipantById, selectApplicationParticpantById,
 *                     selectApplicationParticipant, selectApplicationParticpantByApplicationId,
 *                     selectApplicationParticpantByApplicationName,
 *                     selectApplicationParticpantByApplicationIdSign,
 *                     selectApplicationParticpantByAppAndPhone,
 *                     selectApplicationParticpantByKeyContact,
 *                     selectApplicationParticpantByOmangId).
 * Author           : Anuja Alli
 * Created Date     : Jul 16, 2026
 * ==============================================
 * Last Modified By : Anuja Alli
 * Last Modified On : Jul 16, 2026
 * Modified Description : Setting the userstory number
 * User story       : SFP-53980
 */
@IsTest
private class SEL_ApplicationParticipant_Test {

    private static Application__c createApplication(String status, String schemaCode) {
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'N/A'
        );
        insert lead;

        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = schemaCode,
            AOB_Memo_Code__c = schemaCode,
            IsActive = true
        );
        insert product;

        Application__c application = new Application__c(
            Status__c = status,
            AOB_UG_BCB_Stage__c = 'Pre-Application',
            AOB_Lead__c = lead.Id,
            AOB_Product__c = product.Id,
            CurrencyIsoCode = 'UGX'
        );
        insert application;

        // AOB_Schema_Code__c is a read-only/formula field on Application__c, so it can't be
        // set directly. Read back whatever value the org derives from the related Product2
        // so callers can use the actual computed value rather than assuming its source field.
        return [
            SELECT Id, Status__c, AOB_Schema_Code__c
            FROM Application__c
            WHERE Id = :application.Id
        ];
    }

    private static Application_Participant__c createParticipant(
        Id applicationId,
        String nationalIdNumber,
        Boolean signatory,
        String phone
    ) {
        Application_Participant__c participant = new Application_Participant__c(
            Application__c = applicationId,
            AOB_IDNumber__c = nationalIdNumber,
            AOB_Signatory__c = signatory,
            CNGCU_Phone__c = phone,
            CNGCU_First_Name__c = 'Test',
            CNGCU_Last_Name__c = 'Participant',
            CNGCU_Email__c = 'test.participant@example.com',
            CurrencyIsoCode = 'UGX'
        );
        insert participant;

        return participant;
    }

    @IsTest
    static void testGetSObjectType() {
        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        Assert.areEqual(Application_Participant__c.sObjectType, result);
    }

    @IsTest
    static void testGetSObjectFieldList() {
        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Test.stopTest();

        Assert.isNotNull(fieldList);
        Assert.isTrue(fieldList.contains(Application_Participant__c.Id));
        Assert.isTrue(fieldList.contains(Application_Participant__c.AOB_IDNumber__c));
        Assert.isTrue(fieldList.contains(Application_Participant__c.AOB_Signatory__c));
    }

    @IsTest
    static void testFindParticipantByNIN() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-FIND-001', false, '256700000001');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results = selector.findParticipantByNIN(
            'NIN-FIND-001',
            'In Progress',
            application.AOB_Schema_Code__c
        );
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticipantById() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYID-001', false, '256700000002');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results =
            selector.selectApplicationParticipantById(new List<Id>{ participant.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByIdString() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYIDSTR-001', false, '256700000003');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results =
            selector.selectApplicationParticpantById(participant.Id);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticipantSingle() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-SINGLE-001', false, '256700000004');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        Application_Participant__c result = selector.selectApplicationParticipant(participant.Id);
        Test.stopTest();

        Assert.areEqual(participant.Id, result.Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByApplicationId() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYAPPID-001', false, '256700000005');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        Application_Participant__c result =
            selector.selectApplicationParticpantByApplicationId(application.Id);
        Test.stopTest();

        Assert.areEqual(participant.Id, result.Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByApplicationName() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYAPPNAME-001', false, '256700000006');

        Application__c insertedApplication = [
            SELECT Name
            FROM Application__c
            WHERE Id = :application.Id
        ];

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results =
            selector.selectApplicationParticpantByApplicationName(insertedApplication.Name);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByApplicationIdSign() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYSIGN-001', true, '256700000007');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results =
            selector.selectApplicationParticpantByApplicationIdSign(application.Id, true);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByAppAndPhone() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYPHONE-001', false, '256700000008');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results =
            selector.selectApplicationParticpantByAppAndPhone(application.Id, '256700000008');
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByKeyContact() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-BYKEYCONTACT-001', false, '256700000009');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        List<Application_Participant__c> results =
            selector.selectApplicationParticpantByKeyContact(application.Id);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(participant.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationParticpantByOmangId() {
        Application__c application = createApplication('In Progress', 'PRD001');
        Application_Participant__c participant =
            createParticipant(application.Id, 'NIN-OMANG-001', false, '256700000010');

        SEL_ApplicationParticipant selector = new SEL_ApplicationParticipant();

        Test.startTest();
        Application_Participant__c result =
            selector.selectApplicationParticpantByOmangId('NIN-OMANG-001', application.Id);
        Test.stopTest();

        Assert.areEqual(participant.Id, result.Id);
    }
}