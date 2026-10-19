/**
 * @description       : Controller class for generating Visualforce PDF document
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52370
 * @date              : 01-11-2025
 **/
public with sharing class AOB_CTRL_NeedsAnalysisGeneratePDF {
    public AOB_NeedsAnalysisWrapper data { get; set; }
    public AOB_CTRL_NeedsAnalysisGeneratePDF() {
        String jsonInput = ApexPages.currentPage().getParameters().get('jsonString');		     
        if (String.isNotBlank(jsonInput)) {
            data = (AOB_NeedsAnalysisWrapper) JSON.deserialize(jsonInput, AOB_NeedsAnalysisWrapper.class);
        } else {
            data = new AOB_NeedsAnalysisWrapper();
        }
    }   
}