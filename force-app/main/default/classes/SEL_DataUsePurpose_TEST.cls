/**
* @description       : SFP-54443 - Test Class for SEL_DataUsePurpose
* @author            : Amlendu Bajpai'
* @last modified on  : 02-04-2026
**/
@IsTest
private class SEL_DataUsePurpose_TEST {

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

        SEL_DataUsePurpose selector =
            new SEL_DataUsePurpose();

        Assert.areEqual(
            DataUsePurpose.SObjectType,
            selector.getSObjectType(),
            'Selector should return the DataUseLegalBasis SObjectType.'
        );
    }

    @IsTest
    static void testselectByName() {

        SEL_DataUsePurpose selector =
            new SEL_DataUsePurpose(false,false,false);
        List<DataUsePurpose> result = selector.selectByName('Purpose');

        

        Assert.isNotNull(
            result,
            'result should not be null.'
        );
    }
}