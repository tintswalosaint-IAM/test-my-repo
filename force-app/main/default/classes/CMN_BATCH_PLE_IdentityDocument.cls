/**
 * @description Class responsible for the creation of the missing Life Events for existing data (SFP-11887, SFP-16925)
 *
 * @author Lukasz Kojzar
 *
 * @date May 2022
 */
public with sharing class CMN_BATCH_PLE_IdentityDocument implements Database.Batchable<sObject> {

    private static final String SOUTH_AFRICA = 'ZA';
    @TestVisible
    private static final String BIRTH = 'Birth';
    @TestVisible
    private static Boolean error = false;

    /**
	 * @description Start method of batch class
	 *
	 * @param bc - OOB Batchable input parameter
	 *
	 * @return iterable result
	 */
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT
                Id,
                RelatedLegalEntityId,
                Name
            FROM IdentityDocument
            WHERE
                (
                        CMN_External_CIF_Country__c = :SOUTH_AFRICA
                ) AND
                (
                        IdDocumentType = '1' OR
                        IdDocumentType = '01'
                )
        ]);
    }

    /**
	 * @description Execute method of batch class
	 *
	 * @param bc - OOB Batchable input parameter
	 * @param allIdDocs ID documents to process in the given chunk
	 */
    public void execute(Database.BatchableContext bc, List<sObject> allIdDocs) {
        Map<String, Date> personId2BirthDate = new Map<String, Date>();

        try {
            populateContacts((List<IdentityDocument>) allIdDocs, personId2BirthDate);
            removeClientsWithCreatedBirthEvent(personId2BirthDate);
            createBirthLifeEventsFor(personId2BirthDate);
        } catch (Exception ex) {
            CMN_UTIL_Logger.error(ex, 'CMN_BATCH_PLE_IdentityDocument');
            if (Test.isRunningTest()) {
                error = true;
            }
        }
    }

    /**
	 * @description Finish method of batch class
	 *
	 * @param bc - OOB Batchable input parameter
	 */
    public void finish(Database.BatchableContext bc) {
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
     * Method populates map parameter
     * @param allIdDocs ID documents to process
     * @param personId2BirthDate map to populate (contact Ids map resolving in contact's birthdays)
     */
    private void populateContacts(List<IdentityDocument> allIdDocs, Map<String, Date> personId2BirthDate) {
        Map<Id, Id> acc2personContact = getAccountContactRelationMap(allIdDocs);
        for (IdentityDocument idDoc : allIdDocs) {
            Id contactId = ((String)idDoc.RelatedLegalEntityId).startsWith('003')? idDoc.RelatedLegalEntityId : acc2personContact.get(idDoc.RelatedLegalEntityId);
            if (contactId != null) {
                personId2BirthDate.put(contactId, extractBirthDateFrom(idDoc));
            }
        }
    }

    /**
     * @param allIdDocs ID documents to process
     * @return map with Account -> Person Contact relation
     */
    private Map<Id, Id> getAccountContactRelationMap(List<IdentityDocument> allIdDocs) {
        Set<Id> accsIds = new Set<Id>();
        for (IdentityDocument idDoc : allIdDocs) {
            accsIds.add(idDoc.RelatedLegalEntityId);
        }
        Map<Id, Id> acc2personContact = new Map<Id, Id>();
        for (Account acc : [SELECT Id, PersonContactId FROM Account WHERE Id IN :accsIds]) {
            acc2personContact.put(acc.Id, acc.PersonContactId);
        }
        return acc2personContact;
    }

    /**
     * Method extracts contact birth date from the ID Document number
     *
     * @param idDoc ID Document to process
     *
     * @return contact's birth date
     */
    private Date extractBirthDateFrom(IdentityDocument idDoc) {
        Integer currentYearTwoLastDigits = Integer.valueOf(String.valueOf(Date.today().year()).substring(2,4));
        String yearTwoDigits = idDoc.Name.substring(0,2);
        String year = '19';
        if (currentYearTwoLastDigits > Integer.valueOf(yearTwoDigits)) {
            year = '20';
        }
        year += yearTwoDigits;
        return Date.newInstance(Integer.valueOf(year), Integer.valueOf(idDoc.Name.substring(2,4)), Integer.valueOf(idDoc.Name.substring(4,6)));
    }
}