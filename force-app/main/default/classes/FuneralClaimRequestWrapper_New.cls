/**
 *  @description wrapper class  FuneralClaimRequestWrapper_New for INS_Funeral_Claims.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * 
 *
 * @date Feb 19th 2024
 */
public class FuneralClaimRequestWrapper_New {
    public FuneralFNOLRequest FuneralFNOLRequest {get;set;}
	 /**
     * @description Class TelephonicAddress.
     *
     * 
     */
    public class TelephonicAddress{
		public String PhoneNumber {get;set;}
		public String PhoneType {get;set;}
	}
     /**
     * @description Class RelatedPartyReference.
     *
     * 
     */
	public class RelatedPartyReference {
		public String PartyType {get;set;}
		public list<PartyName> PartyName {get;set;}
		public list<PartyContactPoint> PartyContactPoint {get;set;}
		public String Salutation {get;set;}
	}
     /**
     * @description Class RelatedPartyIdentification.
     *
     * 
     */
	public class RelatedPartyIdentification {
		public String PartyIdentifierValue {get;set;}
		public String PartyIdentificationType {get;set;}
	}
     /**
     * @description Class Reference.
     *
     * 
     */
	public class Reference {
		public list<PartyName> PartyName {get;set;}
		public String Salutation {get;set;}
		public String PartyType {get;set;}
	}
     /**
     * @description Class PersonReference.
     *
     * 
     */
	public class PersonReference {
		public String DeathCauseType {get;set;}
		public String BirthDate {get;set;}
		public String Gender {get;set;}
		public String DeathDate {get;set;}
		public String DeathCircumstanceType {get;set;}
	}
     /**
     * @description Class PartyUniqueIdentification.
     *
     * 
     */
	public class PartyUniqueIdentification {
		public String PartyIdentifierValue {get;set;}
		public String PartyIdentificationType {get;set;}
	}
     /**
     * @description Class PartyRelationship.
     *
     * 
     */
	public class PartyRelationship {
		public String PartyRelationshipType{get;set;}
	}
     /**
     * @description Class PartyName.
     *
     * 
     */
	public class PartyName {
		public String PartyNameValue{get;set;}
		public String PartyNameType{get;set;}
	}
    /**
     * @description Class PartyContactPoint.
     *
     * 
     */
	public class PartyContactPoint {
		public ContactPointUsage ContactPointUsage{get;set;}
		public ContactPoint ContactPoint{get;set;}
	}
    /**
     * @description Calss FuneralFNOLRequest.
     *
     * 
     */
	public class FuneralFNOLRequest {
		public Reference Reference {get;set;}
		public list<DirectoryEntryDateTime> DirectoryEntryDateTime {get;set;}
		public PartyUniqueIdentification PartyUniqueIdentification {get;set;}
		public PersonReference PersonReference {get;set;}
		public list<ClaimIdentification> ClaimIdentification {get;set;}
		public list<Associations> Associations {get;set;}
		public ClaimDisclosure ClaimDisclosure {get;set;}
	}
    /**
     * @description Class DirectoryEntryDateTime.
     *
     * 
     */
	public class DirectoryEntryDateTime {
		public String DirectoryEntryDateType {get;set;}
		public String DirectoryEntryDateTime {get;set;}
	}
    /**
     * @description Class ContactPointUsage.
     *
     * 
     */
	public class ContactPointUsage {
		public String ContactPointUsageType {get;set;}
	}
    /**
     * @description Calss ContactPoint.
     *
     * 
     */
	public class ContactPoint {
		public TelephonicAddress TelephonicAddress {get;set;}
	}
    /**
     * @description Calss ClaimIdentification.
     *
     * 
     */
	public class ClaimIdentification{
		public String BenefitUniqueIdentifier{get;set;}
		public String ExternalPolicyNumber{get;set;}
		public String PolicyNumber{get;set;}
	}
    /**
     * @description class ClaimDisclosure.
     *
     * 
     */
	public class ClaimDisclosure {
		public String Channel {get;set;}
		public String CreatedBy {get;set;}
		public Boolean Proceed {get;set;}
	}
    /**
     * @description class Associations.
     *
     * 
     */
	public class Associations {
		public PartyRelationship PartyRelationship {get;set;}
		public RelatedPartyReference RelatedPartyReference {get;set;}
		public RelatedPartyIdentification RelatedPartyIdentification {get;set;}
	}
}