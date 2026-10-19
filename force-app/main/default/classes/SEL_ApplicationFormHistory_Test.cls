/**
 * @Name of the Class: SEL_ApplicationFormHistory_Test
 * @description Class for Selector Class for ApplicationForm Entity Test class
 *
 * Story:SFP-36390 
 *
 * @author Shravani Ganta
 *
 * @date March 06 2025
 * @last modified on  : 23-05-2025
 * @last modified by  : Tushar Walse
 * @Modification Description :SFP-36390, used new field signing arrangement SBO-UK
 */
@isTest
private class SEL_ApplicationFormHistory_Test {
    @isTest
    static void testSelectById() {
        ApplicationForm appForm = new ApplicationForm();
        appForm.UsageType='Onboarding';										
        insert appForm;

        ApplicationFormHistory history = new ApplicationFormHistory(
            ApplicationFormId = appForm.Id,  
            Field = 'Stage'
        );
        insert history;

        SEL_ApplicationFormHistory selector = new SEL_ApplicationFormHistory();
        ApplicationFormHistory result = selector.selectById(history.Id);
        Assert.isNotNull(result, 'The result should not be null');
        Assert.areEqual(history.Id, result.Id, 'The Ids should match');
    }

    @isTest
    static void testSelectByIds() {
        ApplicationForm appForm1 = new ApplicationForm();
        appForm1.UsageType='Onboarding'; 
        insert appForm1;

        ApplicationForm appForm2 = new ApplicationForm();
        appForm2.UsageType='Onboarding';
        insert appForm2;

        ApplicationFormHistory history1 = new ApplicationFormHistory(
            ApplicationFormId = appForm1.Id, 
            Field = 'Stage'
        );

        ApplicationFormHistory history2 = new ApplicationFormHistory(
            ApplicationFormId = appForm2.Id, 
            Field = 'Stage'
        );

        insert new List<ApplicationFormHistory>{history1, history2};

        SEL_ApplicationFormHistory selector = new SEL_ApplicationFormHistory();
        Set<Id> ids = new Set<Id>{history1.Id, history2.Id};
        List<ApplicationFormHistory> result = selector.selectByIds(ids);

        Assert.areEqual(2, result.size(), 'The result list should contain 2 records');
        Assert.areEqual(history1.Id, result[0].Id, 'The first record should match');
        Assert.areEqual(history2.Id, result[1].Id, 'The second record should match');
    }

    @isTest
    static void testSelectByApplicationFormIds() {
        ApplicationForm appForm1 = new ApplicationForm(); 
        appForm1.UsageType='Onboarding';
        insert appForm1;

        ApplicationForm appForm2 = new ApplicationForm();
        appForm2.UsageType='Onboarding';
        insert appForm2;

        ApplicationFormHistory history1 = new ApplicationFormHistory(
            ApplicationFormId = appForm1.Id, 
            Field = 'Stage'
        );

        ApplicationFormHistory history2 = new ApplicationFormHistory(
            ApplicationFormId = appForm2.Id, 
            Field = 'Stage'
        );

        insert new List<ApplicationFormHistory>{history1, history2};

        SEL_ApplicationFormHistory selector = new SEL_ApplicationFormHistory();
        Set<Id> applicationFormIds = new Set<Id>{appForm1.Id, appForm2.Id};
        List<ApplicationFormHistory> result = selector.selectByApplicationFormIds(applicationFormIds);

        Assert.areEqual(2, result.size(), 'The result list should contain 2 records');
        Assert.areEqual(appForm1.Id, result[0].ApplicationFormId, 'The first record should match');
        Assert.areEqual(appForm2.Id, result[1].ApplicationFormId, 'The second record should match');
    }

    @isTest
    static void testSelectByApplicationFormId() {
        ApplicationForm appForm = new ApplicationForm(); 
        appForm.UsageType='Onboarding';
        insert appForm;

        ApplicationFormHistory history1 = new ApplicationFormHistory(
            ApplicationFormId = appForm.Id, 
            Field = 'Stage'
        );

        ApplicationFormHistory history2 = new ApplicationFormHistory(
            ApplicationFormId = appForm.Id, 
            Field = 'Stage'
        );

        insert new List<ApplicationFormHistory>{history1, history2};

        SEL_ApplicationFormHistory selector = new SEL_ApplicationFormHistory();
        List<ApplicationFormHistory> result = selector.selectByApplicationFormId(appForm.Id);

        Assert.areEqual(2, result.size(), 'The result list should contain 2 records');
        Assert.areEqual(appForm.Id, result[0].ApplicationFormId, 'The ApplicationFormId should match');
        Assert.areEqual(appForm.Id, result[1].ApplicationFormId, 'The ApplicationFormId should match');
    }

    @isTest
    static void testSelectByApplicationFormIdAndField() {
        ApplicationForm appForm = new ApplicationForm(); 
        appForm.UsageType='Onboarding';
        insert appForm;

        ApplicationFormHistory history1 = new ApplicationFormHistory(
            ApplicationFormId = appForm.Id, 
            Field = 'Stage'
        );

        ApplicationFormHistory history2 = new ApplicationFormHistory(
            ApplicationFormId = appForm.Id, 
            Field = 'Stage'
        );

        insert new List<ApplicationFormHistory>{history1, history2};

        SEL_ApplicationFormHistory selector = new SEL_ApplicationFormHistory();
        List<ApplicationFormHistory> result = selector.selectByApplicationFormIdAndField(appForm.Id, 'Stage');

        Assert.areEqual(2, result.size(), 'The result list should contain 2 records');
        Assert.areEqual(appForm.Id, result[0].ApplicationFormId, 'The ApplicationFormId should match');
        Assert.areEqual(appForm.Id, result[1].ApplicationFormId, 'The ApplicationFormId should match');
   }
}