/**
 * @description       : This class calculates a future DateTime based on a given start DateTime and a specified number of business days, taking into account the defined Business Hours and any holidays. It is designed to be used as an Invocable Method in Salesforce Flows, allowing for easy integration into various business processes that require SLA calculations or similar time-based logic.
 * @author            : Vikash
 * @group             : SBFC
 * @last modified on  : 03-16-2026
 * @last modified by  : Gul
**/


public with sharing class SBFC_SLABusinessHours {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_SLABusinessHours.class.getName());
    
    @TestVisible private static Id mockBusinessHoursId;
    
    @testVisible
    private SBFC_SLABusinessHours() {}
    
    @InvocableMethod(label='Calculate Business Days and Time' description='Calculates a future DateTime based on business days and hours.')
    public static List<DateTime> calculateSLAEndDate(List<BusinessDateTimeRequest> requests) {
        List<DateTime> results = new List<DateTime>();

        if (!Schema.sObjectType.BusinessHours.isAccessible()) {
            
            
            return null; // Avoid CRUD violation
        }
        try {
            
            Id businessHoursId;
            
            if (Test.isRunningTest() && mockBusinessHoursId != null) {
            	businessHoursId = mockBusinessHoursId;
            } else{
                
                List<BusinessHours> bhList = [
                SELECT Id
                FROM BusinessHours
                WHERE Name = 'SBFC Business Hours'
                LIMIT 1
            ];
            if (bhList.isEmpty()) {
                LOGGER.error('BusinessHours record not found',new String[] { SBFC_SLABusinessHours.class.getName(), 'SBFC Business Hours' },null);
                return results;
            }
            	businessHoursId  = bhList[0].Id; 
            }
            
            
            for (BusinessDateTimeRequest req : requests) {
                DateTime currentDateTime = req.startDateTime;
                Long millisecondsToAdd = req.numBusinessDays * (1000L * 60L * 60L * 24L);
                DateTime calculatedDateTime = BusinessHours.add(businessHoursId, currentDateTime, millisecondsToAdd);
                results.add(calculatedDateTime);
            }
        } catch (Exception e) {
            LOGGER.error(
                'Error while calculating SLA end date',
                new String[] { SBFC_SLABusinessHours.class.getName(), e.getMessage() },
                e
            );
        }
        return results;
    }

    /**
     * @description Inner class for defining inputs to the Invocable Method.
     * Required for passing complex types to Flow Invocable Actions.
     */
    public class BusinessDateTimeRequest {
        @InvocableVariable(label='Start DateTime' required=true)
        public DateTime startDateTime;

        @InvocableVariable(label='Number of Business Days' required=true)
        public Integer numBusinessDays;
    }

}