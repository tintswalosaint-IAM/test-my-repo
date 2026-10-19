/**
 * @description Selector class for Opportunity object.
 * This class provides methods to retrieve Opportunity records.
 * @author Ofentse Sacha
 * @date May 2023
 */
public with sharing class ICS_SEL_Opportunity extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_Opportunity class.
     */
    public ICS_SEL_Opportunity() {
        super();
    }
    /**
     * @description Retrieves the SObjectType for Opportunity.
     * @return The SObjectType for Opportunity
     */
    public override Schema.SObjectType getSObjectType() {
        return Opportunity.SObjectType;
    }
    /**
     * @description Retrieves the list of SObjectFields for Opportunity.
     * @return The list of SObjectFields for Opportunity
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return Opportunity.SObjectType.getDescribe().fields.getMap().values();
    }
    /**
     * @description Retrieves an Opportunity object based on its ID
     * @param oppID The ID of the Opportunity
     * @return Opportunity object
     */ 
    public Opportunity getOpportunity(String oppID) {
        Set<Id> oppIds = new Set<Id>{ oppID };
        List<SObject> oppList = selectSObjectsById(oppIds);
        return (Opportunity)oppList.get(0);
    }

}