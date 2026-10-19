/**
 * @description Controller class to fetch notes of the application form from the database
 * @author Melnyk Oleg
 * @date April 2023
 */

public with sharing class ICS_CTRL_ApplicationFormNotes {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_ApplicationFormNotes');
    /**
     * @description invocableMethod to get application form notes
     * @param request List of application ids
     */
    @InvocableMethod(label='Get Notes' description='Return a list of notes' category='Opportunity')
    public static List<Results> getNotes(List<Requests> request) {
        Id applicationId = request[0].applicationId;

        // get content document links
        List<ContentDocumentLink> links = [SELECT Id,
            LinkedEntityId,
            ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :applicationId];

        Set<Id> noteIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            noteIds.add(link.ContentDocumentId);
        }

        // get notes
        List<ContentNote> notes = [SELECT Id, Title, Content FROM ContentNote WHERE Id = :noteIds];
        LOGGER.info('Found '+notes.size()+' notes');
        List<Results> resultsList = new List<Results>();
        Results res = new Results();

        for (ContentNote note : notes) {
            String content = EncodingUtil.base64Decode(EncodingUtil.base64Encode(note.Content)).toString();
            switch on note.Title {
                when 'Applicant Details' {
                    res.applicantDetails = content;
                }
                when 'Employment Details' {
                    res.employmentDetails = content;
                }
                when 'Financial Details' {
                    res.financialDetails = content;
                }
                when 'Your Account Details' {
                    res.yourAccountDetails = content;
                }
                when 'Agreement Details' {
                    res.agreementDetails = content;
                }
            }
        }
        resultsList.add(res);

        return resultsList;
    }

    /**
     * @description Request type
     */
    public class Requests {
        @InvocableVariable(label = 'applicationId')
        public Id applicationId;
    }

    /**
     * @description Result type
     */
    public class Results {
        @InvocableVariable(label = 'applicantDetails')
        public String applicantDetails;

        @InvocableVariable(label = 'employmentDetails')
        public String employmentDetails;

        @InvocableVariable(label = 'financialDetails')
        public String financialDetails;

        @InvocableVariable(label = 'yourAccountDetails')
        public String yourAccountDetails;

        @InvocableVariable(label = 'agreementDetails')
        public String agreementDetails;
    }
}