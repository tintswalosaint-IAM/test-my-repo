/**
 * Class Name       : SEL_ApplicationTest
 * Description      : Test class for SEL_Application. Covers getSObjectType,
 *                     getSObjectFieldList, and every selector method (selectWithoutCondition,
 *                     selectApplicationById, selectAppsById, getApplicationByFilter,
 *                     selectAppById, selectApplicationByLeadId, selectApplicationByOnlyRegList,
 *                     selectApplicationByOnlyGroup, selectApplicationByStatusAndSchemaCode,
 *                     selectApplicationByRegAndSchemaCode, selectApplicationByCustomerId).
 * Author           : Anuja Alli
 * Created Date     : Aug 11, 2026
 * User story       : SFP-53980
 * ==============================================
 * Last Modified By : Anuja Alli
 * Last Modified On : Aug 11, 2026
 * Modified Description : Adding UOW framework
 * User story       : SFP-53980
 */
@IsTest
private class SEL_Application_Test {

    private static Application__c createApplication(
        String status,
        String schemaCode,
        String registrationNumber,
        String groupName,
        String customerId
    ) {
        Lead leadRecord = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'N/A'
        );

        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = schemaCode,
            AOB_Memo_Code__c = schemaCode,
            IsActive = true
        );

        CMN_DAL_SObjectUnitOfWork setupUow = new CMN_DAL_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Lead.SObjectType, Product2.SObjectType }
        );
        if (Schema.SObjectType.Lead.isCreateable()) {
            setupUow.registerNew(leadRecord);
        }
        if (Schema.SObjectType.Product2.isCreateable()) {
            setupUow.registerNew(product);
        }
        setupUow.commitWork();
        setupUow.clear();

        Id leadId = leadRecord.Id;
        Id productId = product.Id;

        Application__c application = new Application__c(
            Status__c = status,
            AOB_Lead__c = leadId,
            AOB_Product__c = productId,
            AOB_RegistrationNumber__c = registrationNumber,
            AOB_GroupName__c = groupName,
            AOB_Customer_Id__c = customerId,
            CurrencyIsoCode = 'UGX'
        );

        CMN_DAL_SObjectUnitOfWork uow = new CMN_DAL_SObjectUnitOfWork(
            new List<Schema.SObjectType>{ Application__c.SObjectType, Application_Participant__c.SObjectType }
        );
        if (Schema.SObjectType.Application__c.isCreateable()) {
            uow.registerNew(application);
            uow.commitWork();
            uow.clear();
        }

        // AOB_Schema_Code__c is a read-only/formula field on Application__c, so it can't be
        // set directly. Read back whatever value the org derives from the related Product2
        // so callers can use the actual computed value rather than assuming its source field.
        return [
            SELECT Id, Status__c, AOB_Schema_Code__c, AOB_RegistrationNumber__c,
                   AOB_GroupName__c, AOB_Customer_Id__c, AOB_Lead__c, Name
            FROM Application__c
            WHERE Id = :application.Id
        ];
    }

    @IsTest
    static void testGetSObjectType() {
        SEL_Application selector = new SEL_Application();

        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        Assert.areEqual(Application__c.sObjectType, result);
    }

    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Test.stopTest();

        Assert.isNotNull(fieldList);
        Assert.isTrue(fieldList.contains(Application__c.Id));
        Assert.isTrue(fieldList.contains(Application__c.Status__c));
        Assert.isTrue(fieldList.contains(Application__c.AOB_RegistrationNumber__c));
    }

    @IsTest
    static void testSelectWithoutCondition() {
        createApplication('In Progress', 'PRD001', 'REG-NOCOND-001', 'GroupA', 'CUST-NOCOND-001');
        createApplication('In Progress', 'PRD001', 'REG-NOCOND-002', 'GroupB', 'CUST-NOCOND-002');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results = selector.selectWithoutCondition();
        Test.stopTest();

        Assert.areEqual(2, results.size());
    }

    @IsTest
    static void testSelectApplicationById() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYID-001', 'GroupA', 'CUST-BYID-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results =
            selector.selectApplicationById(new List<Id>{ application.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testSelectAppsById() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYIDSTR-001', 'GroupA', 'CUST-BYIDSTR-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results = selector.selectAppsById(application.Id);
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testGetApplicationByFilter() {
        Application__c application =
            createApplication('Approved', 'PRD001', 'REG-BYFILTER-001', 'GroupA', 'CUST-BYFILTER-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results =
            selector.getApplicationByFilter('Status__c = \'Approved\'');
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testSelectAppById() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-SINGLE-001', 'GroupA', 'CUST-SINGLE-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        Application__c result = selector.selectAppById(application.Id);
        Test.stopTest();

        Assert.areEqual(application.Id, result.Id);
    }

    @IsTest
    static void testSelectApplicationByLeadId() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYLEAD-001', 'GroupA', 'CUST-BYLEAD-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results =
            selector.selectApplicationByLeadId(new List<Id>{ application.AOB_Lead__c });
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationByOnlyRegList() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYREGLIST-001', 'GroupA', 'CUST-BYREGLIST-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results =
            selector.selectApplicationByOnlyRegList(new Set<String>{ 'REG-BYREGLIST-001' });
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationByOnlyGroup() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYGROUP-001', 'GroupOnly', 'CUST-BYGROUP-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results =
            selector.selectApplicationByOnlyGroup(new Set<String>{ 'GroupOnly' });
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationByStatusAndSchemaCode() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYSTATUSSCHEMA-001', 'GroupA', 'CUST-BYSTATUSSCHEMA-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        List<Application__c> results = selector.selectApplicationByStatusAndSchemaCode(
            'In Progress',
            application.AOB_Schema_Code__c
        );
        Test.stopTest();

        Assert.areEqual(1, results.size());
        Assert.areEqual(application.Id, results[0].Id);
    }

    @IsTest
    static void testSelectApplicationByRegAndSchemaCode() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYREGSCHEMA-001', 'GroupA', 'CUST-BYREGSCHEMA-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        Application__c result = selector.selectApplicationByRegAndSchemaCode(
            'REG-BYREGSCHEMA-001',
            application.AOB_Schema_Code__c
        );
        Test.stopTest();

        Assert.areEqual(application.Id, result.Id);
    }

    @IsTest
    static void testSelectApplicationByCustomerId() {
        Application__c application =
            createApplication('In Progress', 'PRD001', 'REG-BYCUSTOMER-001', 'GroupA', 'CUST-BYCUSTOMER-001');

        SEL_Application selector = new SEL_Application();

        Test.startTest();
        Application__c result = selector.selectApplicationByCustomerId('CUST-BYCUSTOMER-001');
        Test.stopTest();

        Assert.areEqual(application.Id, result.Id);
    }
}