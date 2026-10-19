/**
 * @description Class responsible for the creation of the missing Life Birth Events for existing data (SFP-18263)
 *
 * @author Lukasz Kojzar
 *
 * @date October 2022
 */

public with sharing class CMN_BATCH_PLE_Account implements Database.Batchable<sObject> {

    @TestVisible
    private static final String BIRTH = 'Birth';
    private static final String GHANA = 'GH';
    @TestVisible
    private static Boolean error = false;

    public Iterable<sObject> start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
                SELECT
                        PersonBirthdate,
                        PersonContactId
                FROM Account
                WHERE
                        ExternalCIFCountry__c = :GHANA // SFP-18263
                AND
                        PersonBirthdate != null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<sObject> allAccs) {
        Map<String, Date> personId2BirthDate = new Map<String, Date>();

        try {
            populateContacts((List<Account>) allAccs, personId2BirthDate);
            removeClientsWithCreatedBirthEvent(personId2BirthDate);
            createBirthLifeEventsFor(personId2BirthDate);
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_BATCH_PLE_IdentityDocument');
            if (Test.isRunningTest()) {
                error = true;
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
    }

    /**
     * Method populates map parameter
     * @param accs Accounts to Process
     * @param personId2BirthDate map to populate (contact Ids map resolving in contact's birthdays)
     */
    private void populateContacts(List<Account> accs, Map<String, Date> personId2BirthDate) {
        for (Account acc : accs) {
            Id contactId = acc.PersonContactId;
            if (contactId != null) {
                personId2BirthDate.put(contactId, acc.PersonBirthdate);
            }
        }
    }

    /**
     * Method removes contacts from the given map if Birth Life Event has been already created for a contact
     *
     * @param personId2BirthDate contact Ids map resolving in contact's birthdays
     */
    private void removeClientsWithCreatedBirthEvent(Map<String, Date> personId2BirthDate) {
        for (PersonLifeEvent birthEvent : [
                SELECT
                        Id,
                        EventType,
                        EventDescription,
                        PrimaryPersonId
                FROM PersonLifeEvent
                WHERE PrimaryPersonId IN :personId2BirthDate.keySet() AND EventType = :BIRTH
        ]) {
            personId2BirthDate.remove(birthEvent.PrimaryPersonId);
        }
    }

    /**
     * Method creates Birth Life Events for the given map parameter
     *
     * @param personId2BirthDate contact Ids map resolving in contact's birthdays
     */
    private void createBirthLifeEventsFor(Map<String, Date> personId2BirthDate) {
        List<PersonLifeEvent> newEvents = new List<PersonLifeEvent>();
        for (String contactId : personId2BirthDate.keySet()) {
            newEvents.add(
                    new PersonLifeEvent(
                            EventDate = personId2BirthDate.get(contactId),
                            EventType = BIRTH,
                            Name = BIRTH,
                            PrimaryPersonId = contactId
                    )
            );
        }
        insert newEvents;
    }
}