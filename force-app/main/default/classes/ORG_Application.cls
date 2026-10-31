/***************************************************************************************
@Name of the Component : ORG_Application
@description: Main application factory class which is responsible for returning the correct business implementation for the unit
 of work, service, selector and domain layers within the application.
 NOTE: Please add values to selector and service in ALPHABETICAL order, to prevent duplicates
 Values for unitOfWork have to to be in execution order
/***************************************************************************************
@Last Modified By : Jaco de Lange
@Last Modified On : 10-16-2025
@Modification description: added contact and permissionsetassignment for selector variable
 User Story: SFP-53279
/***************************************************************************************
@Last Modified By : Jaco de Lange
@Last Modified On : 17-10-2025
@Modification description: added case object for selector variable
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 18 August 2025
@Modification description: deleted SuppressWarnings
 User Story: BCBSFSA-496 | BCBSFSA-532
/***************************************************************************************
@Last Modified By : Irshad Alam
@Last Modified On : 09 September 2025
@Modification description: SFP-53615: Added CMN_WebserviceCallQueue__c in unitOfWorkRegisteredTypes method. 
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 15 October 2025
@Modification description: Added SEL_ServiceTeam and SEL_ServiceType selector classes to selector factory
 for technical review - replace inline SOQL with selector pattern
User Story: SFP-53311
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 21 October 2025
@Modification description: Added Case object for unitOfWorkRegisteredTypes method
 User Story: BCBSFSA-429 | BCBSFSA-641
/***************************************************************************************
@Last Modified By : Jaco de Lange
@Last Modified On : 10-16-2025
@Modification description: Added contact and permission set assignment for selector variable
User Story: SFP-53279
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 10-03-2026
@Modification description: Added User.SObjectType => SEL_User.class to selector factory
 User Story: SFP-55654
/***************************************************************************************
* @Last Modified By : Alexandr Goryachko
* @Last Modified Date : 17/12/2025
* @Last Modified Description : Added Account, Quote, InsurancePolicy, Opportunity objects
* @User Story : SFP-53455
/***************************************************************************************
* @Last Modified By : Alex Niyonsaba
* @Last Modified Date : 28/04/2026
* @Last Modified Description : FinServ__FinancialAccount__Share.SObjectType
* @User Story : SFP-57683
/***************************************************************************************
* @Last Modified By : Raymond Magezi
* @Last Modified Date : 20/05/2026
* @Last Modified Description : Added SurveyInvitation to unitOfWork
* @User Story : SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi & Fanele Ndzoko
@Last Modified On : 03-July-2026
@Modification description: Added PublicComplaint.SObjectType and VoiceCall.SObjectType to
 unitOfWorkRegisteredTypes to support invocable Apex DML via fflib Unit of Work pattern.
 These types were previously unsupported by the flow engine's internal Unit of Work,
 causing runtime errors in SVC_CaseManualCaseCreation flow.
 User Story: SIT Fix - SObject type PublicComplaint/VoiceCall not supported by unit of work
 User Story: PPBSF-770 : Added User.SObjectType to ensure that mapping exists.
/***************************************************************************************
* @Last Modified By : Anuja alli
* @Last Modified Date : 13 Aug 2026
* @Last Modified Description : Added Appplication, Application_Participant__c,Individual.SObjectType to
*   unitOfWorkRegisteredTypes.
* @User Story : SFP-53980
/***************************************************************************************
* @Last Modified By : Amlendu Bajpai
* @Last Modified Date : 08/07/2026
* @Last Modified Description : DataUseLegalBasis.SObjectType,DataUsePurpose.SObjectType,AuthorizationForm.SObjectType, AuthorizationFormText.SObjectType,AuthorizationFormDataUse.SObjectType, 
                               InfoAuthorizationRequest.SObjectType, ContentVersion.SObjectType,ContentDocumentLink.SObjectType,FeedItem.SObjectType
* @User Story : SFP-54443
/***************************************************************************************/
/* @Last Modified By : Given Khupai
* @Last Modified Date : 20/08/2026
* @Last Modified Description : Re-added CMN_CaseMilestoneMetric__c.SObjectType to
*   unitOfWorkRegisteredTypes - it had dropped out of this org, which was silently
*   breaking INS_SRV_CaseMilestoneMetrics metric inserts/updates
* @User Story : SFP-55625
/***************************************************************************************/
/* @Last Modified By : Shams Arifeen
* @Last Modified Date : 21/08/2026
* @Last Modified Description : Added Producer.SObjectType to unitOfWorkRegisteredTypes.
* @User Story : SFP-60046
/***************************************************************************************/
/* @Last Modified By : Given Khupai
* @Last Modified Date : 27/10/2026
* @Last Modified Description : Added CMN_History_Tracker__c.SObjectType to
*   unitOfWorkRegisteredTypes so INS_SRV_CaseTransferHistory can insert Case
*   transfer history records through the Unit of Work
* @User Story : SFP-51816
/***************************************************************************************/
public without sharing class ORG_Application {
    
    public static final sbgplatform.fflib_Application.SelectorFactory selector = new sbgplatform.fflib_Application.SelectorFactory(
        new Map<SObjectType, Type> {
            AOB_FlowScreen__c.SObjectType => SEL_AOBScreen.class,
            AOB_Field__c.SObjectType => SEL_AOBField.class,
            AOB_ScreenSection__c.SObjectType => SEL_AOBSection.class,
            Lead.SObjectType => AOB_BOTS_SEL_Lead.class,
            Application__c.SObjectType => AOB_BOTS_SEL_Application.class,
            Application_Participant__c.SObjectType => AOB_BOTS_SEL_ApplicationParticipant.class,
            Application_Document__c.SObjectType => AOB_BOTS_SEL_ApplicationDocument.class,
            Application_Line_Item__c.SObjectType => AOB_BOTS_SEL_ApplicationLineItem.class,
            ContentDocumentLink.SObjectType => AOB_BOTS_SEL_ContentDocumentLink.class,
            ContentVersion.SObjectType => AOB_BOTS_SEL_ContentVersion.class,
            NamedCredential.SObjectType => AOB_BOTS_SEL_NamedCredential.class,
            Case.sObjectType => SEL_Case.class,
            SVC_ServiceTeam__c.SObjectType => SEL_ServiceTeam.class,
            SVC_ServiceType__c.SObjectType => SEL_ServiceType.class,
            User.SObjectType => SEL_User.class
        });
    
    public static final sbgplatform.fflib_Application.ServiceFactory service = new sbgplatform.fflib_Application.ServiceFactory(
        new Map<Type, Type> {
            SRV_INS_Quote_Application.IService.class=>SRV_INS_Quote_Application.class,
            AOB_BOTS_SRV_Application.IService.class=>AOB_BOTS_SRV_Application.class,
            AOB_BOTS_SRV_Verification.IService.class=>AOB_BOTS_SRV_Verification.class,
            AOB_BOTS_SRV_ApplicationParticipant.IService.class => AOB_BOTS_SRV_ApplicationParticipant.class,
            KYC_SRV_PartyProfile.IService.class => KYC_SRV_PartyProfile.class,
            KYC_SRV_PartyProfileAddress.IService.class => KYC_SRV_PartyProfileAddress.class,
            KYC_SRV_PartyIdentityVerification.IService.class => KYC_SRV_PartyIdentityVerification.class,
            KYC_SRV_PartyScreeningSummary.IService.class => KYC_SRV_PartyScreeningSummary.class,
            KYC_SRV_PartyScreeningSummaryStep.IService.class => KYC_SRV_PartyScreeningSummaryStep.class,
            KYC_SRV_PartyIdentityVerificationStep.IService.class => KYC_SRV_PartyIdentityVerificationStep.class,
            AOB_BOTS_SRV_CMNWebserviceCallQueue.IService.class=>AOB_BOTS_SRV_CMNWebserviceCallQueue.class
        });
    
    public static final List<SObjectType> unitOfWorkRegisteredTypes = new List<SObjectType> {
        CMN_Request__c.SobjectType,
        CMN_WebserviceCallQueue__c.SObjectType,
        Contact.SObjectType,
        Account.SObjectType,
        Case.SObjectType,
        CMN_CaseMilestoneMetric__c.SObjectType,
        CMN_History_Tracker__c.SObjectType,
        Quote.SObjectType,
        TaxDetails__c.SObjectType,
        InsurancePolicy.SObjectType,
        InsurancePolicyParticipant.SObjectType,
        InsurancePolicyCoverage.SObjectType,
        Opportunity.SObjectType,
        OpportunityLineItem.SObjectType,
        Producer.SObjectType,
        CaseComment.SObjectType,
        Lead.SObjectType,
        PartyProfile.SObjectType,
        PartyProfileAddress.SObjectType,
        PartyProfileRisk.SObjectType,
        PartyIdentityVerification.SObjectType,
        PartyScreeningSummary.SObjectType,
        PartyScreeningStep.SObjectType,
        PartyIdentityVerificationStep.SObjectType,
        PermissionSetAssignment.sObjectType,
        SurveyInvitation.SObjectType,
        User.SObjectType,
        FinServ__FinancialAccount__Share.SObjectType,
        PublicComplaint.SObjectType,
        VoiceCall.SObjectType,
        DataUseLegalBasis.SObjectType,
        DataUsePurpose.SObjectType,
        AuthorizationForm.SObjectType,
        AuthorizationFormText.SObjectType,
        AuthorizationFormDataUse.SObjectType,
        InfoAuthorizationRequest.SObjectType,
        ContentVersion.SObjectType,
        ContentDocumentLink.SObjectType,
        FeedItem.SObjectType,
        Application__c.SObjectType,
        Application_Participant__c.SObjectType,
        Individual.SObjectType
    };

    public static final sbgplatform.fflib_Application.UnitOfWorkFactory unitOfWork = new sbgplatform.fflib_Application.UnitOfWorkFactory(
        unitOfWorkRegisteredTypes
    );
}