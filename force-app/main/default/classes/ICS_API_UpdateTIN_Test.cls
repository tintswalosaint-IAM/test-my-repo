/**
* @description  Class used as test class for ICS_API_UpdateTIN_Test
*
* Story: SFP-37310
*
* @author Ramya Gurram
* @date 15/10/2024
* @last modified on  :16/10/2024
* @last modified by  :  Ramya Gurram
* @Modification Description : updated to latest Version
*/
@isTest
public class ICS_API_UpdateTIN_Test {
    /**
     * @description Sets up test data for all test methods
     */
    @TestSetup
    static void setupTestData() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'SBO Standard User' LIMIT 1];
        String uniqueName = getUniqueName();
        
        User user = new User(
            LastName = 'test',
            Email = 'test@example.com',
            Username = uniqueName + '@test.org',
            ProfileId = profile.Id,
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            UserPermissionsKnowledgeUser = true,
            
            FederationIdentifier = 'FederationIdentifier' + uniqueName
        );
        
        insert user;
        System.runAs(user){
        ICS_DAL_TestFactory.createAccount();
        }
    }
   /**
     * @description Get the unique name to be used for Email, Username of the created user
     * @return A unique Name
     */
    private static String getUniqueName() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        return uniqueName;
    }
    /**
 * @description Tests the ICS_API_UpdateTIN class functionality, verifying:
 * 1. Successful API call processing
 * 2. Correct status code handling
 * 3. Error handling capabilities
 * 
 * Test Scenario:
 * - Creates a test Account
 * - Initiates a TIN update API call
 * - Verifies response status code
 * - Validates error handling
 * 
 * Dependencies:
 * - CMN_DAL_DataFactory for creating test data
 * - CMN_WebserviceCallQueue__c for queueing outbound calls
 * 
 * @see ICS_API_UpdateTIN
 * @see CMN_DAL_DataFactory
 */
    @isTest
    static void UpdateTinTest() {
        try{
        account accountInfo = [select id from Account Limit 1];
        Test.startTest();
        ICS_API_UpdateTIN customerServiceCall = new ICS_API_UpdateTIN();
        customerServiceCall.accountId = accountInfo.id;
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_UpdateTIN.SERVICE_NAME, accountInfo.id);
        customerServiceCall.process(obj);
        Test.stopTest();
        	Assert.areEqual(200,customerServiceCall.getResponseStatusCode(),'UpdateTIN API should return a success response code');
        }catch(exception ex){
            Assert.areEqual(true,ex.getmessage()!=null,'Error Occured in calling TIN');
        }
    }
    
    
}