/**
 * @description - Class used to Perform an API call to persist user info in SAP - SFP-19185
 *
 * <p>DBP-1279</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Nov 23th 2020
 * SFP-19185 - Tatenda Muzondiona - added apexDoc, @desciptions, @params
 */
public with sharing class AOB_API_MaintainCustomer extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public  static final String SERVICE_NAME = AOB_API_MaintainCustomer.class.getName();

    /**
     * @description constructor used to make sure a token will be provided to authenticate to the API call
     * @param mc AOB_DTO_MaintainCustomer
     */
    public AOB_API_MaintainCustomer(AOB_DTO_MaintainCustomer mc)
    {
        this.accessToken = AOB_Utils.getAccessToken();
        this.jsonBody = JSON.serialize(mc).replace('typeZ', 'type').replace('numberZ', 'number').replace('currencyZ', 'currency');
    }

    /**
     * @description The name of your service to be used when looking up custom settings for you service
     *
     * @return SERVICE_NAME
     */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }

    /**
     * @description Override to set your request and response DTO types and any other globals you may have
     */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();

    }

    private class DTO_Request extends CMN_DTO_JsonBase
    {
        /**
        * @description populates triggering object
        * @param triggeringObjectId Id -SFP-19185
        */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }

    /**
     * @description Will serialize requestDTO after its been populated.
     *
     * @return result
     */
    protected virtual override String getBody()
    {
        super.getBody();

        populateRequestDTO();

        return jsonBody;
    }

    /**
     * @description Overriding parent class method to use the right API Method
     * 
     * @return HTTP_VERB_PUT - SFP-19185
     */
    protected override virtual String getVerb()
    {
        return HTTP_VERB_PUT;
    }

    /**
     * @description Method is use to return the endpoint URL using in HTTP response.
     *
     * @return endpoint
     */
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
        String endPoint;
        string fedId;
        List<Account> accounts =
        [
                SELECT id,
                        ExternalCIFUUID__c
                FROM Account
                WHERE id IN
                (
                        SELECT AccountId
                        FROM user
                        WHERE id = :UserInfo.getUserId()
                )
        ];
        if(!accounts.isEmpty())
        {
            fedId = '/' + accounts[0].ExternalCIFUUID__c;
        }
        if(
                settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)
                )
        {
            string path = String.isNotBlank(settings.CMN_Path__c)
                    ? settings.CMN_Path__c
                    : CMN_UTIL_String.EMPTY;
            path += String.isNotBlank(fedId) ? fedId : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                    NAMED_CREDENTIAL_URL_FORMAT,
                    new List<String>
                    {
                            settings.CMN_NamedCredential__c,
                            String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
                    }
            );
        }

        return endPoint;
    }

    /**
     * @description Overriding parent class method to indicate that triggering object is not needed
     * @return Boolean
     */
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }

    /**
     * @description Wrapper class for http response
     */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        /**
        * @description http response
        */
        @AuraEnabled
        public string response { get; set; }

        /**
         * @description The Type of the DTO used when deserializing the class
         *
         * @return Class of the DTO
         */
        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }

    /**
     * @description Mock class for Test classes
     */
    public class AOB_CTRL_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String VALID_RESPONSE = '{"customer":{"uuid":"45573867-782e-00aa-0000-00000ab6f52b","customerType":"INDIVIDUAL","relManagerLink":"","personDetails":{"firstName":"Someone","lastName":"Testing","initials":"ST","otherName":"","birthName":"","preferredName":"","dob":"2010-02-21","gender":"MALE","title":"MR","maritalStatus":"SINGLE","citizenshipCountry":"ZA","nationality":"ZA","countryOfBirth":"ZA","ethnicity":"WHITE"},"links":{"allContacts":"/external-partner/customers/45573867-782e-00aa-0000-00000ab6f52b/contacts","allAddresses":"/external-partner/customers/45573867-782e-00aa-0000-00000ab6f52b/addresses","allIdentifications":"/external-partner/customers/45573867-782e-00aa-0000-00000ab6f52b/identifications","allSourceOfFunds":"/external-partner/customers/45573867-782e-00aa-0000-00000ab6f52b/sourceOfFunds","allStatuses":"/external-partner/customers/45573867-782e-00aa-0000-00000ab6f52b/statuses","allEmployments":"/external-partner/customers/45573867-782e-00aa-0000-00000ab6f52b/employment"},"prominentInfluentialPerson":{"pipInd":"false","relatedInd":"false","name":" ","relationType":""},"prefLanguage":"EN","customerRole":[{"role":"CRM000","startDate":"2018-12-05","endDate":"9999-12-31"},{"role":"BUP014","startDate":"0001-01-01","endDate":"9999-12-31"},{"role":"BUP051","startDate":"2016-01-25","endDate":"9999-12-31"}]}}';

        /**
        * @description creates a mock response for http calls
        * @param  request
        * @param response
        */
        protected override void setResponse(
                HttpRequest request,
                HttpResponse response
        )
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}