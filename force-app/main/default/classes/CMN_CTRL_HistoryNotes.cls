/**
 * @description Controller Class for Handling History Notes API from SAP via ESB Middleware
 * @author Eduardo Salia
 * @date October 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56273
 * @LastModifiedReason: API Code Remediation and Indentation
 */
public with sharing class CMN_CTRL_HistoryNotes {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_CTRL_HistoryNotes');

    /**
     * @description This method retrieves the History Notes
     * @param recordId Id of our current record on the LWC Component
     * @return CMN_DTO_NoteInformationResponse API response
     */
    @AuraEnabled
    public static CMN_DTO_NoteInformationResponse getHistoryNotes(String recordId) {
        try {
            CMN_DTO_NoteInformationResponse response = new CMN_API_GetHistoryNotes().getLatestClientNotes(recordId);
            response = substituteAECodes(response);
            return response;
        } catch (Exception error) {
            LOGGER.error('CMN_CTRL_HistoryNotes.getHistoryNotes', error);
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description Substitutes AE codes in API Response with user names
     * @param response API response
     * @return CMN_DTO_NoteInformationResponse Modified API response
     */
    private static CMN_DTO_NoteInformationResponse substituteAECodes(CMN_DTO_NoteInformationResponse response) {
        Set<String> userCodes = new Set<String>();
        for (CMN_DTO_NoteInformation note : response.notes) {
            if (String.isNotBlank(note.noteCreatedBy)) {
                userCodes.add(note.noteCreatedBy);
            }
        }

        Map<String, String> userCodeToNameMap = new Map<String, String>();
        List<User> users = CMN_DAL_User.findByAECode(userCodes);
        for (Integer i = 0; i < users.size(); i++) {
            User user = users[i];
            userCodeToNameMap.put(user.RM_AE_Code__c, user.Name);
        }

        for (CMN_DTO_NoteInformation note : response.notes) {
            if (String.isNotBlank(userCodeToNameMap.get(note.noteCreatedBy))) {
                note.noteCreatedBy = userCodeToNameMap.get(note.noteCreatedBy);
            }
        }
        return response;
    }

    /**
     * @description This method Creates History Notes on SAP via ESB
     * @param recordId Id of our current record on the LWC Component
     * @param noteDetails Details of the History Note on the LWC Component
     * @param noteType Type of the History Note on the LWC Component
     * @return String response
     */
    @AuraEnabled
    public static String createHistoryNotes(String recordId, String noteDetails, String noteType) {
        try {
            return new CMN_API_GetHistoryNotes().createClientNotes(recordId, noteDetails, noteType);
        } catch (Exception error) {
            LOGGER.error('CMN_CTRL_HistoryNotes.createHistoryNotes', error);
            throw new AuraHandledException(error.getMessage());
        }
    }
}