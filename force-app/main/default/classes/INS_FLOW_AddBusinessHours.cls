/*------------------------------------------------------------
Author:        Given Khupai
Description:   Adds business time (milliseconds) to a start date
               using Business Hours, skipping weekends, after-hours
               and holidays. Invoked from Flow to set the customer
               feedback follow-up due date.
Test Class:    INS_FLOW_AddBusinessHours_TEST
2026-10-16     Given Khupai       SFP-61218 Initial version

------------------------------------------------------------*/
public with sharing class INS_FLOW_AddBusinessHours {

    private INS_FLOW_AddBusinessHours() {}

    /*------------------------------------------------------------
    *   Purpose:    Returns start + business milliseconds for each
    *               request. Returns a null result when any input
    *               is missing.
    *   Parameters: requests - one per Case from the Flow
    *   Returns:    List<Result> in the same order as the requests
    *--------------------------------------------------------------*/
    @InvocableMethod(Label='Add Business Hours' Description='Adds business time in milliseconds to a start date/time using Business Hours (skips weekends, after-hours and holidays)')
    public static List<Result> addBusinessHours(List<Request> requests) {
        List<Result> results = new List<Result>();
        for (Request request : requests) {
            Result result = new Result();
            if (request.businessHoursId != null && request.startDateTime != null && request.milliseconds != null) {
                result.dueDateTime = BusinessHours.add(request.businessHoursId, request.startDateTime, request.milliseconds);
            }
            results.add(result);
        }
        return results;
    }

    public class Request {
        @InvocableVariable(Label='Business Hours Id' Required=true)
        public Id businessHoursId;

        @InvocableVariable(Label='Start Date/Time' Required=true)
        public DateTime startDateTime;

        @InvocableVariable(Label='Business Milliseconds' Description='Business time to add, e.g. 162000000 = 45 business hours = 5 days of 08:00-17:00' Required=true)
        public Long milliseconds;
    }

    public class Result {
        @InvocableVariable(Label='Due Date/Time')
        public DateTime dueDateTime;
    }
}