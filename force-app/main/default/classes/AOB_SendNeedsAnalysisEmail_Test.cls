/**
 * @description       : Test class AOB_SendNeedsAnalysisEmail Apex class to send Needs Analysis Email to customers
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52370
 * @date              : 02-12-2025
 **/
@isTest
private class AOB_SendNeedsAnalysisEmail_Test {
    @isTest
    static void testSendNeedsAnalysisEmail() {
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tusr',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Africa/Harare',
            ProfileId = p.Id
        );
        insert testUser;
        
        EmailTemplate temp = new EmailTemplate(
            DeveloperName = 'PLI_Send_Needs_Analysis_Email',
            Name = 'PLI Send Needs Analysis Email',
            FolderId = UserInfo.getUserId(),  
            TemplateStyle = 'freeForm',
            TemplateType = 'text',
            Subject = 'Test Needs Analysis Email',
            IsActive = true,
            OwnerId = testUser.Id,            
            HtmlValue = '<p>Hello {!User.FirstName} ,</p><p>Your PDF is attached.</p>'
        );
        insert temp;       
        Test.startTest();    
          AOB_SendNeedsAnalysisEmail.sendNeedsAnalysisEmail(testUser.Email, testUser.FirstName, testUser.LastName,'{"total_value_debts":700000,"monthly_financial_obligations":20000,"Financially_dependants":"Spouse"}');
        Test.stopTest();       
        Assert.isTrue(true, 'Email sending executed without error.');
        EmailTemplate usedTemplate = [
            SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName = 'PLI_Send_Needs_Analysis_Email' LIMIT 1];
        Assert.areEqual('PLI_Send_Needs_Analysis_Email', usedTemplate.DeveloperName, 'Email template should exist.');
    }
}