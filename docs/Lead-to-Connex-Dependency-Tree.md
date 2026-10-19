# Lead-to-Connex Solution — Dependency Tree

## Overview

This document maps every component in the Lead-to-Connex integration and shows what each depends on.
Arrows (→) indicate "depends on" / "calls into".

---

## 1. Triggers

### CMN_TRG_Lead
| Depends On | Type |
|-----------|------|
| CMN_FACTORY_TriggerHandler | Apex Class (framework) |
| CMN_TRH_Lead | Apex Class (handler) |
| AOB_PPB_LeadTriggerHandler | Apex Class (unrelated, PPB) |
| Lead | Standard Object |

---

## 2. Apex Classes — Trigger Handlers & Orchestrators

### CMN_TRH_Lead (Trigger Handler)
| Depends On | Type |
|-----------|------|
| INS_UTIL_LeadTrigger | Apex Class |
| CMN_TRH_BaseObject | Apex Class (framework base) |
| CMN_SEL_Account | Apex Class (selector) |
| sbgbase.MilestoneTriggerHandler | Managed Package |
| Lead, Account, Campaign, CampaignMember | Objects |

### INS_UTIL_LeadTrigger (Orchestrator)
| Depends On | Type |
|-----------|------|
| INS_SEL_Leads_ProductQueueAllocation | Apex Class (selector) |
| SEL_Lead | Apex Class (selector) |
| SEL_Campaign | Apex Class (selector) |
| SEL_User | Apex Class (selector) |
| INS_SEL_CampaignMember | Apex Class (selector) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| Leads_ProductQueueAllocation__c | Custom Object |
| sbgplatform.fflib_SObjectUnitOfWork | Managed Package |
| sbgplatform.rflib_Logger | Managed Package |
| Lead, Campaign, CampaignMember, Task | Objects |

---

## 3. Apex Classes — Connex Service Layer

### INS_UTIL_LeadConnexService
| Depends On | Type |
|-----------|------|
| INS_UTIL_LeadConnexSupport | Apex Class |
| INS_UTIL_LeadConnexDecisionService | Apex Class |
| INS_BATCH_ConnexLead | Apex Class (batch) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| Lead | Standard Object |

### INS_UTIL_LeadConnexSupport
| Depends On | Type |
|-----------|------|
| INS_SEL_Leads_ProductQueueAllocation | Apex Class (selector) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| Leads_ProductQueueAllocation__c | Custom Object |
| Lead | Standard Object |

### INS_UTIL_LeadConnexDecisionService
| Depends On | Type |
|-----------|------|
| INS_UTIL_LeadConnexSupport | Apex Class |
| Lead | Standard Object |

---

## 4. Batch Jobs & Scheduled Apex

### INS_BATCH_ConnexLead (Batchable + Schedulable)
| Depends On | Type |
|-----------|------|
| INS_UTIL_ConnexLeads | Apex Class (callout utility) |
| SEL_Lead | Apex Class (selector) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| INS_DTO_LeadSearchCriteria | Apex Class (DTO) |
| sbgbase.BatchJobBase | Managed Package |
| Lead | Standard Object |

**Scheduling:**
- CRON1: `0 0 * * * ?` (on the hour) — retry failed/parked leads
- CRON2: `0 30 * * * ?` (on the half hour) — retry failed/parked leads
- Evening CRON: expires RETRO leads older than 30 days

---

## 5. Apex Classes — API & Callout Layer

### INS_UTIL_ConnexLeads (Callout Orchestrator)
| Depends On | Type |
|-----------|------|
| INS_Leads_API | Apex Class (HTTP client) |
| INS_DTO_ConnexLeads | Apex Class (request DTO) |
| INS_DTO_ConnexLeadsResponse | Apex Class (POST response DTO) |
| INS_DTO_UpdateConnexLeadResponse | Apex Class (PUT response DTO) |
| CMN_Generate_Token_Helper | Apex Class (auth) |
| SEL_User | Apex Class (selector) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| sbgplatform.fflib_SObjectUnitOfWork | Managed Package |
| CMN_UTIL_Logger | Apex Class (logging) |
| Lead | Standard Object |

### INS_Leads_API (HTTP Client)
| Depends On | Type |
|-----------|------|
| AOB_API_RestBaseOutboundPing | Apex Class (base HTTP class) |
| INS_DTO_ConnexLeadsResponse | Apex Class (response DTO) |
| INS_DTO_UpdateConnexLeadResponse | Apex Class (response DTO) |
| INS_Insurance_Leads | Named Credential |
| AOB_Utils | Apex Class (GUID generation) |
| Lead | Standard Object |

### CMN_Generate_Token_Helper (OAuth Token)
| Depends On | Type |
|-----------|------|
| INS_InsuranceClaimsAccess | Named Credential (endpoint) |
| INS_InsuranceClaimsAccessToken | External Credential (client creds) |
| sbgplatform.rflib_Logger | Managed Package |
| INS_CustomException | Apex Class |

---

## 6. Apex Classes — DTOs

### INS_DTO_ConnexLeads (Request Payload)
| Depends On | Type |
|-----------|------|
| Lead | Standard Object (field references) |
| CMN_DTO_JsonBase | Apex Class (base, implicit via pattern) |

### INS_DTO_ConnexLeadsResponse (POST Response)
| Depends On | Type |
|-----------|------|
| CMN_DTO_JsonBase | Apex Class (base) |

### INS_DTO_UpdateConnexLeadResponse (PUT Response)
| Depends On | Type |
|-----------|------|
| CMN_DTO_JsonBase | Apex Class (base) |

### INS_DTO_LeadSearchCriteria (Query Parameters)
| Depends On | Type |
|-----------|------|
| (none — plain DTO) | — |

---

## 7. Apex Classes — Selectors

### SEL_Lead
| Depends On | Type |
|-----------|------|
| sbgplatform.fflib_SObjectSelector | Managed Package |
| Lead | Standard Object |
| Leads_ProductQueueAllocation__c | Custom Object (via relationship) |

### SEL_Campaign
| Depends On | Type |
|-----------|------|
| sbgplatform.fflib_SObjectSelector | Managed Package |
| Campaign | Standard Object |
| CampaignMember | Standard Object |

### SEL_User
| Depends On | Type |
|-----------|------|
| sbgplatform.fflib_SObjectSelector | Managed Package |
| User | Standard Object |

### INS_SEL_Leads_ProductQueueAllocation
| Depends On | Type |
|-----------|------|
| sbgplatform.fflib_SObjectSelector | Managed Package |
| Leads_ProductQueueAllocation__c | Custom Object |

### INS_SEL_CampaignMember
| Depends On | Type |
|-----------|------|
| sbgplatform.fflib_SObjectSelector | Managed Package |
| CampaignMember | Standard Object |

### SEL_GroupMember
| Depends On | Type |
|-----------|------|
| sbgplatform.fflib_SObjectSelector | Managed Package |
| GroupMember, Group | Standard Objects |

---

## 8. Apex Classes — LWC Controllers

### INS_CTRL_FailedConnexLeads
| Depends On | Type |
|-----------|------|
| SEL_Lead | Apex Class (selector) |
| SEL_GroupMember | Apex Class (selector) |
| INS_BATCH_ConnexLead | Apex Class (batch) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| INS_DTO_LeadSearchCriteria | Apex Class (DTO) |
| Lead | Standard Object |

### INS_CTRL_SbibExpireLeads
| Depends On | Type |
|-----------|------|
| SEL_Lead | Apex Class (selector) |
| SEL_GroupMember | Apex Class (selector) |
| INS_Insurance_Lead_Settings__mdt | Custom Metadata |
| INS_DTO_LeadSearchCriteria | Apex Class (DTO) |
| sbgplatform.fflib_SObjectUnitOfWork | Managed Package |
| Lead | Standard Object |

---

## 9. Lightning Web Components (LWCs)

### InsFailedConnexLeads (Failed Leads Report)
| Depends On | Type |
|-----------|------|
| INS_CTRL_FailedConnexLeads | Apex Controller |
| Connex_Leads_Report | Custom Tab |
| Lead_Administrator | Permission Set |
| INS_Dialer_Leads_Managers_PG | Public Group |

### InsSbibExpireLeads (Manual Expiry Report)
| Depends On | Type |
|-----------|------|
| INS_CTRL_SbibExpireLeads | Apex Controller |
| Connex Lead Expiry | Custom Tab |
| INS_Dialer_Leads_Managers_PG | Public Group |

---

## 10. Flows (Declarative Automation)

### Task_Delete_Duplicate_Lead
| Depends On | Type |
|-----------|------|
| Task | Standard Object (trigger: Task created) |
| Lead | Standard Object (action: delete) |
| *Triggered by:* INS_UTIL_LeadTrigger.checkForDuplicates() creating Task | Apex |

### Event_Assign_event_to_Agent
| Depends On | Type |
|-----------|------|
| Event | Standard Object (trigger: Event created) |
| Dialer_Agent_Id__c | Custom Field (Event) |
| User | Standard Object (lookup for assignment) |

### Notification_Alert_to_User
| Depends On | Type |
|-----------|------|
| Lead | Standard Object (trigger: Owner changed) |
| Custom Notification Type | Platform feature |

### Lead_Allocate
| Depends On | Type |
|-----------|------|
| Lead | Standard Object (trigger: create/update) |
| Queue / Assignment rules | Configuration |

---

## 11. Integrations (External Systems)

### ESB Leads API (Standard Bank Enterprise Service Bus)
| Depends On | Type |
|-----------|------|
| INS_Insurance_Leads | Named Credential (endpoint URL) |
| OAuth Bearer Token | From CMN_Generate_Token_Helper |
| X-IBM-Client-Id / Secret | From Named Credential |
| X-Client-Certificate (5 parts) | From Named Credential |

### ConnexOne Platform (Dialler System)
| Depends On | Type |
|-----------|------|
| ESB Leads API | Intermediary (Connex is downstream of ESB) |
| POST /leads | Create new leads |
| PUT /leads/{refNum}/LeadEnhancement | Update/expire existing leads |

### Inbound from Connex (via ESB → Salesforce API)
| Updates | Type |
|-----------|------|
| Lead.Status | Field update (disposition) |
| Lead.Dialer_Agent_Id__c | Field update (agent assignment) |
| Event creation | New Event record (contact history) |

---

## 12. Named Credentials & External Credentials

### INS_Insurance_Leads (Named Credential)
| Used By | Purpose |
|---------|---------|
| INS_Leads_API | ESB Leads API endpoint |
| Contains: clientId, clientSecret, xenvkey, cifCountry, channelName, channel_Id, XClientCertificate1-5 | Auth & routing headers |

### INS_InsuranceClaimsAccess (Named Credential)
| Used By | Purpose |
|---------|---------|
| CMN_Generate_Token_Helper | OAuth token endpoint URL |

### INS_InsuranceClaimsAccessToken (External Credential)
| Used By | Purpose |
|---------|---------|
| CMN_Generate_Token_Helper | client_id & client_secret for OAuth |

---

## 13. Custom Metadata

### INS_Insurance_Lead_Settings__mdt (Record: 'Dialer_Leads')
| Field | Purpose | Used By |
|-------|---------|---------|
| INS_ProductFamily__c | 'Insurance' — eligibility gate | INS_UTIL_LeadConnexSupport, INS_UTIL_LeadTrigger, INS_BATCH_ConnexLead, Controllers |
| INS_LeadType__c | 'SBIB Dialler' — eligibility gate | Same as above |
| INS_LeadDate__c | Threshold date — only leads after this date are processed | Same as above |
| INS_LeadExpireCode__c | Status code sent to Connex when expiring a lead | INS_UTIL_ConnexLeads (PUT payload) |
| INS_HolidayDates__c | Public holiday dates for courtesy SMS logic | INS_UTIL_LeadTrigger (campaign members) |

---

## 14. Custom Objects & Key Fields

### Leads_ProductQueueAllocation__c
| Field | Purpose | Used By |
|-------|---------|---------|
| Leads_Product_Family__c | Product family (e.g., 'Insurance') | isValidProductLead() |
| Lead_Type__c | Lead type (e.g., 'SBIB Dialler') | isValidProductLead() |
| Leads_Product_Name__c | Product name | Reporting |
| Leads_Jurisdiction__c | Jurisdiction filter | Other lead features |

### Lead (Standard Object — Key Custom Fields)
| Field | Purpose | Used By |
|-------|---------|---------|
| Expressed_Interest_Product__c | Lookup to ProductQueueAllocation | Eligibility check |
| Campaign_Source_ID__c | Links to Campaign record | Campaign sync |
| Campaign_Name__c | Populated by trigger from Campaign | Display / payload |
| Referred_System_Reference_Number__c | Connex ID (success) or 'Duplicate' | All processing logic |
| Dialer_Failure_Reason__c | API error message | Failed Leads LWC |
| Dialler_Queue_ID__c | Connex CD List UUID | Payload + validation |
| Dialer_Agent_Id__c | Connex agent identifier | Owner assignment |
| Preferred_Contact_Date_Time__c | Preferred call start | Scheduling logic |
| Preferred_Contact_Date_Time_End__c | Preferred call end | Scheduling logic |
| SA_ID_or_Passport__c | Customer ID/passport | Payload field |
| Loan_Account_Number__c | Loan account | Payload field |
| Stage__c | Lead stage | Status maintenance |

### Campaign (Standard Object — Key Custom Fields)
| Field | Purpose | Used By |
|-------|---------|---------|
| Campaign_Source_ID__c | Unique campaign identifier | Campaign sync, payload |
| Dialler_System_Code__c | Connex queue UUID for campaign | Lead field population |

### Event (Standard Object — Key Custom Fields)
| Field | Purpose | Used By |
|-------|---------|---------|
| Dialer_Agent_Id__c | Agent who made the call | Event_Assign_event_to_Agent flow |

---

## 15. Security & Access Components

### Permission Sets
| Name | Purpose |
|------|---------|
| Lead_Administrator | Full access to lead fields, LWC reports |
| Lead_Referrer | Referrer-level lead access |

### Public Groups
| Name | Purpose |
|------|---------|
| INS_Dialer_Leads_Managers_PG | Controls access to Failed Leads & Expire Leads LWCs |

### External Client App
| Name | Purpose |
|------|---------|
| INS_Connex_CTI | Connex CTI softphone in Service Console |

### Call Center
| Name | Purpose |
|------|---------|
| ConnexOneCXMCallCenter | Soft phone layout (Lead object for inbound/outbound) |

---

## 16. Visual Dependency Graph

```
CMN_TRG_Lead (Trigger)
 └─► CMN_FACTORY_TriggerHandler
      └─► CMN_TRH_Lead (Handler)
           ├─► INS_UTIL_LeadTrigger (Orchestrator)
           │    ├─► INS_SEL_Leads_ProductQueueAllocation ─► Leads_ProductQueueAllocation__c
           │    ├─► INS_Insurance_Lead_Settings__mdt
           │    ├─► SEL_Lead ─► Lead
           │    ├─► SEL_Campaign ─► Campaign
           │    ├─► SEL_User ─► User
           │    ├─► INS_SEL_CampaignMember ─► CampaignMember
           │    └─► INS_UTIL_LeadConnexService
           │         ├─► INS_UTIL_LeadConnexSupport
           │         │    ├─► INS_SEL_Leads_ProductQueueAllocation
           │         │    └─► INS_Insurance_Lead_Settings__mdt
           │         ├─► INS_UTIL_LeadConnexDecisionService
           │         │    └─► INS_UTIL_LeadConnexSupport
           │         └─► INS_BATCH_ConnexLead [ASYNC]
           │              ├─► SEL_Lead
           │              ├─► INS_Insurance_Lead_Settings__mdt
           │              └─► INS_UTIL_ConnexLeads
           │                   ├─► CMN_Generate_Token_Helper
           │                   │    ├─► INS_InsuranceClaimsAccess (Named Cred)
           │                   │    └─► INS_InsuranceClaimsAccessToken (Ext Cred)
           │                   ├─► SEL_User
           │                   ├─► INS_DTO_ConnexLeads (Payload)
           │                   ├─► INS_Leads_API (HTTP)
           │                   │    ├─► INS_Insurance_Leads (Named Cred)
           │                   │    ├─► ESB Leads API [EXTERNAL]
           │                   │    │    └─► ConnexOne Platform [EXTERNAL]
           │                   │    ├─► INS_DTO_ConnexLeadsResponse
           │                   │    └─► INS_DTO_UpdateConnexLeadResponse
           │                   └─► INS_Insurance_Lead_Settings__mdt
           │
           └─► CMN_SEL_Account ─► Account

InsFailedConnexLeads (LWC)
 └─► INS_CTRL_FailedConnexLeads (Controller)
      ├─► SEL_Lead
      ├─► SEL_GroupMember ─► INS_Dialer_Leads_Managers_PG
      ├─► INS_Insurance_Lead_Settings__mdt
      └─► INS_BATCH_ConnexLead [ASYNC] ─► (same chain as above)

InsSbibExpireLeads (LWC)
 └─► INS_CTRL_SbibExpireLeads (Controller)
      ├─► SEL_Lead
      ├─► SEL_GroupMember ─► INS_Dialer_Leads_Managers_PG
      ├─► INS_Insurance_Lead_Settings__mdt
      └─► Lead DML Update ─► CMN_TRG_Lead (re-fires trigger)

Task_Delete_Duplicate_Lead (Flow)
 └─► Triggered by: Task creation (from checkForDuplicates)
      └─► Deletes duplicate Lead record

Event_Assign_event_to_Agent (Flow)
 └─► Triggered by: Event creation (from Connex inbound)
      └─► Assigns Event owner via Dialer_Agent_Id__c

Notification_Alert_to_User (Flow)
 └─► Triggered by: Lead owner change
      └─► Sends custom notification bell

Lead_Allocate (Flow)
 └─► Triggered by: Lead create/update
      └─► Routes lead per allocation rules
```

---

## 17. Cross-Cutting Dependencies Summary

| Dependency | Depended On By (count) |
|------------|----------------------|
| INS_Insurance_Lead_Settings__mdt | 8 classes + 2 LWC controllers |
| SEL_Lead | 5 classes + 2 LWC controllers |
| Lead (object) | All components |
| Leads_ProductQueueAllocation__c | 3 classes (via selector) |
| INS_SEL_Leads_ProductQueueAllocation | 3 classes |
| sbgplatform.fflib_SObjectSelector | All 6 selector classes |
| sbgplatform.fflib_SObjectUnitOfWork | 3 classes |
| INS_Insurance_Leads (Named Cred) | INS_Leads_API |
| INS_InsuranceClaimsAccess (Named Cred) | CMN_Generate_Token_Helper |
| INS_Dialer_Leads_Managers_PG (Group) | 2 LWC controllers |
