/**
Author : Vibhor Goel (www.accidentalcodersf.com) - Accidental Coder - A Salesforce Blog 
Description: Used in flows to parse a multi-select checkbox and convert to comma (no space) delimeter vs. semicolon (with space delimeter)...need comma seperated for Loop variable
Updates: Richard on 2021-10-04 (see code below)
**/
global class MultiSelectFlowValues {
   
   @InvocableMethod
   public static List<list<string>> CheckValues(List<string> values) {
      if(!(values.isEmpty())){
          
          string tempStr = values[0];
/* Code installed with package...release notes say issues exist and this code parses semicolon WITHOUT space */       
          List<String> lstnew = tempStr.split(';');

/* Code installed with package...release notes say issues exist and this code parses semicolon WITH space */
/*      
          List<String> lstnew = tempStr.split('; ');
*/
          list<list<string>> finalLst = new list<list<string>>();
          finalLst.add(lstnew);
          return finalLst;
      }
      else return null;
   }
}