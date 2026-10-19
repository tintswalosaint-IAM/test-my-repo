/***************************************************************************************

@Name of the Component : INS_BusinessHoursCalculator
@Description : The aim is to compute the time elapsed between two dates in business hours.
@Author : Kenneth Dlamini
@Created Date : 2025-04-25
/***************************************************************************************
@Last Modified By :
@Last Modified On :
@Modification description: SFP-46473
***************************************************************************************/
public class INS_BusinessHoursCalculator {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_BusinessHoursCalculator');

    /**
     * @description Calculates the elapsed millisenconds between two DateTime values based on a Business Hours record.
     * @author Kenneth Dlamini | 2025-04-30
     * @param businessHoursId The ID of the Business Hours record.
     * @param startDateTime The start DateTime.
     * @param endDateTime The end DateTime.
     * @return Long number of milliseconds.
     **/
    public static Long calculateElapsedMilliSeconds(Id businessHoursId, DateTime startDateTime, DateTime endDateTime) {
        if (startDateTime >= endDateTime || businessHoursId == null) {
            return 0;
        }
        Long milliseconds = BusinessHours.diff(businessHoursId, startDateTime, endDateTime);     
        if (milliseconds == null) {
            return 0;
        }
        return milliseconds;
    }

    /**
     * @description Converts milliSeconds into business hours.
     * @author Kenneth Dlamini | 2025-05-13
     * @param milliSeconds is the value returned milliSeconds from Business.Diff() function.
     **/
    public static Decimal convertMilliSecondsToHours(Long milliSeconds){
      if (milliSeconds == null) return 0;
      Decimal hours = Math.floor(milliSeconds / (1000 * 60 * 60));
      return hours;
    }

    /**
     * @description Converts milliSeconds into minutes.
     * @author Kenneth Dlamini | 2025-05-13
     * @param milliSeconds is the value returned milliSeconds from Business.Diff() function.
     **/
    public static Decimal convertMilliSecondsToMinutes(Long milliSeconds){
      if (milliSeconds == null) return 0;
      Long convert_to_minutes_constant = (1000 * 60 * 60);
      Decimal minutes = Math.floor((Math.mod(milliSeconds, convert_to_minutes_constant)))/(1000 * 60);
      return minutes;
    }

    /**
     * @description Converts business milliSeconds into seconds.
     * @author Kenneth Dlamini | 2025-05-13
     * @param milliSeconds is the value returned milliSeconds from Business.Diff() function.
     **/
    public static Decimal convertMilliSecondsToSeconds(Long milliSeconds){
      if (milliSeconds == null) return 0;
      Long convert_to_seconds_constant = (1000 * 60);
      Decimal seconds = Math.floor((Math.mod(milliSeconds, convert_to_seconds_constant)))/(1000);
      return seconds;
    }

    /**
     * @description update case TAT when a case is resolved.
     * Date: 2025-5-14
     * Description: 
     *
     * @param newCase
     * @Modification description: SFP-46473
     */
    public static void updateCaseTATDetails(Case newCase, Case oldCase){
      //case has not been resolved yet. Update TAT metrics.
      if (oldCase.SVC_OverallCaseTAT__c  == null){
        Case updateCase = new case();
        if (newCase.ClosedDate == null 
          && newCase.SVC_Case_Allocation_Date__c != null
          && newCase.SVC_AllocatorTAT__c == null){
          //update all TAT metrics.
          Long milliSecondsAllocator_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
          newCase.CreatedDate, newCase.SVC_Case_Allocation_Date__c);
          String sAllocatorTAT_Time = printTATInBusinessHours(milliSecondsAllocator_TAT);
  
          updateCase.Id = newCase.Id;
          updateCase.SVC_AllocatorTAT__c = sAllocatorTAT_Time;
          INS_UpdateCaseTAT.updateCaseTAT(updateCase);
        } else if (newCase.ClosedDate == null 
          && newCase.SVC_AllocationToClassificationTAT__c == null
          && newCase.SVC_CaseClassificationDate__c != null
          && newCase.SVC_Case_Allocation_Date__c != null) {
            //update all TAT metrics.
            //the time it takes for a case to be classified after allocation by an allocator.
          Long milliSecondsAllocationToClassification_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
          newCase.SVC_Case_Allocation_Date__c, newCase.SVC_CaseClassificationDate__c);
          String sAllocationToClassificationTAT_Time = printTATInBusinessHours(milliSecondsAllocationToClassification_TAT);
  
          updateCase.Id = newCase.Id;
          updateCase.SVC_AllocationToClassificationTAT__c = sAllocationToClassificationTAT_Time;
          INS_UpdateCaseTAT.updateCaseTAT(updateCase);

        } else if (newCase.ClosedDate == null 
        && newCase.SVC_Case_Allocation_Date__c == null
        && newCase.SVC_CaseClassificationDate__c != null
        && newCase.SVC_AllocationToClassificationTAT__c == null) {
          //update all TAT metrics.
          //the time it takes for a case to be classified after allocation.
        Long milliSecondsAllocationToClassification_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
        newCase.CreatedDate, newCase.SVC_CaseClassificationDate__c);
        String sAllocationToClassificationTAT_Time = printTATInBusinessHours(milliSecondsAllocationToClassification_TAT);

        updateCase.Id = newCase.Id;
        updateCase.SVC_AllocationToClassificationTAT__c = sAllocationToClassificationTAT_Time;
        INS_UpdateCaseTAT.updateCaseTAT(updateCase);

      } else if (newCase.ClosedDate != null 
        && newCase.SVC_CaseClassificationDate__c != null
        && newCase.SVC_OverallCaseTAT__c == null) {
        Long milliSecondsOverAll_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
        newCase.CreatedDate, newCase.ClosedDate);
        String sOverAllCaseTAT_Time = printTATInBusinessHours(milliSecondsOverAll_TAT);
        //the time it took the agent to resolve the case after classifying it.
        Long milliSecondsServiceAgent_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
        newCase.SVC_CaseClassificationDate__c, newCase.ClosedDate);
        String sServiceAgentTAT_Time = printTATInBusinessHours(milliSecondsServiceAgent_TAT);
        updateCase.Id = newCase.Id;
        updateCase.SVC_OverallCaseTAT__c = sOverAllCaseTAT_Time;
        updateCase.SVC_AfterCaseClassificationTAT__c = sServiceAgentTAT_Time;
        INS_UpdateCaseTAT.updateCaseTAT(updateCase);
      } else if (newCase.ClosedDate != null) { //catch all
          Long milliSecondsOverAll_TAT = 0;        
          if (newCase.SVC_ResolvedDate__c != null) {
            milliSecondsOverAll_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
            newCase.CreatedDate, newCase.SVC_ResolvedDate__c);
          } else { 
            milliSecondsOverAll_TAT = calculateElapsedMilliSeconds(newCase.BusinessHoursId,
            newCase.CreatedDate, newCase.ClosedDate);
          }
          String sOverAllCaseTAT_Time = printTATInBusinessHours(milliSecondsOverAll_TAT);
          updateCase.Id = newCase.Id;
          updateCase.SVC_OverallCaseTAT__c = sOverAllCaseTAT_Time;
          INS_UpdateCaseTAT.updateCaseTAT(updateCase);
      }
    }
  }	

    /**
     * @description Converts business hours into hours, mins and seconds into a string.
     * @author Kenneth Dlamini | 2025-05-13
     * @param milliSeconds is the value returned milliSeconds from Business.Diff() function.
     **/
    public static String printTATInBusinessHours(Long milliSeconds){
      Decimal hours = convertMilliSecondsToHours(milliSeconds);
      Decimal minutes = convertMilliSecondsToMinutes(milliSeconds);
      Decimal seconds = convertMilliSecondsToSeconds(milliSeconds);
      String sTime = hours.intValue() + ' hrs ' + minutes.intValue() + ' mins ' + seconds.intValue() + ' secs.';
      return sTime;
    }
}