/**
 * CMN_TRG_FinancialAccount trigger for Financial Account object 
 * 
 * @author Alex Niyonsaba (niyonsabaa@stanbic.com)
 *
 * @date Aug 13th 2025
 * @User Story: SFP-52104
 */
trigger CMN_TRG_FinancialAccount on FinServ__FinancialAccount__c (after update) {
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_FinancialAccount.class);
}