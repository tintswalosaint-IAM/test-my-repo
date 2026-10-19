/*------------------------------------------------------------
Author:        Kenneth Dlamini
Company:       Salesforce
Description:   AuraEnabled controller — exposes business-hours
               elapsed-time methods (hours, minutes, seconds),
               SLA metrics calculation, and Case/Metric retrieval
               to LWC components.
Test Class:    INS_CTRL_CaseElapsedTimeInBusinessHours_TEST
2025-05-08     Kenneth Dlamini    Initial version
2026-06-17     Given Khupai       SFP-50794 Added permission selector
                                  and Case Milestone Metrics service
2026-07-16     Given Khupai       SFP-55625 Added mock exception flag
                                  for test coverage of catch blocks
------------------------------------------------------------*/
public with sharing class INS_CTRL_CaseElapsedTimeInBusinessHours {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_CaseElapsedTimeInBusinessHours');
    private static final String LOG_AREA = 'Case Elapsed Time Controller';
    private static final String ERR_RETRIEVE_CASE = 'Unable to retrieve Case details. Please try again.';
    private static final String ERR_RETRIEVE_METRIC = 'Unable to retrieve Case Metric details. Please try again.';
    private static final String ERR_CALCULATE_SLA = 'Unable to calculate SLA metrics. Please try again.';
    private static final String ERR_ELAPSED_MS = 'Unable to calculate elapsed time. Please try again.';
    private static final String ERR_ELAPSED_HOURS = 'Unable to calculate elapsed hours. Please try again.';
    private static final String ERR_ELAPSED_MINUTES = 'Unable to calculate elapsed minutes. Please try again.';
    private static final String ERR_ELAPSED_SECONDS = 'Unable to calculate elapsed seconds. Please try again.';
    private static final String ERR_CMDT = 'Unable to retrieve polling configuration. Please try again.';

    @TestVisible
    private static Boolean mockForceException = false;

    @AuraEnabled(cacheable=true)
    public static Case retrieveCaseDetails(Id caseId) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            List<Case> caseData = (new SEL_Case()).selectCaseById(caseId);
            return caseData.isEmpty() ? null : caseData[0];
        } catch (Exception ex) {
            LOGGER.error('retrieveCaseDetails() failed for CaseId={0}, Error={1}', LOG_AREA, new List<Object>{ caseId, ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_RETRIEVE_CASE);
        }
    }

    @AuraEnabled(cacheable=true)
    public static CMN_CaseMilestoneMetric__c retrieveCaseMetricsDetails(Id caseId) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            List<CMN_CaseMilestoneMetric__c> metricList = SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(new Set<Id>{ caseId });
            return metricList.isEmpty() ? null : metricList[0];
        } catch (Exception ex) {
            LOGGER.error('retrieveCaseMetricsDetails() failed for CaseId={0}, Error={1}', LOG_AREA, new List<Object>{ caseId, ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_RETRIEVE_METRIC);
        }
    }

    @AuraEnabled
    public static INS_UTIL_BusinessHoursCalcHelper.SlaMetricsInBusinessHours calculateCaseSlaMetrics(RequestData caseDetails) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            Long ms = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(caseDetails.BusinessHoursId, caseDetails.CreatedDate, caseDetails.ClosedDate);
            return INS_UTIL_BusinessHoursCalcHelper.calculateSlaMetrics(ms);
        } catch (Exception ex) {
            LOGGER.error('calculateCaseSlaMetrics() failed, Error={0}', LOG_AREA, new List<Object>{ ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_CALCULATE_SLA);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Long elapsedMilliSeconds(RequestData caseDetails) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            return INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(caseDetails.BusinessHoursId, caseDetails.CreatedDate, caseDetails.ClosedDate);
        } catch (Exception ex) {
            LOGGER.error('elapsedMilliSeconds() failed, Error={0}', LOG_AREA, new List<Object>{ ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_ELAPSED_MS);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer elapsedHoursTAT(Long milliSeconds) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            Decimal hours = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(milliSeconds);
            return hours.intValue();
        } catch (Exception ex) {
            LOGGER.error('elapsedHoursTAT() failed for input={0}, Error={1}', LOG_AREA, new List<Object>{ milliSeconds, ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_ELAPSED_HOURS);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer elapsedMinutesTAT(Long milliSeconds) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            Decimal minutes = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToMinutes(milliSeconds);
            return minutes.intValue();
        } catch (Exception ex) {
            LOGGER.error('elapsedMinutesTAT() failed for input={0}, Error={1}', LOG_AREA, new List<Object>{ milliSeconds, ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_ELAPSED_MINUTES);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer elapsedSecondsTAT(Long milliSeconds) {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            Decimal seconds = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToSeconds(milliSeconds);
            return seconds.intValue();
        } catch (Exception ex) {
            LOGGER.error('elapsedSecondsTAT() failed for input={0}, Error={1}', LOG_AREA, new List<Object>{ milliSeconds, ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_ELAPSED_SECONDS);
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getMetaDataType() {
        try {
            if (Test.isRunningTest() && mockForceException) {
                throw new AuraHandledException('Mock exception for test coverage');
            }
            return INS_UTIL_BusinessHoursCalcHelper.getMetaDataType();
        } catch (Exception ex) {
            LOGGER.error('getMetaDataType() failed, Error={0}', LOG_AREA, new List<Object>{ ex.getMessage() }, ex);
            throw new AuraHandledException(ERR_CMDT);
        }
    }

    public class RequestData {
        @AuraEnabled public Id BusinessHoursId { get; set; }
        @AuraEnabled public DateTime CreatedDate { get; set; }
        @AuraEnabled public DateTime ClosedDate { get; set; }
    }
}