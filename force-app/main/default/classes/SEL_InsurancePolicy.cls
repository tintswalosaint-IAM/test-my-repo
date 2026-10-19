/**
 * @description       : Selector class for InsurancePolicy object
 * @author            : Jaco de Lange
 * @last modified on  : 11-06-2024
***************************************************
* Last Modified By Alexandr Goryachko
* Last Modified Date 07/04/2026
* Last Modified Description: Added PremiumPaymentAccountNumber__c field to selectByNameInsuredId method
* User Story : SFP-54457
***************************************************
* Last Modified By Shams
* Last Modified Date 24/07/2026
* Last Modified Description: Added a new field Product.Name
* User Story : SFP-59435
**/
public inherited sharing class SEL_InsurancePolicy extends sbgplatform.fflib_SObjectSelector {

    private static final String POLICY_NAME_PLATINUM_LIFE = '%Platinum Life%';
    private static final String POLICY_NAME_FLEXI_PROTECT = '%Flexi Protect%';

    /**
     * @description Defines the default fields to be added to all queries created ny the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'PolicyName',
        'NameInsured.CMN_CustomerBPID__pc',
        'NameInsured.CMN_IdentityNumber__pc',
        'NameInsured.LastName',
        'NameInsured.Initials__c',
        'NameInsured.RecordTypeId'
    };
    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return InsurancePolicy.SObjectType;
    }
     /**
     *
     * @description Method to get list of fields to be part of response
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            InsurancePolicy.Id,
            InsurancePolicy.Name,
            InsurancePolicy.PolicyName
        };
    }
    /**
     * @description Select all the campaigns for those campaign codes with any members for the leads
     * @param insurancePolicyId String Insurance Policy Id
     * @return List<Case>
     **/
    public List<InsurancePolicy> selectInsurancePolicyById(String insurancePolicyId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Id =:insurancePolicyId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select Insurance Policies by NameInsuredId for servicing records
     * @author Michal Orawiec
     * @date 15-10-2025
     * @param nameInsuredId String Account ID of the insured person
     * @return List<InsurancePolicy> List of Insurance Policy records
     **/
    public List<InsurancePolicy> selectByNameInsuredId(String nameInsuredId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(nameInsuredId == null){
            return new List<InsurancePolicy>();
        } else{
            fieldQueryFactory.setCondition('NameInsuredId = :nameInsuredId');
        }
        fieldQueryFactory.selectFields(new List<String>{
                'Id',
                'Name',
                'Product.Name',
                'Account_Name__c',
                'StandardPremiumAmount',
                'NameInsuredId.Name',
                'TotalSumInsured',
                'PremiumAmount',
                'Premium_Payer__c',
                'Premium_Payer__r.FirstName',
                'Premium_Payer__r.LastName',
                'Premium_Payer__r.PersonEmail',
                'Premium_Payer__r.Phone',
                'Premium_Payer__r.PersonMobilePhone',
                'Premium_Payer__r.CMN_IdentityNumber__pc',
                'Premium_Payer__r.PersonBirthdate',
                'PremiumFrequency',
                'PaymentMethod__c',
                'ProductNameFormula__c',
                'NameInsuredId',
                'SourceQuoteId',
                'PremiumPaymentAccountNumber__c',
                'CollectionDay__c'
        });
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select Insurance Policies by OwnerId
     * @author Brendon Mahwete
     * @date 06-02-2026
     * @param ownerId String User/Owner ID to filter policies
     * @return List<InsurancePolicy> List of Insurance Policy records
     **/
    public List<InsurancePolicy> selectByProducerId(String userId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        
        if(String.isBlank(userId)){
            return new List<InsurancePolicy>();
        }
        
        fieldQueryFactory.setCondition('Producer.InternalUserId = :userId');
        fieldQueryFactory.selectFields(new List<String>{
            'Id',
            'PremiumAmount',
            'Status',
            'PolicyName'
        });
        
        String query = fieldQueryFactory.toSOQL();
        return Database.query(query);
    }

    /**
     * @description Select Insurance Policies that related to on oppertunity that has the name Platinum Life or Flexi Protect and by OwnerId
     * @author Brendon Mahwete
     * @date 05-29-2026
     * @param ownerId String User/Owner ID to filter policies
     * @return List<InsurancePolicy> List of Platinum life Insurance Policy records
     **/
    public List<InsurancePolicy> selectPlatinumLifePlociesByProducerId(String userId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        
        if(String.isBlank(userId)){
            return new List<InsurancePolicy>();
        }
        
        fieldQueryFactory.setCondition('(SourceOpportunity.Name LIKE :POLICY_NAME_PLATINUM_LIFE OR SourceOpportunity.Name LIKE :POLICY_NAME_FLEXI_PROTECT) AND Producer.InternalUserId = :userId');
        fieldQueryFactory.selectFields(new List<String>{
            'Id',
            'PremiumAmount',
            'Status',
            'PolicyName'
        });
        
        String query = fieldQueryFactory.toSOQL();
        return Database.query(query);
    }

    /**
     * @description Select Insurance Policies related to a user by AccountId and ProductName
     * @author Vic Wafula
     * @date 31-07-2026
     * @param NameInsuredId and productName to filter policies
     * @return List<InsurancePolicy> List of Platinum life Insurance Policy records
     **/

    public List<InsurancePolicy> selectPoliciesByNameInsuredAndProduct(String accountId, String productName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        
        if(String.isBlank(accountId)){
            return new List<InsurancePolicy>();
        }
        
        fieldQueryFactory.setCondition('SourceOpportunity.Name LIKE :productName AND NameInsuredId = :accountId');
        fieldQueryFactory.selectFields(new List<String>{
            'Id',
            'PremiumAmount',
            'Status',
            'PolicyName',
            'NameInsuredId',
            'Product.Name',
            'ProductId'
        });
        
        String query = fieldQueryFactory.toSOQL();
        return Database.query(query);
    }

}