/**
 * @description Test class for CMN_CFG_UGEscalationSettings.
 * @author Raymond Magezi
 * @date 23-07-2026
 * @see CMN_CFG_UGEscalationSettings
 * @userStory SFP-58853
 * @history 23-07-2026  Raymond Magezi  Initial creation
 * @history 09-07-2026  Raymond Magezi  Removed SEL_UGEnvironmentConfig references;
 *                                      updated to email-based user resolution - SFP-58853
 * @history 12-07-2026  Raymond Magezi  Updated to username-based resolution - SFP-58853
 */
@IsTest
private class CMN_CFG_UGEscalationSettings_TEST {

    @IsTest
    static void loadForCountrySuccessPositiveOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'UG',
                MaxEscalationLevel__c = 5,
                EmailTemplateApiName__c = 'SVC_UG_PB_EscalationNotification',
                AutomatedUserName__c = 'sbgdatauser@standardbank.co.za'
            )
        };

        Test.startTest();
        CMN_CFG_UGEscalationSettings.Config config = CMN_CFG_UGEscalationSettings.loadForCountry('UG');
        Test.stopTest();

        Assert.isNotNull(config.setting);
        Assert.areEqual(5, config.maxLevel);
    }

    @IsTest
    static void loadForCountryNoSettingsNegativeOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>();

        Test.startTest();
        try {
            CMN_CFG_UGEscalationSettings.loadForCountry('UG');
        } catch (CMN_BATCH_UG_CaseEscalation.BatchableException e) {
            Assert.isTrue(e.getMessage().contains('No active'));
        }
        Test.stopTest();
    }

    @IsTest
    static void loadForCountryNotFoundNegativeOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'ZA',
                MaxEscalationLevel__c = 5,
                EmailTemplateApiName__c = 'Test'
            )
        };

        Test.startTest();
        try {
            CMN_CFG_UGEscalationSettings.loadForCountry('UG');
        } catch (CMN_BATCH_UG_CaseEscalation.BatchableException e) {
            Assert.isTrue(e.getMessage().contains('No active'));
        }
        Test.stopTest();
    }

    @IsTest
    static void loadForCountryInvalidConfigNegativeOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'UG',
                MaxEscalationLevel__c = null,
                EmailTemplateApiName__c = 'Test'
            )
        };

        Test.startTest();
        try {
            CMN_CFG_UGEscalationSettings.loadForCountry('UG');
        } catch (CMN_BATCH_UG_CaseEscalation.BatchableException e) {
            Assert.isTrue(e.getMessage().contains('Invalid config'));
        }
        Test.stopTest();
    }

    @IsTest
    static void loadForCountryBlankAutomatedUserPositiveOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'UG',
                MaxEscalationLevel__c = 5,
                EmailTemplateApiName__c = 'TestTemplate',
                AutomatedUserName__c = ''
            )
        };

        Test.startTest();
        CMN_CFG_UGEscalationSettings.Config config = CMN_CFG_UGEscalationSettings.loadForCountry('UG');
        Test.stopTest();

        Assert.areEqual(null, config.automatedUserId);
    }

    @IsTest
    static void loadForCountryNonExistentUserNegativeOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'UG',
                MaxEscalationLevel__c = 5,
                EmailTemplateApiName__c = 'TestTemplate',
                AutomatedUserName__c = 'nonexistentuser@fake.co.za'
            )
        };

        Test.startTest();
        try {
            CMN_CFG_UGEscalationSettings.loadForCountry('UG');
            Assert.fail('Expected exception');
        } catch (CMN_BATCH_UG_CaseEscalation.BatchableException e) {
            Assert.isTrue(e.getMessage().contains('No active automation user'));
        }
        Test.stopTest();
    }

    @IsTest
    static void resolveAutomatedUserExceptionPositiveOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'UG',
                MaxEscalationLevel__c = 5,
                EmailTemplateApiName__c = 'TestTemplate',
                AutomatedUserName__c = 'sbgdatauser@standardbank.co.za'
            )
        };
        CMN_CFG_UGEscalationSettings.mockUserQueryException = true;

        Test.startTest();
        CMN_CFG_UGEscalationSettings.Config config = CMN_CFG_UGEscalationSettings.loadForCountry('UG');
        Test.stopTest();

        Assert.areEqual(null, config.automatedUserId);
    }

    @IsTest
    static void loadForCountryUnexpectedExceptionNegativeOutcome() {
        SEL_UGCaseEscalation.mockActiveSettings = new List<UG_PB_Escalation_Setting__mdt>{
            new UG_PB_Escalation_Setting__mdt(
                CaseOwnerCountry__c = 'UG',
                MaxEscalationLevel__c = 5,
                EmailTemplateApiName__c = 'TestTemplate',
                AutomatedUserName__c = 'sbgdatauser@standardbank.co.za'
            )
        };
        CMN_CFG_UGEscalationSettings.mockUnexpectedException = true;

        Test.startTest();
        try {
            CMN_CFG_UGEscalationSettings.loadForCountry('UG');
            Assert.fail('Expected exception');
        } catch (TypeException e) {
            Assert.isTrue(e.getMessage().contains('Mock unexpected'));
        }
        Test.stopTest();
    }
}