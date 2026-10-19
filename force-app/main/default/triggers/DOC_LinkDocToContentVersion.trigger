/**
 * This Trigger links each contentdoclink record with its parent document
 * 
 * <p>DBP-1819</p>
 * 
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 * 
 * @date Feb 15th 2021
 */
trigger DOC_LinkDocToContentVersion on ContentDocumentLink (after insert) {
	CMN_FACTORY_TriggerHandler.createHandler(DOC_TRH_CotentDocumentLink.class);
}