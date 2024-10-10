/****************************************************************************************   
* File Name   : SyncProductCalloutJob.cls
* Description : Schedulable 구현체에 들어가는 future 메소드
* Test Class  : SyncProductCalloutJob_Test.cls
* Author      : Evander  
* Modification Log  
* ===============================================================  
* Ver  Date        Author        Modification  
* ===============================================================  
* 1.0  2024.10.07  Evander        Create  
**************************************************************************************** 
* TODO  
* 테스트 작성  
****************************************************************************************/ 
public class SyncProductCalloutJob implements Queueable, Database.AllowsCallouts { // ProductSyncJobManager
    private String resultJson;

    public SyncProductCalloutJob(String resultJson) {
        this.resultJson = resultJson;
    }

    public void execute(QueueableContext context) {
        SyncProductController.postSyncResult(this.resultJson);
    }

    @future(callout=true)
    public static void executeFuture() {
        SyncProductController.syncProduct();
    }
}


// @isTest
// public class SyncProductCalloutJobTest implements HttpCalloutMock {
    
//     // Implement the respond method for mocking
//     public HTTPResponse respond(HTTPRequest req) {
//         // Create a fake HTTP response
//         HttpResponse res = new HttpResponse();
//         res.setStatusCode(200);
//         res.setBody('{"deletedProductIds":[],"changedProducts":[{"Id":"01tWU000007ZyOfYAK","Stock__c":2,"Name":"Robotic Arm Assembly System","Description":"Robotic Arm Assembly System","IsActive":true},{"Id":"01tWU000007ZyOfYAL","Stock__c":5,"Name":"Wheeled Assembly","Description":"Wheeled Assembly","IsActive":false}]}');
//         return res;
//     }

//     @isTest
//     static void testExecuteFuture() {
//         // Set the mock for HTTP callouts
//         Test.setMock(HttpCalloutMock.class, new SyncProductCalloutJobTest());
        
//         // Call the future method
//         Test.startTest();
//         SyncProductCalloutJob.executeFuture();
//         Test.stopTest();

//         // Verify the results (for example, check the state of Product2 records)
//         List<Product2> products = [SELECT Id, Stock__c, IsActive FROM Product2 WHERE Id IN ('01tWU000007ZyOfYAK', '01tWU000007ZyOfYAL')];
        
//         // Validate the expected outcome
//         System.assertEquals(2, products.size(), 'Two products should have been processed.');
//         System.assertEquals(2, products[0].Stock__c, 'Stock for first product should be 2.');
//         System.assertEquals(true, products[0].IsActive, 'First product should be active.');
//         System.assertEquals(5, products[1].Stock__c, 'Stock for second product should be 5.');
//         System.assertEquals(false, products[1].IsActive, 'Second product should not be active.');
//     }
// }