/***************************************************************************************
@ Author            : mamidalar@stanbic.com
@ Date              : 16-07-2023
@ Name of the Class : SEL_ServiceAppointment
@description        : SFP-27633-Selector Class for ServiceAppointment Entity
@ Last Modified By  : pechimuthu.palanivinayagam@standardbank.co.za
@ Last Modified On  : 01-03-2024
@ Jira Description : SFP-27633
* ---------------------------------------------------------------------------
*      version             Date            Developer        Description
* ---------------------------------------------------------------------------
  1.0   16-07-2023   mamidalar@stanbic.com   Initial Version
  1.A   01-03-2024   mamidalar@stanbic.com    Description, jira number and API version updated
***************************************************************************************/
public inherited sharing class SEL_ServiceAppointment extends sbgplatform.fflib_SObjectSelector{
    private static Set<String> fields = new Set<String>{
         'Id',
         'ParentRecordId', 
         'Email', 
         'Status', 
         'AppointmentNumber', 
         'SchedStartTime', 
         'AppointmentType', 
         'CreatedDate',
         'schedEndTime',
         'CancellationReason',
         'Status',
             'Street',
             'SchedStartTime',
             'SchedEndTime',
             'Street',
             'City',
             'State',
             'PostalCode',
             'Country',
             'Phone',
             'AppointmentType',
             'OwnerId',
             'AdditionalInformation'
    };  
    /**
    * @description Implementation method for Lead Object as part of fflib framweork
    * @author mamidalar@stanbic.com | AUG 16th 2023 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return ServiceAppointment.sObjectType;
    }
    /**
    * @description Method to get list of fields to be part of response
    * @author mamidalar@stanbic.com | AUG 16th 2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ServiceAppointment.Id,
            ServiceAppointment.ParentRecordId,
            ServiceAppointment.Email,
            ServiceAppointment.Status,
            ServiceAppointment.AppointmentNumber,
            ServiceAppointment.SchedStartTime,
            ServiceAppointment.AppointmentType,
            ServiceAppointment.CreatedDate,
            ServiceAppointment.schedEndTime,
            ServiceAppointment.CancellationReason,
            ServiceAppointment.Status,
            ServiceAppointment.Street,
            ServiceAppointment.SchedStartTime,
            ServiceAppointment.SchedEndTime,
            ServiceAppointment.Street,
            ServiceAppointment.City,
            ServiceAppointment.State,
            ServiceAppointment.PostalCode,
            ServiceAppointment.Country,
            ServiceAppointment.Phone,
            ServiceAppointment.AppointmentType,
            ServiceAppointment.OwnerId,
                ServiceAppointment.AdditionalInformation

        };
    }
  /**
    * @description Method to fetch ServiceAppointment record based on serviceAppointment Id
    * @author mamidalar@stanbic.com | AUG 16th 2023 
    * @param serviceAppointmentId  
    * @return ServiceAppointment 
    **/
    public ServiceAppointment selectById( id serviceAppointmentId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('id= :serviceAppointmentId');
         fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }


 /**
    * @description Method to fetch list of appointment Records Based on Set of Ids
    * @author mamidalar@stanbic.com | AUG 16th 2023 
    * @param List<parentIds> parentIds  
    * @return List<ServiceAppointment> 
    **/
    public List<ServiceAppointment>  selectByParentId(Set<Id> parentIds) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('ParentRecordId IN : parentIds');
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, false);
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    

}