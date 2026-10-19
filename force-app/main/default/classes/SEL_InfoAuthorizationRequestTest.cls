/**
* @description       : SFP-54443 - Test Class for SEL_InfoAuthorizationRequest
* @author            : Amlendu Bajpai
**/
@IsTest
private class SEL_InfoAuthorizationRequestTest {

    @testSetup
    static void setupData() {

        Account acc = new Account(
            LastName = 'Test Person',
            PersonEmail = 'test@test.com'
        );
        insert acc;

        DataUseLegalBasis legal = new DataUseLegalBasis(
            Name = 'Legal Basis'
        );
        insert legal;

        DataUsePurpose purpose = new DataUsePurpose(
            Name = 'Purpose',
            LegalBasisId = legal.Id,
            IsActive = false
        );
        insert purpose;
        purpose.IsActive =true;
       // update purpose;

        AuthorizationForm form = new AuthorizationForm(
            Name='Form'
        );
        insert form;

        AuthorizationFormText aft = new AuthorizationFormText(
            Name='Form Text',
            Locale='en_ZA',
            AuthorizationFormId=form.Id,
            IsActive=true,
            SummaryAuthFormText='Disclosure'
        );
        insert aft;

        form.DefaultAuthFormTextId = aft.Id;
        update form;

        AuthorizationFormDataUse afdu =
            new AuthorizationFormDataUse(
                Name='Data Use',
                AuthorizationFormId=form.Id,
                DataUsePurposeId=purpose.Id
            );
        insert afdu;
        update purpose;

        InfoAuthorizationRequest req =
            new InfoAuthorizationRequest(
                Name='Test',
                SourceRecordId=acc.Id,
                ConsenterId=acc.Id,
                PertainsToId=acc.Id,
                DataUsePurposeId=purpose.Id
            );

        insert req;
    }

    @IsTest
    static void testGetSObjectType() {

        SEL_InfoAuthorizationRequest selector =
            new SEL_InfoAuthorizationRequest(false,false,false);

        Assert.areEqual(
            InfoAuthorizationRequest.SObjectType,
            selector.getSObjectType(),
            'Selector should return the InfoAuthorizationRequest SObjectType.'
        );
    }

    @IsTest
    static void testGetSObjectFieldList() {

        SEL_InfoAuthorizationRequest selector =
            new SEL_InfoAuthorizationRequest();

        List<Schema.SObjectField> fields =
            selector.getSObjectFieldList();

        Assert.isNotNull(
            fields,
            'Field list should not be null.'
        );

        Assert.isTrue(
            fields.contains(InfoAuthorizationRequest.Id),
            'Id field should be included.'
        );

        Assert.isTrue(
            fields.contains(InfoAuthorizationRequest.SourceRecordId),
            'SourceRecordId field should be included.'
        );
    }

    @IsTest
    static void testselectById() {

        InfoAuthorizationRequest expected = [
            SELECT Id
            FROM InfoAuthorizationRequest
            LIMIT 1
        ];

        Test.startTest();

        InfoAuthorizationRequest actual =
            new SEL_InfoAuthorizationRequest()
                .selectById(expected.Id);

        Test.stopTest();

        Assert.isNotNull(
            actual,
            'Record should be returned.'
        );

        Assert.areEqual(
            expected.Id,
            actual.Id,
            'Incorrect record returned.'
        );
    }

    @IsTest
    static void testselectBySourceRecordId() {

        Account acc = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        Test.startTest();

        InfoAuthorizationRequest actual =
            new SEL_InfoAuthorizationRequest()
                .selectBySourceRecordId(acc.Id);

        Test.stopTest();

        Assert.isNotNull(
            actual,
            'Record should be returned.'
        );

        Assert.areEqual(
            acc.Id,
            actual.SourceRecordId,
            'SourceRecordId should match.'
        );
    }
    @IsTest
    static void testselectBySignedDocNumber() {
        Test.startTest();

        List<InfoAuthorizationRequest> actual = new SEL_InfoAuthorizationRequest().selectBySignedDocNumber('12345');
        Test.stopTest();

        Assert.isNotNull(
        actual,
        'No records should be returned when the signed document number is null.'
    	);

            }

    
}