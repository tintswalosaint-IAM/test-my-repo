/**
 * @description       : Test class for INS_CTRL_Navigation
 * @author            : Nicholas Bezuidenhout
 * @group             : Smartenup
 * @User Story        : SFP-47617
**/
@isTest
private class INS_CTRL_Navigation_Test {

    @isTest
    static void testGetValues() {
        //Check if a valid networkId exists
        Id networkId = Network.getNetworkId();

        //Proceed with your mock data setup using the existing Network Id
        NavigationLinkSet mockNavigationLinkSet = new NavigationLinkSet(
            DeveloperName = 'TestDev',
            MasterLabel = 'Test Master Label',
            NetworkId = networkId
        );

        List<NavigationLinkSet> mockNavigationLinkSets = new List<NavigationLinkSet> {
            mockNavigationLinkSet
        };

        INS_CTRL_Navigation controller = new INS_CTRL_Navigation();
        controller.setNavigationLinkSets(mockNavigationLinkSets);
        
        Test.startTest();
        	VisualEditor.DynamicPickListRows result = controller.getValues();
        Test.stopTest();

        assert.areEqual(1, result.size());
    }

    @isTest
    static void testGetDefaultValue() {
        // Check if a valid networkId exists
        Id networkId = Network.getNetworkId();

        // Create mock NavigationLinkSet record using the existing Network Id
        NavigationLinkSet mockNavigationLinkSet = new NavigationLinkSet(
            DeveloperName = 'TestDev',
            MasterLabel = 'Test Master Label',
            NetworkId = networkId
        );

        List<NavigationLinkSet> mockNavigationLinkSets = new List<NavigationLinkSet> {
            mockNavigationLinkSet
        };

        INS_CTRL_Navigation controller = new INS_CTRL_Navigation();
        controller.setNavigationLinkSets(mockNavigationLinkSets);

        Test.startTest();
        	VisualEditor.DataRow result = controller.getDefaultValue();
        Test.stopTest();
        
        assert.areEqual('TestDev', result.getValue());
    }
    
    @isTest
    static void testGetDefaultValueCatchBlock() {
        Test.startTest();
        	INS_CTRL_Navigation controller = new INS_CTRL_Navigation();
            controller.setNavigationLinkSets(new List<NavigationLinkSet>());
        Test.stopTest();
        assert.areEqual(null, controller.getDefaultValue(), 'Expected null when no entries exist');
    }
    
    @isTest
    static void testGetValuesCatchBlock() {
        Test.startTest();
            INS_CTRL_Navigation controller = new INS_CTRL_Navigation();
            controller.setNavigationLinkSets(null);
        Test.stopTest();
        assert.areEqual(null, controller.getValues(), 'Expected null when list is null');
    }
}