/**
* @description Unit test class for PPBBatchMaintainCustomer
*
* @author Muvhuso Nekhubvi
*
* @date September 2025
*/
@SuppressWarnings('PMD.Integration_to_use_API_Framework_Two')
@isTest
public class CHNW_BATCH_MaintainCustomerTest {
    
	private static final Id ACCOUNT_RECORDTYPE_PERSON = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    
    private static List<User> createTestUsers(Integer numbersOfUsers){
     
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Relationship Manager' LIMIT 1];
        
        Profile adminP = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        UserRole r = [select id from UserRole WHERE Name = 'Private Banker' limit 1];
        
        // Create test users with different countries
        List<User> testUsers = new List<User>();
                    
        for (Integer i = 0; i < numbersOfUsers; i++) {
            testUsers.add(new User(
            FirstName = 'Test' + i,
            LastName = 'User1' + i,
            Title = 'Private Banker',
            Email = 'testuser1@standardbank.co.za',
            Username = 'testuser1@standardbank.co.za' + i,//System.currentTimeMillis(),
            CompanyName = 'Standard Bank',
            UserRoleId = r.Id,
            ProfileId = i == 0 ? adminP.Id : p.Id,
            Alias = 'tuser1',
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_ZA',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            State = 'Gauteng',
            User_Country__c = 'ZA',
            RM_AE_Code__c = 'XBWER' + i,
            IsActive = true)
          );
        }
        insert testUsers;
        return testUsers;
    }
    
    private static List<Account> createTestAccounts(Integer numOfAccounts){
     
       List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numOfAccounts; i++) {
            accounts.add(
                new Account(
                    FirstName = 'Jane',
                    LastName = 'Doe - ' + i,
                    RecordTypeId = ACCOUNT_RECORDTYPE_PERSON,
                    VIPIndicator__c = true,
                    BillingState = 'Gauteng',
                    FinServ__MarketingSegment__c = 'Private Banking',
                    ExternalCIFCountry__c = 'ZA',
                    CMN_BPGUID__pc = '45537a43-7a37-40f7-0000-00000ab6f52b',
                    CMN_AccountHoldingBranch__pc = '411' + i,
                    RelationshipMgrCode__c = null
                )
            );
        }
        
        insert accounts;
        return accounts;
    }
	 @IsTest
    private static void runTest() {
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new UpdateCustomerAECodeMockResponse());
        
        List<User> users = createTestUsers(5);      
        System.runAs(users[0]){
            
        
        List<Account> accounts = createTestAccounts(5);
        
        List<String> financialAccountNames = new List<String>{'SIGNATURE BANKING CURRENT ACCOUNT', 'PRIVATE BANKING CURRENT ACCOUNT', 'SPECIAL BANKING CHEQUE ACCOUNT', 'STAFF PRIVATE BANKING CURRENT', 'PRIVATE BANKING PLUS CURRENT ACCOUNT'};
           
        
        List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>();
        
        for(integer j = 0 ; j < financialAccountNames.size(); j++){
             finAccounts.add(
                new FinServ__FinancialAccount__c(
                    name = financialAccountNames[j],
                    FinServ__PrimaryOwner__c = accounts[j].Id
                    )
                 );
        }
        insert finAccounts;
        
        List<String> controlCenters = new List<String>{'4112', '4113', '4114', '4115', '4116'};
    
        List<AOB_ReferencedData__c> referencesData = new List<AOB_ReferencedData__c>();
        for(integer k = 0 ; k < 5 ;k++){
           referencesData.add(new AOB_ReferencedData__c(AOB_Code__c = 'XBWER' + k ,AOB_Value__c = controlCenters[k])); 
        }
        
         // Run the scheduler
        String cron = '0 0 0 1 1 ? 2099';
            
        insert referencesData;
        CHNW_BATCH_MaintainCustomer batch = new CHNW_BATCH_MaintainCustomer();
        Test.startTest();  
           
           Database.executeBatch(batch,200);
            
           System.schedule(
            'Test_PPBBatchMaintainCustomer_Scheduler',
            cron,
            new CHNW_BATCH_MaintainCustomer()
           );
    
        Test.stopTest();
        
        List<Account> accs = [SELECT Id, BillingState, CMN_BPGUID__pc ,FinServ__MarketingSegment__c, RelationshipMgrCode__c FROM Account WHERE RelationshipMgrCode__c =: ''];
        Assert.areEqual(5 , accs.size() , 'All accounts still exist');   
		}
    }
    
     /**
     * @description mocks a response returned from the update customer API API
     */
    public class UpdateCustomerAECodeMockResponse implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(sbgplatform.ApiService.HTTP_OK);
           
            response.setBody('{ "customer": { "uuid": "45537a43-7a37-40f7-0000-00000ab6f52b", "customer_type": "1", "customer_typeX": "INDIVIDUAL", "residenceCountry": "ZA", "relManager": "0046DR1", "personDetails": { "firstName": "STATHAM", "lastName": "JASON", "initials": "S", "dob": "1985-06-13", "gender": "1", "genderX": "MALE", "title": "041", "titleX": "MR", "maritalStatus": "2", "maritalStatusX": "MARRIED", "citizenshipCountry": "ZA", "nationality": "ZA", "countryOfBirth": "ZA", "homeOwnership": "12", "homeOwnershipX": "OTHER", "qualification": "0100", "qualificationX": "COMM", "maritalPropertyRegime": "W", "maritalPropertyRegimeX": "COMMON LAW SPOUSE" }}');
            return response;
        }
    }
}