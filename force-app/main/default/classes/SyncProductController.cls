/****************************************************************************************   
* File Name   : SyncProductController.cls
* Description : Controller for syncing products from Org A
* Test Class  : SyncProductController_Test.cls
* Author      : Evander  
****************************************************************************************/ 
// public with sharing class SyncProductController { 
public with sharing class SyncProductController { 

    // @AuraEnabled // 퍼밋없이 안되면 queueable 만들 필요없음
    // public static void syncProductCover() { // for user
    //     System.debug('hello cover');
    //     System.enqueueJob(new SyncProductCalloutJob());
    // }

    // @AuraEnabled
    // public static void syncProduct() {
    //     System.debug('hello sync product');

    //     try {
    //         HttpRequest req = new HttpRequest();
    //         req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization');
    //         req.setMethod('GET');
    //         req.setHeader('Content-Type', 'application/json');
    //         Http http = new Http();
    //         HttpResponse res = http.send(req);
    //         if (res.getStatusCode() != 200) {
    //             throw new CalloutException('get sync API call failed. Status Code: ' + res.getStatusCode());
    //         }

    //         String resultJson = handleSync(res.getBody());
    //         postSyncResult(resultJson); // queueable?
    //     } catch (Exception e) {
    //         System.debug('Exception occurred: ' + e.getMessage());
    //         throw new AuraHandledException('Error in syncing products: ' + e.getMessage());
    //     }
    // }


    @AuraEnabled
    public static void syncProduct() {
        System.debug('Starting sync product...');
    
        // Initialize the batch with the starting URL
        ProductSyncBatch batch = new ProductSyncBatch('/services/apexrest/product2/synchronization');
        
        // Execute the batch job
        Database.executeBatch(batch);
    
        System.debug('Batch job has been started.');
    }

    // block sometimes
    // @AuraEnabled
    // public static void syncProduct() {
    //     System.debug('Starting sync product...');

    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization');
    //     req.setMethod('GET');
    //     req.setHeader('Content-Type', 'application/json');
    //     Http http = new Http();

    //     Boolean hasMoreData = true;
    //     String nextUrl = '/services/apexrest/product2/synchronization';
        
    //     while (!String.isEmpty(nextUrl)) {
    //         req.setEndpoint('callout:Product_Sync_Named' + nextUrl);
    //         HttpResponse res = http.send(req);

    //         if (res.getStatusCode() != 200) {
    //             throw new CalloutException('Sync API call failed. Status Code: ' + res.getStatusCode());
    //         }


    //         // need batch
    //         String resultJson = handleSync(res.getBody());
    //         // postSyncResult(resultJson);
            
    //         nextUrl = res.getHeader('Next-Url');
    //         System.debug(resultJson);
    //         System.debug(nextUrl);
    //     } // cpu governer ?

    //     System.debug('Product sync complete');
    // }



    // block sometimes
    // @AuraEnabled
    // public static void syncProduct() {
    //     System.debug('Starting sync product...');
    
    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization');
    //     req.setMethod('GET');
    //     req.setHeader('Content-Type', 'application/json');
    //     Http http = new Http();
    
    //     String nextUrl = '/services/apexrest/product2/synchronization';
    //     List<Id> recordsToProcess = new List<Id>(); // To accumulate records
    //     Integer batchSize = 200; // Define your batch size
    
    //     while (!String.isEmpty(nextUrl)) {
    //         req.setEndpoint('callout:Product_Sync_Named' + nextUrl);
    //         HttpResponse res = http.send(req);
    
    //         if (res.getStatusCode() != 200) {
    //             throw new CalloutException('Sync API call failed. Status Code: ' + res.getStatusCode());
    //         }
    
    //         // Handle response and collect IDs for processing
    //         String responseBody = handleSync(res.getBody()); // Assume this returns a List<Id>
    //         recordsToProcess.addAll(responseBody);
    
    //         // If we reach the batch size, perform DML
    //         if (recordsToProcess.size() >= batchSize) {
    //             postSyncResult(recordsToProcess); // Perform DML on the current batch
    //             recordsToProcess.clear(); // Clear the list for the next batch
    //         }
    
    //         nextUrl = res.getHeader('Next-Url');
    //         System.debug('Next-Url: ' + nextUrl);
    //     }
    
    //     // Handle any remaining records
    //     if (!recordsToProcess.isEmpty()) {
    //         postSyncResult(recordsToProcess); // Process any leftover records
    //     }
    
    //     System.debug('Product sync complete');
    // }
    
    







    /** 
    * Description : request body를 Product 리스트로 변환 후 CustomExternalId__c 필드를 기준으로 upsert
    * Author : Evander 
    * @Param requestBody 
    * @return String 
    **/ 
    public static String handleSync(String responseBody) {
        try {
            SyncProductResponseDto responseDto = (SyncProductResponseDto) JSON.deserialize(responseBody, SyncProductResponseDto.class);
            List<Id> deletedProductIds = responseDto.deletedProductIds;
            List<Product2> updatedProducts = responseDto.updatedProducts;

            System.debug('Deleted Product IDs: ' + deletedProductIds);
            System.debug('updated Product IDs: ' + updatedProducts);

            List<Id> successfullyDeletedIds = deleteProducts(deletedProductIds);
            List<Id> successfullyUpdatedIds = upsertProducts(updatedProducts);

            SyncProductResultRequestDto syncResultResponse = new SyncProductResultRequestDto();
            syncResultResponse.successfullyDeletedIds = successfullyDeletedIds;
            syncResultResponse.successfullyUpdatedIds = successfullyUpdatedIds;
            return JSON.serialize(syncResultResponse);
        } catch (Exception e) {
            return JSON.serialize(new SyncProductResultRequestDto());
        }
    }

    private static List<Id> deleteProducts(List<Id> deletedProductIds) {
        List<Id> successfullyDeletedIds = new List<Id>(); 
        List<Id> failedToDeleteIds = new List<Id>(); 

        // if (deletedProductIds != null && !deletedProductIds.isEmpty() && Schema.sObjectType.Product2.isDeletable()) {
        if (deletedProductIds != null && !deletedProductIds.isEmpty()) {
            List<Product2> productsToDelete = [
                SELECT Id 
                FROM Product2 
                WHERE CustomExternalId__c IN :deletedProductIds
            ];
    
            if (!productsToDelete.isEmpty()) {
                Database.DeleteResult[] deleteResults = Database.delete(productsToDelete, false);

                for (Integer i = 0; i < deleteResults.size(); i++) {
                    if (deleteResults[i].isSuccess()) {
                        successfullyDeletedIds.add(productsToDelete[i].CustomExternalId__c); // Log successfully deleted IDs
                    } else {
                        failedToDeleteIds.add(productsToDelete[i].CustomExternalId__c); // Log failed deletes // 메일?
                    }
                }
            }
        }
        return successfullyDeletedIds;
    }
    

    private static List<Id> upsertProducts(List<Product2> updatedProducts) {
        List<Id> successfulUpdatedIds = new List<Id>();
        List<Id> failedToUpdatedIds = new List<Id>();

        for (Product2 product : updatedProducts) {
            product.CustomExternalId__c = product.Id; 
            product.Id = null; 
        }
    
        // if (Schema.sObjectType.Product2.isUpdateable() && Schema.sObjectType.Product2.isCreateable()) {
        if (true) {
            System.debug('hello with accessible');
            Database.UpsertResult[] upsertResults = Database.upsert(updatedProducts, Product2.CustomExternalId__c);

            for (Integer i = 0; i < upsertResults.size(); i++) {
                if (upsertResults[i].isSuccess()) {
                    successfulUpdatedIds.add(updatedProducts[i].CustomExternalId__c);
                } else {
                    failedToUpdatedIds.add(updatedProducts[i].CustomExternalId__c); // Log failed deletes // 메일?
                }
            }
        }
        return successfulUpdatedIds;
    }

    // @future(callout=true)
    public static void postSyncResult(String resultJson) {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization/results');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            System.debug(resultJson);
            req.setBody(resultJson);
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('result s code: ' + res.getStatusCode());
            if (res.getStatusCode() != 200) {
                throw new CalloutException('post result API call failed. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }

}

// testable@@@@@@@@@@@@@@@@@@@@@@
// public with sharing class SyncProductController {
//     @AuraEnabled
//     public static void syncProduct() {
//         try {
//             HttpResponse res = sendSyncRequest();
//             handleSyncResponse(res);
//         } catch (Exception e) {
//             System.debug('Exception occurred: ' + e.getMessage());
//             throw new AuraHandledException('Error in syncing products: ' + e.getMessage());
//         }
//     }

//     private static HttpResponse sendSyncRequest() {
//         HttpRequest req = new HttpRequest();
//         req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization');
//         req.setMethod('GET');
//         req.setHeader('Content-Type', 'application/json');
//         Http http = new Http();
//         HttpResponse res = http.send(req);

//         System.debug('Response Status Code: ' + res.getStatusCode());
//         System.debug('Response Body: ' + res.getBody()); // Log response body
//         return res;
//     }

//     private static void handleSyncResponse(HttpResponse res) {
//         if (res.getStatusCode() != 200) {
//             throw new CalloutException('API call failed. Status Code: ' + res.getStatusCode());
//         }

//         handleSync(res.getBody());
//     }
// }


// vf TEST    and need unit test
// @isTest
// public class SyncProductControllerTest {
    
//     // Mocking HTTP callouts if the controller makes callouts
//     public class MockHttpCallout implements HttpCalloutMock {
//         public HTTPResponse respond(HTTPRequest req) {
//             // Mock response for your callout
//             HttpResponse res = new HttpResponse();
//             res.setStatusCode(200);
//             res.setBody('{"deletedProductIds":[],"updatedProducts":[{"Id":"01tWU000007ZyOfYAK","Stock__c":2,"Name":"Robotic Arm Assembly System","Description":"Robotic Arm Assembly System","IsActive":true},{"Id":"01tWU000007ZyOfYAL","Stock__c":5,"Name":"Wheeled Assembly","Description":"Wheeled Assembly","IsActive":false}]}');
//             return res;
//         }
//     }

//     @isTest
//     static void testSyncProductsVFPage() {
//         // Set the mock for HTTP callouts
//         Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        
//         // Create an instance of the controller
//         SyncProductController controller = new SyncProductController();
        
//         // Set up any test data required
//         // For example, you may want to insert test Product2 records here

//         // Call the syncProduct method
//         Test.startTest();
//         controller.syncProduct(); // Directly call the method used by the VF page
//         Test.stopTest();

//         // You can now verify the results, such as checking Product2 records
//         List<Product2> products = [SELECT Id, Stock__c, IsActive FROM Product2 WHERE Id IN ('01tWU000007ZyOfYAK', '01tWU000007ZyOfYAL')];
        
//         // Validate the expected outcome
//         System.assertEquals(2, products.size(), 'Two products should have been processed.');
//         System.assertEquals(2, products[0].Stock__c, 'Stock for the first product should be 2.');
//         System.assertEquals(true, products[0].IsActive, 'First product should be active.');
//         System.assertEquals(5, products[1].Stock__c, 'Stock for the second product should be 5.');
//         System.assertEquals(false, products[1].IsActive, 'Second product should not be active.');

//         // Optionally, you can also check for specific VF page behavior, 
//         // like page references, messages, or attributes if needed
//     }
// }