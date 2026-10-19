/**
 * @description Queueable class to send escalation emails asynchronously
 *              to avoid SOQL governor limits in batch jobs.
 *
 * @author Raymond Magezi
 *
 * @date January 2026
 *
 * @see CMN_QUEUE_SendEscalationEmails_TEST
 *
 * @userStory SFP-55654
 *
 * @history [Original]  Raymond Magezi  Initial version - SFP-55654
 * @history 29-01-2026  Raymond Magezi  Refactored: Added error handling, logging, validation,
 *                                      governor limit checks (removed unused @InvocableMethod)
 * @history 23-02-2026  Raymond Magezi  Extracted email validation to CMN_UTIL_EmailValidator/CMN_SVC_EmailRequestTransformer
 * @history 16-04-2026  Raymond Magezi  Hotfix: Reduced QUEUEABLE_LIMIT_BUFFER from 5 to 0 for batch
 *                                      context compatibility, converted documentation to Javadoc
 *                                      standard - SFP-55654
 */
public class CMN_QUEUE_SendEscalationEmails implements Queueable {
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_QUEUE_SendEscalationEmails.class.getName());
    
    
    
    @TestVisible
    private static final Integer QUEUEABLE_LIMIT_BUFFER = 0;
    
    @TestVisible
    private static final Integer CHUNK_SIZE = 5;
    
    @TestVisible
    private static final String ERROR_EMPTY_REQUESTS = 'Email requests list is null or empty';
    
    @TestVisible
    private static final String ERROR_QUEUEABLE_LIMIT = 'Queueable job limit exceeded. Cannot enqueue job.';
    
    
    @TestVisible
    private final List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> emailRequests;
    
    /**
     * @description Constructor to initialize email requests
     *
     * @param emailRequests List of email requests to process
     *
     * @throws QueueableException if requests are invalid
     */
    @TestVisible
    private CMN_QUEUE_SendEscalationEmails(List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> emailRequests) {
        if (emailRequests == null || emailRequests.isEmpty()) {
            LOGGER.error('Constructor: {0}', new Object[]{ERROR_EMPTY_REQUESTS});
            throw new QueueableException(ERROR_EMPTY_REQUESTS);
        }
        
        // Defensive copy to prevent external modification
        this.emailRequests = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>(emailRequests);
        
        LOGGER.debug('Constructor: Initialized with {0} email request(s)', 
            new Object[]{this.emailRequests.size()});
    }
    
    /**
     * @description Execute method called by Queueable framework. Processes emails in
     *              chunks of CHUNK_SIZE to avoid SOQL limit exhaustion from downstream
     *              record-triggered flows on EmailMessage. Chains itself with remaining
     *              emails if any exist after processing the current chunk.
     *
     * @param context QueueableContext provided by platform
     */
    public void execute(QueueableContext context) {
        LOGGER.info('execute: Queueable job started - Job ID: {0}, Requests: {1}', 
            new Object[]{context.getJobId(), emailRequests.size()});

        Integer localSuccess = 0;
        Integer localSkipped = 0;
        Integer localErrors = 0;
        
        try {
            List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> validRequests = validateEmailRequests();
            localSkipped = emailRequests.size() - validRequests.size();
            
            if (validRequests.isEmpty()) {
                return;
            }
            
            List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> currentChunk = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>();
            List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> remaining = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>();
            
            for (Integer i = 0; i < validRequests.size(); i++) {
                if (i < CHUNK_SIZE) {
                    currentChunk.add(validRequests[i]);
                } else {
                    remaining.add(validRequests[i]);
                }
            }
            
            LOGGER.info('execute: Chunking - Total: {0}, CurrentChunk: {1}, Remaining: {2}', 
                new Object[]{validRequests.size(), currentChunk.size(), remaining.size()});
            
            checkEmailLimits(currentChunk.size());
            sendEmails(currentChunk);
            localSuccess = currentChunk.size();
            
            if (!remaining.isEmpty()) {
                chainNext(remaining);
            }
            
        } catch (Exception ex) {
            localErrors = emailRequests.size();
            LOGGER.fatal('execute: Unhandled exception in queueable job - Job ID: {0}', new Object[]{context.getJobId()}, ex);
            throw new QueueableException('Failed to send escalation emails: ' + ex.getMessage(), ex);
        } finally {
            logSummary(localSuccess, localSkipped, localErrors);
        }
    }
    
    /**
     * @description Enqueues a new instance with remaining emails for chained processing.
     *              Skips chaining in test context to avoid stack depth errors.
     *
     * @param remaining Email requests not yet sent
     */
    private void chainNext(List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> remaining) {
        LOGGER.info('chainNext: Chaining next queueable with {0} remaining email(s)', new Object[]{remaining.size()});
        if (!Test.isRunningTest()) {
            System.enqueueJob(new CMN_QUEUE_SendEscalationEmails(remaining));
        }
    }
    
    private List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> validateEmailRequests() {
        List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> validRequests = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>();
        
        for (CMN_FLOW_SendEmail.DTO_SendEmailRequest req : emailRequests) {
            if (!CMN_SVC_EmailRequestTransformer.isValidDto(req)) {
                LOGGER.warn('validateEmailRequests: Skipped invalid request - To: {0}', 
                    new Object[]{req == null ? null : req.toAddress});
                continue;
            }
            validRequests.add(req);
        }
        
        if (validRequests.isEmpty()) {
            LOGGER.warn('validateEmailRequests: No valid requests. All {0} request(s) were invalid.', 
                new Object[]{emailRequests.size()});
        } else {
            LOGGER.debug('validateEmailRequests: {0} of {1} request(s) valid', 
                new Object[]{validRequests.size(), emailRequests.size()});
        }
        
        return validRequests;
    }
    
    private void checkEmailLimits(Integer requestCount) {
        Integer emailsRemaining = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations();
        if (requestCount > emailsRemaining) {
            LOGGER.warn('checkEmailLimits: Requests ({0}) exceed limit ({1}). CMN_FLOW_SendEmail handles batching.', 
                new Object[]{requestCount, emailsRemaining});
        }
    }
    
    private void sendEmails(List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> validRequests) {
        LOGGER.info('sendEmails: Sending {0} email(s)', new Object[]{validRequests.size()});
        CMN_FLOW_SendEmail.sendEmail(validRequests);
        LOGGER.info('sendEmails: Successfully processed {0} email(s)', new Object[]{validRequests.size()});
    }
    
    private void logSummary(Integer success, Integer skipped, Integer errors) {
        String summary = String.format(
            'Queueable job complete - Total: {0}, Success: {1}, Skipped: {2}, Errors: {3}',
            new Object[]{emailRequests.size(), success, skipped, errors}
        );
        
        if (errors > 0) {
            LOGGER.error('logSummary: {0}', new Object[]{summary});
        } else if (skipped > 0) {
            LOGGER.warn('logSummary: {0}', new Object[]{summary});
        } else {
            LOGGER.info('logSummary: {0}', new Object[]{summary});
        }
    }
    
    /**
     * @description Queue emails from Apex callers (e.g., batch classes)
     *
     * @param requests List of EmailRequest objects
     *
     * @return Id Queueable job ID
     *
     * @throws QueueableException if validation fails or limits exceeded
     */
    public static Id queueEmails(List<EmailRequest> requests) {
        LOGGER.debug('queueEmails: Received {0} email request(s)', 
            new Object[]{requests == null ? 0 : requests.size()});
        
        validateInputRequests(requests);
        checkQueueableLimit();
        
        List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> emailDtos = CMN_SVC_EmailRequestTransformer.transform(requests);
        
        if (emailDtos.isEmpty()) {
            String errorMsg = 'All email requests were invalid. No emails will be sent.';
            LOGGER.error('queueEmails: {0}', new Object[]{errorMsg});
            throw new QueueableException(errorMsg);
        }
        
        Id jobId = System.enqueueJob(new CMN_QUEUE_SendEscalationEmails(emailDtos));
        LOGGER.info('queueEmails: Queueable job enqueued successfully - Job ID: {0}', new Object[]{jobId});
        
        return jobId;
    }
    
    private static void validateInputRequests(List<EmailRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            LOGGER.warn('queueEmails: {0}', new Object[]{ERROR_EMPTY_REQUESTS});
            throw new QueueableException(ERROR_EMPTY_REQUESTS);
        }
    }
    
    private static void checkQueueableLimit() {
        Integer queueableRemaining = Limits.getLimitQueueableJobs() - Limits.getQueueableJobs();
        
        if (queueableRemaining <= QUEUEABLE_LIMIT_BUFFER) {
            String errorMsg = String.format(
                '{0} Remaining: {1}, Buffer: {2}',
                new Object[]{ERROR_QUEUEABLE_LIMIT, queueableRemaining, QUEUEABLE_LIMIT_BUFFER}
            );
            LOGGER.error('checkQueueableLimit: {0}', new Object[]{errorMsg});
            throw new QueueableException(errorMsg);
        }
        
        LOGGER.debug('checkQueueableLimit: Passed - Remaining: {0}', new Object[]{queueableRemaining});
    }
    
    /**
     * @description Input wrapper for email requests from Apex
     */
    public class EmailRequest {
        public String toAddress;
        public String caseId;
        public List<String> ccAddresses;
        public String templateName;
        public String orgWideEmail;
    }
    
    public class QueueableException extends Exception {}
}