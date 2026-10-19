/**
* @description Test Class for CMN_BATCH_PLE_FinancialAccount and CMN_BATCH_PLE_IdentityDocument class
*
* @author Łukasz Kojzar
*
* @date May 2021
*/


@IsTest
private class CMN_BATCH_PLE_Test {
    private static final Id ACCOUNT_RECORDTYPE_PERSON =
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static final String FIN_ACC_NO1_CAR = 'FIN_ACC_NO1_CAR';
    private static final String FIN_ACC_NO2_CAR = 'FIN_ACC_NO2_CAR';
    private static final String FIN_ACC_NO2_HOME = 'FIN_ACC_NO2_HOME';
    private static final String GHANA = 'GH';

    @TestSetup
    static void testSetUp() {
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.ExternalCIFUUID__c = 'testBPGUID';
        acc.CMN_BPGUID__pc = 'testBPGUID';

        Account acc2 = new Account();
        acc2.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
        acc2.FirstName = 'Jan';
        acc2.LastName = 'Kowalski';
        acc2.ExternalCIFCountry__c = GHANA;
        acc2.PersonBirthdate = Date.today().addYears(-30);
        insert new List<Account>{acc, acc2};

        IdentityDocument idDoc = new IdentityDocument();
        idDoc.Name = '9901016392080';
        idDoc.RelatedLegalEntityId = acc.Id;
        idDoc.IdDocumentType = '1';
        idDoc.CMN_External_CIF_Country__c = 'ZA';
        insert idDoc;

        FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
        finAccount.FinServ__FinancialAccountNumber__c = FIN_ACC_NO1_CAR;
        finAccount.FinServ__FinancialAccountType__c = CMN_BATCH_PLE_FinancialAccount.VAF;
       // finAccount.ExternalCIFCountry__c = 'ZA';
        finAccount.ExternalCIFCountry__c = 'AO';
        finAccount.FinServ__PrimaryOwner__c = acc.Id;

        FinServ__FinancialAccount__c finAccount2 = new FinServ__FinancialAccount__c();
        finAccount2.FinServ__FinancialAccountNumber__c = FIN_ACC_NO2_HOME;
        finAccount2.FinServ__FinancialAccountType__c = CMN_BATCH_PLE_FinancialAccount.HOME_LOAN;
       // finAccount2.ExternalCIFCountry__c = 'ZA';
        finAccount2.ExternalCIFCountry__c = 'AO';
        finAccount2.FinServ__PrimaryOwner__c = acc.Id;

        FinServ__FinancialAccount__c ghanaFA = new FinServ__FinancialAccount__c();
        ghanaFA.FinServ__FinancialAccountNumber__c = FIN_ACC_NO2_CAR;
        ghanaFA.Name = 'Something Car something';
        ghanaFA.ExternalCIFCountry__c = GHANA;
        ghanaFA.FinServ__PrimaryOwner__c = acc.Id;
        insert new List<FinServ__FinancialAccount__c> {finAccount, finAccount2, ghanaFA};

        // deletion of the Person Life Event created by the flows
        delete [
                SELECT
                        Id,
                        EventType,
                        EventDescription,
                        PrimaryPersonId
                FROM PersonLifeEvent
        ];
    }

    @IsTest
    private static void creatingCarHomeLifeEventsTest() {
        Account acc = [SELECT Id, PersonContactId FROM Account WHERE ExternalCIFCountry__c != :GHANA];

        PersonLifeEvent car = new PersonLifeEvent(
                EventDate = Date.today(),
                EventType = CMN_BATCH_PLE_FinancialAccount.CAR,
                Name = CMN_BATCH_PLE_FinancialAccount.CAR_LOAN,
                PrimaryPersonId = acc.PersonContactId
        );
        PersonLifeEvent home = new PersonLifeEvent(
                EventDate = Date.today(),
                EventType = CMN_BATCH_PLE_FinancialAccount.HOME,
                Name = CMN_BATCH_PLE_FinancialAccount.HOME_LOAN_EVENT_NAME,
                PrimaryPersonId = acc.PersonContactId
        );
        insert new List<PersonLifeEvent> {car, home};
        Test.setCreatedDate(car.Id, DateTime.now().addDays(-1));
        Test.setCreatedDate(home.Id, DateTime.now().addDays(-1));

        Test.startTest();
        system.debug([
                SELECT
                        Id,
                        FinServ__FinancialAccountNumber__c,
                        FinServ__FinancialAccountType__c,
                        FinServ__PrimaryOwner__r.PersonContactId,
                        CreatedDate
                FROM FinServ__FinancialAccount__c
                WHERE
                (
                        (
                                ExternalCIFCountry__c = 'ZA'  OR// SFP-11887
                                ExternalCIFCountry__c = 'AO'  // SFP-15714
                        )
                        AND
                        FinServ__FinancialAccountType__c IN (:CMN_BATCH_PLE_FinancialAccount.VAF, :CMN_BATCH_PLE_FinancialAccount.HOME_LOAN)
                )
                OR
                (
                        ExternalCIFCountry__c = :GHANA // SFP-16925
                        AND
                        (
                                Name LIKE '%Car%'
                                OR
                                Name LIKE '%Home%'
                        )
                )
        ]);
        Database.executeBatch(new CMN_BATCH_PLE_FinancialAccount());
        Test.stopTest();

        List<PersonLifeEvent> ples = [SELECT EventDate, EventDescription, EventType, Name, PrimaryPersonId FROM PersonLifeEvent];
        System.assertEquals(3, ples.size(), 'Wrong number of Person Life Events');
        for (PersonLifeEvent ple : ples) {
            System.assertEquals(Date.today(), ple.EventDate.date(), 'Incorrect event date');
            System.assertEquals(acc.PersonContactId, ple.PrimaryPersonId, 'Incorrect person assigned');
            if (ple.EventType == CMN_BATCH_PLE_FinancialAccount.CAR) {
                System.assert(FIN_ACC_NO1_CAR == ple.EventDescription || FIN_ACC_NO2_CAR == ple.EventDescription, 'Incorrect description: ' + ple.EventDescription);
                System.assertEquals(CMN_BATCH_PLE_FinancialAccount.CAR_LOAN, ple.Name, 'Incorrect name');
            } else if (ple.EventType == CMN_BATCH_PLE_FinancialAccount.HOME) {
                System.assertEquals(FIN_ACC_NO2_HOME, ple.EventDescription, 'Incorrect description');
                System.assertEquals(CMN_BATCH_PLE_FinancialAccount.HOME_LOAN_EVENT_NAME, ple.Name, 'Incorrect name');
            } else {
                System.assert(false, 'Incorrect EventType: ' + ple.EventType);
            }
        }
    }

    @IsTest
    private static void creatingBirthLifeEventTest() {
        Test.startTest();
        Database.executeBatch(new CMN_BATCH_PLE_IdentityDocument());
        Test.stopTest();

        PersonLifeEvent ple = [
                SELECT EventDate, PrimaryPersonId
                FROM PersonLifeEvent
                WHERE EventType = :CMN_BATCH_PLE_IdentityDocument.BIRTH
                AND Name = :CMN_BATCH_PLE_IdentityDocument.BIRTH
        ];
        System.assertEquals(Date.newInstance(1999,01,01), ple.EventDate, 'Incorrect Event Date Set');
        System.assertEquals([SELECT PersonContactId FROM Account WHERE ExternalCIFCountry__c != :GHANA].PersonContactId, ple.PrimaryPersonId, 'Incorrect person assigned');
    }

    @IsTest
    private static void creatingGhanaBirthLifeEventTest() {
        Test.startTest();
        Database.executeBatch(new CMN_BATCH_PLE_Account());
        Test.stopTest();

        PersonLifeEvent ple = [
                SELECT EventDate, PrimaryPersonId
                FROM PersonLifeEvent
                WHERE EventType = :CMN_BATCH_PLE_IdentityDocument.BIRTH
                AND Name = :CMN_BATCH_PLE_IdentityDocument.BIRTH
        ];
        System.assertEquals(Date.today().addYears(-30), ple.EventDate, 'Incorrect Event Date Set');
        System.assertEquals([SELECT PersonContactId FROM Account WHERE ExternalCIFCountry__c = :GHANA].PersonContactId, ple.PrimaryPersonId, 'Incorrect person assigned');
    }

    @IsTest
    private static void notCreatingBirthLifeEventWrongCountryTest() {
        IdentityDocument idDoc = [SELECT CMN_External_CIF_Country__c FROM IdentityDocument];
        idDoc.CMN_External_CIF_Country__c = null;
        update idDoc;

        Test.startTest();
        Database.executeBatch(new CMN_BATCH_PLE_IdentityDocument());
        Test.stopTest();

        List<PersonLifeEvent> ple = [
                SELECT Id
                FROM PersonLifeEvent
                WHERE EventType = :CMN_BATCH_PLE_IdentityDocument.BIRTH
                AND Name = :CMN_BATCH_PLE_IdentityDocument.BIRTH
        ];
        System.assert(ple.size() == 0, 'No Birth Event should be created when issuing country is not South Africa');
    }

    @IsTest
    private static void notCreatingSecondBirthLifeEventTest() {
        Account acc = [SELECT PersonContactId FROM Account WHERE ExternalCIFCountry__c != :GHANA];
        insert new PersonLifeEvent(
                EventDate = Date.newInstance(1993,3,3),
                EventType = CMN_BATCH_PLE_IdentityDocument.BIRTH,
                Name = CMN_BATCH_PLE_IdentityDocument.BIRTH,
                PrimaryPersonId = acc.PersonContactId
        );

        Test.startTest();
        Database.executeBatch(new CMN_BATCH_PLE_IdentityDocument());
        Test.stopTest();

        List<PersonLifeEvent> ples = [
                SELECT EventDate, PrimaryPersonId
                FROM PersonLifeEvent
                WHERE EventType = :CMN_BATCH_PLE_IdentityDocument.BIRTH
                AND Name = :CMN_BATCH_PLE_IdentityDocument.BIRTH
        ];
        System.assert(!CMN_BATCH_PLE_IdentityDocument.error, 'No error should occur inside batch');
        System.assert(ples.size() == 1, 'There should be only 1 Birth Event');
        System.assertEquals(Date.newInstance(1993,3,3), ples[0].EventDate, 'Incorrect Event Date Set');
        System.assertEquals([SELECT PersonContactId FROM Account WHERE ExternalCIFCountry__c != :GHANA].PersonContactId, ples[0].PrimaryPersonId, 'Incorrect person assigned');
    }

    @IsTest
    private static void notCreatingSecondGhanaBirthLifeEventTest() {
        Account acc = [SELECT PersonContactId FROM Account WHERE ExternalCIFCountry__c = :GHANA];
        insert new PersonLifeEvent(
                EventDate = Date.newInstance(1992,3,3),
                EventType = CMN_BATCH_PLE_IdentityDocument.BIRTH,
                Name = CMN_BATCH_PLE_IdentityDocument.BIRTH,
                PrimaryPersonId = acc.PersonContactId
        );

        Test.startTest();
        Database.executeBatch(new CMN_BATCH_PLE_Account());
        Test.stopTest();

        List<PersonLifeEvent> ples = [
                SELECT EventDate, PrimaryPersonId
                FROM PersonLifeEvent
                WHERE EventType = :CMN_BATCH_PLE_IdentityDocument.BIRTH
                AND Name = :CMN_BATCH_PLE_IdentityDocument.BIRTH
        ];
        System.assert(!CMN_BATCH_PLE_Account.error, 'No error should occur inside batch');
        System.assert(ples.size() == 1, 'There should be only 1 Birth Event');
        System.assertEquals(Date.newInstance(1992,3,3), ples[0].EventDate, 'Incorrect Event Date Set');
        System.assertEquals([SELECT PersonContactId FROM Account WHERE ExternalCIFCountry__c = :GHANA].PersonContactId, ples[0].PrimaryPersonId, 'Incorrect person assigned');
    }

    @IsTest
    private static void errorIdDocTest() {
        IdentityDocument idDoc = [SELECT Name FROM IdentityDocument];
        idDoc.Name = '1';
        update idDoc;

        Test.startTest();
        Database.executeBatch(new CMN_BATCH_PLE_IdentityDocument());
        Test.stopTest();

        System.assert(CMN_BATCH_PLE_IdentityDocument.error, 'Error expected inside batch for bad Id number');
    }
}