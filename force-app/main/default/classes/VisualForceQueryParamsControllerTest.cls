@isTest
public class VisualForceQueryParamsControllerTest {
    @isTest
    public static void ConstructorTest() {
        PageReference pageRef = Page.VisualForceQueryParamsController;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ANI', '1');
        ApexPages.currentPage().getParameters().put('DNIS', '2');
        ApexPages.currentPage().getParameters().put('UUI', '3');
        ApexPages.currentPage().getParameters().put('UCID', '4');
        ApexPages.currentPage().getParameters().put('Queue', '5');

        VisualForceQueryParamsController controller = new VisualForceQueryParamsController();
        System.assertEquals(controller.ani, '1');
    }
}