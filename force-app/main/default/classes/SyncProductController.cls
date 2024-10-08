/****************************************************************************************   
* File Name   : SyncProductController.cls
* Description : Controller for syncing products from Org A
* Test Class  : SyncProductController_Test.cls
* Author      : Evander  
****************************************************************************************/ 
public with sharing class SyncProductController {   

    @AuraEnabled
    public static void syncProducts() {
        try {
            HttpRequest req = new HttpRequest();
            // param으로 뺀다?
            req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody()); // 상태같은거 ?
            handleSync(res.getBody());

            if (res.getStatusCode() != 200) {
                throw new CalloutException('API call failed. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('Error in syncing products: ' + e.getMessage());
        }
    }
    
    /** 
    * Description : request body를 Product 리스트로 변환 후 Custom_External_Id__c 필드를 기준으로 upsert
    * Author : Evander 
    * @Param requestBody 
    * @return String 
    **/ 
    private static String handleSync(String responseBody) {
        try {
            SyncProductResponseDto responseDto = (SyncProductResponseDto) JSON.deserialize(responseBody, SyncProductResponseDto.class);
            List<Id> deletedProductIds = responseDto.deletedProductIds;
            List<Product2> changedProducts = responseDto.changedProducts;

            System.debug('Deleted Product IDs: ' + deletedProductIds);

            deleteProducts(deletedProductIds);
            upsertProducts(changedProducts);

            return 'Sync completed successfully.';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }

    private static void deleteProducts(List<Id> deletedProductIds) {
        if (deletedProductIds != null && !deletedProductIds.isEmpty() && Schema.sObjectType.Product2.isDeletable()) {
            List<Product2> productsToDelete = [
                SELECT Id 
                FROM Product2 
                WHERE Custom_External_Id__c IN :deletedProductIds
            ];
    
            if (!productsToDelete.isEmpty()) {
                delete productsToDelete;
            }
        }
    }

    private static void upsertProducts(List<Product2> receivedProducts) {
        for (Product2 product : receivedProducts) {
            product.Custom_External_Id__c = product.Id; 
            product.Id = null; 
        }
    
        if (Schema.sObjectType.Product2.isUpdateable() && Schema.sObjectType.Product2.isCreateable()) {
            upsert receivedProducts Custom_External_Id__c;
        }
    }
}
