/**
 * Created by Adam Redlinski on 27.06.2023.
 */

@IsTest
private class WI_FLOW_ConcessionUnlockAndLock_TEST {

    @TestSetup
    static void setupMethod() {
        User approver = WI_DAL_DataFactory.createUser('System Administrator');
        approver.FirstName = 'John';
        approver.LastName = 'Johns';

        insert approver;

        system.runAs(approver) {
            Account acc = WI_DAL_DataFactory.createAccount(new Map<String, Object>{
                    'WI_Title__c' => 'MR.'
            });
            insert acc;

            Case c = WI_DAL_DataFactory.createCase(
                    new Map<String, Object>{
                            'AccountId' => acc.Id,
                            'WI_Retro__c' => 'Yes'
                    }
            );
            insert c;

            FinServ__FinancialAccount__c debitAccount = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, Name = 'debit account');
            insert debitAccount;

            List<Contract> concessions = new List<Contract>();
            concessions.add(new Contract(
                    AccountId = acc.Id,
                    ContractTerm = 5,
                    Status = 'New',
                    WI_Type__c = 'Initiation fee'
            ));


            insert concessions;
        }
    }

    @isTest
    static void testUnlockRecord_NoRecordId() {
        User adm = [SELECT Id FROM User LIMIT 1];
        System.runAs(adm) {
            Test.startTest();
            List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> result = WI_FLOW_ConcessionRenewUnlock.unlockRecord(null);
            System.assertEquals(1, result.size());
            System.assertEquals(false, result[0].isSuccess);
            System.assertEquals('Record Id must be provided', result[0].errors);
            System.assertEquals(false, result[0].isLocked);
            Test.stopTest();
        }
    }

    @isTest
    static void testUnlockRecord_NoRecordsToUnlock() {
        User adm = [SELECT Id FROM User LIMIT 1];
        System.runAs(adm) {
            Test.startTest();
            Contract concession = [SELECT Id FROM Contract LIMIT 1];
            List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> result = WI_FLOW_ConcessionRenewUnlock.unlockRecord(new List<Id>{
                    concession.Id
            });

            System.assertEquals(1, result.size());
            System.assertEquals(true, result[0].isSuccess);
            System.assertEquals(null, result[0].errors);
            System.assertEquals(false, result[0].isLocked);
            Test.stopTest();
        }
    }

    @isTest
    static void testUnlockRecord_WithRecordsToUnlock() {
        User adm = [SELECT Id FROM User LIMIT 1];
        System.runAs(adm) {
            Test.startTest();

            Contract concession = [SELECT Id FROM Contract LIMIT 1];
            Approval.lock(concession.Id);
            List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> result = WI_FLOW_ConcessionRenewUnlock.unlockRecord(new List<Id>{
                    concession.Id
            });


            System.assertEquals(1, result.size());
            System.assertEquals('', result[0].errors);
            System.assertEquals(true, result[0].isSuccess);
            System.assertEquals(true, result[0].isLocked);
            Test.stopTest();
        }
    }


    @isTest
    static void testLockRecord_WithRecordsToLock() {
        User adm = [SELECT Id FROM User LIMIT 1];
        System.runAs(adm) {
            Test.startTest();

            Contract concession = [SELECT Id FROM Contract LIMIT 1];
            List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> result = WI_FLOW_ConcessionRenewLock.lockRecord(new List<Id>{
                    concession.Id
            });

            System.assertEquals(1, result.size());
            System.assertEquals('', result[0].errors);
            System.assertEquals(true, result[0].isSuccess);
            System.assertEquals(true, result[0].isLocked);
            System.assertEquals(true, Approval.isLocked(concession.Id));

            Test.stopTest();
        }
    }

    @isTest
    static void testLockRecord_NoRecordId() {
        User adm = [SELECT Id FROM User LIMIT 1];
        System.runAs(adm) {
            Test.startTest();
            List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> result = WI_FLOW_ConcessionRenewLock.lockRecord(null);
            System.assertEquals(1, result.size());
            System.assertEquals(false, result[0].isSuccess);
            System.assertEquals('Record Id must be provided', result[0].errors);
            System.assertEquals(false, result[0].isLocked);
            Test.stopTest();
        }
    }

    @isTest
    static void testLockRecord_NoRecordsToUnlock() {
        User adm = [SELECT Id FROM User LIMIT 1];
        System.runAs(adm) {
            Test.startTest();
            List<WI_FLOW_ConcessionRenewUnlock.ResultWrapper> result = WI_FLOW_ConcessionRenewLock.lockRecord(null);

            System.assertEquals(1, result.size());
            System.assertEquals(false, result[0].isSuccess);
            System.assertEquals('Record Id must be provided', result[0].errors);
            System.assertEquals(false, result[0].isLocked);
            Test.stopTest();
        }
    }
}