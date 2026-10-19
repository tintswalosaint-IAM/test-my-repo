/*------------------------------------------------------------
Author:        Kenneth Dlamini
Company:       Salesforce
Description:   SFP-46473 Computes elapsed time between two dates in business
               hours. Provides utility methods for TAT calculation,
               formatting, permission checks and CMDT polling config.
Test Class:    INS_UTIL_BusinessHoursCalcHelper_TEST
2025-04-25     Kenneth Dlamini    Initial version
2026-05-27     Given Khupai       SSFP-55625 Added 
                                  service for Case Milestone Metrics
------------------------------------------------------------*/
public with sharing class INS_UTIL_BusinessHoursCalcHelper {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_UTIL_BusinessHoursCalcHelper');
    private static final String LOG_AREA = 'Business Hours Calculator';
    private static final Long MILLIS_PER_HOUR   = 3600000L;
    private static final Long MILLIS_PER_MINUTE = 60000L;
    private static final Long MILLIS_PER_SECOND = 1000L;
    private static final String GENERIC_METADATA_ERROR_MESSAGE = 'Unable to determine TAT refresh polling frequency. Please contact your system administrator.';

    @TestVisible
    private static Boolean mockCmdtMissing = false;
    @TestVisible
    private static Boolean mockForceCmdtException = false;

    public static Long calculateElapsedMilliSeconds(Id businessHoursId, DateTime startDateTime, DateTime endDateTime) {
        if (businessHoursId == null || startDateTime == null || endDateTime == null) {
            return 0;
        }
        if (startDateTime >= endDateTime) {
            return 0;
        }
        Long milliseconds = BusinessHours.diff(businessHoursId, startDateTime, endDateTime);
        if (milliseconds == null) {
            return 0;
        }
        return milliseconds;
    }

    public static Decimal convertMilliSecondsToHours(Long milliSeconds) {
        if (milliSeconds == null || milliSeconds <= 0) {
            return 0;
        }
        return Math.floor(milliSeconds / MILLIS_PER_HOUR);
    }

    public static Decimal convertMilliSecondsToMinutes(Long milliSeconds) {
        if (milliSeconds == null || milliSeconds <= 0) {
            return 0;
        }
        return Math.floor((Math.mod(milliSeconds, MILLIS_PER_HOUR)) / MILLIS_PER_MINUTE);
    }

    public static Decimal convertMilliSecondsToSeconds(Long milliSeconds) {
        if (milliSeconds == null || milliSeconds <= 0) {
            return 0;
        }
        return Math.floor((Math.mod(milliSeconds, MILLIS_PER_MINUTE)) / MILLIS_PER_SECOND);
    }

    public static SlaMetricsInBusinessHours calculateSlaMetrics(Long milliSeconds) {
        SlaMetricsInBusinessHours sla = new SlaMetricsInBusinessHours();
        sla.elapsedTimeMilliSeconds = milliSeconds;
        sla.elapsedTimeInHours = Integer.valueOf(convertMilliSecondsToHours(milliSeconds));
        sla.elapsedTimeInMinutes = Integer.valueOf(convertMilliSecondsToMinutes(milliSeconds));
        sla.elapsedTimeInSeconds = Integer.valueOf(convertMilliSecondsToSeconds(milliSeconds));
        sla.printFormattedTAT = sla.elapsedTimeInHours + ' hrs ' + sla.elapsedTimeInMinutes + ' mins ' + sla.elapsedTimeInSeconds + ' secs.';
        return sla;
    }

    public static String printTATInBusinessHours(Long milliSeconds) {
        return calculateSlaMetrics(milliSeconds).printFormattedTAT;
    }

    /**
     * Returns the configured polling frequency (seconds) for TAT refresh,
     * sourced from SVC_TAT_Business_Hours_Setting__mdt.
     *
     * NOTE: Any exception is logged via rflib_Logger for diagnostics and
     * rethrown as a sanitized AuraHandledException so the client can
     * distinguish a failed lookup from a successful one.
     */
    @AuraEnabled(cacheable=true)
    public static Integer getMetaDataType() {
        Integer repeatFrequencyInSeconds = 5000;
        if (Test.isRunningTest() && mockCmdtMissing) {
            return repeatFrequencyInSeconds;
        }
        try {
            if (Test.isRunningTest() && mockForceCmdtException) {
                throw new AuraHandledException('Mock CMDT exception for test coverage');
            }
            SVC_TAT_Business_Hours_Setting__mdt setting = SVC_TAT_Business_Hours_Setting__mdt.getInstance('Repeat_Process_Frequency');
            if (setting != null && setting.Repeat_Elapsed_Time_Frequency_In_Seconds__c != null) {
                repeatFrequencyInSeconds = setting.Repeat_Elapsed_Time_Frequency_In_Seconds__c.intValue();
            }
        } catch (Exception ex) {
            LOGGER.error('getMetaDataType() failed, Error={0}', LOG_AREA, new List<Object>{ ex.getMessage() }, ex);
            AuraHandledException auraEx = new AuraHandledException(GENERIC_METADATA_ERROR_MESSAGE);
            auraEx.initCause(ex);
            auraEx.setMessage(GENERIC_METADATA_ERROR_MESSAGE);
            throw auraEx;
        }
        return repeatFrequencyInSeconds;
    }

    public class SlaMetricsInBusinessHours {
        @AuraEnabled public Long elapsedTimeMilliSeconds { get; set; }
        @AuraEnabled public Decimal elapsedTimeInHours { get; set; }
        @AuraEnabled public Decimal elapsedTimeInMinutes { get; set; }
        @AuraEnabled public Decimal elapsedTimeInSeconds { get; set; }
        @AuraEnabled public String printFormattedTAT { get; set; }
    }
}