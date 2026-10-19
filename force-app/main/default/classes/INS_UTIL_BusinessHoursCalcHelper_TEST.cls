/**
* @description       : Test class for INS_UTIL_BusinessHoursCalcHelper
* @author            : Given Khupai
* @last modified on  : 08-18-2026
* @LastModified by   : Given Khupai
* @Modification description : Updated getMetaDataTypeExceptionPositiveOutcome to
*  getMetaDataTypeExceptionThrowsAuraHandledException - getMetaDataType() now
*  rethrows AuraHandledException on failure instead of returning the default.
*  Removed hasAccessToCaseTaT() and resetCachedAccess() tests (TSR feedback) -
*  that method was removed from INS_UTIL_BusinessHoursCalcHelper as redundant
*  with the native custom-permission check driving LWC visibility.
**/
@isTest
private class INS_UTIL_BusinessHoursCalcHelper_TEST {

    // ─── calculateElapsedMilliSeconds tests ────────────────────

    @isTest
    static void calculateElapsedMilliSecondsNullBusinessHoursPositiveOutcome() {
        Test.startTest();
        Long result = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(null, DateTime.now().addHours(-1), DateTime.now());
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 when businessHoursId is null');
    }

    @isTest
    static void calculateElapsedMilliSecondsNullStartDatePositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        Test.startTest();
        Long result = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(bh.Id, null, DateTime.now());
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 when startDateTime is null');
    }

    @isTest
    static void calculateElapsedMilliSecondsNullEndDatePositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        Test.startTest();
        Long result = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(bh.Id, DateTime.now(), null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 when endDateTime is null');
    }

    @isTest
    static void calculateElapsedMilliSecondsStartAfterEndPositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        DateTime endTime = DateTime.now();
        DateTime startTime = endTime.addHours(1);
        Test.startTest();
        Long result = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(bh.Id, startTime, endTime);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 when startDateTime > endDateTime');
    }

    @isTest
    static void calculateElapsedMilliSecondsStartEqualsEndPositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        DateTime sameTime = DateTime.now();
        Test.startTest();
        Long result = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(bh.Id, sameTime, sameTime);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 when startDateTime equals endDateTime');
    }

    @isTest
    static void calculateElapsedMilliSecondsValidInputPositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        DateTime startTime = DateTime.now().addHours(-2);
        DateTime endTime = DateTime.now();
        Test.startTest();
        Long result = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(bh.Id, startTime, endTime);
        Test.stopTest();
        Assert.isTrue(result >= 0, 'Should return a non-negative millisecond value');
    }

    // ─── convertMilliSecondsToHours tests ──────────────────────

    @isTest
    static void convertMilliSecondsToHoursNullPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for null input');
    }

    @isTest
    static void convertMilliSecondsToHoursZeroPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(0);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for zero input');
    }

    @isTest
    static void convertMilliSecondsToHoursNegativePositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(-5000L);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for negative input');
    }

    @isTest
    static void convertMilliSecondsToHoursValidPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(7200000L);
        Test.stopTest();
        Assert.areEqual(2, result, 'Should return 2 hours');
    }

    // ─── convertMilliSecondsToMinutes tests ────────────────────

    @isTest
    static void convertMilliSecondsToMinutesNullPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToMinutes(null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for null input');
    }

    @isTest
    static void convertMilliSecondsToMinutesZeroPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToMinutes(0);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for zero input');
    }

    @isTest
    static void convertMilliSecondsToMinutesNegativePositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToMinutes(-5000L);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for negative input');
    }

    @isTest
    static void convertMilliSecondsToMinutesValidPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToMinutes(5400000L);
        Test.stopTest();
        Assert.areEqual(30, result, 'Should return 30 remaining minutes');
    }

    // ─── convertMilliSecondsToSeconds tests ────────────────────

    @isTest
    static void convertMilliSecondsToSecondsNullPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToSeconds(null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for null input');
    }

    @isTest
    static void convertMilliSecondsToSecondsZeroPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToSeconds(0);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for zero input');
    }

    @isTest
    static void convertMilliSecondsToSecondsNegativePositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToSeconds(-5000L);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for negative input');
    }

    @isTest
    static void convertMilliSecondsToSecondsValidPositiveOutcome() {
        Test.startTest();
        Decimal result = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToSeconds(105000L);
        Test.stopTest();
        Assert.areEqual(45, result, 'Should return 45 remaining seconds');
    }

    // ─── calculateSlaMetrics tests ─────────────────────────────

    @isTest
    static void calculateSlaMetricsValidPositiveOutcome() {
        Long input = 9045000L;
        Test.startTest();
        INS_UTIL_BusinessHoursCalcHelper.SlaMetricsInBusinessHours sla = INS_UTIL_BusinessHoursCalcHelper.calculateSlaMetrics(input);
        Test.stopTest();
        Assert.areEqual(input, sla.elapsedTimeMilliSeconds, 'Milliseconds should match input');
        Assert.areEqual(2, sla.elapsedTimeInHours, 'Should be 2 hours');
        Assert.areEqual(30, sla.elapsedTimeInMinutes, 'Should be 30 minutes');
        Assert.areEqual(45, sla.elapsedTimeInSeconds, 'Should be 45 seconds');
        Assert.areEqual('2 hrs 30 mins 45 secs.', sla.printFormattedTAT, 'Formatted TAT should match');
    }

    @isTest
    static void calculateSlaMetricsZeroPositiveOutcome() {
        Test.startTest();
        INS_UTIL_BusinessHoursCalcHelper.SlaMetricsInBusinessHours sla = INS_UTIL_BusinessHoursCalcHelper.calculateSlaMetrics(0);
        Test.stopTest();
        Assert.areEqual(0, sla.elapsedTimeInHours, 'Should be 0 hours');
        Assert.areEqual(0, sla.elapsedTimeInMinutes, 'Should be 0 minutes');
        Assert.areEqual(0, sla.elapsedTimeInSeconds, 'Should be 0 seconds');
    }

    @isTest
    static void calculateSlaMetricsNullPositiveOutcome() {
        Test.startTest();
        INS_UTIL_BusinessHoursCalcHelper.SlaMetricsInBusinessHours sla = INS_UTIL_BusinessHoursCalcHelper.calculateSlaMetrics(null);
        Test.stopTest();
        Assert.areEqual(null, sla.elapsedTimeMilliSeconds, 'Milliseconds should be null');
        Assert.areEqual(0, sla.elapsedTimeInHours, 'Should be 0 hours');
        Assert.areEqual(0, sla.elapsedTimeInMinutes, 'Should be 0 minutes');
        Assert.areEqual(0, sla.elapsedTimeInSeconds, 'Should be 0 seconds');
    }

    // ─── printTATInBusinessHours tests ─────────────────────────

    @isTest
    static void printTATInBusinessHoursValidPositiveOutcome() {
        Test.startTest();
        String result = INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(4200000L);
        Test.stopTest();
        Assert.areEqual('1 hrs 10 mins 0 secs.', result, 'Formatted TAT should match');
    }

    @isTest
    static void printTATInBusinessHoursZeroPositiveOutcome() {
        Test.startTest();
        String result = INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(0);
        Test.stopTest();
        Assert.areEqual('0 hrs 0 mins 0 secs.', result, 'Should return all zeros');
    }

    // ─── getMetaDataType tests ─────────────────────────────────

    @isTest
    static void getMetaDataTypeMockCmdtMissingPositiveOutcome() {
        INS_UTIL_BusinessHoursCalcHelper.mockCmdtMissing = true;
        Test.startTest();
        Integer result = INS_UTIL_BusinessHoursCalcHelper.getMetaDataType();
        Test.stopTest();
        Assert.areEqual(5000, result, 'Should return default 5000 when CMDT is missing');
    }

    @isTest
    static void getMetaDataTypeValidPositiveOutcome() {
        INS_UTIL_BusinessHoursCalcHelper.mockCmdtMissing = false;
        INS_UTIL_BusinessHoursCalcHelper.mockForceCmdtException = false;
        Test.startTest();
        Integer result = INS_UTIL_BusinessHoursCalcHelper.getMetaDataType();
        Test.stopTest();
        Assert.isTrue(result > 0, 'Should return a positive frequency value');
    }

    @isTest
    static void getMetaDataTypeExceptionThrowsAuraHandledException() {
        INS_UTIL_BusinessHoursCalcHelper.mockForceCmdtException = true;
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            INS_UTIL_BusinessHoursCalcHelper.getMetaDataType();
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            Assert.areEqual('Unable to determine TAT refresh polling frequency. Please contact your system administrator.', ex.getMessage(), 'Should return the sanitized error message');
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException when CMDT lookup fails');
    }
}