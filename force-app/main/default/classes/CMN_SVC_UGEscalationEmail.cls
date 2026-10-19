/**
 * @description Service class for UG escalation email construction and sending.
 *              Builds CC address lists, constructs email request DTOs, and dispatches
 *              notifications via CMN_FLOW_SendEmail. Isolates email concerns from
 *              the batch escalation orchestration.
 * @author Raymond Magezi
 * @date 23-07-2026
 * @see CMN_BATCH_UG_CaseEscalation
 * @see CMN_QUEUE_SendEscalationEmails
 * @see CMN_FLOW_SendEmail
 * @userStory SFP-58853
 * @history 23-07-2026  Raymond Magezi  Initial creation - extracted from CMN_BATCH_UG_CaseEscalation
 */
public without sharing class CMN_SVC_UGEscalationEmail {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_SVC_UGEscalationEmail.class.getName());

    private CMN_SVC_UGEscalationEmail() {}

    /**
     * @description Builds CC address list: case owner + previous escalation manager (if level > 1).
     *
     * @param c Case record
     * @param newLevel Target escalation level
     * @param owners Map of owner Users
     * @param previousManagers Map of previous escalation manager Users
     * @return List of CC email addresses
     */
    public static List<String> buildCcAddresses(Case c, Integer newLevel, Map<Id, User> owners, Map<Id, User> previousManagers) {
        List<String> ccAddresses = new List<String>();
        addEmailIfPresent(ccAddresses, owners.get(c.OwnerId));
        if (c.SVC_Escalate_to__c != null && newLevel > 1) {
            addEmailIfPresent(ccAddresses, previousManagers.get(c.SVC_Escalate_to__c));
        }
        return ccAddresses;
    }

    /**
     * @description Adds user email to address list if present, non-blank, and not a sandbox .invalid address.
     */
    private static void addEmailIfPresent(List<String> addresses, User u) {
        if (u != null && String.isNotBlank(u.Email) && !u.Email.endsWith('.invalid')) {
            addresses.add(u.Email);
        }
    }

    /**
     * @description Creates an email request DTO for the escalation notification.
     *              Skips if the resolved manager has no email address.
     *
     * @param c Case record
     * @param managerResult Manager lookup result containing email and Id
     * @param ccAddresses CC recipients
     * @param templateName Email template API name
     * @param orgWideEmail Org-wide email address
     * @param emailRequests List to add the request to
     */
    public static void addEmailRequest(
        Case c,
        CMN_DAL_User.ManagerResult managerResult,
        List<String> ccAddresses,
        String templateName,
        String orgWideEmail,
        List<CMN_QUEUE_SendEscalationEmails.EmailRequest> emailRequests
    ) {
        if (String.isBlank(managerResult.managerEmail)) {
            return;
        }
        CMN_QUEUE_SendEscalationEmails.EmailRequest emailReq = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
        emailReq.toAddress = managerResult.managerEmail;
        emailReq.caseId = c.Id;
        emailReq.ccAddresses = ccAddresses;
        emailReq.templateName = templateName;
        emailReq.orgWideEmail = orgWideEmail;
        emailRequests.add(emailReq);
    }

    /**
     * @description Sends escalation emails individually per case via CMN_FLOW_SendEmail.
     *              Each email is sent in isolation so a single failure does not block others.
     *
     * @param emailRequests List of email requests to send
     */
    public static void sendEscalationEmails(List<CMN_QUEUE_SendEscalationEmails.EmailRequest> emailRequests) {
        for (CMN_QUEUE_SendEscalationEmails.EmailRequest req : emailRequests) {
            try {
                CMN_FLOW_SendEmail.DTO_SendEmailRequest emailReq = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
                emailReq.toAddress = req.toAddress;
                emailReq.ccAddress = req.ccAddresses;
                emailReq.templateUniqueName = req.templateName;
                emailReq.orgWideEmailAddress = req.orgWideEmail;
                emailReq.whatId = req.caseId;
                CMN_FLOW_SendEmail.sendEmail(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>{emailReq});
            } catch (Exception ex) {
                LOGGER.error('sendEscalationEmails: Failed for case {0} - {1}', new Object[]{req.caseId, ex.getMessage()});
            }
        }
    }
}