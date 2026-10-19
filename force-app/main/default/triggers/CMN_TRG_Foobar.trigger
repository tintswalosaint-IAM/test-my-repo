/**
 * @description Example trigger demonstrating how to use Trigger Handler framework
 * 
 * <p>VCCC-378</p>
 * 
 * @author Accenture
 *
 * @date 2019
 */
trigger CMN_TRG_Foobar on CMN_Foobar__c(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_Foobar.class);
}