/**
 * @description Will call a service to perform Natural Language Processing to determine Intent and Sentiment
 * This is using a fire and forget approach (the call does not have to succeed)
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class SVC_API_GetPrediction extends CMN_API_RestBaseOutbound {
    private static final String EMAIL_TYPE = 'Email';
    private static final String ERROR_INVALID_OBJECT_ID = 'Unable to find Object based on ID provided';
    private static final String ERROR_INVALID_OBJECT_TYPE = 'Object Type "{0}" not supported';

    public static final String SERVICE_NAME = SVC_API_GetPrediction.class.getName();

    /**
     * @description Override to set your request and response DTO types and any other globals you may have
     */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
    }

    /**
     * @description Name of your service to be used when looking up custom settings for you service
     *
     * @return the service name
     */
    protected override String getServiceName()
    {
        return SERVICE_NAME;
    }

    /**
     * @description Return the mock endpoint for testing purposes
     *
     * @return CMN_API_HttpBaseOutboundMock
     */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
    {
        return new SVC_API_OutboundPerformPredictionMock();
    }

    /**
     * @description Method checks to see if the web service should be allowed to run
     *
     * @return If true then the web service will be processed else aborted
     */
    protected override Boolean abortRequest() {
        Boolean abort = super.abortRequest();

        if (!abort) {
            SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(queueItem.CMN_TriggeringObjectId__c);

            if (objectType != Case.SObjectType)
            {
                String objectName = objectType?.getDescribe().getLocalName();
                String error = String.format(ERROR_INVALID_OBJECT_TYPE, new List<String>{objectName});
                callResult.errors.add(error);

                abort = false;
            }
        }

        return abort;
    }

    /**
     * @description The request to to be sent for retrieve Debit Order Transactions
     */
    private class DTO_Request extends CMN_DTO_JsonBase {
        Id objectId; //The object in Salesforce for which to do NLP
        String document; //The main body of text to be analysed
        String sender; //The original sender of the text
        String source; //The original source of the text
        String type; //The technology where the text to be analysed was sourced
        String subject; // The subject line of the email

        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);

            //If the code gets here we know that ID is set and it's of a case object
            Case foundCase = SVC_DAL_Case.findById(triggeringObjectId);

            if (foundCase == null) {
                throw new SearchException(ERROR_INVALID_OBJECT_ID);
            }

            objectId = foundCase.Id;
            document = foundCase.Description;
            subject = foundCase.Subject;
            sender = String.isBlank(String.valueOf(foundCase.ContactId))
                    ? foundCase.SuppliedEmail
                    : foundCase.ContactEmail;
            source = foundCase.Owner.Name;
            type = EMAIL_TYPE;
        }
    }
    /**
     * @description Mock class for returning test data
     */
    private class SVC_API_OutboundPerformPredictionMock extends CMN_API_HttpBaseOutboundMock {
        private final String VALID_RESPONSE = '{"result":{"executionArn":"arn:aws:states:eu-west-1:943752670398:execution:euw1-zaf-nprd-tc01463-dev-dev-iep-v2-core-workflow-stepfunction:b64c9c9c-42df-49d3-8681-381adb9e0d4b","startDate":"2020-12-15T06:44:00.883Z"}}';

        protected override void setResponse(
                HttpRequest request,
                HttpResponse response
        ) {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}