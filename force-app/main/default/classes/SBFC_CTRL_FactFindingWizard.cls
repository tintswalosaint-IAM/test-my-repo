/**
 * @description       : This class serves as the controller for the Fact Finding Wizard in the SBFC application. It provides methods to retrieve and manipulate data related to Application Forms, Party Profiles, Application Form Products, and Assets and Liabilities. The class ensures that all operations are performed with proper access checks and error handling to maintain data integrity and security.
 * @author            : Gul
 * @group             : SBFC
 * @last modified on  : 03-16-2026
 * @last modified by  : Gul
**/
public with sharing class SBFC_CTRL_FactFindingWizard {
    
    @testVisible
    private static Boolean FORCE_NO_ACCESS = false;

    //Logger Class
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_CTRL_FactFindingWizard.class.getName());

    /**
     * @description: Get Application Form Data by Lead Id
     * @author: Gul
     * @param leadId
     * @return ApplicationForm
     */
    @AuraEnabled
    public static ApplicationForm getApplicationFormData(String leadId){
        try {
            // Ensure the main object is accessible
            if (!Schema.sObjectType.ApplicationForm.isAccessible()) {
                return null;
            }

            // Check access for child objects before including related subqueries
            Boolean canAccessApplicant = Schema.sObjectType.Applicant != null && Schema.sObjectType.Applicant.isAccessible();
            Boolean canAccessPartyProfile = Schema.sObjectType.PartyProfile != null && Schema.sObjectType.PartyProfile.isAccessible();
            Boolean canAccessAppFormProduct = Schema.sObjectType.ApplicationFormProduct != null && Schema.sObjectType.ApplicationFormProduct.isAccessible();
            Boolean canAccessAssets = Schema.sObjectType.FinServ__AssetsAndLiabilities__c != null && Schema.sObjectType.FinServ__AssetsAndLiabilities__c.isAccessible();

            // Base fields for ApplicationForm
            String soql = 'SELECT Id, CreatedDate, LastModifiedDate, SBFC_Application_Type__c, SBFC_Sale_Region__c, LeadId, SBFC_Atchd_Prof_of_Vld_Cust_Astute_Cnsnt__c, SBFC_Atchd_Latst_Retirement_Benefit_Stmt__c, Lead.FinServ__RelatedAccount__c, Lead.FinServ__RelatedAccount__r.Name, SBFC_Sales_Manager_Principle__c, SBFC_Business_Planning__c, SBFC_Estate_Planning__c, SBFC_Investment_Planning__c, SBFC_Retirement_Planning__c, SBFC_Risk_Planning__c, SBFC_DoYouHaveTrust__c, SBFC_DoYouHaveWill__c, SBFC_DoYouHaveBusiness__c';

            // Include Applicants subquery only if Applicant is accessible; include PartyProfile sub-subquery only if PartyProfile is accessible
            if (canAccessApplicant) {
                String applicantSub = ', (SELECT Id, FirstName, LastName, SBFC_SAIDNumber__c, SBFC_PassportNumber__c, Email, SBFC_SmokersStatus__c, SBFC_ResidentialAddress__Street__s, SBFC_ResidentialAddress__City__s, SBFC_ResidentialAddress__PostalCode__s, SBFC_ResidentialAddress__StateCode__s, SBFC_ResidentialAddress__CountryCode__s, SBFC_MaritalStatusRegime__c, SBFC_MaritalDate__c, SBFC_DivorcedObligations__c, SBFC_Qualification__c, SBFC_Occupation__c, SBFC_RetirementAge__c, SBFC_AdminWork__c, SBFC_TravelWork__c, SBFC_ManualWork__c, SBFC_TotalWork__c, SBFC_WillExecutor__c, SBFC_OffshoreAssetsPresent__c, SBFC_BequestsSpouse__c, SBFC_BequestsOthers__c, SBFC_CashBequests__c, SBFC_DoYouHaveAnyOutstandingDebts__c, SBFC_Overdraft__c, SBFC_CreditCards__c, SBFC_PersonalLoansIncludingTrustLoans__c, SBFC_ClothingAccounts__c, SBFC_SuretyGuaranteeSigned__c, SBFC_Salary__c, SBFC_CarAllowance__c, SBFC_Bonus__c, SBFC_Dividends__c, SBFC_Interest__c, SBFC_Other__c, SBFC_Household_Expenses__c, SBFC_Vehicle_installment__c, SBFC_Home_Loan__c, SBFC_Medical_expenses__c, SBFC_Income_Tax__c';
                if (canAccessPartyProfile) {
                    applicantSub += ', (SELECT Id, FirstName, LastName, SBFC_SAIDNumber__c, DateOfBirth, WI_Email__c, SBFC_ResidentialAddress__Street__s, SBFC_ResidentialAddress__City__s, SBFC_ResidentialAddress__StateCode__s, SBFC_ResidentialAddress__PostalCode__s, SBFC_ResidentialAddress__CountryCode__s, SBFC_RetirementAge__c, SBFC_WillExecutor__c, SBFC_OffshoreAssetsPresent__c, SBFC_BequestsSpouse__c, SBFC_BequestsOthers__c, SBFC_CashBequests__c, SBFC_Overdraft_Spouse__c, SBFC_Credit_Cards_Spouse__c, SBFC_Personal_Loans_Spouse__c, SBFC_Clothing_Accounts_Spouse__c, SBFC_Surety_Guarantee_Signed_Spouse__c, SBFC_Salary__c, SBFC_CarAllowance__c, SBFC_Bonus__c, SBFC_Dividends__c, SBFC_Interest__c, SBFC_Other__c, SBFC_Household_Expenses__c, SBFC_Vehicle_installment__c, SBFC_Home_Loan__c, SBFC_Medical_expenses__c, SBFC_Income_Tax__c, WI_Type__c, Name, BusinessEntityTradeName, BusinessEntityRgstrNumber, SBFC_Purpose_of_Trust__c, SBFC_Trustees__c, SBFC_Founder__c, SBFC_Loan_accounts_Owing_and_to_whom__c, SBFC_Loan_Account_Interest_Rate__c, SBFC_Asset_Values__c, SBFC_Liability_Values__c, SBFC_Beneficiaries__c, SBFC_Notes__c, BusinessEntityRgstrDate, BusinessEntityType, SBFC_ShareholderBusinessValuation__c, SBFC_NatureOfTheBusiness__c, SBFC_Shareholders__c, SBFC_LoanAmount__c, SBFC_TotalAssetEstimatedValue__c, SBFC_TotalEstimatedLiabilities__c FROM SBFC_Party_Profiles__r)';
                }
                applicantSub += ' FROM Applicants)';
                soql += applicantSub;
            }

            // Include ApplicationFormProducts if accessible
            if (canAccessAppFormProduct) {
                soql += ', (SELECT Id, SBFC_NameOfFund__c, SBFC_DateFundJoined__c, SBFC_AnnualSalary__c, SBFC_CurrentFundValue__c, SBFC_MonthlyContributions__c, SBFC_GroupRiskBenefits__c, SBFC_Product_Owner__c FROM ApplicationFormProducts)';
            }

            // Include Assets and Liabilities if accessible
            if (canAccessAssets) {
                soql += ', (SELECT Id, FinServ__AssetsAndLiabilitiesType__c, SBFC_MarketValue__c, SBFC_BaseCost__c, SBFC_OwnerClientSpouse__c, SBFC_AssetSoldAtDeath__c, SBFC_AssetSoldAtDisability__c, SBFC_AssetSoldAtRetirement__c, FinServ__PrimaryOwner__c, SBFC_OutstandingAmount__c, FinServ__Description__c, SBFC_AssestsAndLiabilities__c, FinServ__JointOwner__c FROM Assets_and_Liabilities__r)';
            }

            // Append FROM clause and bind LeadId safely
            soql += ' FROM ApplicationForm WHERE LeadId = \'' + String.escapeSingleQuotes(leadId) + '\' LIMIT 1';

            List<ApplicationForm> appFormData = Database.query(soql);
            if (appFormData.size() > 0) {
                return appFormData[0];
            } else {
                return null;
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[] {SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage()}, e);
            throw new AuraHandledException('Error fetching Application Form data');
        }
    }

    /**
     * @description: Update Party Profile Records
     * @author: Gul
     * @param partyProfiles: List of PartyProfile records to be updated
     */
    @AuraEnabled
    public static void updatePartyProfileRecords(List<PartyProfile> partyProfiles) {
    if (FORCE_NO_ACCESS || !Schema.sObjectType.PartyProfile.isUpdateable()) {
        LOGGER.error('Insufficient access to update PartyProfile records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName()});
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { PartyProfile.SObjectType });
        for (PartyProfile profile : partyProfiles) {
            uow.registerDirty(profile);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error updating PartyProfile records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() },e);
        throw new AuraHandledException('Error updating PartyProfile records');
    }
}
    /**
     * @description: Insert Party Profile Records
     * @author: Gul
     * @param partyProfiles: List of PartyProfile records to be inserted
     */
    @AuraEnabled
    public static void insertPartyProfileRecords(List<PartyProfile> partyProfiles) {
    if (!Schema.sObjectType.PartyProfile.isCreateable()) {
        LOGGER.error('Insufficient access to create PartyProfile records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName()});
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { PartyProfile.SObjectType });
        for (PartyProfile profile : partyProfiles) {
            uow.registerNew(profile);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error inserting PartyProfile records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() },e);
        throw new AuraHandledException('Error inserting PartyProfile records');
    }
}

    /**
     * @description: Delete Party Profile Records
     * @author: Gul
     * @param partyProfiles: List of PartyProfile records to be deleted
     */
    @AuraEnabled
    public static void deletePartyProfileRecords(List<PartyProfile> partyProfiles) {
    if (!Schema.sObjectType.PartyProfile.isDeletable()) {
        LOGGER.error('Insufficient access to delete PartyProfile records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName()});
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { PartyProfile.SObjectType});
        for (PartyProfile profile : partyProfiles) {
            uow.registerDeleted(profile);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error deleting PartyProfile records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() },e);
        throw new AuraHandledException('Error deleting PartyProfile records');
    }
}

    /**
     * @description: Update Application Form Product Records
     * @author: Gul
     * @param applicationFormProds: List of ApplicationFormProduct records to be updated
     */
    @AuraEnabled
    public static void updateApplicationFormProduct(List<ApplicationFormProduct> applicationFormProds) {
    if (!Schema.sObjectType.ApplicationFormProduct.isUpdateable()) {
        LOGGER.error('Insufficient access to update ApplicationFormProduct records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName()});
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { ApplicationFormProduct.SObjectType });
        for (ApplicationFormProduct applicationFormProd : applicationFormProds) {
            uow.registerDirty(applicationFormProd);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error updating ApplicationFormProduct records',new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() },e );
        throw new AuraHandledException('Error updating ApplicationFormProduct');
    }
}

    /**
     * @description: Insert Application Form Product Records
     * @author: Gul
     * @param applicationFormProds: List of ApplicationFormProduct records to be inserted
     */
    @AuraEnabled
    public static void insertApplicationFormProduct(List<ApplicationFormProduct> applicationFormProds) {
    if (!Schema.sObjectType.ApplicationFormProduct.isCreateable()) {
        LOGGER.error('Insufficient access to create ApplicationFormProduct records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName() });
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { ApplicationFormProduct.SObjectType });
        for (ApplicationFormProduct applicationFormProd : applicationFormProds) {
            uow.registerNew(applicationFormProd);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error inserting ApplicationFormProduct records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() }, e);
        throw new AuraHandledException('Error inserting ApplicationFormProduct records');
    }
}

    /**
     * @description: Delete Application Form Product Records
     * @author: Gul
     * @param applicationFormProds: List of ApplicationFormProduct records to be deleted
     */
    @AuraEnabled
    public static void deleteApplicationFormProduct(List<ApplicationFormProduct> applicationFormProds) {
    if (!Schema.sObjectType.ApplicationFormProduct.isDeletable()) {
        LOGGER.error('Insufficient access to delete ApplicationFormProduct records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName() });
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { ApplicationFormProduct.SObjectType });
        for (ApplicationFormProduct applicationFormProd : applicationFormProds) {
            uow.registerDeleted(applicationFormProd);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error deleting ApplicationFormProduct records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() }, e);
        throw new AuraHandledException('Error deleting ApplicationFormProduct records');
    }
}

    /**
     * @description: Update Assets And Liabilities Records
     * @author: Gul
     * @param assetsAndLiabilities: List of FinServ__AssetsAndLiabilities__c records to be updated
     */
    @AuraEnabled
    public static void updateAssetsAndLiabilities(List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities) {
    if (!Schema.sObjectType.FinServ__AssetsAndLiabilities__c.isUpdateable()) {
        LOGGER.error('Insufficient access to update AssetsAndLiabilities records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName() });
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { FinServ__AssetsAndLiabilities__c.SObjectType });
        for (FinServ__AssetsAndLiabilities__c assetAndLiability : assetsAndLiabilities) {
            uow.registerDirty(assetAndLiability);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error updating AssetsAndLiabilities records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() }, e);
        throw new AuraHandledException('Error updating AssetsAndLiabilities records');
        }
    }

    /**
     * @description: Insert Assets And Liabilities Records
     * @author: Gul
     * @param assetsAndLiabilities: List of FinServ__AssetsAndLiabilities__c records to be inserted
     */
    @AuraEnabled
    public static void insertAssetsAndLiabilities(List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities) {
    if (!Schema.sObjectType.FinServ__AssetsAndLiabilities__c.isCreateable()) {
        LOGGER.error('Insufficient access to create AssetsAndLiabilities records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName() });
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { FinServ__AssetsAndLiabilities__c.SObjectType });
        for (FinServ__AssetsAndLiabilities__c assetAndLiability : assetsAndLiabilities) {
            uow.registerNew(assetAndLiability);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error inserting AssetsAndLiabilities records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() }, e);
        throw new AuraHandledException('Error inserting AssetsAndLiabilities records');
    }
}

    /**
     * @description: Delete Assets And Liabilities Records
     * @author: Gul
     * @param assetsAndLiabilities: List of FinServ__AssetsAndLiabilities__c records to be deleted
     */
    @AuraEnabled
    public static void deleteAssetsAndLiabilities(List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities) {
    if (!Schema.sObjectType.FinServ__AssetsAndLiabilities__c.isDeletable()) {
        LOGGER.error('Insufficient access to delete AssetsAndLiabilities records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName() });
        return;
    }
    try {
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { FinServ__AssetsAndLiabilities__c.SObjectType });
        for (FinServ__AssetsAndLiabilities__c assetAndLiability : assetsAndLiabilities) {
            uow.registerDeleted(assetAndLiability);
        }
        uow.commitWork();
    } catch (Exception e) {
        LOGGER.error('Error deleting AssetsAndLiabilities records', new String[] { SBFC_CTRL_FactFindingWizard.class.getName(), e.getMessage() }, e);
        throw new AuraHandledException('Error deleting AssetsAndLiabilities records');

    }
}
}