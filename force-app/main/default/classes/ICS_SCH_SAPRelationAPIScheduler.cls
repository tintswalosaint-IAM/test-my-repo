/*************************************************************
* @description SFP-43424 Class used to sap create customer
*
* @autor Ikyatha Naidu
*
* @date Apr 26 2025
***************************************************************
* Last Modified By  Ikyatha Naidu
* Last Modified Date 27/04/2025
* Last Modified Description: updated to latest Version
 ***************************************************************************************
*@Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 19-06-2025
 * @Modification description : SFP-49674
 ***************************************************************************************
*/
public class ICS_SCH_SAPRelationAPIScheduler implements Schedulable {
            private String opportunityId;
            
            public ICS_SCH_SAPRelationAPIScheduler(String opportunityId) {
                this.opportunityId = opportunityId;
            }
            
            public void execute(SchedulableContext sc) {
                // Check if all CIF IDs are updated for this opportunity
                checkAndCallRelationAPI(opportunityId);
                
                // Remove the job from the list of scheduled opportunities
              
                if(sc != null) {
                    System.abortJob(sc.getTriggerId());
                }
            }
            
            private void checkAndCallRelationAPI(String opportunityId) {
                // Get all application forms for this opportunity
                SEL_ApplicationForm formSelector = new SEL_ApplicationForm();
                List<ApplicationForm> forms = formSelector.selectByOpportunityId(opportunityId);
                
                // Check if all accounts have CIF IDs
                Boolean allUpdated = true;
                for(ApplicationForm formData: forms) {
                    if(formData.Account.ExternalCIFId__c == null) {
                        allUpdated = false;
                        break;
                    }
                }
                
                // If all accounts have CIF IDs, call relation API
                if(allUpdated) {
                    if(forms.size() > 1) {
                        // For joint applications
                        for(ApplicationForm formData: forms) {
                            callRelation(formData.accountId, false, 'Joint');
                        }
                        
                        // Get applicants and call relation API for primary applicant
                        List<Applicant> applicantList = new SEL_Applicant().selectPrimaryApplicantByOppIds(new List<String>{opportunityId});
                        for(Applicant applicantRec : applicantList) {
                            if(applicantRec.Role == 'Primary Applicant') {
                                callRelation(applicantRec.AccountId, true, 'Joint');
                            }
                        }
                    } else {
                        // For single applications
                        callRelation(forms[0].accountId, false, 'Single');

                    }
                }
            }
            private void callRelation(String accountId, Boolean isJoint, String customerTypeInfo) {
               
                    ICS_CTRL_SAPCreateRelation relationController = new ICS_CTRL_SAPCreateRelation(
                        accountId,
                        isJoint,
                        customerTypeInfo
                    );
                    System.enqueueJob(relationController);  
                    if(isJoint==false)
                    {
                        ICS_CTRL_InvokeUpdateTIN.processOpportunityFuture(accountId); 
                    }             
            }
        }