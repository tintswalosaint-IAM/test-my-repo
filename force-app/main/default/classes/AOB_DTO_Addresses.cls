/** 
* Class for API call personal details indentification section
*
* <p></p>
*
* @author Maryem BOURHI(mbourhi @salesforce.com)
*
* @date Nov 27th 2020
*/
public class AOB_DTO_Addresses {

	public String uuid {get;set;} 
    @auraEnabled
	public List<Type_Z> type_Z;
    @auraEnabled
	public String line1 {get;set;} 
    @auraEnabled
	public String line2 {get;set;} 
    @auraEnabled
	public String line3 {get;set;} 
    @auraEnabled
	public String line4 {get;set;} 
    @auraEnabled
	public String district {get;set;} 
    @auraEnabled
	public String city {get;set;} 
    @auraEnabled
	public String province {get;set;} 
    @auraEnabled
	public String postalCode {get;set;} 
	public String countryCode {get;set;} 
	public String plotNumber {get;set;} 
	public String POBOX {get;set;} 
	public String obsoleteReason {get;set;} 
	public String preferredInd {get;set;} 
	public String comment {get;set;} 
	public String startDate {get;set;} 
	public String endDate {get;set;} 
	
    public class Type_Z {
		public String addressType;
		public String addressTypeX;
		public String startDate;
		public String endDate;
	}
	public static AOB_DTO_Addresses parse(String json) {
		return (AOB_DTO_Addresses) System.JSON.deserialize(json, AOB_DTO_Addresses.class);
	}
	


}