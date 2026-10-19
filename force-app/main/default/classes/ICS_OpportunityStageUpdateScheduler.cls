/**
 * @description       : SFP-52492 This schedulable Apex class automatically updates the Stage of a specific Opportunity 
 * to "Document Upload" once all related Application Forms have reached the 
 * "Awaiting Document Upload" stage.
 * @author            : Ramya Gurram
 * @ last modified on  : 10-16-2025
 * To provide access to flows triggered by community user and also to avoid issues around licensing we used without sharing
 **/
public without sharing class ICS_OpportunityStageUpdateScheduler implements Schedulable {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_OpportunityStageUpdateScheduler');
    private String opportunityId;

    public ICS_OpportunityStageUpdateScheduler(String opportunityId) {
        this.opportunityId = opportunityId;
    }
    public void execute(SchedulableContext sc) {
        List < Opportunity > oppsToUpdate = new List < Opportunity > ();
        SEL_Opportunity oppSelector = new SEL_Opportunity();
        opportunity oppData = oppSelector.selectById(opportunityId);
        Boolean allDocsUploaded = true;
        SEL_ApplicationForm selectApplicationForm = new SEL_ApplicationForm();
        List < ApplicationForm > forms = selectApplicationForm.selectByOpportunityId(oppData.id);
        for (ApplicationForm appForm: forms) {
            if (appForm.Stage != 'Awaiting Document Upload') {
                allDocsUploaded = false;
                break;
            }
        }

        if (allDocsUploaded && oppData.StageName == 'Risk Rating') {
            oppData.StageName = 'Documents upload';
            oppsToUpdate.add(oppData);
        }

        if (!oppsToUpdate.isEmpty()) {
            update oppsToUpdate;
        }
    }
}