trigger BundlePlanTrigger on Bundle_Plan__c (before insert, before update) {
    if(Trigger.isBefore == true){
        for(Bundle_Plan__c thePlan : Trigger.new) {
            thePlan.Name_Unique__c = thePlan.Name;
        }
    }
}