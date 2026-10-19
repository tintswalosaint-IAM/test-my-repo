/**
 * Created by bhaskar.arora on 7/23/2021.
 */

trigger SVC_TRG_Case on Case (after update, before update)
{
    CMN_FACTORY_TriggerHandler.createHandler(SVC_TRH_Case.class);
}