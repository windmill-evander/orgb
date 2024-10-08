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
            req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/sync');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody());

            if (res.getStatusCode() != 200) {
                throw new CalloutException('API call failed. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('Error in syncing products: ' + e.getMessage());
        }
    }
}
