/****************************************************************************************   
* File Name   : SyncProductController.cls
* Description : Controller for syncing products from Org A
* Test Class  : SyncProductController_Test.cls
* Author      : Evander  
****************************************************************************************/ 
public with sharing class SyncProductController { 

    @AuraEnabled
    public static void syncProduct() {
        ProductSyncBatch batch = new ProductSyncBatch('/services/apexrest/product2/synchronization');
        Database.executeBatch(batch);
    }

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
        if (!Schema.sObjectType.Product2.isDeletable()) {
            throw new DmlException('User does not have permission');
        }
        if (deletedProductIds == null || deletedProductIds.isEmpty()) {
            return new List<Id>();
        }

        List<Product2> productsToDelete = [
            SELECT Id 
            FROM Product2 
            WHERE CustomExternalId__c IN :deletedProductIds
        ];
        if (productsToDelete.isEmpty()) {
            return new List<Id>();
        }
        Database.DeleteResult[] deleteResults = Database.delete(productsToDelete, false);
        return createDeletedIds(deleteResults, productsToDelete);
    }

    private static List<Id> createDeletedIds(Database.DeleteResult[] deleteResults, List<Product2> productsToDelete) {
        List<Id> successfullyDeletedIds = new List<Id>();
        List<Id> failedToDeleteIds = new List<Id>();
        for (Integer i = 0; i < deleteResults.size(); i++) {
            if (deleteResults[i].isSuccess()) {
                successfullyDeletedIds.add(productsToDelete[i].CustomExternalId__c);
            } else {
                failedToDeleteIds.add(productsToDelete[i].CustomExternalId__c); // log
            }
        }
        return successfullyDeletedIds;
    }
    

    private static List<Id> upsertProducts(List<Product2> updatedProducts) {
        if (!Schema.sObjectType.Product2.isUpdateable() || !Schema.sObjectType.Product2.isCreateable()) {
            throw new DmlException('User does not have permission');
        }

        for (Product2 product : updatedProducts) {
            product.CustomExternalId__c = product.Id; 
            product.Id = null; 
        }

        if (updatedProducts == null || updatedProducts.isEmpty()) {
            return new List<Id>();
        }
        Database.UpsertResult[] upsertResults = Database.upsert(updatedProducts, Product2.CustomExternalId__c);
        return createUpdatedIds(upsertResults, updatedProducts);
    }

    private static List<Id> createUpdatedIds(Database.UpsertResult[] upsertResults, List<Product2> updatedProducts) {
        List<Id> successfulUpdatedIds = new List<Id>();
        List<Id> failedToUpdatedIds = new List<Id>();
        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (upsertResults[i].isSuccess()) {
                successfulUpdatedIds.add(updatedProducts[i].CustomExternalId__c);
            } else {
                failedToUpdatedIds.add(updatedProducts[i].CustomExternalId__c); // log
            }
        }
        return successfulUpdatedIds;
    }

    public static void postSyncResult(String resultJson) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/synchronization/results');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(resultJson);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            throw new CalloutException('post result API call failed. Status Code: ' + res.getStatusCode());
        }
    }
}