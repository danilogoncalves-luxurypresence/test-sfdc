trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {

    for(ContentDocumentLink cdl : trigger.new ){
        cdl.visibility = 'AllUsers';
    }
}