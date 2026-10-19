/**
 * @description Class responsible for the creation of the missing Life Events for existing data (SFP-11887, SFP-15714, SFP-16925)
 *
 * @author Lukasz Kojzar
 *
 * @date May 2022
 */
public with sharing class CMN_BATCH_PLE_FinancialAccount implements Database.Batchable<sObject> {

    // Do not run more than once per day! (see SOQL in 'deleteExistingCarOrHomeLifeEventsFor' method)

    @TestVisible
    private static final String VAF = 'VAF';
    private static final String SOUTH_AFRICA = 'ZA';
    private static final String ANGOLA = 'AO';
    private static final String GHANA = 'GH';
    @TestVisible
    private static final String HOME_LOAN = 'Home Loan';
    @TestVisible
    private static final String HOME_LOAN_EVENT_NAME = 'Home Loan';
    @TestVisible
    private static final String CAR = 'Car';
    @TestVisible
    private static final String CAR_LOAN = 'Car Loan';
    @TestVisible
    private static final String HOME = 'Home';
    @TestVisible
    private static Boolean error = false;

    public Iterable<sObject> start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Name,
                        FinServ__FinancialAccountNumber__c,
                        FinServ__FinancialAccountType__c,
                        FinServ__PrimaryOwner__r.PersonContactId,
                        ExternalCIFCountry__c,
                        CreatedDate
                FROM FinServ__FinancialAccount__c
                WHERE
                (
                        (
                                ExternalCIFCountry__c = :SOUTH_AFRICA  OR// SFP-11887
                                ExternalCIFCountry__c = :ANGOLA  // SFP-15714
                        )
                        AND
                        FinServ__FinancialAccountType__c IN (:VAF, :HOME_LOAN)
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
    }

    public void execute(Database.BatchableContext bc, List<sObject> allFinAccs) {
        Set<Id> allContacts = new Set<Id>();
        Map<String, FinServ__FinancialAccount__c> accNumber2FinAcc = new Map<String, FinServ__FinancialAccount__c>();

        try {
            populateCollections((List<FinServ__FinancialAccount__c>) allFinAccs, accNumber2FinAcc, allContacts);
            deleteExistingCarOrHomeLifeEventsFor(allContacts);
            createLifeEventsFor(accNumber2FinAcc.values());
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_BATCH_PLE_FinancialAccount');
            if (Test.isRunningTest()) {
                error = true;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    private void createLifeEventsFor(List<FinServ__FinancialAccount__c> finAccsToCreateEvents) {
        List<PersonLifeEvent> newEvents = new List<PersonLifeEvent>();
        for (FinServ__FinancialAccount__c finAcc : finAccsToCreateEvents) {
            newEvents.add(
                    new PersonLifeEvent(
                            EventDate = finAcc.CreatedDate,
                            EventDescription = finAcc.FinServ__FinancialAccountNumber__c,
                            EventType = isVAF(finAcc) ? CAR : HOME,
                            Name = isVAF(finAcc) ? CAR_LOAN : HOME_LOAN_EVENT_NAME,
                            PrimaryPersonId = finAcc.FinServ__PrimaryOwner__r.PersonContactId
                    )
            );
        }
        insert newEvents;
    }

    private Boolean isVAF (FinServ__FinancialAccount__c finAcc) {
        return (finAcc.ExternalCIFCountry__c == GHANA && finAcc.Name.contains('Car')) || finAcc.FinServ__FinancialAccountType__c == VAF;
    }

    private void deleteExistingCarOrHomeLifeEventsFor(Set<Id> personContacts) {
        delete [
                SELECT
                        Id,
                        EventType,
                        EventDescription,
                        PrimaryPersonId
                FROM PersonLifeEvent
                WHERE PrimaryPersonId IN :personContacts AND EventType IN (:CAR, :HOME)
                AND CreatedDate < TODAY
        ];
    }

    private void populateCollections(List<FinServ__FinancialAccount__c> allFinAccs, Map<String, FinServ__FinancialAccount__c> accNumber2FinAcc, Set<Id> personContacts) {
        for (FinServ__FinancialAccount__c finAcc : allFinAccs) {
            Id contactId = finAcc.FinServ__PrimaryOwner__r?.PersonContactId;
            if (contactId != null) {
                accNumber2FinAcc.put(finAcc.FinServ__FinancialAccountNumber__c, finAcc);
                personContacts.add(contactId);
            }
        }
    }
}