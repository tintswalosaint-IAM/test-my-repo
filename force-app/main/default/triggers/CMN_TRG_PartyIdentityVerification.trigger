trigger CMN_TRG_PartyIdentityVerification on PartyIdentityVerification (after insert, after update, before insert, before update,before delete,After delete) {
    
 CMN_FACTORY_TriggerHandler.createHandler(SVC_TRH_PartyIdentityVerification.class);

}