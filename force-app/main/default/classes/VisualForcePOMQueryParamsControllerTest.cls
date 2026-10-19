@isTest
public class VisualForcePOMQueryParamsControllerTest {
    @isTest
    public static void ConstructorTest() {
        PageReference pageRef = Page.VisualForcePOMQueryParamsController;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('CampaignName', 'StandardBank');
        ApexPages.currentPage().getParameters().put('Dialed', '12233');
        ApexPages.currentPage().getParameters().put('First Name', 'John');
        ApexPages.currentPage().getParameters().put('Last Name', 'Smith');
        ApexPages.currentPage().getParameters().put('Phone 1', '445566');
        ApexPages.currentPage().getParameters().put('Time Zone', 'GMT+2');
        ApexPages.currentPage().getParameters().put('E-Mail', 'test@test.com');
        ApexPages.currentPage().getParameters().put('Zipcode Predefined', '160000');
        ApexPages.currentPage().getParameters().put('dnis', '01');

        VisualForcePOMQueryParamsController controller = new VisualForcePOMQueryParamsController();
        System.assertEquals(controller.campaign, 'StandardBank');
    }
}