/***************************************************************************************

@Name of the Component : LoadSalesforceOffersTestDataFactory
@Description : Class to load test data for test classes for top 3 recommended action for Insurance..
@Author : Kenneth Dlamini
@Created Date : 2024-09-19
/***************************************************************************************
@Last Modified By : Kenneth Dlamini
@Last Modified On : 2025-07-25
@Modification description: SFP-36986, SFP-36989
***************************************************************************************/
@isTest
public class LoadSalesforceOffersTestDataFactory {
    static SVC_ClientRecommendationEngineSettings__mdt customSettings = SVC_ClientRecommendationEngineSettings__mdt.getInstance('SVC_LineItemsPerClient'); 
    static String systemId = customSettings.SVC_System_ID__c;

    public static User createTestUser(Integer userIndex) {

        Id userProfileId = [SELECT Id FROM Profile WHERE Name = 'System administrator' LIMIT 1].Id;

        User aTestUser = new User(Username=userIndex + 'salesforceoffers@test.com',
                FirstName='Kenneth', LastName='Dlamini',
                email= userIndex + 'salesforceoffers@test.com',
                alias= userIndex + 'SFO_ZA',
                CommunityNickname= userIndex + 'Kenny',
                TimeZoneSidKey='Africa/Johannesburg',
                LocaleSidKey='en_US', 
                EmailEncodingKey='UTF-8',
                ProfileId=userProfileId, 
                LanguageLocaleKey='en_ZA'
        );
        insert aTestUser;
        return aTestUser;
    }

    public static void assignUserPermissionSet(User aTestUser){
        PermissionSet permSet = [SELECT Id 
        FROM PermissionSet 
        WHERE Name = 'SVC_EnableRecommendedActionPrivileges'];
        insert new PermissionSetAssignment(AssigneeId = aTestUser.Id, PermissionSetId = permSet.Id);
    }

    public static Account createTestAccount(User aTestUser){
        RecordType rType = [SELECT Id, Name, DeveloperName, Description, SObjectType 
        FROM RecordType 
        WHERE SObjectType ='Account' AND DeveloperName = 'PersonAccount' LIMIT 1];
        Account testAccount = new Account();
        testAccount.Active__c = 'true';
        testAccount.FirstName = 'SalesforceTestAccount';
        testAccount.LastName = 'SalesforceOffers';
        testAccount.PersonEmail = 'salesforcetestaccount100@test.com';
        testAccount.SVC_Country__c = 'ZA';
        testAccount.RecordTypeId = rType.Id;
        testAccount.OwnerId = aTestUser.Id;
        insert testAccount;
        return testAccount;
    }

    public static void createTestCase(User aTestUser, Account aTestAccount){
        BusinessHours bhoursId = [select Id from BusinessHours where Name='ZA_Mon-Fri 08:00-17:00 GMT+02:00' limit 1];
        //create test case
        Case testCase = new Case();
            testCase.status = 'New';
            testCase.BusinessHoursId = bhoursId.Id;
            testCase.Origin = 'Email';
            testCase.Subject = 'Client with Salesforce Offers';
            testCase.Description = 'Please have a conversation with the client.';
            testCase.CurrencyIsoCode = 'ZAR';
            testCase.Case_Owner_Country__c = 'ZA';
            testCase.AccountId = aTestAccount.Id;
            testCase.OwnerId = aTestUser.Id;      
            insert testCase;
    }

    public static List<sbgpers__Recommended_Action__c> loadClientOffers(User aTestUser, Account aTestAccount){
        List<sbgpers__Recommended_Action__c> salesforceOffersList = new List<sbgpers__Recommended_Action__c>();
        Date validTillDate = Date.today();
        validTillDate = validTillDate.addDays(2);
        Date expiryDate = validTillDate.addDays(-4);
        sbgpers__Recommended_Action__c clientOffer = new sbgpers__Recommended_Action__c(
            sbgpers__Category__c = 'Policy Maturity',
            sbgpers__Account__c = aTestAccount.Id,
            OwnerId = aTestUser.Id,
            sbgpers__Sub_Category__c = 'Policy Renewal',
            sbgpers__Details__c = 'Testing testing testing',
            sbgpers__External_System_Id__c = systemId,
            sbgpers__Valid_Until__c = validTillDate
        );
        salesforceOffersList.add(clientOffer);
        sbgpers__Recommended_Action__c policyRenewal = new sbgpers__Recommended_Action__c(
            sbgpers__Category__c = 'Policy Expired',
            sbgpers__Account__c = aTestAccount.Id,
            OwnerId = aTestUser.Id,
            sbgpers__Sub_Category__c = 'Policy Renewal',
            sbgpers__Details__c = 'Customer policy has expired. Have a conversation about renewal.',
            sbgpers__External_System_Id__c = systemId,
            sbgpers__Valid_Until__c = validTillDate
        );
        salesforceOffersList.add(policyRenewal);

        sbgpers__Recommended_Action__c kYCStatus = new sbgpers__Recommended_Action__c(
            sbgpers__Category__c = 'KYC Outstanding.',
            sbgpers__Account__c = aTestAccount.Id,
            OwnerId = aTestUser.Id,
            sbgpers__Sub_Category__c = 'Update KYC Status',
            sbgpers__Details__c = 'Customer KYC outstanding. Have a conversation about updating their KYC status.',
            sbgpers__External_System_Id__c = systemId,
            sbgpers__Valid_Until__c = validTillDate
        );
        salesforceOffersList.add(kYCStatus);

        sbgpers__Recommended_Action__c crossSell = new sbgpers__Recommended_Action__c(
            sbgpers__Category__c = 'XSell Funeral Product.',
            sbgpers__Account__c = aTestAccount.Id,
            OwnerId = aTestUser.Id,
            sbgpers__Sub_Category__c = 'XSell Product',
            sbgpers__Details__c = 'Recommend Product to client. Have a conversation about XSell opportunity.',
            sbgpers__External_System_Id__c = systemId,
            sbgpers__Valid_Until__c = validTillDate
        );
        salesforceOffersList.add(crossSell);

        sbgpers__Recommended_Action__c expiredConversation = new sbgpers__Recommended_Action__c(
            sbgpers__Category__c = 'XSell Flexi Funeral Product.',
            sbgpers__Account__c = aTestAccount.Id,
            OwnerId = aTestUser.Id,
            sbgpers__Sub_Category__c = 'XSell Product',
            sbgpers__Details__c = 'Recommend Flexi Funeral Product to client. Have a conversation about XSell opportunity.',
            sbgpers__External_System_Id__c = systemId,
            sbgpers__Valid_Until__c = expiryDate
        );
        salesforceOffersList.add(expiredConversation);

        insert salesforceOffersList;

        return salesforceOffersList;
    }
}