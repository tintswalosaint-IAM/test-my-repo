/**
 * @Name of the Class : ICS_API_RestBaseOutbound
 * @description  class used as a API base class for updating the contactId in  SBO-UK PING Feature - Story: SFP-31800
 * @author Ikyatha Naidu
 * @Story SFP-31800
 * @date  09/01/2024
 * ***************************************
 * @last modified on  : 28-03-2024
 * @last modified by  : Ramya Gurram
 * @Modification Description : updated to latest version
 */
public virtual class ICS_API_RestBaseOutbound extends CMN_API_RestBaseOutbound
{
    // Public variable to store JSON body data
    public String jsonBody;

    // Public variable to store access token
    public String accessToken;
    
    /**
     * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
     * If the flag "dummyData" is set, fill the DTO with mock information and don't do query
     * We are doing this to support unit tests
     */
    protected virtual override void populateRequestDTO()
    {
        super.populateRequestDTO();
        
        baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
    }
    
    /**
     * @description Used to set the Http Request Headers
     */
    @testvisible
    protected virtual override void setHeaders(){
        setServiceSettings();
        super.setHeaders();
    }
    
    /**
     * @description Used to get response Status Code
     *
     * @return Integer
     */
    public virtual Integer getResponseStatusCode()
    {
        return response.getStatusCode();
    }    
}