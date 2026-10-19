/**
 * @Name of the Class : ICS_ContactForm_Controller.cls
 * @description: class used as controller to pull the data into PDF
 * @Author Ikyatha Naidu 
 * @Date 01/06/2024 
 * @Last Modified On  : 25/08/2024 
 * @Last Modified By  : Ikyatha Naidu
 * @Modification Description : Initial Version
 */
public class ICS_ContactForm_Controller {
     public ICS_ContactForm_Controller() {
        initializeAddressFields();
    }
     public List<AddressField> addressFields { get; set; }
    private void initializeAddressFields() {
        addressFields = new List<AddressField>{
            new AddressField('Apartment No., Building Name etc.', componentApartmentNo),
            new AddressField('Street address, Close. etc.', componentStreetAddress),
            new AddressField('Second street address (if required)', componentSecondStreetAddress),
            new AddressField('Town, Parish, Region, County etc.', componentTown),
            new AddressField('Country', componentCountry),
            new AddressField('Province/State', componentState),
            new AddressField('Postcode', componentPostCode)
        };
    }

    public class AddressField {
        public String label { get; set; }
        public String value { get; set; }

        public AddressField(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    //Contact Details
     	public String componentEmail { get; set; }
     	public String  componentAlterPhone{ get; set; }
     	public String componentPhone { get; set; }
    //ResidentialAddress
        public String  componentApartmentNo { get;set; }
        public String componentStreetAddress { get;set; }
    	public String componentSecondStreetAddress { get;set; }
        public String componentTown { get;set; }
        public String componentCountry { get;set; }
        public String componentState { get;set; }
        public String componentPostCode { get;set; }
        public String componentDate { get;set; }
    	public String componentTime { get;set; }
    //PreviousResidentialAddress
        public String componentPrevApartmentNo {get;set;}
        public String componentPrevStreetAddress { get;set; }
    	public String componentPrevSecondStreetAddress { get;set; }
        public String componentPrevTown { get;set; }
        public String componentPrevCountry { get;set; }
        public String componentPrevState { get;set; }
        public String componentPrevPostCode { get;set; }
        public String componentPrevDate { get;set; }
    	public String componentPrevTime { get;set; }
    //CorrespodanceAddress
        public String componentCorresAddrSameResidentialAddr {get;set;}
        public String componentCorresApartmentNo{get;set;}
    	public String componentCorresStreetAddress{get;set;}
        public String componentCorresSecondStreetAddress{get;set;}
        public String componentCorresTown{get;set;}
        public String componentCorresCountry{get;set;}
        public String componentCorresState{get;set;}
        public String componentCorresPostCode{get;set;}
        public String componentCorresReltnShipCorresAddr{get;set;}
}