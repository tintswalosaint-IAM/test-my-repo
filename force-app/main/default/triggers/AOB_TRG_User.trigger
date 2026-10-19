/**
 * AOB_TRG_User trigger for user object
 * 
 * <p></p>
 * 
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 9th 2020
 */
trigger AOB_TRG_User on User(after insert, after update){
	CMN_FACTORY_TriggerHandler.createHandler(AOB_TRH_User.class);
}