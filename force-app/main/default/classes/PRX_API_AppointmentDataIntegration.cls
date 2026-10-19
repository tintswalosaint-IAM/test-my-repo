/**
@ Author            : mamidalar@stanbic.com
@ Date              : 04-03-2024
@ Name of the Class : PRX_API_AppointmentIntegration
@description         :REST resource class for handling ServiceAppointment data integration.
*Provides API endpoints for managing and updating ServiceAppointment records.
@ Last Modified By  : mamidalar@stanbic.com
@ Last Modified On  : 16-02-2024
@ Modification Description : SFP-28035
@ ---------------------------------------------------------------------------
@ Developer         Date                   Description
@ ---------------------------------------------------------------------------
@ mamidalar@stanbic.com    04-03-2024             Created
*/
@RestResource(urlMapping='/ServiceAppointment/*')
global with sharing class PRX_API_AppointmentDataIntegration {
/***@description Logger for PRX_API_AppointmentDataIntegration.*/
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PRX_API_AppointmentDataIntegration');
/**
* @description  Retrieves the appointment details based on the provided email address.
* @author rahul.mamidala@standardbank.co.za | 02-28-2025 
* @param None
* @return  List<ServiceAppointment>
*/
   @HttpGet
    global static List<ServiceAppointment> getAppointments() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            Map<String, String> reqParams = req.params;
            String email = reqParams.get('email');
            if (email == null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"Email parameter is missing"}');
                return new List<ServiceAppointment>();
            }
             List<Lead> leads = new SEL_Lead().selectByEmail(email);
            if (leads.isEmpty()) {
            return new List<ServiceAppointment>();
            }
            Set<Id> leadIds = new Set<Id>();
            for (Lead lead : leads) {
                leadIds.add(lead.Id);
            }
            List<ServiceAppointment> allAppointments= new SEL_ServiceAppointment().selectByParentId(leadIds);                                                
            return allAppointments;
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error":"An error occurred: ' + e.getMessage() + '"}');
            return new List<ServiceAppointment>();
        }
    }

/**
* @description Creates a new appointment record based on the provided request data and lead ID.
* @author rahul.mamidala@standardbank.co.za | 02-28-2025 
* @param None
* @return None
*/
// @HttpPost
// global static void createAppointment() {
//     RestRequest req = RestContext.request;
//     RestResponse res = RestContext.response;
//     try {
//         if (!hasPermissions()) {
//             handleError(res, 403, 'Insufficient permissions to create Service Appointments');
//             return;
//         }
//         String reqData = req.requestBody.toString();
//         if (String.isBlank(reqData)) {
//             handleError(res, 400, 'Request body is empty');
//             return;
//         }
//         ServiceAppointment appointmentInstance = buildServiceAppointment(reqData);
//         insert appointmentInstance;
//         ServiceAppointment appointment = new SEL_ServiceAppointment().selectById(appointmentInstance.id);
//          appointmentInstance = (ServiceAppointment) Security.stripInaccessible( AccessType.CREATABLE, new List<ServiceAppointment>{appointmentInstance}
//           ).getRecords()[0];
//         String servapp = appointment.AppointmentNumber;
//         res.responseBody = Blob.valueOf('{"servid":"' + servapp + '"}');
//     } catch (Exception e) {
//         handleError(res, 500, 'An error occurred: ' + e.getMessage());
//         LOGGER.error('Creating of Appointments failed, Please try again ' + e.getMessage());
//     }
// }

@HttpPost
global static void createAppointment() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    try {
        if (!hasPermissions()) {
            handleError(res, 403, 'Insufficient permissions to create Service Appointments');
            return;
        }
        String reqData = req.requestBody.toString();
        if (String.isBlank(reqData)) {
            handleError(res, 400, 'Request body is empty');
            return;
        }
        ServiceAppointment appointmentInstance = buildServiceAppointment(reqData);
        appointmentInstance = (ServiceAppointment) Security.stripInaccessible(AccessType.CREATABLE, new List<ServiceAppointment>{appointmentInstance}
        ).getRecords()[0];
        insert appointmentInstance;
        ServiceAppointment appointment = new SEL_ServiceAppointment().selectById(appointmentInstance.Id);
        List<ServiceAppointment> readableAppointments = (List<ServiceAppointment>) Security.stripInaccessible(
         AccessType.READABLE, new List<ServiceAppointment>{appointment}).getRecords();
        if (!readableAppointments.isEmpty()) {
            String servapp = readableAppointments[0].AppointmentNumber;
            res.responseBody = Blob.valueOf('{"servid":"' + servapp + '"}');
        } else {
            handleError(res, 403, 'Insufficient field-level read access on the created appointment');
        }
    } catch (Exception e) {
        handleError(res, 500, 'An error occurred: ' + e.getMessage());
        LOGGER.error('Creating of Appointments failed, Please try again: ' + e.getMessage());
    }
}

/**
 * @description Checks if the current user has permission to create ServiceAppointment records.
 * @author rahul.mamidala@standardbank.co.za | 02-28-2025 
 * @param None
 * @return Boolean - True if the user has create access, otherwise false.
 */
private static Boolean hasPermissions() {
    return Schema.SObjectType.ServiceAppointment.isCreateable();
}
/**
 * @description Handles errors by setting the response status code and message.
* @author rahul.mamidala@standardbank.co.za | 02-28-2025 
 * @param res The RestResponse object to update.
 * @param statusCode The HTTP status code to set in the response.
 * @param message The error message to include in the response body.
 */
private static void handleError(RestResponse res, Integer statusCode, String message) {
    res.statusCode = statusCode;
    res.responseBody = Blob.valueOf('{"error":"' + message + '"}');
}
/**
 * @description Builds a ServiceAppointment record from the provided request data.
* @author rahul.mamidala@standardbank.co.za | 02-28-2025 
 * Parses the input JSON, assigns values to the appointment fields, and sets related information.
 * @param reqData The JSON string containing appointment details.
 * @return ServiceAppointment The constructed ServiceAppointment instance.
 */
private static ServiceAppointment buildServiceAppointment(String reqData) {
Map<String, Object> serviceAppointmentData = (Map<String, Object>) JSON.deserializeUntyped(reqData);
Id recordTypeId = Schema.SObjectType.ServiceAppointment.getRecordTypeInfosByDeveloperName().get('Prx_Service_Appointment').getRecordTypeId();
ServiceAppointment appointmentInstance = new ServiceAppointment();
appointmentInstance.Status = PRX_CTRL_Constants.UPCOMING;
appointmentInstance.RecordTypeId = recordTypeId;
String leadId = (String) serviceAppointmentData.get(PRX_CTRL_Constants.LEAD_ID);
appointmentInstance.ParentRecordId = leadId;
Lead lead = new SEL_Lead().selectById(leadId);
appointmentInstance.OwnerId = lead.OwnerId;
setAppointmentTimes(appointmentInstance, serviceAppointmentData);
appointmentInstance.Street = (String) serviceAppointmentData.get(PRX_CTRL_Constants.STREET);
appointmentInstance.City = (String) serviceAppointmentData.get(PRX_CTRL_Constants.CITY);
appointmentInstance.State = (String) serviceAppointmentData.get(PRX_CTRL_Constants.PROVINCE);
appointmentInstance.PostalCode = (String) serviceAppointmentData.get(PRX_CTRL_Constants.POSTAL_CODE);
appointmentInstance.Country = (String) serviceAppointmentData.get(PRX_CTRL_Constants.COUNTRY);
appointmentInstance.Email = (String) serviceAppointmentData.get(PRX_CTRL_Constants.EMAIL);
appointmentInstance.Phone = (String) serviceAppointmentData.get(PRX_CTRL_Constants.PHONE);
appointmentInstance.AppointmentType = (String) serviceAppointmentData.get(PRX_CTRL_Constants.APPOINTMENT_TYPE);
appointmentInstance.Description = (String) serviceAppointmentData.get(PRX_CTRL_Constants.QUERY);
return appointmentInstance;
}
/**
 * @description Sets the scheduled start and end times for a ServiceAppointment.
 * @author rahul.mamidala@standardbank.co.za | 02-28-2025 
 * Converts provided UTC times to the appropriate time zone (Africa/Johannesburg) and adjusts for GMT+2.
 * @param appointmentInstance The ServiceAppointment instance to update.
 * @param serviceAppointmentData A map containing appointment scheduling details.
 * @return None
 */
private static void setAppointmentTimes(ServiceAppointment appointmentInstance, Map<String, Object> serviceAppointmentData) {
    TimeZone tz = TimeZone.getTimeZone(PRX_CTRL_Constants.TIME_ZONE_SOUTH_AFRICA);
    String schedStartTimeString = (String) serviceAppointmentData.get(PRX_CTRL_Constants.SCHED_START_TIME);
    DateTime schedStartTimeUTC = DateTime.valueOf(schedStartTimeString);
    DateTime schedStartTimeLocal = schedStartTimeUTC.addSeconds(tz.getOffset(schedStartTimeUTC) / 1000);
    DateTime schedStartTimeAdjusted = schedStartTimeLocal.addMinutes(PRX_CTRL_Constants.OFFSET_MINUTES);
    appointmentInstance.SchedStartTime = schedStartTimeAdjusted;
    DateTime schedEndTimeLocal = schedStartTimeAdjusted.addMinutes(PRX_CTRL_Constants.DURATION_MINUTES);
    appointmentInstance.SchedEndTime = schedEndTimeLocal;
}
/**
 * @description Handles HTTP PUT requests to update a ServiceAppointment record.
 * @author rahul.mamidala@standardbank.co.za | 02-28-2025 
 * Validates permissions, processes the request body, and updates the appointment based on the specified action.
 * @param None
 * @return None
 */
@HttpPut 
global static void updateAppointment() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    try {
        if (!Schema.SObjectType.ServiceAppointment.isUpdateable()) {
            res.statusCode = 403;
            res.responseBody = Blob.valueOf('{"error":"Insufficient permissions to update Service Appointments"}');
            return;
        }
        String reqData = req.requestBody.toString();
        if (String.isBlank(reqData)) {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error":"Request body is empty"}');
            return;
        }
        Map<String, Object> serviceAppointmentData = (Map<String, Object>) JSON.deserializeUntyped(reqData);
        String appointmentId = (String) serviceAppointmentData.get('apserid');
        ServiceAppointment appointmentInstance = new SEL_ServiceAppointment().selectById(appointmentId);
        if (appointmentInstance == null) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('{"error":"Service Appointment not found"}');
            return;
        }
        String action = (String) serviceAppointmentData.get('action');
        String value = (String) serviceAppointmentData.get('value');
        switch on action {
            when 'cancelled'{
                appointmentInstance.Status = PRX_CTRL_Constants.STATUS_CANCELED;
                appointmentInstance.CancellationReason = value;
            }
            when 'captureNotes' {
                appointmentInstance.AdditionalInformation = value;
            }
            when 'reschedule' {
                appointmentInstance.Status = PRX_CTRL_Constants.STATUS_UPCOMING;
                updateAppointmentTimes(appointmentInstance, value);
            }
            when else {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('{"error":"Invalid action specified"}');
                LOGGER.error('Invalid action specified: ' + action);
                return;
            }
        }
        update appointmentInstance;
        res.statusCode = 200;
        res.responseBody = Blob.valueOf('{"success":true}');
        
    } catch(Exception e) {
        res.statusCode = 500;
        res.responseBody = Blob.valueOf('{"error":"An error occurred: ' + e.getMessage() + '"}');
        LOGGER.error('Update of Appointments failed, Please try again ' + e.getMessage());
    }
}
/**
 * @description Updates the scheduled start and end times of a ServiceAppointment.
 * Converts the provided UTC datetime to Africa/Johannesburg time zone and adjusts for GMT+2.
 * @author rahul.mamidala@standardbank.co.za | 02-28-2025 
 * @param appointmentInstance The ServiceAppointment instance to update.
 * @param dateTimeString The new scheduled start time in string format.
 * @return None
 */
private static void updateAppointmentTimes(ServiceAppointment appointmentInstance, String dateTimeString) {
    TimeZone tz = TimeZone.getTimeZone(PRX_CTRL_Constants.TIME_ZONE_SOUTH_AFRICA);
    DateTime schedStartTimeUTC = DateTime.valueOf(dateTimeString);
    DateTime schedStartTimeLocal = schedStartTimeUTC.addSeconds(tz.getOffset(schedStartTimeUTC) / 1000);
    DateTime schedStartTimeAdjusted = schedStartTimeLocal.addMinutes(PRX_CTRL_Constants.OFFSET_MINUTES);
    appointmentInstance.SchedStartTime = schedStartTimeAdjusted;
    DateTime schedEndTimeLocal = schedStartTimeAdjusted.addMinutes(PRX_CTRL_Constants.DURATION_MINUTES);
    appointmentInstance.SchedEndTime = schedEndTimeLocal;
}
}