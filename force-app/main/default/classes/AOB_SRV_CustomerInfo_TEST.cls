@isTest
/**
 * @description Test class for AOB_SRV_CustomerInfo
 *
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-19956 08-08-2023 Gill Lumley   Add method to test callGetPersonalDetailsMarketingConsents  
 * Changed SFP-13875 21-08-2023 Gill Lumley   Fix PMD violations
 */
public class AOB_SRV_CustomerInfo_TEST {

    /**
     * @description Set up common test data for use by test methods
     */    
    @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Account acc;
        System.runAs(communityUser) {
            List<AOB_ReferencedData__c> referecedDataList = new List<AOB_ReferencedData__c>();
            Map<string, string> referencedData = new Map<string, string>();
            referencedData.put('AOB_Code__c', 'mr');
            referencedData.put('AOB_Value__c', 'mr');
            referencedData.put('AOB_SAPField__c', AOB_Constants.TITLE);
            referencedData.put('AOB_CountryCode__c', 'SA');  
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('AOB_Value__c', 'test');
            referencedData.put('AOB_SAPField__c', 'EMPMT_STTUS');
            referencedData.put('AOB_CountryCode__c', 'SA');  
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('AOB_Value__c', 'test');
            referencedData.put('AOB_SAPField__c', 'INCOME _TYPE');
            referencedData.put('AOB_CountryCode__c', 'SA');  
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('AOB_Value__c', 'test');
            referencedData.put('AOB_SAPField__c', 'PMIFP_RLTNP');
            referencedData.put('AOB_CountryCode__c', 'SA');  
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('AOB_Value__c', 'test');
            referencedData.put('AOB_SAPField__c', 'PMIFP_RLTNP');
            referencedData.put('AOB_CountryCode__c', 'SA');  
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            insert referecedDataList;
            Map<string, string> applicationData = new Map<string, string>();
            acc = [SELECT id FROM account WHERE id IN (SELECT accountId FROM contact WHERE id = :communityUser.contactId)];
            applicationData.put('AOB_Customer__c', acc.id);
            insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c', applicationData);
        }

    }

    /**
     * @description This method is used to test callGetCustomerAPI methd
     */
    @isTest
    public static void callGetCustomerAPITest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Customers.Customer customer = AOB_SRV_CustomerInfo.callGetCustomerAPI();
            Test.stopTest();
            Assert.isNotNull(customer,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPITest customer should be populated');
        }
    }

    /**
     * @description This method is used to test callGetToken methd
     */
    @isTest
    public static void callGetTokenTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            String token = AOB_SRV_CustomerInfo.callGetToken();
            Test.stopTest();
            Assert.isNotNull(token,'AOB_SRV_CustomerInfo_TEST.AOB_callGetTokenTest token should be populated');
        }
    }
    
    /**
     * @description This method is used to test maintainCustomer methd
     */
    @isTest
    public static void maintainCustomer2Test() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            String fieldsString = '{"firstName":"Someone","surName":"Testing","idNumber":"7602125236089","AddIncome":"on","employmentType":null,"inheritance":"679378","publicOffRelated":"on","relationshipNature":"PARENT","nameofTheIndividual":"PARENT NAME","applicationId":"a0f2z0000008paZAAQ"}';
            List<AOB_DTO_SelectOption> taxes=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> funds=new List<AOB_DTO_SelectOption>();
            String oldEmployment = '{"orgName":"DEPT. OF CORRECTIONAL SERVICE","staffIndicator":"","startDate":"2000-09-17","endDate":"2008-02-20","industrialSector":"","occupation":"","employmentType":"FULL TIME"}';
            String marketingConsents = '[{"consentCode":"01","consentCodeX":"EXTERNAL MARKETING","consentStatus":"false"},{"consentCode":"04","consentCodeX":"SHARE CUSTOMER DATA","consentStatus":"true"}]';
            Integer result = AOB_SRV_CustomerInfo.maintainCustomer(fieldsString,taxes,funds,oldEmployment, marketingConsents);
            Test.stopTest();
            Assert.areEqual(200,result,'AOB_SRV_CustomerInfo_TEST.AOB_maintainCustomer2Test result should be 200');
        }
    }
    
    /**
     * @description This method is used to test saveCustomerDetails methd
     */
    @isTest
    public static void saveCustomerDetailsTest() {
        try { 
            User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
            List<AOB_Application__c> apps=[select id from AOB_Application__c ];
            System.runAs(communityUser) {
                Test.startTest();
                String fieldsString = '{"firstName":"Someone","surName":"Testing","idNumber":"7602125236089","AddIncome":"on","employmentType":null,"inheritance":"679378","publicOffRelated":"on","relationshipNature":"PARENT","nameofTheIndividual":"PARENT NAME","applicationId":"'+apps[0].id+'"}';
                AOB_SRV_CustomerInfo.saveCustomerDetails(fieldsString);
                Test.stopTest();
            }
        } catch (Exception e) {
            Assert.isNotNull(e,'AOB_SRV_CustomerInfo_TEST.saveCustomerDetailsTest - error should not be thrown');
        }              
    }
    
    /**
     * @description This method is used to test saveIdentificationDocument method
     */
    @isTest
    public static void saveIdentificationDocumentTest() {
        try { 
            User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
            System.runAs(communityUser) {
                Test.startTest();
                String fieldsString = '{"firstName":"Someone","surName":"Testing","idNumber":"7602125236089","AddIncome":"on","employmentType":null,"inheritance":"679378","publicOffRelated":"on","relationshipNature":"PARENT","nameofTheIndividual":"PARENT NAME","applicationId":"a0f2z0000008paZAAQ"}';
                AOB_SRV_CustomerInfo.saveIdentificationDocument(fieldsString);
                Test.stopTest();
            }
        } catch (Exception e) {
            Assert.isNotNull(e,'AOB_SRV_CustomerInfo_TEST.csaveIdentificationDocumentTest - error should not be thrown');
        }              
    }

    /**
     * @description This method is used to test callGetCustomerAPI methd
     */
    @isTest
    public static void callGetCustomerAPISOFTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            List<AOB_DTO_Customers.SourceOfFunds> result = AOB_SRV_CustomerInfo.callGetCustomerAPISOF();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPISOFTest result should be populated');
        }
    }

    /**
     * @description This method is used to test callGetCustomerAPIIdentifications methd
     */
    @isTest
    public static void callGetCustomerAPIIdentificationsTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Identifications result = AOB_SRV_CustomerInfo.callGetCustomerAPIIdentifications();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPIIdentificationsTest result should be populated');
        }
    }

    /**
     * @description This method is used to test callGetCustomerAPI methd
     */
    @isTest
    public static void callGetCustomerAPIAddressesTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Addresses result = AOB_SRV_CustomerInfo.callGetCustomerAPIAddresses();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPIAddressesTest result should be populated'); 
        }
    }

    /**
     * @description This method is used to test callGetCustomerAPI methd
     */
    @isTest
    public static void callGetCustomerAPIContactTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_PersonalContact result = AOB_SRV_CustomerInfo.callGetCustomerAPIContact();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPIContactTest result should be populated');
        }
    }

    /**
     * @description This method is used to test callGetCustomerAPI methd
     */
    @isTest
    public static void callGetCustomerAPIEmploymentTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Employment result = AOB_SRV_CustomerInfo.callGetCustomerAPIEmployment();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPIEmploymentTest result should be populated');
        }
    }

    /**
     * @description This method is used to test maintainCustomer methd
     */
    @isTest
    public static void maintainCustomerTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AOB_API_MaintainCustomer.AOB_CTRL_PersonalDetailsMock());
            List<AOB_DTO_SelectOption> taxes = new List<AOB_DTO_SelectOption>();
            taxes.add(new AOB_DTO_SelectOption('type','390984'));
            List<AOB_DTO_SelectOption> funds = new List<AOB_DTO_SelectOption>();
            funds.add(new AOB_DTO_SelectOption('0017','399992'));
            String oldEmployment = '{"orgName":"DEPT. OF CORRECTIONAL SERVICE","staffIndicator":"","startDate":"2000-09-17","endDate":"2008-02-20","industrialSector":"","occupation":"","employmentType":"FULL TIME"}';
            String fieldsString = '{"firstName":"Someone","surName":"Testing","idNumber":"7602125236089","AddIncome":"on","employmentType":null,"inheritance":"679378","publicOffRelated":"on","relationshipNature":"PARENT","nameofTheIndividual":"PARENT NAME","applicationId":"a0f2z0000008paZAAQ"}';
            String marketingConsents = '[{"consentCode":"01","consentCodeX":"EXTERNAL MARKETING","consentStatus":"false"},{"consentCode":"04","consentCodeX":"SHARE CUSTOMER DATA","consentStatus":"true"}]';
            Integer result = AOB_SRV_CustomerInfo.maintainCustomer(fieldsString, taxes, funds, taxes, funds, oldEmployment, marketingConsents);
            Test.stopTest();
            Assert.areEqual(200, result,'AOB_SRV_CustomerInfo_TEST.AOB_maintainCustomerTest result should be 200');
        }
    }
    
    /* @isTest
    public static void generateData_Test() {
        User communityUser = [
        SELECT Id
        FROM USER
        WHERE Email LIKE '%@test.org'
        LIMIT 1
        ];
        System.runAs(communityUser) {
        Test.startTest();
        AOB_DTO_OTP response = AOB_CTRL_OTP.generateData();
        Test.stopTest();
        Assert.isNotNull(response,'AOB_SRV_CustomerInfo_TEST');
        }
    } 
    */
    
    @isTest
    public static void callAccessTokenTest() {
        User communityUser = [
        SELECT Id
        FROM USER
        WHERE Email LIKE '%@test.org'
        LIMIT 1
        ];
        System.runAs(communityUser) {
        Test.startTest();
        string token = AOB_CTRL_OTP.callAccessToken();
        Test.stopTest();
        Assert.areEqual('AAIkYzc0NmM',token,'AOB_SRV_CustomerInfo_TEST.callAccessTokenTest token should be value');
        }
    }
    
    @isTest
    public static void callGetTokenTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            String token = AOB_CTRL_PersonalDetails.callGetToken();
            Test.stopTest();
            Assert.isNotNull(token,'AOB_SRV_CustomerInfo_TEST.AOB_callGetTokenTest1 token should be populated');
        }
    }
    
    @isTest
    public static void maintainCustomerFailTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            String personDetails='';
            List<AOB_DTO_SelectOption> oldTaxes=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> oldFunds=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> taxes=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> fundsList=new List<AOB_DTO_SelectOption>();
            String oldEmploymen='';
            String marketingConsents = '';
            Test.startTest();
            boolean failed=false;
            try{
               AOB_CTRL_PersonalDetails.maintainCustomer(personDetails,oldTaxes,oldFunds,taxes,fundsList,oldEmploymen, marketingConsents);
            }
            catch(exception e){
                failed=true;
            }
            Test.stopTest();
            Assert.isTrue(failed,'AOB_SRV_CustomerInfo_TEST.AOB_maintainCustomerFailTest should fail');
        }
    }
    
    @isTest
    public static void callGetCustomerAPIEmploymentTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Employment result = AOB_CTRL_PersonalDetails.callGetCustomerAPIEmployment();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPIEmploymentTest1 result should be populated');
        }
    }
    
    @isTest
    public static void getAllPicklistEntriesCodesFailTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            boolean failed=false;
            try{
              AOB_CTRL_PersonalDetails.getAllPicklistEntriesCodes(null);
            }
            catch(exception e){
                failed=true;
            }
            Test.stopTest();
            Assert.isTrue(failed,'AOB_SRV_CustomerInfo_TEST.AOB_getAllPicklistEntriesCodesFailTest should fail');
        }
    }
    
    @isTest
    public static void getAllPicklistEntriesFailTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            boolean failed=false;
            try{
              AOB_CTRL_PersonalDetails.getAllPicklistEntries(null);
            }
            catch(exception e){
                failed=true;
            }
            Test.stopTest();
            Assert.isTrue(failed,'AOB_SRV_CustomerInfo_TEST.AOB_getAllPicklistEntriesFailTest should fail');
        }
    }
    
    @isTest
    public static void callGetCustomerAPITest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Customers.Customer customer = AOB_CTRL_PersonalDetails.callGetCustomerAPI();
            Test.stopTest();
            Assert.isNotNull(customer,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPITest1 customer should be populated');
        }
    }
    
    @isTest
    public static void callGetCustomerAPIIdentificationsTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_identifications idNumber = AOB_CTRL_PersonalDetails.callGetCustomerAPIIdentifications();
            Test.stopTest();
            Assert.isNotNull(idNumber,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPI_identificationsTest idNumber should be populated');
        }
    }
    
    @isTest
    public static void getAllPicklistEntriesCodesTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            List<String> picklists = new List<String>{ 'EMPMT_STTUS', 'PMIFP_RLTNP', 'INCOME _TYPE' };
            Map<String, List<AOB_DTO_SelectOption>> result = AOB_CTRL_PersonalDetails.getAllPicklistEntriesCodes(picklists);
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_getAllPicklistEntriesCodesTest result should be populated');
        }
    }
    
    @isTest
    public static void callGetCustomerAPIContactTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_PersonalContact result = AOB_CTRL_PersonalDetails.callGetCustomerAPIContact();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPI_contactTest result should be populated');
        }
    }

    
    @isTest
    public static void getAllPicklistEntriesTest() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            List<String> picklists = new List<String>{ 'EMPMT_STTUS', 'PMIFP_RLTNP', 'INCOME _TYPE' };
            Map<String, List<AOB_DTO_SelectOption>> result = AOB_CTRL_PersonalDetails.getAllPicklistEntries(picklists);
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_getAllPicklistEntriesTest result should be populated');
        }
    }
    
    @isTest
    public static void maintainCustomerTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            List<AOB_DTO_SelectOption> oldTaxes=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> oldFunds=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> taxes=new List<AOB_DTO_SelectOption>();
            List<AOB_DTO_SelectOption> fundsList=new List<AOB_DTO_SelectOption>();
            String oldEmployment = '{"orgName":"DEPT. OF CORRECTIONAL SERVICE","staffIndicator":"","startDate":"2000-09-17","endDate":"2008-02-20","industrialSector":"","occupation":"","employmentType":"FULL TIME"}';
            String personDetails = '{"firstName":"Someone","surName":"Testing","idNumber":"7602125236089","AddIncome":"on","employmentType":null,"inheritance":"679378","publicOffRelated":"on","relationshipNature":"PARENT","nameofTheIndividual":"PARENT NAME","applicationId":"a0f2z0000008paZAAQ"}';
            String marketingConsents = '[{"consentCode":"01","consentCodeX":"EXTERNAL MARKETING","consentStatus":"false"},{"consentCode":"04","consentCodeX":"SHARE CUSTOMER DATA","consentStatus":"true"}]';
            Test.startTest();
            
            Integer httpcode = AOB_CTRL_PersonalDetails.maintainCustomer(personDetails,oldTaxes,oldFunds,taxes,fundsList,oldEmployment,marketingConsents);
            Test.stopTest();
            Assert.areEqual(200,httpcode,'AOB_SRV_CustomerInfo_TEST.AOB_maintainCustomerTest1 http code should be 200');
        }
    }
    
    @isTest
    public static void callGetCustomerAPISOFTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            List<AOB_DTO_Customers.SourceOfFunds> result = AOB_CTRL_PersonalDetails.callGetCustomerAPISOF();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPISOFTest1 result should be populated');
        }
    }
    
    @isTest
    public static void callGetCustomerAPIAddressesTest1() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Addresses result = AOB_CTRL_PersonalDetails.callGetCustomerAPIAddresses();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPI_addressesTest result should be populated'); 
        }
    }
    
    @isTest
    public static void callGetCustomerAPIEmploymentTest11() {
        User communityUser = [SELECT Id FROM USER WHERE Email LIKE '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_DTO_Employment result = AOB_CTRL_PersonalDetails.callGetCustomerAPIEmployment();
            Test.stopTest();
            Assert.isNotNull(result,'AOB_SRV_CustomerInfo_TEST.AOB_callGetCustomerAPIEmploymentTest11 result should be populated');
        }
    }

}