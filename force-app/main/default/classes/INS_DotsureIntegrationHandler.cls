/**
 * @description Dotsure Integration Handler
 *              Implements INS_IIntegrationHandler for Dotsure system integration
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-11
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-09-11   Raja Arsalan    
 **/
public class INS_DotsureIntegrationHandler implements INS_IIntegrationHandler {
    
    /**
     * @description Process a single Lead record for Dotsure integration
     * @param leadRecord 
     * @param accessToken
     * @param settings
     **/
    public void processRecord(
        Lead leadRecord, 
        String accessToken, 
        INS_Insurance_Lead_Settings__mdt settings
    ) {
        INS_DotsureService.syncLeadToDotsure(leadRecord, accessToken, settings);
    }
    
}