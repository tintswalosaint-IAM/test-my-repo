@isTest
public with sharing class ICS_DTO_DSXResponse_Test {
    @isTest
    static void testSearchClass() {
        
        
        ICS_DTO_DSXResponse.PageInfo pageInfo = new ICS_DTO_DSXResponse.PageInfo();
        pageInfo.currentPage = 1;
        pageInfo.totalPages = 50;
        
        ICS_DTO_DSXResponse.DocumentInfo documentInfo = new ICS_DTO_DSXResponse.DocumentInfo();
        documentInfo.documentId = 'y602BQ2AY-764g7y';
        documentInfo.documentName = 'Pulani-Thuli_SOW-Proof-of-Gift_2024-09-05.pdf';
        documentInfo.documentType = 'SOW Proof of Gift';
        documentInfo.documentDate = '2024-05-24';
        documentInfo.retentionDate = '2026-05-24';
        documentInfo.clientNo = 'BP00000002';
        documentInfo.clientName = 'Pulani Thuli';
        documentInfo.salesForceId = '0xUKH2BQ2AY764gP';
        List<ICS_DTO_DSXResponse.DocumentInfo> documents = new List<ICS_DTO_DSXResponse.DocumentInfo>();
        documents.add(documentInfo);
        
        ICS_DTO_DSXResponse.Search search = new ICS_DTO_DSXResponse.Search();
        search.pageInfo = pageInfo;
        search.documents = documents;

        String jsonString = JSON.serialize(search);

        ICS_DTO_DSXResponse.Search deserializedSearch = 
            (ICS_DTO_DSXResponse.Search) JSON.deserialize(jsonString, ICS_DTO_DSXResponse.Search.class);

        Assert.areEqual(search.pageInfo.currentPage, deserializedSearch.pageInfo.currentPage, 'currentPage should match');
        Assert.areEqual(search.pageInfo.totalPages, deserializedSearch.pageInfo.totalPages, 'totalPages should match');
        Assert.areEqual(search.documents[0].documentId, deserializedSearch.documents[0].documentId, 'documentId should match');
        Assert.areEqual(search.documents[0].documentName, deserializedSearch.documents[0].documentName, 'documentName should match');
        Assert.areEqual(search.documents[0].documentType, deserializedSearch.documents[0].documentType, 'documentType should match');
        Assert.areEqual(search.documents[0].documentDate, deserializedSearch.documents[0].documentDate, 'documentDate should match');
        Assert.areEqual(search.documents[0].retentionDate, deserializedSearch.documents[0].retentionDate, 'retentionDate should match');
        Assert.areEqual(search.documents[0].clientNo, deserializedSearch.documents[0].clientNo, 'clientNo should match');
        Assert.areEqual(search.documents[0].clientName, deserializedSearch.documents[0].clientName, 'clientName should match');
        Assert.areEqual(search.documents[0].salesForceId, deserializedSearch.documents[0].salesForceId, 'salesForceId should match');
    }

    @isTest
    static void testPageInfoClass() {
        
        
        ICS_DTO_DSXResponse.PageInfo pageInfo = new ICS_DTO_DSXResponse.PageInfo();
        pageInfo.currentPage = 1;
        pageInfo.totalPages = 50;

        String jsonString = JSON.serialize(pageInfo);

        ICS_DTO_DSXResponse.PageInfo deserializedPageInfo = 
            (ICS_DTO_DSXResponse.PageInfo) JSON.deserialize(jsonString, ICS_DTO_DSXResponse.PageInfo.class);

        Assert.areEqual(pageInfo.currentPage, deserializedPageInfo.currentPage, 'currentPage should match');
        Assert.areEqual(pageInfo.totalPages, deserializedPageInfo.totalPages, 'totalPages should match');
    }

    @isTest
    static void testDocumentInfoClass() {
        
        
        ICS_DTO_DSXResponse.DocumentInfo documentInfo = new ICS_DTO_DSXResponse.DocumentInfo();
        documentInfo.documentId = 'y602BQ2AY-764g7y';
        documentInfo.documentName = 'Pulani-Thuli_SOW-Proof-of-Gift_2024-09-05.pdf';
        documentInfo.documentType = 'SOW Proof of Gift';
        documentInfo.documentDate = '2024-05-24';
        documentInfo.retentionDate = '2026-05-24';
        documentInfo.clientNo = 'BP00000002';
        documentInfo.clientName = 'Pulani Thuli';
        documentInfo.salesForceId = '0xUKH2BQ2AY764gP';
        String jsonString = JSON.serialize(documentInfo);

        ICS_DTO_DSXResponse.DocumentInfo deserializedDocumentInfo = 
            (ICS_DTO_DSXResponse.DocumentInfo) JSON.deserialize(jsonString, ICS_DTO_DSXResponse.DocumentInfo.class);

        Assert.areEqual(documentInfo.documentId, deserializedDocumentInfo.documentId, 'documentId should match');
        Assert.areEqual(documentInfo.documentName, deserializedDocumentInfo.documentName, 'documentName should match');
        Assert.areEqual(documentInfo.documentType, deserializedDocumentInfo.documentType, 'documentType should match');
        Assert.areEqual(documentInfo.documentDate, deserializedDocumentInfo.documentDate, 'documentDate should match');
        Assert.areEqual(documentInfo.retentionDate, deserializedDocumentInfo.retentionDate, 'retentionDate should match');
        Assert.areEqual(documentInfo.clientNo, deserializedDocumentInfo.clientNo, 'clientNo should match');
        Assert.areEqual(documentInfo.clientName, deserializedDocumentInfo.clientName, 'clientName should match');
        Assert.areEqual(documentInfo.salesForceId, deserializedDocumentInfo.salesForceId, 'salesForceId should match');
    }
}