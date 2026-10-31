/*------------------------------------------------------------
Author:        Given Khupai
Description:   Test class for INS_FLOW_AddBusinessHours. Verifies
               the due date matches BusinessHours.add() and that
               missing inputs return a null due date.
2026-10-16     Given Khupai       SFP-61218 Initial version

------------------------------------------------------------*/
@IsTest(SeeAllData=false)
private class INS_FLOW_AddBusinessHours_TEST {

    private static final Long FIVE_BUSINESS_DAYS_MS = 162000000L;

    private static INS_FLOW_AddBusinessHours.Request buildRequest(Id businessHoursId, DateTime startDateTime, Long milliseconds) {
        INS_FLOW_AddBusinessHours.Request request = new INS_FLOW_AddBusinessHours.Request();
        request.businessHoursId = businessHoursId;
        request.startDateTime = startDateTime;
        request.milliseconds = milliseconds;
        return request;
    }

    @IsTest
    static void addBusinessHoursMatchesBusinessHoursAddPositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        DateTime startTime = DateTime.now();

        Test.startTest();
        List<INS_FLOW_AddBusinessHours.Result> results = INS_FLOW_AddBusinessHours.addBusinessHours(
            new List<INS_FLOW_AddBusinessHours.Request>{ buildRequest(bh.Id, startTime, FIVE_BUSINESS_DAYS_MS) }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'One result per request');
        Assert.areEqual(
            BusinessHours.add(bh.Id, startTime, FIVE_BUSINESS_DAYS_MS),
            results[0].dueDateTime,
            'Due date should equal start plus the business milliseconds'
        );
        Assert.isTrue(results[0].dueDateTime > startTime, 'Due date should be after the start');
    }

    @IsTest
    static void addBusinessHoursMissingInputReturnsNullNegativeOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];

        Test.startTest();
        List<INS_FLOW_AddBusinessHours.Result> results = INS_FLOW_AddBusinessHours.addBusinessHours(
            new List<INS_FLOW_AddBusinessHours.Request>{
                buildRequest(null, DateTime.now(), FIVE_BUSINESS_DAYS_MS),
                buildRequest(bh.Id, null, FIVE_BUSINESS_DAYS_MS),
                buildRequest(bh.Id, DateTime.now(), null)
            }
        );
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'One result per request');
        for (INS_FLOW_AddBusinessHours.Result result : results) {
            Assert.isNull(result.dueDateTime, 'Due date should be null when an input is missing');
        }
    }
}