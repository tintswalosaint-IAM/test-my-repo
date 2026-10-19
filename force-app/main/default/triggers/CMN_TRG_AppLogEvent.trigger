/**
 * @description App log event  trigger for handling log events
 * 
 * <p>VCCC-378</p>
 * 
 * @author Accenture
 *
 * @date 2020
 */
trigger CMN_TRG_AppLogEvent on CMN_AppLogEvent__e (after insert)
{
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_AppLogEvent.class);
}