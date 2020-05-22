@isTest
public with sharing class FilePreviewControllerTest {
    public FilePreviewControllerTest() {

    }

    @testSetup
    static void setup() {
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }

    @isTest
    static void testMethods() {
        Account acct = [SELECT Id FROM Account WHERE Name='TEST_ACCT' LIMIT 1];
        List<String> filters =new List<String>{'gt100KB','lt100KBgt10KB','lt10KB'};
        Integer defaultLimit = 3;
        Integer offset = 0;
        String sortField = 'ContentDocument.Title';
        String sortOrder = 'DESC';
        List<Id> ContentDocumentIds = new List<Id>();
        for (ContentDocument cd : [SELECT Id FROM ContentDocument]) {
            ContentDocumentIds.add(cd.Id);
        }

        FilePreviewController.FilesInformation fileinfo =
        FilePreviewController.initFiles(acct.Id, filters, defaultLimit, sortField, sortOrder);
        List<ContentDocumentLink> lf =
        FilePreviewController.loadFiles(acct.Id, filters, defaultLimit, offset, sortField, sortOrder);
        List<ContentDocumentLink> qf =
        FilePreviewController.queryFiles(acct.Id, ContentDocumentIds);

        System.assertEquals(1, fileInfo.totalCount, 'TotalCount must be one.');
        System.assertEquals(1, lf.size(), 'loadFiles must retrun one ContentDocumentLink.');
        System.assertEquals(1, qf.size(), 'queryFiles must retrun one ContentDocumentLink.');
    }
}
