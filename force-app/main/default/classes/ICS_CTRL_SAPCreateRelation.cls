/*************************************************************
 * @description SFP-32986 CTRL Class used to send relation data
 *
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima 
 * Last Modified Date 21/10/2024
 * Last Modified Description: Initial Version
 */
public with sharing class ICS_CTRL_SAPCreateRelation implements Queueable , Database.AllowsCallouts{
    public String AccountId;
     Public boolean isJoint;
    Public string customerType;
    public ICS_CTRL_SAPCreateRelation(String accId,boolean isJointInfo,string customerTypeInfo) {
        this.AccountId = accId;
        this.isJoint = isJointInfo;
        this.customerType = customerTypeInfo;
    }
	 private String fetchBpId(String accId) {
        String bpId = null;
        SEL_Account selectorAccount = new SEL_Account();
        Account  accData = selectorAccount.selectById(accId);
        bpId = accData.ExternalCIFId__c	;

        return bpId;
    }
    public void execute(QueueableContext context) {
        switch on customerType {
            when 'Joint' {
                handleJointCustomer();
            }
            when 'Single' {
                handleSingleCustomer();
            }
        }
    }
    
    private void handleJointCustomer() {
        String bpId = fetchBpId(accountId);
        
        if (String.isNotBlank(bpId) && !isJoint) {
            createSapRelation();
            createCYT();
        }
        
        if (isJoint) {
             createSapRelation();
            createCYT();
        }
    }
    
    private void handleSingleCustomer() {
        if (!isJoint) {
            createSapRelation();
            createCYT();
        }
    }
    
    private void createSapRelation() {
          if(!test.isrunningtest()){
              
        CMN_WebserviceCallQueue__c webServiceObj=(CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService(
            'ICS_API_SAPCreateRelation',
            '',
            accountId,
            isJoint
        );
              insert webServiceObj;
          }
    }
    
    private void createCYT() {
        if(!test.isrunningtest()){
        System.enqueueJob(new ICS_CTRL_SAPCreateCYT(accountId, isJoint,customerType));
        }
    }

}