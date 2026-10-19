/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :May 2023
@ Name of the Class :CMN_IdentifiiApplicantTest
@description       :Test Class to cover CMN_IdentifiiApplicant.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-05-2023
@ Modification Description : SFP-12450
***************************************************************************************/
@isTest
public class CMN_IdentifiiApplicantTest {
     /**
    * @description TestMethod for invokeIdentifiiCallouttest
    *
    */
    @istest  static void invokeIdentifiiCallouttest() {
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);

        insert appList;
        list<string> appIdList = new list<string>();
        appIdList.add(appList[0].id);
        Test.startTest();
        String repStatus = CMN_IdentifiiApplicant.invocableMethod( appList);
        Test.stopTest();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
       Assert.areEqual((String)m.get('status'), 'Success','The status should be Success');
    }
    /**
    * @description TestMethod for invokeIdentifiiCallouttest
    *
    */
    @istest  static void invokeIdentifiiCallouttest2() {
        try{
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        Test.startTest();
        String repStatus = CMN_IdentifiiApplicant.invocableMethod( appList);
        Test.stopTest();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Assert.areEqual((String)m.get('status'), 'Success','The status should be Success');
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test');
        }
    }
    /**
    * @description TestMethod for invokeIdentifiiGETDocumentsCallouttest
    *
    */
    @istest static void invokeIdentifiiGETDocumentsCallouttest() {
        List<Application__c> appList=BCB_DAL_TestFactory.createApplication(1);
        insert appList;
        Test.startTest();
        String repStatus = CMN_IdentifiiApplicant.invocableGETMethod(appList, 'testrecordid');
        Test.stopTest();
        BCB_Identify_BodyBean.Response responseMap = (BCB_Identify_BodyBean.Response) JSON.deserialize(repStatus, BCB_Identify_BodyBean.Response.class);
       Assert.areEqual(responseMap.IdentityImages.isEmpty(), false,'Response image should return False');
    }
    
      /**
    * @description TestMethod for BCBIdentifyOCRBeanTest
    *
    */
    @IsTest
    public static void BCBIdentifyOCRBeanTest() {
        BCB_Identify_OCRBean.cls_DocumentTypeDetected documentTypeDetected = new BCB_Identify_OCRBean.cls_DocumentTypeDetected();
        documentTypeDetected.ID = '123';
        documentTypeDetected.Name = 'Passport';
        documentTypeDetected.Description = 'Travel document';
        documentTypeDetected.DocType = 1;
        documentTypeDetected.IssueCountryCode = 'USA';

        BCB_Identify_OCRBean.cls_DocumentTypeSelected documentTypeSelected = new BCB_Identify_OCRBean.cls_DocumentTypeSelected();
        documentTypeSelected.ID = '456';
        documentTypeSelected.Name = 'Driver License';
        documentTypeSelected.Description = 'Driving permit';
        documentTypeSelected.DocType = 2;
        documentTypeSelected.IssueCountryCode = 'CAN';

        BCB_Identify_OCRBean.cls_FrontVIZFields frontVIZFields = new BCB_Identify_OCRBean.cls_FrontVIZFields();
        frontVIZFields.DocumentNumber = '123456789';
        frontVIZFields.LastName = 'Doe';
        frontVIZFields.FirstName = 'John';
        frontVIZFields.DateOfExpiry = '2023-06-30';
        frontVIZFields.Nationality = 'USA';
        frontVIZFields.PersonalNumber = '987654321';
        frontVIZFields.DateOfBirth = '1980-01-01';
        frontVIZFields.Gender = 'Male';

        BCB_Identify_OCRBean.cls_BackVIZFields backVIZFields = new BCB_Identify_OCRBean.cls_BackVIZFields();
        backVIZFields.District = 'ABC';
        backVIZFields.Location = 'XYZ';
        backVIZFields.MRTD = 'MRTD123';
        backVIZFields.SubLocation = 'PQR';
        backVIZFields.Division = 'DEF';
        backVIZFields.Village = 'GHI';

        BCB_Identify_OCRBean.cls_IdentityDocumentMetadatas[] identityDocumentMetadatas = new BCB_Identify_OCRBean.cls_IdentityDocumentMetadatas[]{
            new BCB_Identify_OCRBean.cls_IdentityDocumentMetadatas()
        };
        identityDocumentMetadatas[0].ID = '789';
        identityDocumentMetadatas[0].Metadata = new BCB_Identify_OCRBean.cls_Metadata();
        identityDocumentMetadatas[0].FrontTypeIDDetected = '456';
        identityDocumentMetadatas[0].BackTypeIDDetected = '789';
        identityDocumentMetadatas[0].FrontVIZFields = frontVIZFields;
        identityDocumentMetadatas[0].BackVIZFields = backVIZFields;
        identityDocumentMetadatas[0].FrontMRZFields = new BCB_Identify_OCRBean.cls_FrontMRZFields();
        identityDocumentMetadatas[0].BackMRZFields = new BCB_Identify_OCRBean.cls_BackMRZFields();
        identityDocumentMetadatas[0].DocumentTypeFront = new BCB_Identify_OCRBean.cls_DocumentTypeFront();
        identityDocumentMetadatas[0].DocumentTypeFront.ID = '987';
        identityDocumentMetadatas[0].DocumentTypeFront.Name = 'ID Card';
        identityDocumentMetadatas[0].DocumentTypeFront.Description = 'Identity card';
        identityDocumentMetadatas[0].DocumentTypeFront.DocType = 3;
        identityDocumentMetadatas[0].DocumentTypeFront.IssueCountryCode = 'AUS';
        identityDocumentMetadatas[0].DocumentTypeBack = new BCB_Identify_OCRBean.cls_DocumentTypeBack();
        identityDocumentMetadatas[0].DocumentTypeBack.ID = '654';
        identityDocumentMetadatas[0].DocumentTypeBack.Name = 'Residence Permit';
        identityDocumentMetadatas[0].DocumentTypeBack.Description = 'Permit to reside';
        identityDocumentMetadatas[0].DocumentTypeBack.DocType = 4;
        identityDocumentMetadatas[0].DocumentTypeBack.IssueCountryCode = 'FRA';

        BCB_Identify_OCRBean bean = new BCB_Identify_OCRBean();
        bean.DocumentTypeDetected = documentTypeDetected;
        bean.DocumentTypeSelected = documentTypeSelected;
        bean.IdentityDocumentMetadatas = identityDocumentMetadatas;


        BCB_Identify_OCRBean.cls_DocumentTypeDetected actualDocumentTypeDetected = bean.DocumentTypeDetected;
       Assert.areEqual('123', actualDocumentTypeDetected.ID,'Test');
       Assert.areEqual('Passport', actualDocumentTypeDetected.Name,'Test');
       Assert.areEqual('Travel document', actualDocumentTypeDetected.Description,'Test');
       Assert.areEqual(1, actualDocumentTypeDetected.DocType,'Test');
       Assert.areEqual('USA', actualDocumentTypeDetected.IssueCountryCode,'Test');

        BCB_Identify_OCRBean.cls_DocumentTypeSelected actualDocumentTypeSelected = bean.DocumentTypeSelected;
       Assert.areEqual('456', actualDocumentTypeSelected.ID,'Test');
       Assert.areEqual('Driver License', actualDocumentTypeSelected.Name,'Test');
       Assert.areEqual('Driving permit', actualDocumentTypeSelected.Description,'Test');
       Assert.areEqual(2, actualDocumentTypeSelected.DocType,'Test');
       Assert.areEqual('CAN', actualDocumentTypeSelected.IssueCountryCode,'Test');

        BCB_Identify_OCRBean.cls_IdentityDocumentMetadatas[] actualIdentityDocumentMetadatas = bean.IdentityDocumentMetadatas;
       Assert.areEqual(1, actualIdentityDocumentMetadatas.size(),'Test');

        BCB_Identify_OCRBean.cls_IdentityDocumentMetadatas actualIdentityDocumentMetadata = actualIdentityDocumentMetadatas[0];
       Assert.areEqual('789', actualIdentityDocumentMetadata.ID,'Test');

        BCB_Identify_OCRBean.cls_Metadata actualMetadata = actualIdentityDocumentMetadata.Metadata;
       Assert.areNotEqual(null, actualMetadata,'Test');

       Assert.areEqual('456', actualIdentityDocumentMetadata.FrontTypeIDDetected,'Test');
       Assert.areEqual('789', actualIdentityDocumentMetadata.BackTypeIDDetected,'Test');

        BCB_Identify_OCRBean.cls_FrontVIZFields actualFrontVIZFields = actualIdentityDocumentMetadata.FrontVIZFields;
       Assert.areNotEqual(null, actualFrontVIZFields,'Test');
       Assert.areEqual('123456789', actualFrontVIZFields.DocumentNumber,'Test');
       Assert.areEqual('Doe', actualFrontVIZFields.LastName,'Test');
       Assert.areEqual('John', actualFrontVIZFields.FirstName,'Test');
       Assert.areEqual('2023-06-30', actualFrontVIZFields.DateOfExpiry,'Test');
       Assert.areEqual('USA', actualFrontVIZFields.Nationality,'Test');
       Assert.areEqual('987654321', actualFrontVIZFields.PersonalNumber,'Test');
       Assert.areEqual('1980-01-01', actualFrontVIZFields.DateOfBirth,'Test');
       Assert.areEqual('Male', actualFrontVIZFields.Gender,'Test');

       BCB_Identify_OCRBean.cls_BackVIZFields actualBackVIZFields = actualIdentityDocumentMetadata.BackVIZFields;
       Assert.areNotEqual(null, actualBackVIZFields,'Test');
       Assert.areEqual('ABC', actualBackVIZFields.District,'Test');
       Assert.areEqual('XYZ', actualBackVIZFields.Location,'Test');
       Assert.areEqual('MRTD123', actualBackVIZFields.MRTD,'Test');
       Assert.areEqual('PQR', actualBackVIZFields.SubLocation,'Test');
       Assert.areEqual('DEF', actualBackVIZFields.Division,'Test');
       Assert.areEqual('GHI', actualBackVIZFields.Village,'Test');

       BCB_Identify_OCRBean.cls_DocumentTypeFront actualDocumentTypeFront = actualIdentityDocumentMetadata.DocumentTypeFront;
       Assert.areNotEqual(null, actualDocumentTypeFront,'Test');
       Assert.areEqual('987', actualDocumentTypeFront.ID,'Test');
       Assert.areEqual('ID Card', actualDocumentTypeFront.Name,'Test');
       Assert.areEqual('Identity card', actualDocumentTypeFront.Description,'Test');
       Assert.areEqual(3, actualDocumentTypeFront.DocType,'Test');
       Assert.areEqual('AUS', actualDocumentTypeFront.IssueCountryCode,'Test');

       BCB_Identify_OCRBean.cls_DocumentTypeBack actualDocumentTypeBack = actualIdentityDocumentMetadata.DocumentTypeBack;
       Assert.areNotEqual(null, actualDocumentTypeBack,'Test');
       Assert.areEqual('654', actualDocumentTypeBack.ID,'Test');
       Assert.areEqual('Residence Permit', actualDocumentTypeBack.Name,'Test');
       Assert.areEqual('Permit to reside', actualDocumentTypeBack.Description,'Test');
       Assert.areEqual(4, actualDocumentTypeBack.DocType,'Test');
       Assert.areEqual('FRA', actualDocumentTypeBack.IssueCountryCode,'Test');
    }
    @isTest static void BCBIdentifyBodyBeanTest() {
        BCB_Identify_BodyBean.Body body = new BCB_Identify_BodyBean.Body();
        body.ApplicationId = 'TestAppId';
        body.IdNumber = '1234567890';
        body.ClientReference = 'TestRef';
        body.DHACheckDisabled = 0;
        body.IDValidationDisabled = 0;

        BCB_Identify_BodyBean.IdentityImages image = new BCB_Identify_BodyBean.IdentityImages();
        image.ID = 'TestImageId';
        image.IdentityID = 'TestId';
        image.Image = Blob.valueOf('TestImage');
        BCB_Identify_BodyBean.ImageType imageType = new BCB_Identify_BodyBean.ImageType();
        imageType.Description = 'TestDescription';
        imageType.ID = 'TestId';
        image.ImageType = imageType;

        List<BCB_Identify_BodyBean.IdentityImages> imageList = new List<BCB_Identify_BodyBean.IdentityImages>();
        imageList.add(image);

        BCB_Identify_BodyBean.Response response = new BCB_Identify_BodyBean.Response();
        response.LivenessFRMatch = true;
        response.LivenessFRScore = 0.95;
        response.DocumentTypeIDDetected = 'TestDocId';
        response.IdentityImages = imageList;
        response.DateOfExpiry = '2023-12-31';
        response.PersonalNumber = '12345';

        BCB_Identify_BodyBean bean = new BCB_Identify_BodyBean();
        bean.ApiKey = 'TestApiKey';
        bean.Secret = 'TestSecret';
        bean.Body = body;
        bean.Url = 'TestUrl';
        bean.Method = 'POST';

       
    }
}