@IsTest
public class ContentDocumentLinkTriggerTest {
    
    @IsTest
    static void testShareDocs() {
        Test.startTest();
        Account accA =new Account(Name='Demo');
        insert accA ; 
        Opportunity opp = new Opportunity(Name='test opp',StageName='stage', AccountId = accA.Id ,Probability = 95, CloseDate=system.today());
        insert opp;
        
        Quote Q = New Quote(Name='Test Quote', OpportunityId=opp.Id);
        insert Q;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=q.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        Test.stopTest();
        
    }
}