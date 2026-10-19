/**
* @File Name : UG_AOB_PPB_ApplicationStages.cls
* @Description : Apex class to hold the values of the Stages.
* @Author : Narendra G
* @Last Modified By : jagadish Thummala
* @Last Modified On : 10-29-2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | July 20, 2025 |   | Initial Version
**/

public with sharing class UG_AOB_PPB_ApplicationStages {

    // Self Assist application stages
    public static final String STAGE_PERSONAL_DETAILS         = 'UG AOB PPB Personal Details';
    public static final String STAGE_IDENTIFII                = 'UG AOB PPB Identifii';
    public static final String STAGE_UPLOAD_PICTURE           = 'UG AOB PPB Upload Picture';
    public static final String STAGE_ADDRESS_DETAILS          = 'UG AOB PPB Address Details';
    public static final String STAGE_EMPLOYMENT_DETAILS       = 'UG AOB PPB Employment Details';
    public static final String STAGE_ALTERNATIVE_MODE_PAYMENT = 'UG AOB PPB Alternative Mode of Payment';
    public static final String STAGE_APPLICATION_SUMMARY      = 'UG AOB PPB Application Summary'; 
    public static final String STAGE_CIF_CREATED              = 'UG AOB PPB CIF Created';
    public static final String STAGE_OD_ACCOUNT_CREATION      = 'UG AOB PPB OD Account Creation';
    public static final String STAGE_QNA                      = 'UG AOB PPB QNA';
    public static final String STAGE_FUND_ACCOUNT             = 'UG AOB PPB Fund Account';          
    public static final String STAGE_CONGRATULATIONS          = 'UG AOB PPB Congratulations';


    /**
     * @return the list of Self Assist application stages, in order
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getStageMap() {
        try {
            return new Map<String,String>{
                'PERSONAL_DETAILS'         => STAGE_PERSONAL_DETAILS,
                'IDENTIFII'                => STAGE_IDENTIFII,
                'UPLOAD_PICTURE'           => STAGE_UPLOAD_PICTURE,
                'ADDRESS_DETAILS'          => STAGE_ADDRESS_DETAILS,
                'EMPLOYMENT_DETAILS'       => STAGE_EMPLOYMENT_DETAILS,
                'ALTERNATIVE_MODE_PAYMENT' => STAGE_ALTERNATIVE_MODE_PAYMENT,
                'APPLICATION_SUMMARY'      => STAGE_APPLICATION_SUMMARY,
                'CIF_CREATED'              => STAGE_CIF_CREATED,
                'OD_ACCOUNT_CREATION'      => STAGE_OD_ACCOUNT_CREATION,
                'QNA'                      => STAGE_QNA,
                'FUND_ACCOUNT'             => STAGE_FUND_ACCOUNT,         
                'CONGRATULATIONS'          => STAGE_CONGRATULATIONS
            };
        } catch (Exception e) {
            throw new AuraHandledException('Failed to load application stages: ' + e.getMessage());
        }
    }

}