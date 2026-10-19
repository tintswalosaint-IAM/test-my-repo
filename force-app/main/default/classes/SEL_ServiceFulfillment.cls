/**
* @description       : Selector Class for Service Fulfillments
* @author            : Karabo Machubeni
* @last modified on  : 05-04-2025
* @last modified by  : Agisanang Shole
					   added a selector method to query service fulfillments with process instance and steps
* @last modified on            : 12-03-2026
* @last modified by            : Vikash Beersye
* @modification description    : [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
* @last modified by Vikash Beersye - SFP-58345 : HOTFIX - Salesforce VT
* @last modified date 2026/05/15
**/

public inherited sharing class SEL_ServiceFulfillment extends sbgplatform.fflib_SObjectSelector {
    
    private static Set<String> fields = new Set<String>{
        'Account__r.Name',
        'Account__r.Salutation',
        'Amount__c',
        'BeneficiaryAccountBank__c',
        'BeneficiaryAccountName__c',
        'BeneficiaryAccountNumber__c',
        'Case__c',
        'Case__r.CaseNumber',
        'Case__r.WI_Retro__c',
        'CreatedById',
        'CreatedBy.Name',
        'CreatedDate',
        'CurrencyIsoCode',
        'Debit_Account_Number__c',
        'DebitAccount__c',
        'EIP_Included__c',
        'Id',
        'WI_Parent_Service_Fulfillment__c',
        'LastModifiedById',
        'LastModifiedDate',
        'Manager__c',
        'Name',
        'NarrativeCreditAccount__c',
        'NarrativeDebitAccount__c',
        'OwnerId',
        'Owner.Email',
        'Risk_Rating__c',
        'Status__c',
        'SVC_CreditAccountNumber__c',
        'SVC_DebitAccountNumber__c',
        'SVC_MerchantName__c',
        'SVC_MotivationForSettlement__c',
        'SVC_ReasonForDispute__c',
        'SVC_RefundRequestDate__c',
        'SVC_SettlementDate__c',
        'SVC_StatementFromDate__c',
        'SVC_StatementToDate__c',
        'SVC_TransactionDate__c',
        'SystemModstamp',
        'Temp_Source_Id__c',
        'UrgentOrNormal__c',
        'WI_Parent_Service_Fulfillment__c'
        
    };

    private List<String> getProcessStepFields(){
    return new List<String>{
        'Id',
        'StepStatus',
        'ProcessInstanceId',
        'CreatedDate',
        'Actor.Name'
    };
}
    
    private List<String> getProcessInstanceFields(){
        return new List<String>{
            'Id',
            'SubmittedById'
        };
    }

    private List<String> getServiceFulfillmentHistoryFields(){
        return new List<String>{
            'Id',
            'NewValue',
            'OldValue',
            'ParentId',
            'Parent.CreatedById',
            'Field'
       
        };
    }
    
    /**
    * @description Implementation method for Service Fulfillment Object as part of fflib framweork
    * @author Karabo Machubeni| 19-05-2024
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return ServiceFulfillment__c.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Karabo Machubeni| 19-05-2024
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        
        return new List<Schema.SObjectField> {
            ServiceFulfillment__c.Account__c,
            ServiceFulfillment__c.Account__r.Name,
            ServiceFulfillment__c.Amount__c,
            ServiceFulfillment__c.BeneficiaryAccountBank__c,
            ServiceFulfillment__c.BeneficiaryAccountName__c,
            ServiceFulfillment__c.BeneficiaryAccountNumber__c,
            ServiceFulfillment__c.Case__c,
            ServiceFulfillment__c.CreatedById,
            ServiceFulfillment__c.CreatedDate,
            ServiceFulfillment__c.CurrencyIsoCode,
            ServiceFulfillment__c.Debit_Account_Number__c,
            ServiceFulfillment__c.DebitAccount__c,
            ServiceFulfillment__c.EIP_Included__c,
            ServiceFulfillment__c.Id,
            ServiceFulfillment__c.WI_Parent_Service_Fulfillment__c,
            ServiceFulfillment__c.LastModifiedById,
            ServiceFulfillment__c.LastModifiedDate,
            ServiceFulfillment__c.Manager__c,
            ServiceFulfillment__c.Name,
            ServiceFulfillment__c.NarrativeCreditAccount__c,
            ServiceFulfillment__c.NarrativeDebitAccount__c,
            ServiceFulfillment__c.OwnerId,
            ServiceFulfillment__c.Risk_Rating__c,
            ServiceFulfillment__c.Status__c,
            ServiceFulfillment__c.SVC_CreditAccountNumber__c,
            ServiceFulfillment__c.SVC_DebitAccountNumber__c,
            ServiceFulfillment__c.SVC_MerchantName__c,
            ServiceFulfillment__c.SVC_MotivationForSettlement__c,
            ServiceFulfillment__c.SVC_ReasonForDispute__c,
            ServiceFulfillment__c.SVC_RefundRequestDate__c,
            ServiceFulfillment__c.SVC_SettlementDate__c,
            ServiceFulfillment__c.SVC_StatementFromDate__c,
            ServiceFulfillment__c.SVC_StatementToDate__c,
            ServiceFulfillment__c.SVC_TransactionDate__c,
            ServiceFulfillment__c.SystemModstamp,
            ServiceFulfillment__c.Temp_Source_Id__c,
            ServiceFulfillment__c.UrgentOrNormal__c,
            ServiceFulfillment__c.WI_Parent_Service_Fulfillment__c
        };
            

    }
    
    /**
    * Method to fetch list of Service Fulfillements based on Status
    *
    * @return List<ServiceFulfillment__c>
    */
    public List<ServiceFulfillment__c> getServiceFulfillmentsByStatus(String status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Status__c = :status');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.selectField('Case__r.Owner.Email'); //added polymorphic field here as cannot add in theSchema.SObjectField
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description get Service Fulfillments with associated ProcessInstanceHistory records based on status.
    * @author Mbuyiseni Mbhokane | 07-16-2024 
    * @param status 
    * @return List<ServiceFulfillment__c> 
    **/
    public List<ServiceFulfillment__c> getServiceFulfillmentsWithProcessInstanceByStatus(String status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Status__c = :status');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.selectField('Case__r.Owner.Email'); //added polymorphic field here as cannot add in theSchema.SObjectField
        sbgplatform.fflib_QueryFactory childQuery = fieldQueryFactory.subselectQuery(
            this.getChildRelationship(
                this.getSObjectType(),
                ProcessInstanceHistory.SObjectType
            )
        );
        childQuery.selectFields(this.getProcessStepFields());
        System.debug('@@VB Here  =>' + fieldQueryFactory.toSOQL());
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    

    /**
    * @description get service fulfillments with history records based on record ids.
    * @author Mbuyiseni Mbhokane | 07-24-2024 
    * @param recIds 
    * @return List<ServiceFulfillment__c> 
    **/
    public List<ServiceFulfillment__c> getServiceFulfillmentsWithHistoriesById(Set<Id> recIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN: recIds');
        fieldQueryFactory.selectFields(fields);
        sbgplatform.fflib_QueryFactory childQuery = fieldQueryFactory.subselectQuery(
            this.getChildRelationship(
                this.getSObjectType(),
                ServiceFulfillment__History.SObjectType
            )
        );
        childQuery.setCondition('Field != \'created\' AND Field != \'Locked\'');
        childQuery.selectFields(this.getServiceFulfillmentHistoryFields());
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description parent child relationship
    * @author Mbuyiseni Mbhokane | 07-16-2024 
    * @param parentObject 
    * @param childObject 
    * @return Schema.ChildRelationship 
    **/
    private Schema.ChildRelationship getChildRelationship(
            SObjectType parentObject,
            SObjectType childObject
    ) {
        Schema.ChildRelationship childRelation;
        for (
                Schema.ChildRelationship child :
                parentObject.getDescribe().getChildRelationships()
        ) {
            if (child.getChildSObject() == childObject && child.getRelationshipName() != null) {
                childRelation = child;
                break;
            }
        }
        return childRelation;
    }
    
    /**
    * @description get Service Fulfillments with associated ProcessInstance and ProcessInstanceHistory records.
    * @author Agisanang Shole | 05-04-2025 
    * @param serviceFulfillmentIds 
    * @return List<ServiceFulfillment__c> 
    **/
    public List<ServiceFulfillment__c> getServiceFulfillmentsWithProcessInstanceAndSteps(Set<Id> serviceFulfillmentIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN :serviceFulfillmentIds');
        fieldQueryFactory.selectFields(fields);
        sbgplatform.fflib_QueryFactory stepsChildQuery = fieldQueryFactory.subselectQuery(
            this.getChildRelationship(
                this.getSObjectType(),
                ProcessInstanceHistory.SObjectType
            )
        );
        
        sbgplatform.fflib_QueryFactory instanceChildQuery = fieldQueryFactory.subselectQuery(
            this.getChildRelationship(
                this.getSObjectType(),
                ProcessInstance.SObjectType
            )
        );
        stepsChildQuery.selectFields(this.getProcessStepFields());
        instanceChildQuery.selectFields(this.getProcessInstanceFields());
        return Database.query(fieldQueryFactory.toSOQL());
    }
}