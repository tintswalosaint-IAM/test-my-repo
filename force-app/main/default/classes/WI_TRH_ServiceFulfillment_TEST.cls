/**
 * @description Trigger Handler framework TEST handler class
 *
 * @author Adam Redlinski
 * @date 2023/06/05
 * 
 * @modified by Sibonelo Ngcobo - [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
 * @date 2026/03/16
 */
@isTest
private class WI_TRH_ServiceFulfillment_TEST {
    private static final String SUBMITTER_ERROR_MSG = 'Submitter cannot be the same as approver';
    
    @TestSetup
    private static void setup() {
        Group pg = [SELECT Id FROM Group WHERE DeveloperName = 'WI_RelationshipManagerHead' LIMIT 1];
        
        Group testGroup = new Group(
            Name = 'Test Group',
            DeveloperName = 'Test_Group',
            Type = 'Regular'
        );
        insert testGroup;

        User testUser = AOB_DAL_TestFactory.createUser('System Administrator', true);

        insert new List<GroupMember>{
                new GroupMember(
                        GroupId = pg.Id,
                        UserOrGroupId = testUser.Id
                ),
                new GroupMember(
                    GroupId = testGroup.Id,
                    UserOrGroupId = testUser.Id
                ),
                new GroupMember(
                    GroupId = pg.Id,
                    UserOrGroupId = testGroup.Id
                )
                    
        };

        System.runAs(testUser) {
            Account acc = WI_DAL_DataFactory.createAccount(null);
            insert acc;

            Case c = WI_DAL_DataFactory.createCase(
                    new Map<String, Object>{
                            'AccountId' => acc.Id
                    }
            );
            insert c;

            FinServ__FinancialAccount__c debitAccount = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, Name = 'debit account');
            insert debitAccount;
            insert new ServiceFulfillment__c(Amount__c = 3000000, BeneficiaryAccountBank__c = 'Discovery Bank', Case__c = c.Id, DebitAccount__c = debitAccount.Id, Status__c = 'New');
        }

        system.runAs(testUser) {
            Account acc = WI_DAL_DataFactory.createAccount(new Map<String, Object>{
                    'WI_Title__c' => 'MR.'
            });
            insert acc;

            Case c = WI_DAL_DataFactory.createCase(
                    new Map<String, Object>{
                            'AccountId' => acc.Id,
                            'WI_Retro__c' => 'Yes'
                    }
            );
            insert c;

            FinServ__FinancialAccount__c debitAccount = new FinServ__FinancialAccount__c(FinServ__PrimaryOwner__c = acc.Id, Name = 'debit account');
            insert debitAccount;

            List<ServiceFulfillment__c> fulfillments = new List<ServiceFulfillment__c>();
            fulfillments.add(new ServiceFulfillment__c(
                    Status__c = 'New',
                    DebitAccount__c = debitAccount.Id,
                    Case__c = c.Id,
                    Amount__c = 28484,
                    NarrativeDebitAccount__c = '24',
                    BeneficiaryAccountName__c = 'test',
                    BeneficiaryAccountBank__c = 'Discovery Bank',
                    BeneficiaryAccountNumber__c = '1234',
                    NarrativeCreditAccount__c = 'testNarrativeCredit'
            ));

            insert fulfillments;
        }
    }

    @IsTest
    static void testManagerLookupValidation() {
        ServiceFulfillment__c vt = [SELECT Id, Amount__c, Manager__c FROM ServiceFulfillment__c LIMIT 1];
        vt.Manager__c = UserInfo.getUserId();

        try {
            update vt;
        } catch (DmlException ex) {
            Assert.isTrue(ex.getMessage().contains('Chosen Manager is not allowed. Please, chose a Manager from the W&I Relationship Manager Head group.'));
        }

        User us = [SELECT Id FROM User WHERE Alias = 'aob' LIMIT 1];
        vt.Manager__c = us.Id;
        update vt;

        vt = [SELECT Id, Amount__c, Manager__c FROM ServiceFulfillment__c LIMIT 1];
        Assert.areEqual(us.Id, vt.Manager__c);
    }

@IsTest
static void testApproverValidation() {
    ServiceFulfillment__c sf = [SELECT Id FROM ServiceFulfillment__c LIMIT 1];
    User testUser = [SELECT Id FROM User WHERE Alias = 'aob' LIMIT 1];

    System.runAs(testUser) {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(sf.Id);

        Approval.ProcessResult submitResult = Approval.process(request);
        Assert.isTrue(submitResult.isSuccess(), 'Submission should succeed.');

        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :sf.Id
        ];

        Assert.isTrue(!workItems.isEmpty(), 'Expected a pending approval work item.');

        Approval.ProcessWorkitemRequest selfApproveReq = new Approval.ProcessWorkitemRequest();
        selfApproveReq.setWorkitemId(workItems[0].Id);
        selfApproveReq.setAction('Approve');
        selfApproveReq.setComments('request is approved.');

        try {
            Approval.process(selfApproveReq);
            Assert.fail('Expected self approval validation to be thrown.');
        } catch (DmlException ex) {
            Assert.isTrue(
                ex.getMessage().contains(SUBMITTER_ERROR_MSG),
                'Unexpected error: ' + ex.getMessage()
            );
        }
    }
}
    
}