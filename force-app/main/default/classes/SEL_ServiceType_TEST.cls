/***************************************************************************************
@Name of the Component : SEL_ServiceType_TEST
@Description : Test class for SEL_ServiceType
@Author : Raymond Magezi
@Created Date : 15 October 2025
User Story: SFP-53311
@Modification description: Test class created for technical review - replace inline SOQL with selector pattern
***************************************************************************************/
@IsTest(SeeAllData=false)
private class SEL_ServiceType_TEST {

	//variable for keeping service type name for test cases
	private static final String SERVICE_TYPE_NAME = 'Test Service Type';
	//variable for keeping service type category for test cases
	private static final String SERVICE_TYPE_CATEGORY = 'Test Category';
	//variable for keeping assert error message
	private static final String SERVICE_TYPE_ERROR_MSG = 'Service type was not found';

	/**
    * @description Test method for SEL_ServiceType.selectServiceTypesWithCategories
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTypesWithCategories() {
		SVC_ServiceType__c newServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_Category__c = SERVICE_TYPE_CATEGORY,
				SVC_Active__c = true
		);
		insert newServiceType;

		Test.startTest();
		List<SVC_ServiceType__c> serviceTypes = SEL_ServiceType.newInstance().selectServiceTypesWithCategories();
		Test.stopTest();
		
		Assert.areEqual(1, serviceTypes.size(), SERVICE_TYPE_ERROR_MSG);
		Assert.areEqual(SERVICE_TYPE_CATEGORY, serviceTypes[0].SVC_Category__c, 'Category does not match');
	}

	/**
    * @description Test method for SEL_ServiceType.selectServiceTypesWithCategories with null category
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTypesWithCategoriesNullCategory() {
		SVC_ServiceType__c newServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_Category__c = null,
				SVC_Active__c = true
		);
		insert newServiceType;

		Test.startTest();
		List<SVC_ServiceType__c> serviceTypes = SEL_ServiceType.newInstance().selectServiceTypesWithCategories();
		Test.stopTest();
		
		Assert.areEqual(0, serviceTypes.size(), 'Should not return service types with null category');
	}

	/**
    * @description Test method for SEL_ServiceType.selectServiceTypePicklistOptions
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTypePicklistOptions() {
		SVC_ServiceType__c newServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_ServiceType__c = 'SVC_Complaint',
				SVC_Active__c = true
		);
		insert newServiceType;

		Test.startTest();
		List<SVC_ServiceType__c> serviceTypes = SEL_ServiceType.newInstance().selectServiceTypePicklistOptions();
		Test.stopTest();
		
		Assert.areEqual(1, serviceTypes.size(), SERVICE_TYPE_ERROR_MSG);
		Assert.areEqual('SVC_Complaint', serviceTypes[0].SVC_ServiceType__c, 'Service type picklist value does not match');
		Assert.areEqual(SERVICE_TYPE_NAME, serviceTypes[0].Name, 'Service type name does not match');
	}

	/**
    * @description Test method for SEL_ServiceType.selectServiceTypePicklistOptions with null SVC_ServiceType__c
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTypePicklistOptionsNullValue() {
		SVC_ServiceType__c newServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_ServiceType__c = null,
				SVC_Active__c = true
		);
		insert newServiceType;

		Test.startTest();
		List<SVC_ServiceType__c> serviceTypes = SEL_ServiceType.newInstance().selectServiceTypePicklistOptions();
		Test.stopTest();
		
		Assert.areEqual(0, serviceTypes.size(), 'Should not return service types with null SVC_ServiceType__c');
	}
}