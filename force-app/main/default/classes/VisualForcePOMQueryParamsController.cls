global class VisualForcePOMQueryParamsController {
    public String campaign {get; private set;}
    public String dialedNumber{get; private set;}
    public String firstName {get; private set;}
    public String lastName {get; private set;}
    public String phone {get; private set;}
    public String timeZone {get; private set;}
    public String email {get; private set;}
    public String zipCode {get; private set;}
    public String dnis {get; private set;}
    public VisualForcePOMQueryParamsController() {
        campaign = 
ApexPages.currentPage().getParameters().get('CampaignName');
        dialedNumber = 
ApexPages.currentPage().getParameters().get('Dialed');
        firstName = 
ApexPages.currentPage().getParameters().get('First Name');
        lastName = 
ApexPages.currentPage().getParameters().get('Last Name');
        phone = 
ApexPages.currentPage().getParameters().get('Phone 1');
        timeZone = 
ApexPages.currentPage().getParameters().get('Time Zone');
        email = 
ApexPages.currentPage().getParameters().get('E-Mail');
        zipCode = 
ApexPages.currentPage().getParameters().get('Zipcode Predefined');
        dnis = 
ApexPages.currentPage().getParameters().get('dnis');
    }
}