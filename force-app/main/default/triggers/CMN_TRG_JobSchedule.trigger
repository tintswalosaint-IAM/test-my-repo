/**
 * @description CMN_TRG_JobSchedule activated by saving Job Scheduler records (rule: 1 record per periodic job setting)
 * 
 * <p>VCCC-378</p>
 * 
 * @author Accenture
 *
 * @date 2019
 */
trigger CMN_TRG_JobSchedule on CMN_JobScheduler__c(before insert, before update, before delete)
{
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_JobScheduler.class);
}