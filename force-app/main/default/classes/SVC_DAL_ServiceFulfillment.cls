/**
 * @description       : Query methods related to Service Fulfillment object
 * @author            : Aliaksei Koval
 * @group             : 
 * @last modified on  : 05-16-2024
 * @last modified by  : Aliaksei Koval
**/
public inherited sharing class SVC_DAL_ServiceFulfillment {

    public static final String OBJECT_NAME = ServiceFulfillment__c.SObjectType.getDescribe().getLocalName();
    private static final String FIELD_ID = ServiceFulfillment__c.Id.getDescribe().getLocalName();
    private static final String FIELD_MOTIVATION_SETTLEMENT = ServiceFulfillment__c.SVC_MotivationForSettlement__c.getDescribe().getLocalName();
    private static final String FIELD_DEBIT_ACCOUNT_NUMBER = ServiceFulfillment__c.SVC_DebitAccountNumber__c.getDescribe().getLocalName();
    private static final String FIELD_CREDIT_ACCOUNT_NUMBER = ServiceFulfillment__c.SVC_CreditAccountNumber__c.getDescribe().getLocalName();
    private static final String FIELD_AMOUNT = ServiceFulfillment__c.Amount__c.getDescribe().getLocalName();
    private static final String FIELD_TRANSACTION_DATE = ServiceFulfillment__c.SVC_TransactionDate__c.getDescribe().getLocalName();
	private static final String REFUND_REQUEST_DATE = ServiceFulfillment__c.SVC_RefundRequestDate__c.getDescribe().getLocalName();
	private static final String REASON_FOR_DISPUTE = ServiceFulfillment__c.SVC_ReasonForDispute__c.getDescribe().getLocalName();
	private static final String SETTLEMENT_DATE = ServiceFulfillment__c.SVC_SettlementDate__c.getDescribe().getLocalName();
	private static final String STATEMENT_FROM_DATE = ServiceFulfillment__c.SVC_StatementFromDate__c.getDescribe().getLocalName();
	private static final String STATEMENT_TO_DATE = ServiceFulfillment__c.SVC_StatementToDate__c.getDescribe().getLocalName();
    private static final String FIELD_CASEID = ServiceFulfillment__c.Case__c.getDescribe().getLocalName();


	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Service Fulfillment fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
            FIELD_ID,
            FIELD_MOTIVATION_SETTLEMENT,
            FIELD_DEBIT_ACCOUNT_NUMBER,
            FIELD_CREDIT_ACCOUNT_NUMBER,
            FIELD_AMOUNT,
            FIELD_TRANSACTION_DATE,
            FIELD_CASEID,
			REFUND_REQUEST_DATE,
			REASON_FOR_DISPUTE,
			SETTLEMENT_DATE,
			STATEMENT_FROM_DATE,
			STATEMENT_TO_DATE
		};
	}

    /**
	 * @description Method to return a list of service fulfillment by Id
	 *
	 * @param fulfillmentId
	 *
	 * @return List of Service Fulfillments
	 */
	public static ServiceFulfillment__c findById(String fulfillmentId)
	{
		return (ServiceFulfillment__c)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, fulfillmentId, getDefaultFields());
	}

	/**
	 * @description Method to return a list of service fulfillment by Id
	 *
	 * @param caseId
	 *
	 * @return List of Service Fulfillments
	 */
	public static List<ServiceFulfillment__c> findByCaseId(String caseId)
	{
		return [SELECT Id FROM ServiceFulfillment__c WHERE Case__c = :caseId];
	}
}