@IsTest
private class ClientFinderControllerTest {
    @IsTest
    static void getAvailableRecordTypesReturnsOnlyIamRecordTypes() {
        Test.startTest();
        List<ClientFinderController.RecordTypeOption> options = ClientFinderController.getAvailableRecordTypes();
        Test.stopTest();

        for (ClientFinderController.RecordTypeOption option : options) {
            System.assert(
                option.developerName.startsWith('IAM_'),
                'Only IAM Account record types should be returned.'
            );
            System.assertNotEquals(null, option.id, 'Record type id should be populated.');
            System.assertNotEquals(null, option.label, 'Record type label should be populated.');
        }

        if (!options.isEmpty()) {
            ClientFinderController.RecordTypeOption firstOption = options[0];
            System.assertEquals(firstOption.id, firstOption.id, 'Id getter should be accessible.');
            System.assertEquals(firstOption.label, firstOption.label, 'Label getter should be accessible.');
            System.assertEquals(
                firstOption.developerName,
                firstOption.developerName,
                'Developer name getter should be accessible.'
            );
        }
    }

    @IsTest
    static void searchRequiresAccountName() {
        Test.startTest();
        try {
            ClientFinderController.searchAccounts('', null, null, null, null, null, null, null);
            System.assert(false, 'Expected an exception for a blank Account Name.');
        } catch (AuraHandledException expectedException) {
            System.assertNotEquals(null, expectedException.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void searchReturnsResultsForAvailableIamRecordType() {
        Test.startTest();
        List<ClientFinderController.AccountSearchResult> results = ClientFinderController.searchAccounts(
            'No Account Should Match This Test Name',
            null,
            null,
            null,
            null,
            null,
            null,
            getAnyIamRecordTypeDevName()
        );
        Test.stopTest();

        System.assertNotEquals(null, results, 'Search should return a result list.');
    }

    @IsTest
    static void searchSupportsExternalCifFilter() {
        Account testAccount = new Account(
            Name = 'Client Finder Test Account',
            ExternalCIFId__c = 'NoCifShouldMatchThisTest'
        );
        insert testAccount;

        Test.startTest();
        String iamRtDevName = getAnyIamRecordTypeDevName();
        List<ClientFinderController.AccountSearchResult> results = ClientFinderController.searchAccounts(
            'Client Finder Test Account',
            null,
            null,
            'NoCifShouldMatchThisTest',
            null,
            null,
            null,
            iamRtDevName
        );
        Test.stopTest();

        System.assertNotEquals(null, results, 'Search should return a result list when CIF is supplied.');
        System.assertEquals(1, results.size(), 'The inserted test Account should be returned.');
        System.assertEquals(testAccount.Id, results[0].id, 'Result id should match the Account.');
        System.assertEquals(testAccount.Name, results[0].name, 'Result name should match the Account.');
        System.assertEquals(
            testAccount.ExternalCIFId__c,
            results[0].externalCIFId,
            'Result External CIF should match the Account.'
        );
    }

    private static String getAnyIamRecordTypeDevName() {
        for (Schema.RecordTypeInfo recordTypeInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (
                recordTypeInfo.isAvailable() &&
                !recordTypeInfo.isMaster() &&
                recordTypeInfo.getDeveloperName().startsWith('IAM_')
            ) {
                return recordTypeInfo.getDeveloperName();
            }
        }

        return null;
    }
}