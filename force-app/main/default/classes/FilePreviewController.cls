/**
* @author Gil Avignon
* @date 12/05/2020
* @description File Preview Component with filter and sort options
*/
public with sharing class FilePreview {
    private static Map<String, String> mapConditionByFilter = new Map<String, String>{
        'gt100KB' => 'ContentDocument.ContentSize >= ' + 100 * 1024,
        'lt100KBgt10KB' => '(ContentDocument.ContentSize < ' + 100 * 1024 + ' AND ContentDocument.ContentSize > ' + 10 * 1024 + ')',
        'lt10KB' => 'ContentDocument.ContentSize <= ' + 10 * 1024
    };

    @AuraEnabled
    public static FilesInformation initFiles(Id recordId, List<String> filters, Integer defaultLimit, String sortField, String sortOrder) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        defaultLimit = defaultLimit == null ? 3 : defaultLimit;

        String query = generateQuery(recordId, filters, defaultLimit, null, sortField, sortOrder);
        String countQuery = 'SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = ' + '\'' + recordId + '\'';
        countQuery += generateConditionString(filters);

        contentDocumentLinks = Database.query(query);
        FilesInformation fileInfo = new FilesInformation();
        fileInfo.totalCount = Database.countQuery(countQuery);
        fileInfo.contentDocumentLinks = contentDocumentLinks;

        return fileInfo;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> loadFiles(Id recordId, List<String> filters, Integer defaultLimit, Integer offset, String sortField, String sortOrder) {

        String query = generateQuery(recordId, filters, defaultLimit, offset, sortField, sortOrder);
        System.debug(query);

        List<ContentDocumentLink> contentDocumentLinks = Database.query(query);

        return contentDocumentLinks;
    }

    @AuraEnabled
    public static List<ContentDocumentLink> queryFiles(Id recordId, List<Id> contentDocumentIds) {
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();

        contentDocumentLinks = [SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.FileExtension, ContentDocument.ContentSize, ContentDocument.FileType
                                FROM ContentDocumentLink
                                WHERE LinkedEntityId = :recordId AND ContentDocumentId IN :contentDocumentIds];

        return contentDocumentLinks;
    }
    
    private static String generateConditionString(List<String> filters){
        String conditionString = '';
        if(filters != null && !filters.isEmpty()){
            conditionString += ' AND (';
            Boolean firstFilter = true;
            for(String filter : filters){
                if(mapConditionByFilter.containsKey(filter)){
                    if(!firstFilter){
                        conditionString += ' OR ';
                    }
                    conditionString += mapConditionByFilter.get(filter);
                    firstFilter = false;
                }
            }
            conditionString += ')';
        }
        return conditionString;
    }

    private static String generateQuery(Id recordId, List<String> filters, Integer defaultLimit, Integer offset, String sortField, String sortOrder){
        String query = 'SELECT Id, ContentDocumentId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.FileExtension, ContentDocument.ContentSize,ContentDocument.FileType ';
        query += 'FROM ContentDocumentLink ';
        query += 'WHERE LinkedEntityId = \'' + recordId + '\'';

        query += generateConditionString(filters);

        query += ' ORDER BY ' + sortField + ' ' + sortOrder;
        query += '  LIMIT ' + defaultLimit;

        if(offset != null){
            query += ' OFFSET ' + offset;
        }

        return query;
    }

    public class FilesInformation{
        @AuraEnabled
        public Integer totalCount;
        @AuraEnabled
        public List<ContentDocumentLink> contentDocumentLinks;
    }

}
