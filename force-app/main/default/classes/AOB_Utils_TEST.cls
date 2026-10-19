/**
 * @description Test class for Utils
 *
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 9th 2020
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-9129  01-04-2022 Gill Lumley   Add getWFRErrorTest method
 * Changed SFP-10057 20-04-2022 Gill Lumley   Add getPublicHolidayDatesTest method
 * Changed SFP-12774 10-10-2023 Gill Lumley   Test setup: Add country code when setting up referenced data test records; add public holiday test records to improve code coverage
 * 
 */
@isTest
public class AOB_Utils_TEST {
    /**
     * @description  This method is used to setup the test data
     */
    @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        System.runAs(communityUser) {
            List<AOB_ReferencedData__c> referecedDataList = new List<AOB_ReferencedData__c>();
            Map<string, string> referencedData = new Map<string, string>();
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('Name', 'test');
            referencedData.put('AOB_SAPField__c', 'EMPMT_STTUS');
            referencedData.put('AOB_CountryCode__c', 'SA');             
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('Name', 'test');
            referencedData.put('AOB_SAPField__c', 'INCOME _TYPE');
            referencedData.put('AOB_CountryCode__c', 'SA');               
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('Name', 'test');
            referencedData.put('AOB_SAPField__c', 'PMIFP_RLTNP');
            referencedData.put('AOB_CountryCode__c', 'SA');               
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            referencedData.put('AOB_Code__c', 'test');
            referencedData.put('Name', 'test');
            referencedData.put('AOB_SAPField__c', 'PMIFP_RLTNP');
            referencedData.put('AOB_CountryCode__c', 'SA');               
            referecedDataList.add((AOB_ReferencedData__c) AOB_DAL_TesTFactory.genericObjectCreation('AOB_ReferencedData__c', referencedData));
            insert referecedDataList;

            // SFP-12774: Increase code coverage for AOB_Utils by adding public holiday test records
            List<Holiday> holidayList=new List<Holiday>();
            holidayList.add(new Holiday 
              (Name = 'One Off Holiday',
               Description = 'ZA',
               IsAllDay = true,
               ActivityDate = Date.newInstance(2024, 02, 01),
               IsRecurrence = false));            
            holidayList.add(new Holiday 
              (Name = 'Christmas Day',
               Description = 'ZA',
               IsAllDay = true,
               ActivityDate = Date.newInstance(2023, 12, 25),
               IsRecurrence = true,
               RecurrenceStartDate = Date.newInstance(2023, 12, 25),
               RecurrenceType = 'RecursYearly',
               RecurrenceDayOfMonth = 25,
               RecurrenceMonthOfYear = 'December'));
            holidayList.add(new Holiday 
               (Name = 'Day of Goodwill',
                Description = 'ZA',
                IsAllDay = true,
                ActivityDate = Date.newInstance(2023, 12, 26),
                IsRecurrence = true,
                RecurrenceStartDate = Date.newInstance(2023, 12, 26),
                RecurrenceType = 'RecursYearly',
                RecurrenceDayOfMonth = 26,
                RecurrenceMonthOfYear = 'December'));               
            insert holidayList;

            Map<string, string> applicationData = new Map<string, string>();
            Account acc = [SELECT id FROM account WHERE id IN (SELECT accountId FROM contact WHERE id = :communityUser.contactId)];
            applicationData.put('AOB_Customer__c', acc.id);
            applicationData.put('AOB_TECH_FlowNames__c', 'FlowNames');
            insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c', applicationData);
        }

    }

    /**
     * @description  This method is used to test get app settings by Label
     */
    @isTest
    private static void getAppSettingByLabelTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            //List<AOB_AppSettings__mdt> appSettings = AOB_DAL_TestFactory.loadAppSettings(AOB_Constants.PING);
            Test.startTest();
            String setting = AOB_Utils.getAppSettingByLabel(AOB_Constants.PING_ID);
            Test.stopTest();
            System.AssertNotEquals(setting, null,'Test pass');
        }
    }

    /**
     * @description  This method is used to test getCountrySetting
     */
    @isTest
    private static void getCountrySettingTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_Country_Settings__mdt countrySetting = AOB_Utils.getCountrySetting('SB-COZA');
            Test.stopTest();
            System.AssertNotEquals(countrySetting, null,'Test pass');
        }
    }

    /**
     * @description  This method is used to test generateGUID
     */
    @isTest
    private static void generateGUIDTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            //List<AOB_AppSettings__mdt> appSettings = AOB_DAL_TestFactory.loadAppSettings(AOB_Constants.PING);
            Test.startTest();
            String result = AOB_Utils.generateGUID();
            Test.stopTest();
            System.AssertNotEquals(result, null,'Test pass');
        }
    }

    /**
     * @description  This method is used to test get app settings by category
     */
    @isTest
    private static void getAppSettingByCategoryTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            //List<AOB_AppSettings__mdt> appSettings = AOB_DAL_TestFactory.loadAppSettings(AOB_Constants.PING);
            Test.startTest();
            Map<String, String> settings = AOB_Utils.getAppSettingByCategory(AOB_Constants.PING);
            Test.stopTest();
            System.AssertNotEquals(settings, null,'Test pass');
        }
    }

    /**
     * @description  This method is used to test date format
     */
    @isTest
    private static void formatDateTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            String stringDate = AOB_Utils.formatDate('2020-07-19T21:00:00Z');
            Integer remainingDays = AOB_Utils.remainingDays('2020-07-19T21:00:00Z');
            Test.stopTest();
            System.AssertEquals(stringDate, '19 July 2020','Test pass');
            System.AssertNotEquals(remainingDays, null,'Test Fail');
        }
    }

    /**
     * @description  This method is used to test endpoint generation
     */
    @isTest
    private static void generateWSendpointTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            CMN_WebserviceSetting__mdt mdt = [SELECT id, CMN_NamedCredential__c, CMN_Path__c FROM CMN_WebserviceSetting__mdt LIMIT 1];
            Test.startTest();
            String endpoint = AOB_Utils.generateWSendpoint(mdt);
            Test.stopTest();
            Assert.isNotNull(endpoint, 'Test pass');
        }
    }

    /**
     * @description  This method is used to test parse jwt
     */
    @isTest
    private static void formatGUIDTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            String guid = '45573867782E00AA000000000AB6F52B';
            Test.startTest();
            String stringGuid = AOB_Utils.formatGUID(guid);
            Test.stopTest();
            Assert.areEqual(stringGuid, '45573867-782e-00aa-0000-00000ab6f52b','Test pass');
        }
    }

    /**
     * @description  This method is used to test parse jwt
     */
    @isTest
    private static void parseJWTTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            String token = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0xIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOlsib3BlbmlkIiwicHJvZmlsZSIsImVtYWlsIl0sImNsaWVudF9pZCI6IjI3MzEwZjFlLTBlZGEtNDM1MS05OTYxLTUwMTQ2NDFjYzBmNSIsImlzcyI6Imh0dHBzOi8vZW50ZXJwcmlzZXN0c3NpdC5zdGFuZGFyZGJhbmsuY28uemEiLCJqdGkiOiJzazFCc3prOW5NYTJhTXplUFRPRWVGIiwic3ViIjoiYW1sMDZAc2IuY28uemEiLCJuYmYiOjE2MTI5NzA0MDQsImJwaWQiOiI1MDEyODMxNDMiLCJicGlkZ3VpZCI6IjRFQkQwQzhGMEVENTAwQ0FFMTAwODAwMDBBQjZEMUU0IiwiaWQiOiJjZjM4MjE3Mi01ZTJlLTRiMzMtOTUyMS1hZjhiNzU5MmY5NDIiLCJpYXQiOjE2MTI5NzA0MDQsImV4cCI6MTYxMjk3MDcwNH0.Ed8nlTvMHE7n3apWCaP6DouZGPhOXbg80bVXqOD9S8wnDlY7IIk3pb5bJujxL7K7tUa3OhISKw2mqxU9BVn7yUuGtRQRDXbtlXGAkc6NvZ8IWnHJrnZqf3iqMhPeCbMQcyjV814g6j4r220XZ0NZ0_BxhZ7TVH0ew6ofkuCSE7DYQCl6-83dFdSHTKFHnfsIy2QOXS9c9WR7bQj9MLAub5kZCo6qHVR0RCtoXfIDWfh2uGcgHeBO6qlFc-g2yndWA-F29-wlWJupy9BG1L8iPPjlzi8Bk8SHaErVVax17XObBxw_zUOaLmvT4C_cSgeHtAvQKDpS9VxDqpQwfRSkHw';
            Test.startTest();
            String parsetToken = AOB_Utils.parseJWT(token);
            Test.stopTest();
            Assert.areNotEqual(parsetToken,'','Test pass');
        }
    }

    /**
     * @description  This method is used to test getAllPicklistEntriesCodes
     */
    @isTest
    private static void getAllPicklistEntriesCodesTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            AOB_ReferencedData__c record1 = new AOB_ReferencedData__c(AOB_Code__c ='test1', Name='testName1', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_CountryCode__c = 'SA', AOB_Language__c='en_US');
            insert record1;
            AOB_ReferencedData__c record2 = new AOB_ReferencedData__c(AOB_Code__c ='test2', Name='testName2', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_CountryCode__c = 'SA', AOB_Language__c='en_US');
            insert record2;
            List<String> sapFields = new List<String>();
            sapFields.add('PMIFP_RLTNP');
            Test.startTest();
            Map<String, List<AOB_DTO_SelectOption>> entries = AOB_Utils.getAllPicklistEntriesCodes(sapFields);
            Test.stopTest();
            Assert.isNotNull(entries, 'Test pass');
       }
    }

    /**
     * @description  This method is used to test getAllPicklistEntries
     */
    @isTest
    private static void getAllPicklistEntriesTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            
            AOB_ReferencedData__c record1 = new AOB_ReferencedData__c(AOB_Code__c ='test1', Name='testName1', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_CountryCode__c = 'SA', AOB_Language__c='en_US');
            insert record1;
            AOB_ReferencedData__c record2 = new AOB_ReferencedData__c(AOB_Code__c ='test2', Name='testName2', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_CountryCode__c = 'SA', AOB_Language__c='en_US');
            insert record2;
            
            List<String> sapFields = new List<String>();
            sapFields.add('PMIFP_RLTNP');
            Test.startTest();
            Map<String, List<AOB_DTO_SelectOption>> entries = AOB_Utils.getAllPicklistEntries(sapFields);
            Test.stopTest();
            Assert.isNotNull(entries, 'Test pass');
            for (AOB_DTO_SelectOption entry : entries.get('PMIFP_RLTNP')){
                Assert.areEqual('test',entry.value.substring(0,4), 'AOB_Utils_TEST.getAllPicklistEntriesTest - value(name) should be prefixed with test');
            }
        }
    }

    /**
     * @description  This method is used to test readXMLResponse
     */
    @isTest
    private static void getreadXMLResponseTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            String validResponse = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://www.VERSIONR.VBOTPBRI.Request.com" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><VERSIONROperationResponse xmlns="http://www.VERSIONR.VBOTPBRI.Response.com"><vers_v_version_data><vers_v_trancode>VBOB</vers_v_trancode><vers_v_version>5</vers_v_version><vers_v_token></vers_v_token><vers_v_cardno>0</vers_v_cardno><vers_v_channel_id>MAPP</vers_v_channel_id><vers_v_user_id>0026</vers_v_user_id><vers_v_user_ibt>4586</vers_v_user_ibt><vers_v_response_code>2001</vers_v_response_code><vers_v_digital_uid> </vers_v_digital_uid></vers_v_version_data><otp_data><otp_function_id>VAL</otp_function_id><otp_otp>13182</otp_otp><otp_delivery_type>E</otp_delivery_type><otp_country_code>27     </otp_country_code><otp_cell_no></otp_cell_no><otp_email_address>test@standardbank.co.za </otp_email_address><otp_qname>MAPPOTP020010885</otp_qname><otp_msg_type>SIGNCD</otp_msg_type><otp_msg_content>Credit Card                                                                                                                                                                                                                                                                                                                   </otp_msg_content></otp_data></VERSIONROperationResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
            XmlStreamReader reader = new XmlStreamReader(validResponse);
            String sxmltag = 'vers_v_response_code';
            Test.startTest();
            string response = AOB_Utils.readXMLResponse(reader, sxmltag);
            Test.stopTest();
            Assert.isNotNull(response, 'Test pass');
        }
    }

    /**
     * @description  This method is used to test parse jwt
     */
    @isTest
    private static void getgetAllPicklistEntriesTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            List<String> selectLists = new List<String>{ 'PMIFP_RLTNP' };
            Test.startTest();
            Map<String, List<AOB_DTO_SelectOption>> entries = AOB_Utils.getAllPicklistEntries(selectLists);
            Test.stopTest();
            Assert.isNotNull(entries,'Test pass');
        }
    }

    /**
     * @description  This method is used to test getObjectUrl
     */
    @isTest
    private static void getObjectUrlTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            string res = AOB_Utils.getObjectUrl(app1);
            Test.stopTest();
            Assert.isNotNull(res, 'Test pass');
        }
    }

    /**
     * @description  This method is used to test createCase
     */
    @isTest
    private static void createCaseTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
        String context = 'DOCUMENT';
        Boolean assignToQueue = true;
        System.runAs(communityUser) {
            Test.startTest();
            Case ca = AOB_Utils.createCase(context, app1.id, assignToQueue);
            Test.stopTest();
            Assert.isNotNull(ca, 'Test pass');
        }
    }

    /**
     * @description  This method is used to test assignCaseToQueue
     */
    @isTest
    private static void assignCaseToQueueTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
        Case ca = (Case) AOB_DAL_TestFactory.genericObjectCreation('Case', new Map<String, Schema.SObjectType>());
        insert ca;
        System.runAs(communityUser) {
            Test.startTest();
            AOB_Utils.assignCaseToQueue('DOCUMENT', ca.id, app1.id);
            Test.stopTest();
            Assert.isNotNull(ca, 'Test pass');
        }
    }
    /**
     * @description  This method is used to test getPicklistEntriesByParentField
     */
    @isTest
    private static void getPicklistEntriesByParentFieldTest(){
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            //AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            List<AOB_DTO_SelectOption> result = AOB_Utils.getPicklistEntriesByParentField('EMPMT_STTUS','');
            Test.stopTest();
            Assert.isNotNull(result,'Test pass');
        }
    }
    /**
     * @description  This method is used to test getAllPicklistEntriesByProduct
     */
    @isTest
    private static void getAllPicklistEntriesByProductTest(){
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            AOB_ReferencedData__c record1 = new AOB_ReferencedData__c(AOB_Code__c ='test1', Name='testName1',AOB_ProductCategory__c='test', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_Language__c='en_US');
            insert record1;
            AOB_ReferencedData__c record2 = new AOB_ReferencedData__c(AOB_Code__c ='test2', Name='testName2', AOB_ProductCategory__c='test', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_Language__c='en_US');
            insert record2;
            Test.startTest();
            List<String> selectLists = new List<String>{ 'PMIFP_RLTNP' };
            //AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            Map<String, List<AOB_DTO_SelectOption>> result = AOB_Utils.getAllPicklistEntriesByProduct(selectLists,'test');
            Test.stopTest();
            Assert.isNotNull(result,'Test pass');
        }
    }
    /**
     * @description  This method is used to test getBusinessHours
     */
    @isTest
    private static void getBusinessHoursTest(){
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            //AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            List<String> result = AOB_Utils.getBusinessHours();
            Test.stopTest();
            Assert.isNotNull(result,'Test pass');
        }
    }
    /**
     * @description  This method is used to test getWebServiceSettingsByName
     */
    @isTest
    private static void getWebServiceSettingsByNameTest(){
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            //AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            CMN_WebserviceSetting__mdt result = AOB_Utils.getWebServiceSettingsByName('AOB_API_PersonalDetails');
            Test.stopTest();
            Assert.isNotNull(result,'Test pass');
        }
    }
    

    /**
     * @description  This method is used to test getApplicationsMap
     */
    @isTest
    private static void getApplicationsMapTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
        List<CMN_WebserviceCallQueue__c> webserviceList = new List<CMN_WebserviceCallQueue__c>{ new CMN_WebserviceCallQueue__c(CMN_TriggeringObjectId__c = app1.Id) };
        System.runAs(communityUser) {
            Test.startTest();
            Map<Id, AOB_Application__c> result = AOB_Utils.getApplicationsMap(webserviceList);
            Test.stopTest();
            Assert.isNotNull(result,'Test Fail');
            Assert.areEqual(app1.Id, result.get(app1.Id)?.Id,'Test pass');
        }
    }

    /**
     * @description  This method is used to test getApplicationFlowNames
     */
    @isTest
    private static void getApplicationFlowNamesTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            String result = AOB_Utils.getApplicationFlowNames(app1.id);
            Test.stopTest();
            Assert.isNotNull(result,'Test pass');
        }
    }
    
    /**
     * @description  This method is used to test getApplicationFlowNames Fail scenario
     */
    @isTest
    private static void getApplicationFlowNamesFailTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            Boolean failed=false;
            try{
                AOB_Utils.getApplicationFlowNames(null);
            }
            catch( exception e){
                failed=true;
            }
            Test.stopTest();
            Assert.areEqual(failed, true,'Test pass');
        }
    }
    /**
     * @description  This method is used to test getFreshAccessToken
     */
    @isTest
    private static void getFreshAccessTokenTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            String token=AOB_Utils.getFreshAccessToken();
            Test.stopTest();
            Assert.isNotNull(token,'Test pass');
        }
    }
/**
     * @description  This method is used to test getFreshAccessToken
     */
    @isTest
    private static void getAccessTokenTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            String token=AOB_Utils.getAccessToken();
            Test.stopTest();
            Assert.isNotNull(token,'Test pass');
        }
    }

    /**
     * @description  This method is used to test getReferenceData
     */
    @isTest
    private static void getReferenceDataTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_ReferencedData__c refD = [SELECT Id, AOB_Code__c, AOB_SAPField__c, Name FROM AOB_ReferencedData__c LIMIT 1];
            AOB_ReferencedData__c result = AOB_Utils.getReferenceData(refD.AOB_Code__c,refD.AOB_SAPField__c);
            Test.stopTest();
            Assert.areEqual(refD.Name, result.Name,'Test pass');
        }
    } 
    
    /**
     * @description This method is used to test getWFRError
     */
    @isTest
    private static void getWFRErrorTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_WFR_Error__mdt wfrError = AOB_Utils.getWFRError('01');
            Test.stopTest();
            Assert.isNotNull(wfrError,'Test pass');
        }
    } 

    /**
     * @description This method is used to test getPublicHolidayDates
     */
    @isTest
    private static void getPublicHolidayDatesTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        Date fromDate = date.today();
        Date toDate = fromDate.addYears(1);
        System.runAs(communityUser) {
            Test.startTest();
            List<Date> holidays = AOB_Utils.getPublicHolidayDates('ZA',fromDate,toDate);
            Test.stopTest();
            Assert.isNotNull(holidays,'Test pass');
        }
    } 
    

}