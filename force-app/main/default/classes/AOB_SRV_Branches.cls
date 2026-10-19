/**
* This class is used as a service class for all operations related with Open Application
*
* <p>DBP-1279</p>
*
* @author Maryem Bourhi (mbourhi@salesforce.com)
*
* @date Nov 18th 2020
*/
public with sharing class AOB_SRV_Branches {
    
    /**
    * @description calls the get Token API with the Application scope
    * @return 	a string containing the token
    */
    public static string callGetToken() {
        AOB_API_AccessToken customerServiceCall = new AOB_API_AccessToken(
            AOB_API_AccessTokenBase.HTTP_BODY_SCOPE_BRANCHES
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_AccessToken.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj; 
        AOB_API_AccessToken.DTO_Response response = (AOB_API_AccessToken.DTO_Response) customerServiceCall.baseResponseDTO;
        return response.access_token;
    }
    
    /**
    * @description Calls the open application API
    * @return 	a string containing the response of the API
    */
    public static List<AOB_API_GetBranches.ETdata8_Multi> callGetBranches(
        string token
    ) {
        AOB_API_GetBranches customerServiceCall = new AOB_API_GetBranches(token);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetBranches.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;  
        AOB_API_GetBranches.DTO_Response result = (AOB_API_GetBranches.DTO_Response) customerServiceCall.baseResponseDTO;
        return result.ETdata8_Detail_Record.ETdata8_Multi;
    }
    
    /**
    * @description inserts all new branches
    */
    public static void insertBranches(
        List<AOB_API_GetBranches.ETdata8_Multi> Branches
    ) {
        List<AOB_ReferencedData__c> allNewData = new List<AOB_ReferencedData__c>();
        AOB_ReferencedData__c data;
        integer i = 0;
        for (AOB_API_GetBranches.ETdata8_Multi branch : branches) {
            data = new AOB_ReferencedData__c();
            i++;
            data.AOB_Code__c = branch.ETdata8_Code;
            data.Name = branch.ETdata8_Description;
            data.AOB_Sequence__c = i;
            data.AOB_SAPField__c = AOB_QUEUE_GetBranches.FIELD_NAME;
            allNewData.add(data);
        }
        if (!allNewData.isEmpty()) {
            try {
                insert allNewData;
            } catch (Exception error) {
                CMN_UTIL_Logger.error(error, 'AOB_SRV_Branches.insertBranches');
            }
        }
    }
}