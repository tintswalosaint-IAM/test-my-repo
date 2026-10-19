/**
* @description Trigger for performing account maintenance tasks
*
* @author Karabo Machubeni
*
* @date August 2023
*/
trigger CMN_TRG_Account on Account (after update, after insert) {
 CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_Account.class);
}