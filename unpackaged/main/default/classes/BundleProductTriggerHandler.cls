public class BundleProductTriggerHandler {

    public class productPrices {
        Decimal setupFeeListPrice = 0;
        Decimal setupFeeDiscountPrice = 0;
        Decimal setupFeeMinimumPrice = 0;
        Decimal numberOfSetupFeeProducts = 0;
        Decimal otherFeeListPrice = 0;
        Decimal otherFeeDiscountPrice = 0;
        Decimal otherFeeMinimumPrice = 0;
        Decimal numberOfOtherProducts = 0;
    }
    
    public static void updateBundlePlanTotals(Set<Id> allBundlePlanIds){
	    System.Debug('Updating Bundle Plan Totals');
        System.Debug(allBundlePlanIds);

        // We want to calculate a bunch of values here, including totals and discounts
        // there are too many to use Roll Up fields, so we do the Trigger
//		Set<Id> allBundlePlanIds = new Set<Id>();
//        for(Bundle_Product__c theProduct : updatedBundleProducts){
//            allBundlePlanIds.add(theProduct.Bundle_Plan__c);
//        }
        List<Bundle_Product__c> allBundleProducts = new List<Bundle_Product__c>();
        Map<String, productPrices> totalPricesByBundleProductId = new Map<String, productPrices>();
        
        // We need to get *all* the products related to the Plan, not just the one in the Trigger
		allBundleProducts = [SELECT Id,
                             Bundle_Plan__c,
                             Product_Family__c,
                             Standard_Price__c,
                             Bundle_Price__c,
                             Minimum_Price_Allowed__c 
                             FROM Bundle_Product__c
                             WHERE Bundle_Plan__c IN :allBundlePlanIds];
        
        Map<String, Bundle_Plan__c> bundlePlansById = new Map<String, Bundle_Plan__c>();

        for(Bundle_Product__c theProduct : allBundleProducts){
                // check to see if our map already has a value for this bundle plan
                // if it does, we add to it. If it doesn't we set a new value
                productPrices thePrices = new productPrices();
            if(theProduct.Minimum_Price_Allowed__c == null){ theProduct.Minimum_Price_Allowed__c = 0; }

            	// Check to see if we've seen this before and get the values
            	if(totalPricesByBundleProductId.containsKey(theProduct.Bundle_Plan__c) == true) {
                    thePrices = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c);
                }

                    if(theProduct.Product_Family__c == 'Setup Fee'){
                        thePrices.setupFeeListPrice = thePrices.setupFeeListPrice + theProduct.Standard_Price__c;
                        thePrices.setupFeeDiscountPrice = thePrices.setupFeeDiscountPrice + theProduct.Bundle_Price__c;
                        thePrices.setupFeeMinimumPrice = thePrices.setupFeeMinimumPrice + theProduct.Minimum_Price_Allowed__c;
                        thePrices.numberOfSetupFeeProducts = thePrices.numberOfSetupFeeProducts + 1;
                    } else {
                        thePrices.otherFeeListPrice = thePrices.otherFeeListPrice + theProduct.Standard_Price__c;
                        thePrices.otherFeeDiscountPrice = thePrices.otherFeeDiscountPrice + theProduct.Bundle_Price__c;
                        thePrices.otherFeeMinimumPrice = thePrices.otherFeeMinimumPrice + theProduct.Minimum_Price_Allowed__c;
                        thePrices.numberOfOtherProducts = thePrices.numberOfOtherProducts + 1;
                    }
                    totalPricesByBundleProductId.put(theProduct.Bundle_Plan__c, thePrices);

        		Bundle_Plan__c theUpdatedPlan = new Bundle_Plan__c();
        		  	theUpdatedPlan.Id = theProduct.Bundle_Plan__c;
        		  	theUpdatedPlan.Total_List_Price_of_Other_Products__c   = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).otherFeeListPrice;
        		  	theUpdatedPlan.Total_Discount_Price_of_Other_Products__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).otherFeeDiscountPrice;
        		  	theUpdatedPlan.Total_Minimum_Price_of_Other_Products__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).otherFeeMinimumPrice;
        		  	theUpdatedPlan.Number_of_Other_Products__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).numberOfOtherProducts;
        		  	theUpdatedPlan.Total_List_Price_of_Setup_Fee_Products__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).setupFeeListPrice;
        		  	theUpdatedPlan.Total_Discount_Price_of_Setup_Fees__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).setupFeeDiscountPrice;
        		  	theUpdatedPlan.Total_Minimum_Price_of_Setup_Fees__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).setupFeeMinimumPrice;
        		  	theUpdatedPlan.Number_of_Setup_Fee_Products__c  = totalPricesByBundleProductId.get(theProduct.Bundle_Plan__c).numberOfSetupFeeProducts;
            	System.Debug(theUpdatedPlan);
            
            	bundlePlansById.put(theProduct.Bundle_Plan__c, theUpdatedPlan);
            	System.Debug(bundlePlansById);

        }
        
        // Now we have our list, let's update!
        update bundlePlansById.values();
        
                
            }
    
    
        }