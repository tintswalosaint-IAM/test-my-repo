@IsTest
private class ICS_SEL_PartyProfile_Test {
    @IsTest
    static void testGetSObjectType() {
        ICS_SEL_PartyProfile partyProfileSelector = new ICS_SEL_PartyProfile();
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();
        
        Assert.areEqual(PartyProfile.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    @IsTest
    static void testGetSObjectFieldList() {
        ICS_SEL_PartyProfile partyProfileSelector = new ICS_SEL_PartyProfile();
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = PartyProfile.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(fieldMap.size(), sObjectFieldList.size(), 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }
    
    @IsTest
    static void testGetPartyProfileList() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    
        PartyProfile partyProfile1 = new PartyProfile(AccountId = testAccount.Id, Name = 'Profile 1');
        PartyProfile partyProfile2 = new PartyProfile(AccountId = testAccount.Id, Name = 'Profile 2');
        insert new List<PartyProfile>{partyProfile1, partyProfile2};
    
        ICS_SEL_PartyProfile partyProfileSelector = new ICS_SEL_PartyProfile();
        List<PartyProfile> partyProfileList = partyProfileSelector.getPartyProfileList(testAccount.Id);
    
        Set<String> partyProfileNames = new Set<String>();
        for (PartyProfile pp : partyProfileList) {
            partyProfileNames.add(pp.Name);
        }
    
        Assert.areEqual(2, partyProfileList.size(), 'Unexpected PartyProfile count');
        Assert.isTrue(partyProfileNames.contains(partyProfile1.Name), 'Profile 1 not found in list');
        Assert.isTrue(partyProfileNames.contains(partyProfile2.Name), 'Profile 2 not found in list');
    }
}