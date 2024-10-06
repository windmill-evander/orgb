public with sharing class OrgAAPIClient {
    @AuraEnabled
    public static String syncProducts() {
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Product_Sync_Named/services/apexrest/product2/sync');
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            Http http = new Http();
            HttpResponse res = http.send(req);

            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody()); // 상태같은거 ?

            if (res.getStatusCode() == 200) {
                return res.getBody();
            } else {
                throw new CalloutException('API call failed. Status Code: ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('Error in getUserDetails: ' + e.getMessage());
        }
    }
}