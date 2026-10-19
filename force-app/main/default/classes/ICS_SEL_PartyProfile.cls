/**
 * @description Selector class for PartyProfile object.
 * This class provides methods to retrieve PartyProfile records.
 * @author Ofentse Sacha
 * @date May 2023
 */
public with sharing class ICS_SEL_PartyProfile extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_PartyProfile class.
     */
    public ICS_SEL_PartyProfile() {
        super();
    }
    
    /**
     * @description Retrieves the SObjectType for PartyProfile.
     * @return The SObjectType for PartyProfile
     */
    public override Schema.SObjectType getSObjectType() {
        return PartyProfile.SObjectType;
    }
    
    /**
     * @description Retrieves the list of SObjectFields for PartyProfile.
     * @return The list of SObjectFields for PartyProfile
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return PartyProfile.SObjectType.getDescribe().fields.getMap().values();
    }
    
    /**
     * @description Retrieves a list of PartyProfile records associated with a given Account ID.
     * @param accID The ID of the Account
     * @return List of PartyProfile objects associated with the Account
     */
    public List<PartyProfile> getPartyProfileList(String accID) {
        Set<String> partyProfileFields = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().fields.getMap().keySet();
        List<String> fieldsInPartyProfile = new List<String>(partyProfileFields);
        
        List<PartyProfile> partyProfileList = new List<PartyProfile>();
        partyProfileList = (List<PartyProfile>)Database.query('SELECT ' + String.join(fieldsInPartyProfile, ',') + ' FROM PartyProfile WHERE AccountId = :accID');
        
        return partyProfileList;
    }


}