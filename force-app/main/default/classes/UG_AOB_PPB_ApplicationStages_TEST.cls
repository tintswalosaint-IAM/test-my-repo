/**
* @File Name : UG_AOB_PPB_ApplicationStagesTest.cls
* @Description : Test class for UG_AOB_PPB_ApplicationStages
* @Author :
* @Last Modified By : jagadish Thummala
* @Last Modified On : 10-30-2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 21, 2025 |   | Initial Version
**/
@IsTest
public with sharing class UG_AOB_PPB_ApplicationStages_TEST {
    /**
     * Test method to verify getStageMap returns correct stage mappings
     */
    @isTest
    static void testGetStageMapSuccess() {
        // Start test context
        Test.startTest();
        
        // Call the method
        Map<String, String> stageMap = UG_AOB_PPB_ApplicationStages.getStageMap();
        
        Test.stopTest();
        
        // Assertions to verify all stage mappings
        Assert.isNotNull(stageMap, 'Stage map should not be null');
        Assert.areEqual(12, stageMap.size(), 'Stage map should contain 12 entries');
        
        // Verify each stage mapping
        Assert.areEqual('UG AOB PPB Identifii', stageMap.get('IDENTIFII'), 
                       'IDENTIFII stage should match');
        Assert.areEqual('UG AOB PPB Upload Picture', stageMap.get('UPLOAD_PICTURE'), 
                       'UPLOAD_PICTURE stage should match');
        Assert.areEqual('UG AOB PPB Address Details', stageMap.get('ADDRESS_DETAILS'), 
                       'ADDRESS_DETAILS stage should match');
        Assert.areEqual('UG AOB PPB Employment Details', stageMap.get('EMPLOYMENT_DETAILS'), 
                       'EMPLOYMENT_DETAILS stage should match');
        Assert.areEqual('UG AOB PPB Alternative Mode of Payment', stageMap.get('ALTERNATIVE_MODE_PAYMENT'), 
                       'ALTERNATIVE_MODE_PAYMENT stage should match');
        Assert.areEqual('UG AOB PPB Application Summary', stageMap.get('APPLICATION_SUMMARY'), 
                       'APPLICATION_SUMMARY stage should match');
        Assert.areEqual('UG AOB PPB CIF Created', stageMap.get('CIF_CREATED'), 
                       'CIF_CREATED stage should match');
        Assert.areEqual('UG AOB PPB OD Account Creation', stageMap.get('OD_ACCOUNT_CREATION'), 
                       'OD_ACCOUNT_CREATION stage should match');
        Assert.areEqual('UG AOB PPB QNA', stageMap.get('QNA'), 
                       'QNA stage should match');
        Assert.areEqual('UG AOB PPB Fund Account', stageMap.get('FUND_ACCOUNT'), 
                       'FUND_ACCOUNT stage should match');
        Assert.areEqual('UG AOB PPB Congratulations', stageMap.get('CONGRATULATIONS'), 
                       'CONGRATULATIONS stage should match');
        Assert.areEqual('UG AOB PPB Personal Details', stageMap.get('PERSONAL_DETAILS'), 
                       'PERSONAL_DETAILS stage should match');
    }
    
    /**
     * Test method to verify static final constants are accessible
     */
    @isTest
    static void testStaticConstants() {
        // Verify all static constants are correctly defined
        Assert.areEqual('UG AOB PPB Identifii', 
                       UG_AOB_PPB_ApplicationStages.STAGE_IDENTIFII, 
                       'STAGE_IDENTIFII constant should match');
        Assert.areEqual('UG AOB PPB Upload Picture', 
                       UG_AOB_PPB_ApplicationStages.STAGE_UPLOAD_PICTURE, 
                       'STAGE_UPLOAD_PICTURE constant should match');
        Assert.areEqual('UG AOB PPB Address Details', 
                       UG_AOB_PPB_ApplicationStages.STAGE_ADDRESS_DETAILS, 
                       'STAGE_ADDRESS_DETAILS constant should match');
        Assert.areEqual('UG AOB PPB Employment Details', 
                       UG_AOB_PPB_ApplicationStages.STAGE_EMPLOYMENT_DETAILS, 
                       'STAGE_EMPLOYMENT_DETAILS constant should match');
        Assert.areEqual('UG AOB PPB Alternative Mode of Payment', 
                       UG_AOB_PPB_ApplicationStages.STAGE_ALTERNATIVE_MODE_PAYMENT, 
                       'STAGE_ALTERNATIVE_MODE_PAYMENT constant should match');
        Assert.areEqual('UG AOB PPB Application Summary', 
                       UG_AOB_PPB_ApplicationStages.STAGE_APPLICATION_SUMMARY, 
                       'STAGE_APPLICATION_SUMMARY constant should match');
        Assert.areEqual('UG AOB PPB CIF Created', 
                       UG_AOB_PPB_ApplicationStages.STAGE_CIF_CREATED, 
                       'STAGE_CIF_CREATED constant should match');
        Assert.areEqual('UG AOB PPB OD Account Creation', 
                       UG_AOB_PPB_ApplicationStages.STAGE_OD_ACCOUNT_CREATION, 
                       'STAGE_OD_ACCOUNT_CREATION constant should match');
        Assert.areEqual('UG AOB PPB QNA', 
                       UG_AOB_PPB_ApplicationStages.STAGE_QNA, 
                       'STAGE_QNA constant should match');
        Assert.areEqual('UG AOB PPB Fund Account', 
                       UG_AOB_PPB_ApplicationStages.STAGE_FUND_ACCOUNT, 
                       'STAGE_FUND_ACCOUNT constant should match');
        Assert.areEqual('UG AOB PPB Congratulations', 
                       UG_AOB_PPB_ApplicationStages.STAGE_CONGRATULATIONS, 
                       'STAGE_CONGRATULATIONS constant should match');
    }
    
    /**
     * Test method to verify cacheable behavior of getStageMap
     * Cacheable methods should return consistent results across multiple calls
     */
    @isTest
    static void testGetStageMapCacheableBehavior() {
        Test.startTest();
        
        // Call the method multiple times
        Map<String, String> firstCall = UG_AOB_PPB_ApplicationStages.getStageMap();
        Map<String, String> secondCall = UG_AOB_PPB_ApplicationStages.getStageMap();
        
        Test.stopTest();
        
        // Verify both calls return the same data
        Assert.areEqual(firstCall.size(), secondCall.size(), 
                       'Both calls should return same size map');
        Assert.areEqual(firstCall.get('IDENTIFII'), secondCall.get('IDENTIFII'), 
                       'Both calls should return same values');
    }
}