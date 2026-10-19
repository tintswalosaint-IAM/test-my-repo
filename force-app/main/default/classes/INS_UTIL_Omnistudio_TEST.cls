/*--------------------------------------------------------------------------------------------------
 * @description Test class for Omnistudio invoke class
 * @author Alexandr Goryachko
 * @date 2024/06/13
 * 
 * 2024-06-13   Alexandr Goryachko   Initial version
 * 2025-12-12   Alexandr Goryachko   Update Test class to prevent it from failing
-----------------------------------------------------------------------------------------------------*/
@isTest
public class INS_UTIL_Omnistudio_TEST {
    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;
                
        Account accountContact = [Select Id,PersonContactId From Account where Name = 'John Snow' limit 1];

        Producer producer = WI_DAL_DataFactory.createProducer(
            new Map<String, Object>{
                'AccountId' => acc.Id,
                'Name' => 'John Snow',
                'ContactId' => accountContact.PersonContactId
            }
        );
        insert producer;
    }

    /**
     * @description To check logging error logic
     */
    @isTest
    private static void logErrorTest() {
        String methodName = 'logError';
        Map<String, Object> inputMap = new Map<String, Object>{
            'response' => 'Status 404'
        };
        Map<String, Object> options = new Map<String, Object>{
            'request' => 'customers/772a7a37-3335-1edf-89fd-e357e61c893f'
        };
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        INS_UTIL_Omnistudio util = new INS_UTIL_Omnistudio();
        Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
        Assert.isTrue(isSuccess, 'Expected true but got false in logError method');
        Test.stopTest();
        List<sbgplatform__rflib_Log__c> logs = [SELECT Id FROM sbgplatform__rflib_Log__c];
        Assert.isFalse(logs.isEmpty(), 'Logs records were not created');
    }

    /**
     * @description To check getting dependent picklist addresses
     */
    @isTest
    private static void getAddressPicklistTest() {
        String methodName = 'getAddressPicklist';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        INS_UTIL_Omnistudio util = new INS_UTIL_Omnistudio();
        Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);

        Assert.isTrue(isSuccess, 'Expected true but got false in getAddressPicklist method');
        List<Map<String, String>> dependentAddress = util.getAddressPicklist();
        Assert.isFalse(dependentAddress.isEmpty(), 'Address list was not populated');
        Test.stopTest();
    }

    /**
     * @description To check getting producers records
     */
    @isTest
    private static void getProducersTest() {
        String methodName = 'getProducers';
        Map<String, Object> inputMap = new Map<String, Object>{
            'underwriters' => new List<String>{'John Snow'}
        };
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        INS_UTIL_Omnistudio util = new INS_UTIL_Omnistudio();
        Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);

        Assert.isTrue(isSuccess, 'Expected true but got false in getProducers method');
        Test.stopTest();
    }

    /**
     * @description To check merge two quotes in a single response
     */
    @isTest
    private static void mergeQuoteTest() {
        String methodName = 'mergeQuote';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMergeQuoteInput);
        Map<String, Object> options = (Map<String, Object>)JSON.deserializeUntyped(jsonMergeQuoteOptions);
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        INS_UTIL_Omnistudio util = new INS_UTIL_Omnistudio();
        Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);

        Assert.isTrue(isSuccess, 'Expected true but got false in mergeQuote method');
        List<Object> quotes = util.mergeQuotes(inputMap, options);
        Assert.isFalse(quotes.isEmpty(), 'Quotes was not merged');
        Test.stopTest();
    }
    
            /**
     * @description To check merge quote fail
     */
    @isTest
    private static void mergeQuoteTestFail() {
        String methodName = 'mergeQuote';
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(jsonMergeQuoteInputFail);
        Map<String, Object> options = (Map<String, Object>)JSON.deserializeUntyped(jsonMergeQuoteOptions);
        Map<String, Object> outMap = new Map<String, Object>();

        Test.startTest();
        INS_UTIL_Omnistudio util = new INS_UTIL_Omnistudio();
        Boolean isSuccess = util.invokeMethod(methodName, inputMap, outMap, options);
        Assert.isFalse(isSuccess, 'Response processing failed');
      
        Test.stopTest();
    }

    private static final String jsonMergeQuoteInput = '{"response":{"quotes":[{"itemPremiums":[{"policyFrequency":0,"fees":0,"prorata":0,"inspectionRequired":false,"discountLoading":0,"discountAmount":0,"discountType":"FIXED","decisionReason":"|\\r\\nTracking device compulsory for cover","decision":0,"vatAmount":200.052,"commissionAmount":12.5,"sasriaCommission":0,"sasriaVat":0,"sasria":2.02,"sumInsured":185800,"referralMessage":null,"hasReferals":false,"voluntaryExcess":4500,"newExcess":0,"basicExcess":4500,"premiumDue":1533.732,"premium":0,"itemDescription":"2020 FORD FIGO","itemType":"CAR","itemId":"e20ec57d-f07d-4d0b-c069-08dcf73d4871"},{"policyFrequency":0,"fees":0,"prorata":0,"inspectionRequired":false,"discountLoading":0,"discountAmount":0,"discountType":"FIXED","decisionReason":"|\\r\\nProactive tracking device compulsory for cover|\\r\\nLicense age less than 1 year","decision":0,"vatAmount":746.139,"commissionAmount":12.5,"sasriaCommission":0,"sasriaVat":0,"sasria":2.02,"sumInsured":231850,"referralMessage":null,"hasReferals":false,"voluntaryExcess":0,"newExcess":0,"basicExcess":0,"premiumDue":5720.399,"premium":0,"itemDescription":"2024 VOLKSWAGEN POLO PLAYA / POLO","itemType":"CAR","itemId":"9c43bc9c-1075-48a1-c06a-08dcf73d4871"},{"policyFrequency":0,"fees":0,"prorata":0,"inspectionRequired":false,"discountLoading":0,"discountAmount":0,"discountType":"FIXED","decisionReason":"|\\r\\nYour request was successfully processed!","decision":0,"vatAmount":228.9825,"commissionAmount":12.5,"sasriaCommission":0,"sasriaVat":0,"sasria":2.02,"sumInsured":260350,"referralMessage":null,"hasReferals":false,"voluntaryExcess":4500,"newExcess":0,"basicExcess":4500,"premiumDue":1755.5325,"premium":0,"itemDescription":"2015 TOYOTA RAV 4","itemType":"CAR","itemId":"88689067-7d52-42f2-c06b-08dcf73d4871"}],"totalPremium":9009.6635,"underwriter":"Stansure"},{"itemPremiums":[{"policyFrequency":0,"fees":0,"prorata":0,"inspectionRequired":false,"discountLoading":0,"discountAmount":0,"discountType":"FIXED","decisionReason":"","decision":0,"vatAmount":0,"commissionAmount":12.5,"sasriaCommission":0,"sasriaVat":0,"sasria":2.02,"sumInsured":185800,"referralMessage":null,"hasReferals":false,"voluntaryExcess":0,"newExcess":0,"basicExcess":3000,"premiumDue":1042.37,"premium":0,"itemDescription":"2020 FORD FIGO","itemType":"CAR","itemId":"e20ec57d-f07d-4d0b-c069-08dcf73d4871"},{"policyFrequency":0,"fees":0,"prorata":0,"inspectionRequired":false,"discountLoading":0,"discountAmount":0,"discountType":"FIXED","decisionReason":"","decision":0,"vatAmount":0,"commissionAmount":12.5,"sasriaCommission":0,"sasriaVat":0,"sasria":2.02,"sumInsured":231850,"referralMessage":null,"hasReferals":false,"voluntaryExcess":0,"newExcess":0,"basicExcess":3000,"premiumDue":2144.45,"premium":0,"itemDescription":"2024 VOLKSWAGEN POLO PLAYA / POLO","itemType":"CAR","itemId":"9c43bc9c-1075-48a1-c06a-08dcf73d4871"},{"policyFrequency":0,"fees":0,"prorata":0,"inspectionRequired":false,"discountLoading":0,"discountAmount":0,"discountType":"FIXED","decisionReason":"","decision":0,"vatAmount":0,"commissionAmount":12.5,"sasriaCommission":0,"sasriaVat":0,"sasria":2.02,"sumInsured":260350,"referralMessage":null,"hasReferals":false,"voluntaryExcess":0,"newExcess":0,"basicExcess":3000,"premiumDue":1310.3,"premium":0,"itemDescription":"2015 TOYOTA RAV 4","itemType":"CAR","itemId":"88689067-7d52-42f2-c06b-08dcf73d4871"}],"totalPremium":4497.12,"underwriter":"Hollard"}],"reference":"PQ8C1102","quoteId":"1ac35c78-f432-4eeb-dd80-08dcf73d4800"}}';
    private static final String jsonMergeQuoteOptions = '{"request":{"path":"short-term/quote","body":{"vehicles":[{"claimsHistory":{"threeYearClaims":0,"twoYearClaims":0,"oneYearClaims":0},"voluntaryExcess":0,"coverOption":"MARKET","carHireOption":"NONE","creditShortfall":{},"coverEffectiveDate":"2024-10-28","extras":[],"parking":{"dayAddress":{"addressLine3":"Roodpoort","postalCode":"1735","streetNumber":"802 Lisbon Avenue","addressLine2":"Roodpoort","addressLine1":"ZA"},"nightAddress":{"addressType":"PHYSICAL","id":"a24a457d-eb26-0307-4289-261a7af5fb4f","addressLine3":"Roodpoort","province":"Gauteng","postalCode":"1735","streetNumber":"802 Lisbon Avenue","addressLine1":"ZA","addressLine2":"Roodpoort"},"nightLocationLabel":"In Basement - Electronic Access","nightLocation":"INBASEMENTELECTRONICACCES","dayLocation":"INBASEMENTELECTRONICACCES"},"drivers":[{"driverType":"PRIMARY","licenseExpiry":"2024-11-28","initials":"B","sfJunctionId":"a3v9X000006fgpRQAQ","title":"MS","licenseType":"LICENSE","sfId":"0xU9X0000000ASQUA2","dateOfBirth":"1992-07-22","licenseFirstIssue":"2015-10-06","licenseCode":"EB","maritalStatus":"MARRIED","identityNumber":"9207225105081","contactNumber":"0832923652","email":"nadiakoen93@gmail.com","gender":"MALE","surname":"Stickling","firstname":"Bonathan"}],"immobiliser":true,"existingDamage":false,"excessWaiver":false,"rebuilt":false,"name":"CP-00585622","isCodeIII":false,"mmCode":"22020251","colour":"Silver","model":"FIGO 1.5TI VCT AMBIENTE (5DR) (2018-2022)","make":"FORD","year":"2020","licensePlateNumber":"CAW 33233","sfCusomerPropertyId":"0b89X0000001UfBQAU","sfPricebookEntryId":"01uKO000000joijYAA","sfId":"00k9X000005Vj61QAC","sfOpportunityId":"0069X00000J97SLQAZ","sfProductId":"01tKO000000YX9eYAG","alarmType":"FACTORY","coverTypeLabel":"Comprehensive","sumInsured":154600,"isNewcar":false,"transmission":"MANUAL","coverType":"COMPREHENSIVE","isFinanced":false,"usage":"SOCIALONLY","trackingDevice":"TRACKING","performanceModification":false},{"claimsHistory":{"threeYearClaims":0,"twoYearClaims":0,"oneYearClaims":0},"voluntaryExcess":0,"coverOption":"MARKET","carHireOption":"NONE","creditShortfall":{},"coverEffectiveDate":"2024-10-28","extras":[],"parking":{"dayAddress":{"addressLine3":"Roodpoort","postalCode":"1735","streetNumber":"802 Lisbon Avenue","addressLine2":"Roodpoort","addressLine1":"ZA"},"nightAddress":{"addressType":"PHYSICAL","id":"a24a457d-eb26-0307-4289-261a7af5fb4f","addressLine3":"Roodpoort","province":"Gauteng","postalCode":"1735","streetNumber":"802 Lisbon Avenue","addressLine1":"ZA","addressLine2":"Roodpoort"},"nightLocationLabel":"In Locked Garage","nightLocation":"INLOCKEDGARAGE","dayLocation":"INLOCKEDGARAGE"},"drivers":[{"driverType":"PRIMARY","licenseExpiry":"2024-11-28","initials":"J","sfJunctionId":"a3v9X000006fmd7QAA","title":"MS","licenseType":"LICENSE","sfId":"0xU9X0000000AU2UAM","dateOfBirth":"1992-07-22","licenseFirstIssue":"2024-06-30","licenseCode":"B","maritalStatus":"MARRIED","identityNumber":"9207225105081","contactNumber":"0832923652","email":"nadiakoen93@gmail.com","gender":"MALE","surname":"Stickling","firstname":"Jonathan"}],"immobiliser":true,"existingDamage":false,"excessWaiver":true,"rebuilt":false,"name":"CP-00585623","isCodeIII":false,"mmCode":"64027685","colour":"Red","model":"POLO 1.0 TSI R-LINE DSG (2022-2024)","make":"VOLKSWAGEN","year":"2024","licensePlateNumber":"REG8774989","sfCusomerPropertyId":"0b89X0000001Uk1QAE","sfPricebookEntryId":"01uKO000000joijYAA","sfId":"00k9X000005VlXdQAK","sfOpportunityId":"0069X00000J97SLQAZ","sfProductId":"01tKO000000YX9eYAG","alarmType":"FACTORY","coverTypeLabel":"Comprehensive","sumInsured":475800,"isNewcar":true,"transmission":"AUTOMATIC","coverType":"COMPREHENSIVE","isFinanced":true,"usage":"PROFESSIONAL","trackingDevice":"TRACKING","performanceModification":false},{"voluntaryExcess":0,"coverOption":"MARKET","carHireOption":"NONE","creditShortfall":{},"coverEffectiveDate":"2024-10-28","extras":[],"parking":{"dayAddress":{"addressLine3":"Roodpoort","postalCode":"1735","streetNumber":"802 Lisbon Avenue","addressLine2":"Roodpoort","addressLine1":"ZA"},"nightAddress":{"addressType":"PHYSICAL","id":"a24a457d-eb26-0307-4289-261a7af5fb4f","addressLine3":"Roodpoort","province":"Gauteng","postalCode":"1735","streetNumber":"802 Lisbon Avenue","addressLine1":"ZA","addressLine2":"Roodpoort"},"nightLocationLabel":"In Locked Garage","nightLocation":"INLOCKEDGARAGE","dayLocation":"INLOCKEDGARAGE"},"drivers":[{"driverType":"PRIMARY","licenseExpiry":"2024-11-28","initials":"J","sfJunctionId":"a3v9X000006fqlwQAA","title":"MS","licenseType":"LICENSE","sfId":"0xU9X0000000AYsUAM","dateOfBirth":"1992-07-22","licenseFirstIssue":"2012-10-27","licenseCode":"EB","maritalStatus":"MARRIED","identityNumber":"9207225105081","contactNumber":"0832923652","email":"nadiakoen93@gmail.com","gender":"MALE","surname":"Stickling","firstname":"Jonathan"}],"claimsHistory":{"threeYearClaims":1,"twoYearClaims":0,"oneYearClaims":0},"immobiliser":true,"existingDamage":false,"excessWaiver":false,"rebuilt":false,"name":"CP-00585624","isCodeIII":false,"mmCode":"60077603","colour":"White","model":"RAV4 2.0 GX (2015-2019)","make":"TOYOTA","year":"2015","licensePlateNumber":"CAW 31059","sfCusomerPropertyId":"0b89X0000001UwvQAE","sfPricebookEntryId":"01uKO000000joijYAA","sfId":"00k9X000005VphhQAC","sfOpportunityId":"0069X00000J97SLQAZ","sfProductId":"01tKO000000YX9eYAG","alarmType":"FACTORY","coverTypeLabel":"Comprehensive","sumInsured":192800,"isNewcar":false,"transmission":"MANUAL","coverType":"COMPREHENSIVE","isFinanced":true,"usage":"SOCIALONLY","trackingDevice":"TRACKING","performanceModification":false}],"policyHolder":{"firstName":"Jonathan","lastName":"Stickling","dateOfBirth":"1992-07-22","gender":"MALE","contactNumber":"0832923652","email":"nadiakoen93@gmail.com","criminalOffence":false,"insuranceDeclinedPreviously":false,"identityNumber":"9207225105081","maritalStatus":"MARRIED","creditCheckConsent":true,"initials":"J","itcConsent":true},"quoteHeader":{"country":"ZA","coverEffectiveDate":"2024-10-28","channel":"NONE"}}}}';
	private static final String jsonMergeQuoteInputFail = '{"response":{"quotes":[{"itemPremiums":[{"policyFrequency":"MONTHLY","inspectionRequired":false,"discountLoading":null,"discountAmount":0,"discountType":null,"decisionReason":"REFERRED : Minimum premium applied","decision":"REFERRED","vatAmount":18.000,"commissionAmount":24.0,"sasriaCommission":0.0,"sasriaVat":0.00,"sasria":0,"sumInsured":150000.00,"referralMessage":"Minimum premium applied","hasReferals":true,"voluntaryExcess":0.0,"basicExcess":500,"premiumDue":120,"premium":120,"itemDescription":"Gauteng Road Gauteng Road 1550","underWriterName":"HOLLARD","itemType":"BUILDING","itemId":"22f87ce4-173f-4827-461b-08dd5cab11db"}],"optIn":false,"fees":0,"totalPremium":120,"underwriter":"HOLLARD"},{"itemPremiums":[{"policyFrequency":null,"inspectionRequired":null,"discountLoading":null,"discountAmount":null,"discountType":null,"decisionReason":null,"decision":null,"vatAmount":0,"commissionAmount":0,"sasriaCommission":0,"sasriaVat":0.00,"sasria":0,"sumInsured":0,"referralMessage":"ValidationError: ItcValuesV2.ItcScore must be between 0 and 1000 (2450)","hasReferals":false,"voluntaryExcess":0,"basicExcess":0,"premiumDue":0,"premium":0,"itemDescription":null,"underWriterName":null,"itemType":0}],"optIn":false,"fees":0,"totalPremium":0,"underwriter":"KINGPRICE"},{"itemPremiums":[],"optIn":false,"fees":0,"totalPremium":0,"underwriter":"AUTO AND GENERAL"},{"itemPremiums":[],"optIn":false,"fees":0,"totalPremium":0,"underwriter":"FIRST FOR WOMEN"}],"reference":"PQB8FB77","quoteId":"b17d5186-0875-469c-7532-08dd5cab1171"}}';
}