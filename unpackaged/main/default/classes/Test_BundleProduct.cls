@istest
public class Test_BundleProduct {

    @testsetup
    public static void createProducts(){
        // I need at least three products, or I need more than one test
        // - Add a product with no discount override
        // - Add a product with a percentage discount override
        // - Add a product with no perentage discount override
        List<Product2> allProducts = new List<Product2>();
        
        Product2 theProduct = new Product2();
        	theProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('One-Time Fees').getRecordTypeId();
        	theProduct.Name = 'Setup for Tests';
        	theProduct.isActive = true;
        	theProduct.Billing_Type__c = 'One-Time';
        allProducts.add(theProduct);
        
        Product2 theOtherProduct = new Product2();
        	theOtherProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Recurring Revenue').getRecordTypeId();
        	theOtherProduct.Name = 'Not Setup for Tests';
        	theOtherProduct.isActive = true;
        	theOtherProduct.Billing_Type__c = 'Recurring';
        	theOtherProduct.Billing_Frequency__c = 'Monthly';
        allProducts.add(theOtherProduct);
        
        Product2 theOtherOtherProduct = new Product2();
        	theOtherOtherProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Recurring Revenue').getRecordTypeId();
        	theOtherOtherProduct.Name = 'Also Not Setup for Tests';
        	theOtherOtherProduct.isActive = true;
        	theOtherOtherProduct.Billing_Type__c = 'Recurring';
        	theOtherOtherProduct.Billing_Frequency__c = 'Monthly';
        allProducts.add(theOtherOtherProduct);

        insert allProducts;

        
        // Now we need pricebook entries for all these
        List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();
        for(Product2 thisProduct : allProducts){
            PricebookEntry theEntry = new PricebookEntry();
            	theEntry.Pricebook2Id = Test.getStandardPricebookId();
            	theEntry.Product2Id = thisProduct.Id;
            	theEntry.isActive = true;
            	theEntry.UnitPrice = 500;
            allPricebookEntries.add(theEntry);
        }
        
        insert allPricebookEntries;
    }
    
    @istest
    public static void createABundle(){

		List<Product2> allProducts = [SELECT Id FROM Product2];
        System.Debug(allProducts);


        List<PricebookEntry> allPricebookEntries = new List<PricebookEntry>();
        Map<String, PricebookEntry> allPricebookEntriesByProductName = new Map<String, PricebookEntry>();
        allPricebookEntries = [SELECT Id,
                               PricebookEntry.Name,
                               Pricebook2Id,
                               Pricebook2.isStandard,
                               Product2Id,
                               Product2.Name,
                               UnitPrice,
                               UseStandardPrice
                               FROM PricebookEntry
                               WHERE Pricebook2Id = :Test.getStandardPricebookId()];
        System.Debug(allPricebookEntries);
        for(PricebookEntry thePricebookEntry : allPricebookEntries){
            allPricebookEntriesByProductName.put(thePricebookEntry.Product2.Name, thePricebookEntry);
        }

        String thePricebookId = Test.getStandardPricebookId();
        // String thePricebookId = allPricebookEntries[0].Pricebook2Id;
        System.Debug('Pricebook ID: ' + thePricebookId);
        
        // Create the Bundle
        Bundle_Plan__c dasPlan = new Bundle_Plan__c();
            dasPlan.Name = 'Test Bundle';
            dasPlan.Price_Book__c = thePricebookId;
        	dasPlan.Plan_Discount__c = 5;
        	dasPlan.Tier_Plan__c = 'Launch';
        insert dasPlan;
        
        decimal defaultDiscount = 1 - (dasPlan.Plan_Discount__c/100);
        
        // Now we start inserting products into the bundle so we create a list
 		List<Bundle_Product__c> allBundleProducts = new List<Bundle_Product__c>();  
 		// First we insert a product with the standard price

        Bundle_Product__c theProduct = new Bundle_Product__c();
	        theProduct.Bundle_Plan__c = dasPlan.Id;
        	theProduct.Product__c = allPricebookEntries[0].Product2Id;
        	System.Debug('Product Pricebook: ' + allPricebookEntries[0].Pricebook2Id);
        	// theProduct.Minimum_Price_Allowed__c = (allPricebookEntries[0].UnitPrice * defaultDiscount) - 0.01;
        	theProduct.Fixed_Price_Discount_Override__c = null;
        	theProduct.Discount_Override__c = null;
		allBundleProducts.add(theProduct);
        
 		Bundle_Product__c theProduct1 = new Bundle_Product__c();
	        theProduct1.Bundle_Plan__c = dasPlan.Id;
        	theProduct1.Product__c = allPricebookEntries[1].Product2Id;
        	// theProduct1.Minimum_Price_Allowed__c = allPricebookEntries[1].UnitPrice * defaultDiscount;
        	theProduct1.Fixed_Price_Discount_Override__c = 0;
        	theProduct1.Discount_Override__c = null;
		allBundleProducts.add(theProduct1);        	

 		Bundle_Product__c theProduct2 = new Bundle_Product__c();
	        theProduct2.Bundle_Plan__c = dasPlan.Id;
        	theProduct2.Product__c = allPricebookEntries[2].Product2Id;
        	// theProduct2.Minimum_Price_Allowed__c = allPricebookEntries[2].UnitPrice * (defaultDiscount - 0.05);
        	theProduct2.Fixed_Price_Discount_Override__c = null;
        	theProduct2.Discount_Override__c = dasPlan.Plan_Discount__c + 1;
		allBundleProducts.add(theProduct2);        	

        insert allBundleProducts;
        
        dasPlan.isActive__c = true;
        update dasPlan;

    }
}