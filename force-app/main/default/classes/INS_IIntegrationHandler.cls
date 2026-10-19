/**
* @description Integration Handler Interface
*              Defines contract for all integration handlers 
* @author Raja Arsalan
* @group Insurance
* @last modified on 2026-09-11
* 
* Modifications Log
* Date         Author          Modification
* 2026-09-11   Raja Arsalan    Added accessToken parameter for token reuse across batch
**/
public interface INS_IIntegrationHandler {
    
    /**
* @description Process a single Lead record for external system integration
* @param leadRecord 
* @param accessToken
* @param settings 
**/
    
    void processRecord(
        Lead leadRecord, 
        String accessToken, 
        INS_Insurance_Lead_Settings__mdt settings
    );
    
}