@isTest
public class CustomSearchControllerTest {

    @isTest static void searchForIdsTest(){
        
        List<String> lstResults = new List<String>();
        
        Test.startTest();
        
        lstResults = CustomSearchController.searchForIds('Test');
        
        Test.stopTest();
        
        System.assertEquals(true, lstResults.isEmpty());
        
    }
    
}