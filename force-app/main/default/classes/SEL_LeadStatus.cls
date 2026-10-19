/**
 * @description Selector class for querying converted LeadStatus records.
 *
 * @author Tintswalo Mushwana
 * @date July 2026
 */

public inherited sharing class SEL_LeadStatus { 

/**
 * @description Gets converted LeadStatus records by their MasterLabel
 * @param statusNames Set of set status names to query
 * @return Map of MasterLabel to LeadStatus records
 */
  
 public static Map<String, LeadStatus> getConvertedStatusesByName(Set<String> statusNames){
     Map<String, LeadStatus> statusMap = new Map<String, LeadStatus>();
     
     for(LeadStatus status : [
        SELECT Id, MasterLabel
        FROM LeadStatus
        WHERE MasterLabel IN :statusNames 
        AND IsConverted = true
        WITH SECURITY_ENFORCED
        ]){
            statusMap.put(status.MasterLabel,status);
        }
      return statusMap;
 }

    }