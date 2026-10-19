/**
 * @description       : Test class for INS_CTRL_NavigationMenuItems
 * @author            : Nicholas Bezuidenhout
 * @group             : Smartenup
 * @User Story        : SFP-47617
**/
@isTest
public class INS_CTRL_NavigationMenuItems_Test {

    @isTest
    static void testGetNavigationMenuItemsWithValidInputs() {
        // Replace with an existing NavigationLinkSet DeveloperName
        String menuName = 'Quick_Application_Navigation'; 
        String publishedState = 'Live';

        Test.startTest();
        	List<NavigationMenuItem> result = INS_CTRL_NavigationMenuItems.getNavigationMenuItems(menuName, publishedState);
        Test.stopTest();

        // Validate results
        assert.areNotEqual(result, null, 'Result should not be null.');
    }

    @isTest
    static void testGetNavigationMenuItemsWithEmptyMenuName() {
        Test.startTest();
        	List<NavigationMenuItem> result = INS_CTRL_NavigationMenuItems.getNavigationMenuItems('', 'Live');
        Test.stopTest();

        // Validate results
        assert.areNotEqual(result, null, 'Result should be null.');
        assert.areEqual(0, result.size(), 'Result should be an empty list for empty menu name.');
    }
    
    @isTest
    static void testNoNavigationLinkSetFound() {
        Test.startTest();
        	List<NavigationMenuItem> items = INS_CTRL_NavigationMenuItems.getNavigationMenuItems('DoesNotExist', 'Published');
        Test.stopTest();

        assert.areEqual(null, items, 'Should return empty list when no NavigationLinkSet found');
    }
}