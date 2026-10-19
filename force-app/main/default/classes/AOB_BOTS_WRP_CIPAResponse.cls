/**
* @description Wrapper class for CIPA Response
* @author Dayakar
*/
public class AOB_BOTS_WRP_CIPAResponse{
     
    public String name;	//IndividualDirector
	public cls_attributes attributes;
	public cls_names[] names;
	public cls_mobiles[] mobiles;
	public cls_emails[] emails;
	public cls_residentialAddresses[] residentialAddresses;
	public cls_serviceAddresses[] serviceAddresses;
	class cls_CountryAttributes {
		public String Country;	//BW
		public String SameAs;	//different
		public String Line1;	//Private Bag 278
		public String RegionCode;	//Gaborone
	}
     public class cls_NameAttributes {
		public String FirstName;
		public String FullName;
		public String LastName;
	}
     class cls_attributes {
		
	}
	class cls_names {
		public String name;	//IndividualName
		public cls_NameAttributes attributes;
	}
	class cls_mobiles {
		public String name;	//MobileAddress
		public cls_attributes attributes;
	}
	class cls_emails {
		public String name;	//EmailAddress
		public cls_attributes attributes;
	}
	class cls_residentialAddresses {
		public String name;	//ResidentialAddress
		public cls_CountryAttributes attributes;
	}
	class cls_serviceAddresses {
		public String name;	//ServiceAddress
		public cls_attributes attributes;
	}
     
    public static AOB_BOTS_WRP_CIPAResponse parse(String json){
		return (AOB_BOTS_WRP_CIPAResponse) System.JSON.deserialize(json, AOB_BOTS_WRP_CIPAResponse.class);
	}

}