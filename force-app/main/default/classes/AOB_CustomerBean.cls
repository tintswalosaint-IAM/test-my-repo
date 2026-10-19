/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_Customer
@ Description       :BeanClass for dealing with Customer api and sending the result to the container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala.
@ Last Modified On  :15/02/2024.
@ Modification Description : SFP-31036
***************************************************************************************/
public without sharing class AOB_CustomerBean { 

	/** @description portFolioNum */
	public String portFolioNum {get;set;} 
	 /** @description EASIndicator */
	public String EASIndicator {get;set;} 
	 /** @description customerType */
	public String customerType {get;set;} 
	 /** @description personDetails */
	public PersonDetails personDetails {get;set;} 
	 /** @description orgDetails */
	public OrgDetails orgDetails {get;set;} 
	 /** @description contacts */
	public List<Contacts> contacts {get;set;} 
	 /** @description complianceRoles */
    public List<ComplianceRoles> complianceRoles {get;set;}
	 /** @description identification */
	public List<Identification> identification {get;set;} 
	 /** @description residenceCountry */
	public String residenceCountry {get;set;}
	 /** @description relManagerLink */
    public String relManagerLink {get;set;}
	 /** @description prefLanguage */
	public String prefLanguage {get;set;} 
	 /** @description prominentInfluentialPerson */
	public ProminentInfluentialPerson prominentInfluentialPerson {get;set;} 
	 /** @description employmentDetails */
	public EmploymentDetails employmentDetails {get;set;} 
	 /** @description sourceOfFunds */
	public List<SourceOfFunds> sourceOfFunds {get;set;} 
	 /** @description taxDetails */
	public List<TaxDetails> taxDetails {get;set;}
	 /** @description customerRoles */ 
	public List<CustomerRoles> customerRoles {get;set;} 
	 /** @description addresses */
	public List<Addresses> addresses {get;set;} 
	 /** @description mktgConsents */
	public List<MktgConsents> mktgConsents {get;set;} 
	 /** @description responsibleBranch */
	public String responsibleBranch {get;set;}
	 /** @description authorizationGroup */ 
	public String authorizationGroup {get;set;} 
	 /** @description industrialSectors */
	public List<IndustrialSectors> industrialSectors {get;set;}
	 /** @description taxClassification */ 
	public TaxClassification taxClassification {get;set;} 
	 /** @description permits */
	public List<Permits> permits {get;set;}
	 /** @description gIIN */ 
	public String gIIN {get;set;} 
	 /** @description mktgSegment */
	public String mktgSegment {get;set;}
	 /** @description accessOwnerSegment */
    public String accessOwnerSegment {get;set;}
	 /** @description segmentCategory */ 
	public String segmentCategory {get;set;}
	 /** @description minorIndicator */ 
    public String minorIndicator {get;set;}
	 /** @description seniorIndicator */ 
    public String seniorIndicator {get;set;} 
	 /** @description misc */
	public List<Misc> misc {get;set;}
	public RelationshipDetails relationshipDetails {get;set;} // Added relationship details
     /** @description PersonDetails is using for Customer API request body **/
    public class PersonDetails {
		 /** @description firstName */
		public String firstName {get;set;} 
		 /** @description lastName */
		public String lastName {get;set;} 
	 /** @description initials */
	 	public String initials {get;set;} 
	 /** @description otherName */
	 	public String otherName {get;set;} 
	 /** @description birthName */
	 	public String birthName {get;set;} 
	 /** @description preferredName */
	 	public String preferredName {get;set;} 
	 /** @description dob */
	 	public String dob {get;set;} 
	 /** @description gender */
	 	public String gender {get;set;} 
	 /** @description title */
	 	public String title {get;set;} 
	 /** @description maritalStatus */
	 	public String maritalStatus {get;set;} 
	 /** @description citizenshipCountry */
	 	public String citizenshipCountry {get;set;} 
	 /** @description nationality */
	 	public String nationality {get;set;} 
	 /** @description countryOfBirth */
	 	public String countryOfBirth {get;set;} 
	 /** @description ethnicity */
	 	public String ethnicity {get;set;} 
	 /** @description foreignNationalIndicator */
	 	public String foreignNationalIndicator {get;set;} 
	 /** @description foreignNationalReport */
	 	public String foreignNationalReport {get;set;} 
	 /** @description foreignNationalStatus */
	 	public String foreignNationalStatus {get;set;}
	 /** @description assetClassification */
	 	public String assetClassification {get;set;} 
	 /** @description homeOwnership */
	 	public String homeOwnership {get;set;} 
	 /** @description qualification */
	 	public String qualification {get;set;} 
	 /** @description maritalPropertyRegime */
	 	public String maritalPropertyRegime {get;set;}
      /** @description dependants */
	     public Integer dependants {get;set;}
       /** @description dependantsMinor */
	     public Integer dependantsMinor {get;set;}
        /** @description clientType */
		 public String clientType {get;set;}
		 /** @description studentIndicator */
		  public Boolean studentIndicator {get;set;} 
		/** @description studentDetails */
		public StudentDetails studentDetails {get;set;} 
        /** @description purgeAllowedIndicator */
		public String purgeAllowedIndicator {get;set;}
		/** @description digitalBankingIndicator */
		public String digitalBankingIndicator {get;set;}
	}
     /** @description StudentDetails is using for Customer API request body **/
    public class StudentDetails {
		/** @description studyYear */
		public String studyYear {get;set;} 
		/** @description Institution */
		public String Institution {get;set;} 
		/** @description courseName */
		public String courseName {get;set;} 
		/** @description commencedDate */
		public String commencedDate {get;set;} 
		/** @description expectedCompletionDate */
		public String expectedCompletionDate {get;set;} 
		/** @description enrollmentType */
		public String enrollmentType {get;set;} 
		/** @description renewalDate */
		public String renewalDate {get;set;} 
	}
     /** @description OrgDetails is using for Customer API request body **/
    public class OrgDetails {
		/** @description legalName */
		public String legalName {get;set;} 
		/** @description companyName */
		public String companyName {get;set;} 
		/** @description legalForm */
		public String legalForm {get;set;} 
		/** @description orgEstablishDt */
		public String orgEstablishDt {get;set;} 
		/** @description numEmployees */
		public Integer numEmployees {get;set;} 
		/** @description fiscalYearEnd */
		public String fiscalYearEnd {get;set;} 
		/** @description ownership */
		public String ownership {get;set;} 
	}
     /** @description Contacts is using for Customer API request body **/
    public class Contacts {
		/** @description contactType */
		public String contactType {get;set;} 
		/** @description value */
		public String value {get;set;} 
		/** @description countryCode */
		public String countryCode {get;set;} 
		/** @description extension */
		public String extension {get;set;} 
		/** @description preferredInd */
		public String preferredInd {get;set;}
        /** @description preferredFormat */
		public String preferredFormat {get;set;}
		/** @description contactPeriod */
		public String contactPeriod {get;set;} 
		/** @description obsoleteInd */
		public String obsoleteInd {get;set;} 
		/** @description phoneType */
		public String phoneType {get;set;} 
		/** @description startDate */
		public String startDate {get;set;} 
		/** @description endDate */
		public String endDate {get;set;} 
        /** @description cityCode */
		public String cityCode {get;set;} 
        /** @description localCode */
		public String localCode {get;set;} 
	}
     /** @description ComplianceRoles is using for Customer API request body **/
    public class ComplianceRoles {
		/** @description compRole */
		public String compRole {get;set;} 
		/** @description complianceGrade */
		public String complianceGrade {get;set;} 
		/** @description complianceStatus */
		public String complianceStatus {get;set;} 
        /** @description statusReason */
		public String statusReason {get;set;} 
		/** @description verifiedBy */
		public String verifiedBy {get;set;} 
	}
     /** @description Identification is using for Customer API request body **/
    public class Identification {
		/** @description identificationType */
		public String identificationType {get;set;} 
		/** @description identificationNumber */
		public String identificationNumber {get;set;} 
		/** @description issuingCountry */
		public String issuingCountry {get;set;}
        /** @description issuedOrganisation */
		public String issuedOrganisation {get;set;}
		/** @description issuedDate */
		public String issuedDate {get;set;} 
		/** @description expirationDate */
		public String expirationDate {get;set;} 
		/** @description PreferredIdentificationIndicator */
		public String PreferredIdentificationIndicator {get;set;}
        /** @description documentCode */
		public String documentCode {get;set;}
		/** @description documentDescription */
		public String documentDescription {get;set;} 
		/** @description documentTypeCode */
		public String documentTypeCode {get;set;}
		/** @description documentTypeDescription */ 
		public String documentTypeDescription {get;set;}
	}
     /** @description ProminentInfluentialPerson is using for Customer API request body **/
    public class ProminentInfluentialPerson {
		/** @description pipInd */
		public String pipInd {get;set;} 
		/** @description relatedInd */
		public String relatedInd {get;set;} 
		/** @description name */
		public String name {get;set;} 
		/** @description relationType */
		public String relationType {get;set;} 
	}
     /** @description EmploymentDetails is using for Customer API request body **/
	public class EmploymentDetails {
		/** @description orgName */
		public String orgName {get;set;} 
		/** @description employerId */
		public string employerId{get;set;}
		/** @description staffIndicator */
		public String staffIndicator {get;set;}
		/** @description startDate */ 
		public String startDate {get;set;} 
		/** @description endDate */
		public String endDate {get;set;} 
		/** @description industrialSector */
		public String industrialSector {get;set;}
		/** @description occupation */ 
		public String occupation {get;set;} 
		/** @description employmentType */
		public String employmentType {get;set;}
	}
     /** @description SourceOfFunds is using for Customer API request body **/
    public class SourceOfFunds {
		/** @description sourceFundType */
		public String sourceFundType {get;set;} 
		/** @description sourceFundAmount */
		public String sourceFundAmount {get;set;}
		/** @description currencyCode */ 
		public String currencyCode {get;set;}
		/** @description tradeFinanceIndicator */
        public String tradeFinanceIndicator {get;set;}
	}
     /** @description TaxDetails is using for Customer API request body **/
    public class TaxDetails {
		/** @description taxType */
		public String taxType {get;set;} 
		/** @description taxNumber */
		public String taxNumber {get;set;} 
		/** @description provisionalTaxPayerInd */
		public String provisionalTaxPayerInd {get;set;} 
	}
    /** @description CustomerRoles is using for Customer API request body **/      
    public class CustomerRoles {
		/** @description role */
		public String role {get;set;} 
		/** @description startDate */
		public String startDate {get;set;} 
		/** @description endDate */
		public String endDate {get;set;} 
	}
     /** @description Addresses is using for Customer API request body **/
    public class Addresses {
		/** @description uuid */
		public String uuid {get;set;} 
		/** @description addressTypes */
		public List<AddressTypes> addressTypes {get;set;} 
		/** @description line1 */
		public String line1 {get;set;} 
		/** @description line2 */
		public String line2 {get;set;} 
		/** @description line3 */
		public String line3 {get;set;} 
		/** @description city */
		public String city {get;set;} 
		/** @description province */
		public String province {get;set;} 
		/** @description postalCode */
		public String postalCode {get;set;} 
		/** @description countryCode */
		public String countryCode {get;set;} 
		/** @description preferredInd */
		public String preferredInd {get;set;} 
        /** @description preferredFormat */
		public String preferredFormat {get;set;}
		/** @description comment */
		public String comment {get;set;} 
		/** @description startDate */
		public String startDate {get;set;} 
	}
     /** @description AddressTypes is using for CustomerAlertSubscription API request body **/
    public class AddressTypes {
		/** @description addressType */
		public String addressType {get;set;} 
	}
     /** @description MktgConsents is using for CustomerAlertSubscription API request body **/
    public class MktgConsents {
		/** @description consentCode */
		public String consentCode {get;set;} 
		/** @description consentStatus */
		public Boolean consentStatus {get;set;} 
	}
	 /** @description IndustrialSectors is using for Customer API request body **/
	public class IndustrialSectors {
		/** @description industrialClassificationSystem */
		public String industrialClassificationSystem {get;set;} 
		/** @description industrialSector */
		public String industrialSector {get;set;} 
	}
     /** @description TaxClassification is using for Customer API request body **/
    public class TaxClassification {
		/** @description taxCountry */
		public String taxCountry {get;set;} 
		/** @description taxRegion */
		public String taxRegion {get;set;} 
		/** @description taxType */
		public String taxType {get;set;} 
		/** @description taxGroup */
		public String taxGroup {get;set;} 
		/** @description taxExemptReason */
		public String taxExemptReason {get;set;} 
	}
     /** @description Permits is using for Customer API request body **/
    public class Permits {
		/** @description permitType */
		public String permitType {get;set;} 
		/** @description permitNumber */
		public String permitNumber {get;set;} 
		/** @description effDt */
		public String effDt {get;set;} 
		/** @description expDt */
		public String expDt {get;set;} 
	} 
	 /** @description Misc is using for Customer API request body **/
	public class Misc {
		/** @description key */
		public String key {get;set;} 
		/** @description value */
		public String value {get;set;}
        /** @description miscDate */
		public String miscDate {get;set;} 
		/** @description counterPartyInfo */
		public String counterPartyInfo {get;set;}
        /** @description distributionChannel */
		public String distributionChannel {get;set;} 
	}
	/** @description RelationshipDetails is using for Customer API request body **/
	    public class RelationshipDetails {
		/** @description childCustId */
        public String childCustId {get;set;}
		/** @description childEntity */
        public String childEntity {get;set;}
		/** @description childEntityType */
        public String childEntityType {get;set;}
		/** @description relationship */
        public String relationship {get;set;}
		/** @description relationshipCategory */
        public String relationshipCategory {get;set;}
		/** @description guardCode */
        public String guardCode {get;set;}
		/** @description relationshipMiscInfo */
        public RelationshipMiscInfo relationshipMiscInfo {get;set;}

	}
	public class RelationshipMiscInfo {
		/** @description countryOfIssue */
        public String countryOfIssue {get;set;}
		/** @description DTDt1 */
        public String DTDt1 {get;set;}
		/** @description DTDt2 */
        public String DTDt2 {get;set;}
		/** @description Type */
        public String Type {get;set;}
    }

}