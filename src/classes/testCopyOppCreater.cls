@isTest
private class testCopyOppCreater {
    static testMethod void copyOppCreator(){    
        Case cse=new Case();
        insert cse;
 
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=cse.id;
        insert attach;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:cse.id];
        System.assertEquals(1, attachments.size());
     }
 }