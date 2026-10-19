/**
*@description Selector class for Acc_Future_Funding__c object.
*This class provides methods to retrieve Acc_Future_Funding__c records.
* @author Ofentse Sacha
* @date May 2023
*/
public with sharing class ICS_SEL_AccFutureFunding extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_AccFutureFunding class.
     */
    public ICS_SEL_AccFutureFunding() {
        super();
    }
	/**
     * @description Retrieves the SObjectType for Acc_Future_Funding__c.
     * @return The SObjectType for Acc_Future_Funding__c
     */
    public override Schema.SObjectType getSObjectType() {
        return Acc_Future_Funding__c.SObjectType;
    }
	/**
     * @description Retrieves the list of SObjectFields for Acc_Future_Funding__c.
     * @return The list of SObjectFields for Acc_Future_Funding__c
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return Acc_Future_Funding__c.SObjectType.getDescribe().fields.getMap().values();
    }

    /**
     * @description Retrieves a list of Acc_Future_Funding__c records associated with a given Application ID.
     * @param appID The ID of the Application
     * @return List of Acc_Future_Funding__c objects associated with the Application
     */
    public List<Acc_Future_Funding__c> getAccFutureList(String appID) {
        return (List<Acc_Future_Funding__c>) Database.query('SELECT ' + getFieldListString() + ' FROM Acc_Future_Funding__c WHERE Application__c = :appID');
    }
}