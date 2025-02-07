trigger BundleProductTrigger on Bundle_Product__c (before insert, before update, after insert, after update, after delete) {
    
    System.Debug('Bundle Product Trigger');
    System.Debug(Trigger.isBefore);
    
    if(Trigger.isBefore == true) {
		
        System.Debug('Bundle Product Before Trigger');
        // 1) Sets the product name to Bundle-Plan (as well as a unique name so we don't create duplicates)
        // 2) Gets the price from the standard price book and pops it into a field here
        Set<Id> allProductIds = new Set<Id>();
        Set<Id> allBundlePlanIDs = new Set<Id>();
        
        for(Bundle_Product__c theRecord : Trigger.new){
            allBundlePlanIDs.add(theRecord.Bundle_Plan__c);	
            allProductIds.add(theRecord.Product__c);    
        }

        List<Bundle_Plan__c> allBundlePlans = [SELECT Id, Name,
                                               Plan_Discount__c,
                                               Price_Book__c
                                               FROM Bundle_Plan__c
                                               WHERE Id IN :allBundlePlanIDs];
        Map<String, Bundle_Plan__c> bundlePlanById = new Map<String, Bundle_Plan__c>();
    
        Set<Id> allPricebookIds = new Set<Id>();
            for(Bundle_Plan__c thePlan : allBundlePlans){
                bundlePlanById.put(thePlan.Id, thePlan);
                allPricebookIds.add(thePlan.Price_Book__c);
                System.Debug(thePlan);
            }
        System.Debug('All Pricebook IDs' + allPricebookIds);

    
        List<Product2> allProducts = [SELECT Id, Name, Bundle_Discount__c FROM Product2 WHERE Id IN :allProductIds];
            System.Debug(allProducts);
        List<PriceBookEntry> allPricebookEntries = [SELECT Id, 
                                                    Name, 
                                                    UnitPrice, 
                                                    Product2Id, 
                                                    Product2.Name, 
                                                    Product2.Family, 
                                                    PriceBook2Id,
                                                    PriceBook2.Name
                                                    FROM PriceBookEntry 
                                                    WHERE Pricebook2Id IN :allPricebookIds
                                                    AND Product2Id IN: allProductIds];
		System.Debug(allPriceBookEntries.size() + ' PricebookEntries Found');
        for(PriceBookEntry theEntry : allPriceBookEntries){
            System.Debug(theEntry.Name + ' .:. ' + theEntry.PriceBook2Id);
        }

        // Put our PriceBookEntries in a map with an compound ID of PriceBookEntryID-ProductId
        Map<String, PriceBookEntry> pricebookEntryByBothIds = new Map<String, PriceBookEntry>();
        for(PriceBookEntry theEntry : allPricebookEntries) {
            pricebookEntryByBothIds.put(theEntry.PriceBook2Id + '-' + theEntry.Product2Id, theEntry);
        }    
    
    
    for(Bundle_Product__c theRecord : Trigger.new){
		
        Decimal theDiscount;
        if(theRecord.Discount_Override__c != null){
			theDiscount = (1 - theRecord.Discount_Override__c/100);         
        } else {
			theDiscount = (1 - bundlePlanById.get(theRecord.Bundle_Plan__c).Plan_Discount__c/100);         
        }
        
		String thePricebookID = bundlePlanById.get(theRecord.Bundle_Plan__c).Price_Book__c;
        	System.Debug('PricebookID: ' + thePricebookID);

        if(pricebookEntryByBothIds.containsKey(thePricebookId + '-' + theRecord.Product__c) == true){
            System.Debug('Found a Matching Product: ' + pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).Name);
            System.Debug(pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).PriceBook2.Name);
            System.Debug(pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).PriceBook2.Id);
            
            theRecord.PriceBookEntry_ID__c = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).Id;
            theRecord.PriceBook_Entry_Name__c  = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).Name;
            theRecord.Pricebook_ID__c  = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).Pricebook2Id;
            theRecord.PriceBook_Name__c  = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).PriceBook2.Name;
            
            theRecord.Standard_Price__c = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).UnitPrice;
            theRecord.Product_Name__c = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).Product2.Name;
            theRecord.Product_Family__c = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).Product2.Family;

        if(theRecord.Fixed_Price_Discount_Override__c != null) {
            theRecord.Bundle_Price__c = theRecord.Fixed_Price_Discount_Override__c;
        } else {
			theRecord.Bundle_Price__c = pricebookEntryByBothIds.get(thePricebookId + '-' + theRecord.Product__c).UnitPrice * theDiscount;         
        }
        }

        // Set the Minimum Price if it wasn't set
        if(theRecord.Minimum_Price_Allowed__c == null) { theRecord.Minimum_Price_Allowed__c = theRecord.Bundle_Price__c; }

    }
	} else if (Trigger.isAfter == true && Trigger.isDelete == false) {
    	
    	System.Debug('Bundle Product After Trigger');
        // Send everything to update the Bundle Plan
    	Set<Id> allBundlePlanIds = new Set<Id>();
        for(Bundle_Product__c theProduct : Trigger.new) {
            allBundlePlanIds.add(theProduct.Bundle_Plan__c);
        }
        BundleProductTriggerHandler.updateBundlePlanTotals(allBundlePlanIds);
    } else if (Trigger.isAfter == true && Trigger.isDelete == true) {
    	System.Debug('Bundle Product After Delete Trigger');

        Set<Id> allBundlePlanIds = new Set<Id>();
        for(Bundle_Product__c theProduct : Trigger.old) {
            allBundlePlanIds.add(theProduct.Bundle_Plan__c);
        }
        BundleProductTriggerHandler.updateBundlePlanTotals(allBundlePlanIds);
    }
}