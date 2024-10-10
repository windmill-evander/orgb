/****************************************************************************************   
* File Name   : ScheduledProductSync.cls
* Description : 주기적 Sync Product를 위한 Schedulable 구현체
* Test Class  : ScheduledProductSync_Test.cls
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
public with sharing class ScheduledProductSync implements Schedulable { // ProductSyncScheduler 
    public void execute(SchedulableContext sc) {
        // SyncProductCalloutJob.executeFuture();
        ProductSyncBatch batch = new ProductSyncBatch('/services/apexrest/product2/synchronization');
        Database.executeBatch(batch);
    }
}


// @isTest
// public class ScheduledProductSyncTest {
    
//     @isTest
//     static void testScheduledProductSync() {
//         // Setup test data if needed
//         // Example: create a few Product2 records if your sync process modifies them
//         List<Product2> products = new List<Product2>{
//             new Product2(Name='Test Product 1', IsActive=true),
//             new Product2(Name='Test Product 2', IsActive=true)
//         };
//         insert products;

//         // Schedule the job
//         String cronExp = '0 0 12 * * ?'; // Adjust cron expression as needed
//         ScheduledProductSync scheduledJob = new ScheduledProductSync();
//         String jobId = System.schedule('Test Scheduled Product Sync', cronExp, scheduledJob);

//         // Execute the job
//         Test.startTest();
//         System.abortJob(jobId); // Optional: Abort the job if you want to prevent it from executing
//         Test.stopTest();

//         // Verify the results
//         // For example, you might want to check if the products were updated
//         List<Product2> updatedProducts = [SELECT Id, IsActive FROM Product2 WHERE Id IN :products];
//         for (Product2 product : updatedProducts) {
//             System.assertEquals(true, product.IsActive, 'Product should be active after sync.');
//         }
//     }
// }