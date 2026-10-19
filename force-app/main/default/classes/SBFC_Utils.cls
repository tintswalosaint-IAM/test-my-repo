/**
* @File Name : SBFC_Utils.cls
* @Description : SFP-54443 - Utility class for reuseability code .
* @Author : Amlendu Bajpai
* @Last Modified By :Amlendu Bajpai
* @Last Modified On : November 10, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | November 10, 2025 |   | Initial Version
**/

public inherited sharing class SBFC_Utils {
    /**
     * @description constructor method
     * */
	private SBFC_Utils() {}
    
    // Constants — single source of truth for record names
    private static final String LEGAL_BASIS_NAME        = 'Disclosure Data Use Legal Basis';
    private static final String DATA_USE_PURPOSE_NAME   = 'Disclosure - Authorization Form Text';
    private static final String AUTH_FORM_NAME          = 'Disclosure - Authorization Form';
    private static final String AUTH_FORM_TEXT_NAME     = 'Disclosure - Authorization Form Text';
    private static final String AUTH_FORM_DATA_USE_NAME = 'Disclosure - Authorization Form Data Use';
    private static final Id RECORD_TYPE_INFOAUTHREQUEST = InfoAuthorizationRequest.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('SBFC').getRecordTypeId();
    
    /**
     * @description method to create InfoAuthorization Request
     * @param Account as input
     * @return InfoAuthorizationRequest as response
     * */
    
    public static InfoAuthorizationRequest createDisclosureInfoAuthorizationRequest(Account account) {

        DataUseLegalBasis legal        = getOrCreateLegalBasis();
        DataUsePurpose dup             = getOrCreateDataUsePurpose(legal.Id);
        AuthorizationForm af           = getOrCreateAuthorizationForm();
        AuthorizationFormText aft      = getOrCreateAuthorizationFormText(af);
        getOrCreateAuthorizationFormDataUse(dup.Id, af.Id);
        if(af.DefaultAuthFormTextId == NULL){
            af.DefaultAuthFormTextId = aft.Id;
            sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
            uow.registerDirty(af);
            uow.commitWork();
        }

        // Ensure the DataUsePurpose is active
        if (!dup.IsActive) {
            dup.IsActive = true;
            sbgplatform.fflib_ISObjectUnitOfWork uowdup = ORG_Application.unitOfWork.newInstance();
            uowdup.registerDirty(dup);
        	uowdup.commitWork();
        }

        InfoAuthorizationRequest infoAuthReq = new InfoAuthorizationRequest();
        infoAuthReq.RecordTypeId      = RECORD_TYPE_INFOAUTHREQUEST;
        infoAuthReq.SBFC_Account__c   = account.Id;
        infoAuthReq.SourceRecordId    = account.Id;
        infoAuthReq.PertainsToId      = account.Id;
        infoAuthReq.ConsenterId       = account.Id;
        infoAuthReq.Name              = account.Name + ' Moonstone Disclosure';
        infoAuthReq.RequesterId       = UserInfo.getUserId();
        infoAuthReq.DataUsePurposeId  = dup.Id;
        infoAuthReq.Locale            = 'en_US';
        infoAuthReq.CommunicationType = 'Email';
        infoAuthReq.ResponseStatus    = 'New';
        return infoAuthReq;
    }
    
    /**
     * @description Returns the existing Disclosure DataUseLegalBasis or creates it.
     */
    private static DataUseLegalBasis getOrCreateLegalBasis() {
        List<DataUseLegalBasis> existing =
            new SEL_DataUseLegalBasis().selectByName(LEGAL_BASIS_NAME);
        if (!existing.isEmpty()) {
            return existing[0];
        }
        DataUseLegalBasis legal = new DataUseLegalBasis();
        legal.Name = LEGAL_BASIS_NAME;
        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerNew(legal);
        uow.commitWork();
        return legal;
    }

    /**
     * @description Returns the existing Disclosure DataUsePurpose or creates it.
     * @param legalBasisId Id of the parent DataUseLegalBasis
     */
    private static DataUsePurpose getOrCreateDataUsePurpose(Id legalBasisId) {
        List<DataUsePurpose> existing =
            new SEL_DataUsePurpose().selectByName(DATA_USE_PURPOSE_NAME);
        if (!existing.isEmpty()) {
            return existing[0];
        }
        DataUsePurpose dup = new DataUsePurpose();
        dup.Name         = DATA_USE_PURPOSE_NAME;
        dup.LegalBasisId = legalBasisId;
        dup.IsActive     = false;   // activated after the framework is complete
        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerNew(dup);
        uow.commitWork();
        return dup;
    }

    /**
     * @description Returns the existing Disclosure AuthorizationForm or creates it.
     */
    private static AuthorizationForm getOrCreateAuthorizationForm() {
        List<AuthorizationForm> existing =
            new SEL_AuthorizationForm().selectByName(AUTH_FORM_NAME);
        if (!existing.isEmpty()) {
            return existing[0];
        }
        AuthorizationForm af = new AuthorizationForm();
        af.Name = AUTH_FORM_NAME;
        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerNew(af);
        uow.commitWork();
        return af;
    }

    /**
     * @description Returns the existing Disclosure AuthorizationFormText or creates it,
     *              and ensures it is set as the AuthorizationForm's default text.
     * @param af The parent AuthorizationForm
     */
    private static AuthorizationFormText getOrCreateAuthorizationFormText(AuthorizationForm af) {
        List<AuthorizationFormText> existing =
            new SEL_AuthorizationFormText().selectByName(AUTH_FORM_TEXT_NAME);
        if (!existing.isEmpty()) {
            return existing[0];
        }
        AuthorizationFormText aft = new AuthorizationFormText();
        aft.Name                = AUTH_FORM_TEXT_NAME;
        aft.Locale              = 'en_ZA';
        aft.AuthorizationFormId = af.Id;
        aft.IsActive            = true;
        aft.SummaryAuthFormText = 'Disclosure';
        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerNew(aft);
        uow.commitWork();

        // Set as the form's default text
        af.DefaultAuthFormTextId = aft.Id;
        sbgplatform.fflib_ISObjectUnitOfWork uow1 = ORG_Application.unitOfWork.newInstance();
        uow1.registerDirty(af);
        uow1.commitWork();

        return aft;
    }

    /**
     * @description Returns the existing Disclosure AuthorizationFormDataUse or creates it.
     * @param dataUsePurposeId    Id of the DataUsePurpose
     * @param authorizationFormId Id of the AuthorizationForm
     */
    private static AuthorizationFormDataUse getOrCreateAuthorizationFormDataUse(
            Id dataUsePurposeId, Id authorizationFormId) {
        List<AuthorizationFormDataUse> existing =
            new SEL_AuthorizationFormDataUse().selectByName(AUTH_FORM_DATA_USE_NAME);
        if (!existing.isEmpty()) {
            return existing[0];
        }
        AuthorizationFormDataUse afDu = new AuthorizationFormDataUse();
        afDu.Name                = AUTH_FORM_DATA_USE_NAME;
        afDu.DataUsePurposeId    = dataUsePurposeId;
        afDu.AuthorizationFormId = authorizationFormId;
        sbgplatform.fflib_ISObjectUnitOfWork uow1 = ORG_Application.unitOfWork.newInstance();
        uow1.registerNew(afDu);
        uow1.commitWork();
        return afDu;
    }
}