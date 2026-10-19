/**
 * @description       : Test class for SEL_CMN_Request selector class
 * @story             : SFP - 48887 : Premium Collection Gateway - Customer Authorizes Payment
 * @author            : Jaco de Lange
 * created date       : 17/09/2025
**/
@isTest
private  class SEL_CMN_Request_Test {

    @TestSetup
    static void setupData() {
        List<CMN_Request__c> reqList = new List<CMN_Request__c>();

        for (Integer i = 0; i < 3; i++) {
            reqList.add(new CMN_Request__c(
                Contract_Number__c = 'CNT-' + i,
                Cellphone_Number__c = '082000000' + i,
                Secure_Access_Token__c = 'token' + i,
                Secure_Access_Token_Expiration_Date__c = DateTime.now().addDays(7),
                Site_URL_Link__c = 'https://example.com/' + i,
                Payment_Collection_Type__c = 'Type' + i,
                Payment_Reference_Id__c = 'REF'+i,
                Instalment_Amount__c = '100',
                Status__c = 'Pending Submission',
                Currency__c = 'ZAR',
                INS_Product_Id__c = 'Product' + i,
                INS_Merchant_Request_Id__c = 'MERCHANT' + i,
                INS_Checkout_Request_Id__c = 'CHECKOUT' + i,
                Instalment_Reference_Number__c = 'INSTREF' + i
            ));
        }
        insert reqList;
    }
    
    @isTest
    static void testGetSObjectTypeAndFields() {
        SEL_CMN_Request sel = new SEL_CMN_Request();
        // Verify SObjectType
        assert.areEqual(CMN_Request__c.SObjectType, sel.getSObjectType());
        // Verify fields list contains Id and Name
        List<Schema.SObjectField> fieldList = sel.getSObjectFieldList();
        Assert.areEqual(16, fieldList.size(), 'Field list should contain 16 fields');
        Assert.areNotEqual(null, fieldList, 'Field list should not be null');
    }
    @isTest
    static void testSelectByToken() {
        //call selector
        SEL_CMN_Request sel = new SEL_CMN_Request();
        List<CMN_Request__c> result = sel.selectByToken('token1');

        Assert.areEqual(1, result.size(), 'Should find exactly one CMN_Request__c record');
        Assert.areEqual('token1', result[0].Secure_Access_Token__c, 'Token should match');
    } 
     @isTest
    static void testSelectByPayRefId() {
        
        //call selector
        SEL_CMN_Request sel = new SEL_CMN_Request();
        List<CMN_Request__c> result = sel.selectByPayRefId('REF2');

        Assert.areEqual(1, result.size(), 'Should return 1 record for REF2');
        Assert.areEqual('REF2', result[0].Payment_Reference_Id__c, 'Reference ID must match');
    } 
    @IsTest
    static void testSelectByMerchantReqIdAndCheckOutReqId() {
       
       SEL_CMN_Request selector = new SEL_CMN_Request();

       List<CMN_Request__c> result = selector.selectByMerchantReqIdAndCheckOutReqId('MERCHANT1', 'CHECKOUT1');

       Assert.areEqual(1, result.size(), 'Expected one record for merchant/checkOut combination');
       Assert.areEqual('MERCHANT1', result[0].INS_Merchant_Request_Id__c, 'Merchant ID must match');
       Assert.areEqual('CHECKOUT1', result[0].INS_Checkout_Request_Id__c, 'Checkout ID must match');
    }
}