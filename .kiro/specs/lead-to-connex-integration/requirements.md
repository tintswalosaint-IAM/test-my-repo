# Requirements Document

## Introduction

This feature replaces SAP CRM functionality in preparation for SAP decommissioning. It enables qualified Salesforce leads to be dispatched directly to Connex for downstream engagement via the Connex Leads API. The integration includes real-time dispatch on lead creation, automated retry of failed leads, a self-service LWC for managing failures, duplicate detection and cleanup, embedded CTI for agent workflows, and MVP2 capabilities for manual lead expiry and agent account ownership.

## Glossary

- **Lead**: A Salesforce Lead record representing a potential customer referral for insurance products.
- **Connex**: The external dialler system that receives leads for agent engagement via its Leads API.
- **Apex_Trigger**: The Salesforce Apex trigger that fires on Lead insert and update events to evaluate eligibility and dispatch leads.
- **Scheduled_Batch_Job**: A Salesforce scheduled Apex batch class that runs every 30 minutes during business hours to retry failed or parked leads.
- **Expiry_Batch_Job**: A Salesforce scheduled Apex batch class that runs every evening at 20:15 to expire retro leads older than 30 days.
- **LWC_Failed_Report**: A Lightning Web Component that displays failed leads and enables manual correction, individual resubmission, and bulk resubmission.
- **LWC_Expiry_Report**: A Lightning Web Component (MVP2) that enables searching and bulk-expiring leads.
- **Duplicate_Detection_Flow**: A Salesforce Flow that evaluates key fields to identify and automatically delete duplicate leads.
- **Eligibility_Evaluator**: The Apex logic that determines whether a lead qualifies for Connex dispatch based on product family, lead type, and date metadata.
- **CTI_Screen**: The Connex Computer Telephony Integration screen embedded within Salesforce for agent call handling.
- **Product_Queue_Allocation**: The Leads_ProductQueueAllocation__c custom object record that associates a lead's expressed interest with a product family and lead type.
- **Insurance_Lead_Settings**: The INS_Insurance_Lead_Settings__mdt custom metadata type containing Dialer_Leads configuration (INS_ProductFamily__c, INS_LeadType__c, INS_LeadDate__c).
- **Named_Credential**: The Salesforce Named Credential storing Connex API authentication details securely.
- **Campaign_Source_ID**: The identifier on a Lead that links the lead to a specific campaign and dialler queue.
- **Referred_System_Reference_Number**: The Connex-assigned identifier stored on the Lead after successful dispatch (Referred_System_Reference_Number__c).
- **Dialer_Failure_Reason**: The field on the Lead record (Dialer_Failure_Reason__c) that stores the reason for a failed Connex dispatch.
- **Agent_Account_Ownership**: A custom object (MVP2) representing banker/agent relationships for lead routing.
- **RETRO_Lead**: A lead with Lead Source value of "RETRO", subject to specific duplicate detection rules.
- **NON_RETRO_Lead**: A lead with a Lead Source value other than "RETRO", subject to standard duplicate detection rules.
- **Preferred_Call_Time**: A field on the Lead indicating the customer's preferred time to be contacted.
- **Business_Hours**: The organisation's defined operating hours during which batch processing and courtesy campaign assignment occur.

## Requirements

### Requirement 1: Lead Eligibility Evaluation

**User Story:** As a campaign manager, I want only qualified leads dispatched to Connex, so that the dialler system receives valid referrals matching insurance product criteria.

#### Acceptance Criteria

1. WHEN a Lead is created or updated, THE Eligibility_Evaluator SHALL determine the Lead is eligible for Connex dispatch only when ALL of the following conditions are true: Expressed_Interest_Product__c is populated, a related Product_Queue_Allocation record exists, the Product_Queue_Allocation Leads_Product_Family__c matches Insurance_Lead_Settings Dialer_Leads.INS_ProductFamily__c, the Product_Queue_Allocation Lead_Type__c matches Insurance_Lead_Settings Dialer_Leads.INS_LeadType__c, and Lead.CreatedDate is on or after Insurance_Lead_Settings Dialer_Leads.INS_LeadDate__c.
2. WHEN a Lead fails any single eligibility condition, THE Eligibility_Evaluator SHALL exclude the Lead from Connex dispatch processing.
3. WHEN a Lead is identified as a duplicate by the Duplicate_Detection_Flow, THE Eligibility_Evaluator SHALL exclude the Lead from Connex dispatch regardless of other eligibility conditions.

### Requirement 2: Real-Time Lead Dispatch via Apex Trigger

**User Story:** As a campaign manager, I want valid leads sent to Connex immediately upon creation, so that agents can engage customers without delay.

#### Acceptance Criteria

1. WHEN a new Lead is inserted and passes eligibility evaluation and has no Preferred_Call_Time set, THE Apex_Trigger SHALL submit the Lead to the Connex Leads API via an HTTP POST request.
2. WHEN a new Lead is inserted and passes eligibility evaluation and has a Preferred_Call_Time in the future, THE Apex_Trigger SHALL queue the Lead for processing by the Scheduled_Batch_Job instead of dispatching immediately.
3. WHEN the Connex API returns a successful response containing a Connex ID, THE Apex_Trigger SHALL store the Connex ID in the Lead's Referred_System_Reference_Number__c field.
4. WHEN the Connex API returns a failure response, THE Apex_Trigger SHALL store the failure reason in the Lead's Dialer_Failure_Reason__c field and set the Lead status to indicate dispatch failure.
5. THE Apex_Trigger SHALL process up to 200 Lead records in a single transaction using bulkified patterns.

### Requirement 3: Lead Update Dispatch

**User Story:** As a campaign manager, I want updated leads re-evaluated and sent to Connex when qualifying changes occur, so that Connex always has current lead data.

#### Acceptance Criteria

1. WHEN an existing Lead is updated and the Campaign_Source_ID or key eligibility fields change and the Lead passes eligibility evaluation, THE Apex_Trigger SHALL re-evaluate the Lead for Connex dispatch.
2. WHEN a Lead that already has a Referred_System_Reference_Number__c is re-dispatched, THE Apex_Trigger SHALL send the update to the Connex Leads API via an HTTP PUT request.
3. WHEN a Lead that does not have a Referred_System_Reference_Number__c is dispatched after an update, THE Apex_Trigger SHALL send the Lead to the Connex Leads API via an HTTP POST request.
4. WHEN the Campaign_Source_ID changes on an updated Lead, THE Apex_Trigger SHALL update the associated Campaign Member records accordingly.

### Requirement 4: Scheduled Batch Retry of Failed Leads

**User Story:** As an operations manager, I want failed leads automatically retried, so that transient errors do not require manual intervention.

#### Acceptance Criteria

1. THE Scheduled_Batch_Job SHALL execute every 30 minutes during Business_Hours.
2. WHEN the Scheduled_Batch_Job executes, THE Scheduled_Batch_Job SHALL query all Leads with a dispatch failure status or a parked status and resubmit each Lead to the Connex Leads API.
3. WHEN a Lead has a Dialer_Failure_Reason__c indicating an invalid mobile number, THE Scheduled_Batch_Job SHALL exclude the Lead from automated retry processing.
4. WHEN the Scheduled_Batch_Job successfully dispatches a previously failed Lead, THE Scheduled_Batch_Job SHALL update the Lead's Referred_System_Reference_Number__c and clear the Dialer_Failure_Reason__c field.
5. WHEN a Lead has a Preferred_Call_Time that has been reached or passed, THE Scheduled_Batch_Job SHALL include the Lead in the current batch execution for dispatch.

### Requirement 5: Scheduled Batch Lead Expiry

**User Story:** As an operations manager, I want retro leads older than 30 days automatically expired, so that stale leads do not remain active in the dialler.

#### Acceptance Criteria

1. THE Expiry_Batch_Job SHALL execute every evening at 20:15.
2. WHEN the Expiry_Batch_Job executes, THE Expiry_Batch_Job SHALL identify all RETRO_Lead records older than 30 days that have not been converted or closed and set their status to expired.

### Requirement 6: LWC Failed Report

**User Story:** As a campaign team member, I want to view and manage failed leads in a report, so that I can correct data issues and resubmit leads without developer assistance.

#### Acceptance Criteria

1. THE LWC_Failed_Report SHALL display all Leads with a dispatch failure status, showing the Lead name, mobile number, campaign source, failure reason, and created date.
2. WHEN a user selects a single Lead in the LWC_Failed_Report and clicks resubmit, THE LWC_Failed_Report SHALL invoke the Connex dispatch logic for the selected Lead.
3. WHEN a user selects multiple Leads in the LWC_Failed_Report and clicks bulk resubmit, THE LWC_Failed_Report SHALL invoke the Connex dispatch logic for all selected Leads.
4. WHEN a user edits a Lead's data fields in the LWC_Failed_Report and saves, THE LWC_Failed_Report SHALL persist the updated field values to the Lead record.
5. THE LWC_Failed_Report SHALL be accessible only to users who are members of the INS_Dialer_Leads_Managers_PG public group and hold the Lead_Administrator permission set.

### Requirement 7: Duplicate Detection and Handling

**User Story:** As a campaign manager, I want duplicate leads detected and removed automatically, so that agents do not contact the same customer multiple times.

#### Acceptance Criteria

1. WHEN a new Lead is inserted, THE Apex_Trigger SHALL evaluate the Lead for duplicates using the combination of formatted Mobile Phone, Last Name, and Campaign_Source_ID.
2. WHEN a RETRO_Lead is identified as a duplicate of an existing Lead that has a status of New, Working, or Waiting and was created within the last 30 days, THE Duplicate_Detection_Flow SHALL mark the new Lead for deletion.
3. WHEN a NON_RETRO_Lead is identified as a duplicate of an existing active Lead created within the last 30 days, THE Duplicate_Detection_Flow SHALL mark the new Lead for deletion.
4. WHEN a duplicate Lead is identified, THE Apex_Trigger SHALL create a Task record on the existing Lead documenting the duplicate detection event.
5. WHEN a Lead is marked for deletion by duplicate detection, THE Duplicate_Detection_Flow SHALL delete the duplicate Lead record.

### Requirement 8: Phone Number Formatting

**User Story:** As a system administrator, I want mobile numbers normalised on lead creation and update, so that duplicate detection and API dispatch use consistent phone formats.

#### Acceptance Criteria

1. WHEN a Lead is inserted or updated with a mobile phone value, THE Apex_Trigger SHALL format the mobile phone number to the standard South African format before persisting the record.
2. WHEN a Lead's mobile phone number is already in the standard South African format, THE Apex_Trigger SHALL retain the existing value without modification.

### Requirement 9: Campaign Synchronisation

**User Story:** As a campaign manager, I want leads automatically linked to the correct campaign and dialler queue, so that campaign reporting is accurate and agents receive leads in the correct queue.

#### Acceptance Criteria

1. WHEN a Lead is inserted or updated with a Campaign_Source_ID, THE Apex_Trigger SHALL set the Lead's Campaign Name and Dialler Queue ID based on the matching campaign configuration.
2. WHEN a Lead passes eligibility evaluation after insert, THE Apex_Trigger SHALL create a Campaign Member record linking the Lead to the source campaign.
3. WHEN a Lead is created during Business_Hours, THE Apex_Trigger SHALL additionally create a courtesy Campaign Member record.
4. WHEN a Lead's Campaign_Source_ID changes on update, THE Apex_Trigger SHALL update or replace the existing Campaign Member records to reflect the new campaign.

### Requirement 10: Lead Status Management

**User Story:** As an operations manager, I want lead statuses updated automatically based on qualification and account ownership, so that the lead lifecycle is accurately tracked.

#### Acceptance Criteria

1. WHEN a Lead has a Referred_System_Reference_Number__c populated and has no associated Account and is in a qualified status, THE Apex_Trigger SHALL update the Lead status to "Onboarding".
2. WHEN a Lead's Dialer Agent ID changes on update, THE Apex_Trigger SHALL reassign the Lead Owner to the user matching the new Dialer Agent ID.

### Requirement 11: Connex CTI Embedded Screen

**User Story:** As a sales agent, I want the Connex CTI screen embedded within Salesforce, so that I can handle calls without switching between applications.

#### Acceptance Criteria

1. THE CTI_Screen SHALL be embedded within the Salesforce Lightning interface as an iframe or Open CTI integration.
2. WHEN a lead outcome is recorded in Connex via the CTI_Screen, THE CTI_Screen SHALL update the corresponding Salesforce Lead status automatically.
3. WHEN an agent interacts with a lead via the CTI_Screen, THE CTI_Screen SHALL create Event records tracking contact history and agent engagement on the Lead.

### Requirement 12: Error Handling and Categorisation

**User Story:** As an operations manager, I want API errors categorised by type, so that the system can apply the correct retry strategy and users can identify actionable failures.

#### Acceptance Criteria

1. WHEN the Connex API returns an HTTP 502 response, THE Apex_Trigger SHALL mark the Lead for automated retry by the Scheduled_Batch_Job.
2. WHEN the Connex API returns an HTTP 500 response, THE Apex_Trigger SHALL mark the Lead for manual retry via the LWC_Failed_Report.
3. WHEN the Connex API returns a validation error indicating an invalid mobile number, THE Apex_Trigger SHALL mark the Lead as requiring manual correction and exclude the Lead from automated retry.
4. IF the Connex API is unreachable due to a transport error, THEN THE Apex_Trigger SHALL mark the Lead for automated retry by the Scheduled_Batch_Job and log the transport error details in Dialer_Failure_Reason__c.

### Requirement 13: Security and Access Control

**User Story:** As a system administrator, I want access to lead management features controlled by permission sets and public groups, so that only authorised users can view and modify sensitive lead data.

#### Acceptance Criteria

1. THE Named_Credential SHALL store Connex API authentication credentials securely, separate from application code.
2. THE LWC_Failed_Report SHALL enforce access restrictions based on membership in the INS_Dialer_Leads_Managers_PG public group and the Lead_Administrator permission set.
3. THE Apex_Trigger SHALL respect Field-Level Security settings when reading and writing PII fields on Lead records.
4. THE Lead object SHALL have Field History Tracking enabled for the Status, Stage, Lead Owner, and Lead Source fields.

### Requirement 14: Idempotency and Duplicate Dispatch Prevention

**User Story:** As a system administrator, I want the integration to prevent duplicate dispatches to Connex, so that leads are not sent multiple times causing data inconsistency in the dialler.

#### Acceptance Criteria

1. THE Apex_Trigger SHALL use the Lead's Referred_System_Reference_Number__c as a stable external reference to determine whether a Lead has already been dispatched to Connex.
2. WHEN a Lead already has a Referred_System_Reference_Number__c and is re-dispatched, THE Apex_Trigger SHALL use an HTTP PUT request to update the existing Connex record rather than creating a new one.

### Requirement 15: Manual Lead Expiry (MVP2)

**User Story:** As a campaign manager, I want to search for and bulk-expire leads manually, so that I can manage lead lifecycle for non-retro campaigns without batch dependency.

#### Acceptance Criteria

1. THE LWC_Expiry_Report SHALL provide search filters for Lead status, campaign source, created date range, and lead source.
2. WHEN a user selects multiple Leads in the LWC_Expiry_Report and clicks expire, THE LWC_Expiry_Report SHALL update all selected Lead records to an expired status.
3. THE LWC_Expiry_Report SHALL be accessible only to users with the Lead_Administrator permission set.

### Requirement 16: Agent Account Ownership (MVP2)

**User Story:** As a team lead, I want banker/agent relationships stored in a custom object, so that leads can be routed to the correct agent based on account ownership.

#### Acceptance Criteria

1. THE Agent_Account_Ownership object SHALL store the relationship between a banker (Account owner) and an assigned agent (User).
2. WHEN a Lead is qualified and an Agent_Account_Ownership record exists matching the Lead's associated Account, THE Apex_Trigger SHALL assign the Lead Owner to the agent defined in the Agent_Account_Ownership record.

### Requirement 17: Test Coverage

**User Story:** As a developer, I want comprehensive test coverage for all Apex code, so that deployments meet organisational quality standards and regressions are caught early.

#### Acceptance Criteria

1. THE Apex_Trigger and all supporting Apex classes SHALL maintain a minimum of 85% code coverage through unit tests.
2. THE unit tests SHALL cover bulk scenarios processing 200 Lead records in a single transaction.
3. THE unit tests SHALL verify all error handling paths including HTTP 500, HTTP 502, transport errors, and validation failures.
