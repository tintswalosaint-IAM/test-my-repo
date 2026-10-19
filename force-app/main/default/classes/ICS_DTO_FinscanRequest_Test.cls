@isTest
public with sharing class ICS_DTO_FinscanRequest_Test {
    @isTest
    static void testOptionsClass() {
        ICS_DTO_FinscanRequest.Options options = new ICS_DTO_FinscanRequest.Options();
        options.addClient = 1;
        options.generateClientId = 0;
        options.updateUserFields = 1;
        options.sendToReview = 0;
        options.returnCategory = 1;
        options.returnSearchComplianceRecords = 0;
        options.returnComplianceRecords = 1;
        options.returnSourceLists = 0;
        options.returnSearchDetails = 1;
        options.skipSearch = 0;
        options.skipClientUpdate = 0;
        options.processUBO = 1;
        options.searchUBOMembers = 1;
        String jsonString = JSON.serialize(options);

        ICS_DTO_FinscanRequest.Options deserializedOptions = 
            (ICS_DTO_FinscanRequest.Options) JSON.deserialize(jsonString, ICS_DTO_FinscanRequest.Options.class);

        Assert.areEqual(options.addClient, deserializedOptions.addClient, 'addClient should match');
        Assert.areEqual(options.generateClientId, deserializedOptions.generateClientId, 'generateClientId should match');
        Assert.areEqual(options.updateUserFields, deserializedOptions.updateUserFields, 'updateUserFields should match');
        Assert.areEqual(options.sendToReview, deserializedOptions.sendToReview, 'sendToReview should match');
    }

    @isTest
    static void testPairsUpdateClass() {
        ICS_DTO_FinscanRequest.PairsUpdate pairsUpdate = new ICS_DTO_FinscanRequest.PairsUpdate();
        pairsUpdate.organizationName = 'Test Org';
        pairsUpdate.userName = 'testUser';
        pairsUpdate.password = 'testPassword';
        pairsUpdate.clientId = 'C001';
        pairsUpdate.applicationId = new List<String>{'App001', 'App002'};

        String jsonString = JSON.serialize(pairsUpdate);

        ICS_DTO_FinscanRequest.PairsUpdate deserializedPairsUpdate = 
            (ICS_DTO_FinscanRequest.PairsUpdate) JSON.deserialize(jsonString, ICS_DTO_FinscanRequest.PairsUpdate.class);

        Assert.areEqual(pairsUpdate.organizationName, deserializedPairsUpdate.organizationName, 'organizationName should match');
        Assert.areEqual(pairsUpdate.userName, deserializedPairsUpdate.userName, 'userName should match');
        Assert.areEqual(pairsUpdate.password, deserializedPairsUpdate.password, 'password should match');
    }

    @isTest
    static void testClientUpdateClass() {
        ICS_DTO_FinscanRequest.ClientUpdate clientUpdate = new ICS_DTO_FinscanRequest.ClientUpdate();
        clientUpdate.organizationName = 'Test Org';
        clientUpdate.userName = 'testUser';
        clientUpdate.password = 'testPassword';
        clientUpdate.applicationId = 'App001';
        clientUpdate.newApplicationId = 'App002';
        clientUpdate.clientId = 'C001';
        clientUpdate.newClientId = 'C002';
        clientUpdate.clientStatus = 1;
        clientUpdate.nameLine = 'John Doe';

        String jsonString = JSON.serialize(clientUpdate);

        ICS_DTO_FinscanRequest.ClientUpdate deserializedClientUpdate = 
            (ICS_DTO_FinscanRequest.ClientUpdate) JSON.deserialize(jsonString, ICS_DTO_FinscanRequest.ClientUpdate.class);

        Assert.areEqual(clientUpdate.organizationName, deserializedClientUpdate.organizationName, 'organizationName should match');
        Assert.areEqual(clientUpdate.userName, deserializedClientUpdate.userName, 'userName should match');
        Assert.areEqual(clientUpdate.password, deserializedClientUpdate.password, 'password should match');
        Assert.areEqual(clientUpdate.applicationId, deserializedClientUpdate.applicationId, 'applicationId should match');
        Assert.areEqual(clientUpdate.newApplicationId, deserializedClientUpdate.newApplicationId, 'newApplicationId should match');
        Assert.areEqual(clientUpdate.clientId, deserializedClientUpdate.clientId, 'clientId should match');
        Assert.areEqual(clientUpdate.newClientId, deserializedClientUpdate.newClientId, 'newClientId should match');
        Assert.areEqual(clientUpdate.clientStatus, deserializedClientUpdate.clientStatus, 'clientStatus should match');
        Assert.areEqual(clientUpdate.nameLine, deserializedClientUpdate.nameLine, 'nameLine should match');
    }
    
    @isTest
    static void testLookupClass() {
        ICS_DTO_FinscanRequest.Lookup lookup = new ICS_DTO_FinscanRequest.Lookup();
        lookup.organizationName = 'Test Organization';
        lookup.userName = 'testUser';
        lookup.password = 'testPassword';
        lookup.applicationId = '123456';
        lookup.clientSearchCode = 1001;
        lookup.clientId = 'C001';
        lookup.nameLine = 'John Doe';
        lookup.gender = 'Male';
        lookup.userField1Label = 'Field1';
        lookup.userField1Value = 'Value1';
        lookup.userField2Label = 'Field2';
        lookup.userField2Value = 'Value2';
        lookup.userField9Label = 'Field9';
        lookup.userField9Value = 'Value9';
        lookup.userField10Label = 'Field10';
        lookup.userField10Value = 'Value10';
        ICS_DTO_FinscanRequest.Options options = new ICS_DTO_FinscanRequest.Options();
        options.addClient = 1;
        options.generateClientId = 0;
        options.updateUserFields = 1;
        options.sendToReview = 0;
        options.returnCategory = 1;
        options.returnSearchComplianceRecords = 0;
        options.returnComplianceRecords = 1;
        options.returnSourceLists = 0;
        options.returnSearchDetails = 1;
        options.skipSearch = 0;
        options.skipClientUpdate = 0;
        options.processUBO = 1;
        options.searchUBOMembers = 1;
        lookup.options = options;
        lookup.userFieldsCountry = new List<Integer>{1, 2, 3};

        String jsonString = JSON.serialize(lookup);

        ICS_DTO_FinscanRequest.Lookup deserializedLookup = 
            (ICS_DTO_FinscanRequest.Lookup) JSON.deserialize(jsonString, ICS_DTO_FinscanRequest.Lookup.class);

        Assert.areEqual(lookup.organizationName, deserializedLookup.organizationName, 'organizationName should match');
        Assert.areEqual(lookup.userName, deserializedLookup.userName, 'userName should match');
        Assert.areEqual(lookup.password, deserializedLookup.password, 'password should match');
        Assert.areEqual(lookup.applicationId, deserializedLookup.applicationId, 'applicationId should match');
        Assert.areEqual(lookup.clientSearchCode, deserializedLookup.clientSearchCode, 'clientSearchCode should match');
        Assert.areEqual(lookup.clientId, deserializedLookup.clientId, 'clientId should match');
        Assert.areEqual(lookup.nameLine, deserializedLookup.nameLine, 'nameLine should match');
        Assert.areEqual(lookup.gender, deserializedLookup.gender, 'gender should match');
        Assert.areEqual(lookup.userField1Label, deserializedLookup.userField1Label, 'userField1Label should match');
        Assert.areEqual(lookup.userField1Value, deserializedLookup.userField1Value, 'userField1Value should match');
        Assert.areEqual(lookup.userField2Label, deserializedLookup.userField2Label, 'userField2Label should match');
        Assert.areEqual(lookup.userField2Value, deserializedLookup.userField2Value, 'userField2Value should match');
        Assert.areEqual(lookup.userField9Label, deserializedLookup.userField9Label, 'userField9Label should match');
        Assert.areEqual(lookup.userField9Value, deserializedLookup.userField9Value, 'userField9Value should match');
        Assert.areEqual(lookup.userField10Label, deserializedLookup.userField10Label, 'userField10Label should match');
        Assert.areEqual(lookup.userField10Value, deserializedLookup.userField10Value, 'userField10Value should match');
        Assert.areEqual(lookup.options.addClient, deserializedLookup.options.addClient, 'options.addClient should match');
        Assert.areEqual(lookup.options.generateClientId, deserializedLookup.options.generateClientId, 'options.generateClientId should match');
        Assert.areEqual(lookup.options.updateUserFields, deserializedLookup.options.updateUserFields, 'options.updateUserFields should match');
        Assert.areEqual(lookup.userFieldsCountry, deserializedLookup.userFieldsCountry, 'userFieldsCountry should match');
    }
}