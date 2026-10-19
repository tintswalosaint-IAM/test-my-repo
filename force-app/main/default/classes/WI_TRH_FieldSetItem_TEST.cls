/**
 * @description Trigger Handler framework TEST handler class
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/06
 */
@isTest
public class WI_TRH_FieldSetItem_TEST {
    
    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;

        SVC_ServiceType__c serviceType = WI_DAL_DataFactory.createServiceType(null);
        insert serviceType;

        SlaProcess process = [SELECT Id FROM SlaProcess WHERE Name = 'svc sla1 60 minutes' LIMIT 1];

        Entitlement entitlement = WI_DAL_DataFactory.createEntitlement(
            new Map<String, Object>{
                'AccountId' => acc.Id,
                'SlaProcessId' => process.Id
            }
        );
        insert entitlement;

        CMN_Team__c team = WI_DAL_DataFactory.createTeam(null);
        insert team;

        SVC_ServiceTeam__c serviceTeam = WI_DAL_DataFactory.createServiceTeam(
            new Map<String, Object>{
                Schema.SVC_ServiceTeam__c.SVC_Entitlement__c.getDescribe().getName() => entitlement.Id,
                Schema.SVC_ServiceTeam__c.SVC_ServiceType__c.getDescribe().getName() => serviceType.Id,
                Schema.SVC_ServiceTeam__c.CMN_Team__c.getDescribe().getName() => team.Id
            }
        );
        insert serviceTeam;

        ActionPlanTemplate actionPlanTemplate = WI_DAL_DataFactory.createActionPlanTemplate(null);
        insert actionPlanTemplate;

        ServiceTeamActionPlanTemplate__c templateLink = WI_DAL_DataFactory.createServiceTeamActionPlanTemplate(
            new Map<String, Object>{
                Schema.ServiceTeamActionPlanTemplate__c.ActionPlanTemplate__c.getDescribe().getName() => actionPlanTemplate.Id,
                Schema.ServiceTeamActionPlanTemplate__c.ServiceTeam__c.getDescribe().getName() => serviceTeam.Id
            }
        );
        insert templateLink;
    }

    /**
     * @description To check validation error
     */
    @isTest
    private static void validateWrongApiNameTest() {
        ServiceTeamActionPlanTemplate__c templateLink = [
            SELECT Id 
            FROM ServiceTeamActionPlanTemplate__c
            LIMIT 1
        ];
        FieldSetItem__c fieldSetItem = new FieldSetItem__c(
            ActionPlanTemplateLink__c = templateLink.Id,
            ObjectApiName__c = 'WrongObject',
            FieldApiName__c = 'WrongField'
        );
        Test.startTest();
        try {
            insert fieldSetItem;
        } catch (Exception ex) {
            Assert.isTrue(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Contains Custom Error');
        }
        try {
            fieldSetItem.ObjectApiName__c = 'Case';
            insert fieldSetItem;
        } catch (Exception ex) {
            Assert.isTrue(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Contains Custom Error');
        }

        fieldSetItem.ObjectApiName__c = 'Case';
        fieldSetItem.FieldApiName__c = 'Subject';
        insert fieldSetItem;

        try {
            fieldSetItem.ObjectApiName__c = 'WrongObject';
            update fieldSetItem;
        } catch (Exception ex) {
            Assert.isTrue(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Contains Custom Error');
        }
        Test.stopTest();
    }
}