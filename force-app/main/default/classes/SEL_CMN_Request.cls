/**
 * @description       : Selector class for CMN Request object.
 * @author            : Jaco de Lange
 * @group             : IAM : SFP - 48887 : Premium Collection Gateway - Customer Authorizes Payment
 * @created date      : 07-01-2025
 * 
 * @last modified on  : 10-24-2025
 * @last modified by  : Jaco de Lange
 * @Modification description : Add selectByMerchantReqIdAndCheckOutReqId method
**/
public inherited sharing class SEL_CMN_Request extends sbgplatform.fflib_SObjectSelector{

    /**
     * @description Defines the default fields to be added to all queries created ny the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */

     private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'Contract_Number__c',
        'Cellphone_Number__c',
        'Secure_Access_Token__c',
        'Secure_Access_Token_Expiration_Date__c',
        'Site_URL_Link__c',
        'Payment_Collection_Type__c',
        'Payment_Reference_Id__c',
        'Instalment_Amount__c',
        'Status__c',
        'Currency__c',
        'INS_Product_Id__c',
        'INS_Merchant_Request_Id__c',
        'INS_Checkout_Request_Id__c',
        'Instalment_Reference_Number__c'
    };

    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return CMN_Request__c.SObjectType;
    }

    /**
     *
     * @description Method to get list of fields to be part of response
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CMN_Request__c.Id,
            CMN_Request__c.Name,
            CMN_Request__c.Contract_Number__c,
            CMN_Request__c.Cellphone_Number__c,
            CMN_Request__c.Secure_Access_Token__c,
            CMN_Request__c.Secure_Access_Token_Expiration_Date__c,
            CMN_Request__c.Site_URL_Link__c,
            CMN_Request__c.Payment_Collection_Type__c,
            CMN_Request__c.Payment_Reference_Id__c,
            CMN_Request__c.Instalment_Amount__c,
            CMN_Request__c.Status__c,
            CMN_Request__c.Currency__c,
            CMN_Request__c.INS_Product_Id__c,
            CMN_Request__c.INS_Merchant_Request_Id__c,
            CMN_Request__c.INS_Checkout_Request_Id__c,
            CMN_Request__c.Instalment_Reference_Number__c
        };
    }
    /**
     * @description Select request by token
     * @param token
     * @return List<CMN_Request__c>
     **/
    public List<CMN_Request__c> selectByToken(String token) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Secure_Access_Token__c =:token');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select request by payment reference id
     * @param payRefId
     * @return List<CMN_Request__c>
     **/
    public List<CMN_Request__c> selectByPayRefId(String payRefId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Payment_Reference_Id__c =:payRefId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Select request by merchant request and check out request id
     * @param merchantReqId
     * @param checkOutReqId
     * @return List<CMN_Request__c>
     **/
    public List<CMN_Request__c> selectByMerchantReqIdAndCheckOutReqId(String merchantReqId, String checkOutReqId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('INS_Merchant_Request_Id__c =: merchantReqId AND INS_Checkout_Request_Id__c =: checkOutReqId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}