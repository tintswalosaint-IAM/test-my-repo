/**
 * @description Test class of LWC controller
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/05
 */
@isTest
public class WI_CTRL_ActionPlanFields_TEST {
    
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

        FieldSetItem__c fieldSetItem = WI_DAL_DataFactory.createFieldSetItem(
            new Map<String, Object>{
                Schema.FieldSetItem__c.ActionPlanTemplateLink__c.getDescribe().getName() => templateLink.Id
            }
        );
        insert fieldSetItem;

        Case c = WI_DAL_DataFactory.createCase(
            new Map<String, Object>{
                Schema.Case.SVC_ServiceTeam__c.getDescribe().getName() => serviceTeam.Id
            }
        );
        insert c;

        
        ActionPlanTemplateVersion tempVersion = [SELECT Id, Status FROM ActionPlanTemplateVersion WHERE ActionPlanTemplateId = :actionPlanTemplate.Id LIMIT 1];

        ActionPlanTemplateItem tItem = WI_DAL_DataFactory.createActionPlanTemplateItem(
            new Map<String, Object>{
                'ActionPlanTemplateVersionId' => tempVersion.Id
            }
        );
        insert tItem;

        ActionPlanTemplateItemValue tValue1 = WI_DAL_DataFactory.createActionPlanTemplateItemValue(
            new Map<String, Object>{
                'ActionPlanTemplateItemId' => tItem.Id,
                'ItemEntityFieldName' => 'Task.Subject',
                'Name' => 'templateItem1value1',
                'ValueLiteral' => 'Test Action Task 1'
            }
        );
        insert tValue1;

        ActionPlanTemplateItemValue tValue2 = WI_DAL_DataFactory.createActionPlanTemplateItemValue(
            new Map<String, Object>{
                'ActionPlanTemplateItemId' => tItem.Id,
                'ItemEntityFieldName' => 'Task.Priority',
                'Name' => 'templateItem1value2',
                'ValueLiteral' => 'Normal'
            }
        );
        insert tValue2;

        ActionPlanTemplateItemValue tValue3 = WI_DAL_DataFactory.createActionPlanTemplateItemValue(
            new Map<String, Object>{
                'ActionPlanTemplateItemId' => tItem.Id,
                'ItemEntityFieldName' => 'Task.ActivityDate',
                'Name' => 'templateItem1value3',
                'ValueFormula' => 'StartDate + 10'
            }
        );
        insert tValue3;

        tempVersion.Status = 'Final';
        update tempVersion;

        ActionPlan plan = WI_DAL_DataFactory.createActionPlan(
            new Map<String, Object>{
                'ActionPlanTemplateVersionId' => tempVersion.Id,
                'TargetId' => c.Id
            }
        );
        insert plan;
    }

    /**
     * @description To check retrieve data
     */
    @isTest
    private static void getDataTest() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        WI_CTRL_ActionPlanFields.DataResponse response = WI_CTRL_ActionPlanFields.getData(
            c.Id
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check exception
     */
    @isTest
    private static void getDataExceptionTest() {
        Test.startTest();
        WI_CTRL_ActionPlanFields.DataResponse response = WI_CTRL_ActionPlanFields.getData(
            null
        );
        Assert.isFalse(response.isSuccess, 'Success response');
        Test.stopTest();
    }
}