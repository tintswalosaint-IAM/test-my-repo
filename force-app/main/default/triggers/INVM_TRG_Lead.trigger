trigger INVM_TRG_Lead on Lead (after update, before update) {
	CMN_FACTORY_TriggerHandler.createHandler(INVM_TRG_Lead.class);
}