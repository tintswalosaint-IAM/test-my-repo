/**
* @description       : SFP-54443 - Controller class for the Product picklist values in the Leads flow.
* @author            : Facu
* @group             : Standard Bank
* @last modified on  : 20-07-2026
* @last modified by  : Raja Arsalan
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   01-12-2022   Facu             Initial Version
*
* 2.0   20-07-2026   Raja Arsalan     Updated the test methods to have assert.equals
									  and added a new method getAvailableProducts_BlankInputs.
**/

@IsTest(SeeAllData = false)
public class Leads_CTRL_Products_TEST {
    
    private static Leads_ProductQueueAllocation__c prod;
    
    
    /**
* @description Creates test data required for product-related test scenarios.
*/	
    @TestSetup
    public static void setupScenario() {
        
        prod = new Leads_ProductQueueAllocation__c();
        prod.Active__c = true;
        prod.Leads_Jurisdiction__c = 'South Africa';
        prod.Leads_Product_Segment__c = 'Personal';
        prod.Leads_Product_Name__c = 'test prod';
        
        insert prod;
    }
    
    /**
* @description Verifies that the available jurisdiction
* 				picklist values are returned successfully.
*/
    @IsTest
    static void getJurisdiction() {
        
        Test.startTest();
        
        List<INS_SRV_Products.INS_DTO_ProductResponse> res =
            Leads_CTRL_Products.getAvailableValuesinPickList('jurisdiction');
        
        Test.stopTest();
        
        Assert.areNotEqual(null, res, 'No Jurisdiction Values');
    }
    
    /**
* @description Verifies that the available segment picklist
* 				values are returned successfully.
*/
    @IsTest
    static void getSegment() {
        
        Test.startTest();
        
        List<INS_SRV_Products.INS_DTO_ProductResponse> res =
            Leads_CTRL_Products.getAvailableValuesinPickList('segment');
        
        Test.stopTest();
        
        Assert.areNotEqual(null, res, 'No Segment Values');
    }
    
    /**
* @description Verifies that available products are returned
* 				for a valid jurisdiction and segment.
*/    
    @IsTest
    static void getProduct() {
        
        Test.startTest();
        
        List<INS_SRV_Products.INS_DTO_ProductResponse> res =
            Leads_CTRL_Products.getAvailableProducts(
                'South Africa',
                'Personal'
            );
        
        Test.stopTest();
        
        Assert.areNotEqual(null, res, 'Product should be returned');
    }
    
    /**
* @description Verifies that no products are returned
* 				for an invalid product segment.
*/	
    @IsTest
    static void getEmptyProduct() {
        
        Test.startTest();
        
        List<INS_SRV_Products.INS_DTO_ProductResponse> res =
            Leads_CTRL_Products.getAvailableProducts(
                'South Africa',
                'xxx'
            );
        
        Test.stopTest();
        
        Assert.areEqual(0, res.size(), 'Product should not be returned');
    }
    /**
* @description Verifies that an empty list is returned when an invalid picklist field name is provided.
*/
    @IsTest
    static void getValuesForInvalidPickList() {
        
        Test.startTest();
        
        List<INS_SRV_Products.INS_DTO_ProductResponse> res =
            Leads_CTRL_Products.getAvailableValuesinPickList('InvalidField');
        
        Test.stopTest();
        
        Assert.areNotEqual(null, res, 'Response should not be null');
        Assert.areEqual(0, res.size(), 'An invalid field name should return an empty list');
    }
    
    /**
* @description Verifies that an empty list is returned when both jurisdiction and segment are blank.
*/
    @IsTest
    static void getAvailableProducts_BlankInputs() {
        
        Test.startTest();
        
        List<INS_SRV_Products.INS_DTO_ProductResponse> res =
            Leads_CTRL_Products.getAvailableProducts('', '');
        
        Test.stopTest();
        
        Assert.areNotEqual(null, res, 'Response should not be null');
        Assert.areEqual(0, res.size(),
                            'An empty list should be returned when both inputs are blank.');
    }
    
}