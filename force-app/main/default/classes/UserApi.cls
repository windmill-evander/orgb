@RestResource(urlMapping='/product2/*')
global with sharing class UserApi {
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;

        if (req.requestURI.endsWith('/sync')) {
            String requestBody = req.requestBody.toString();
            System.debug('Request Body: ' + requestBody);
            return handleSync(requestBody);
        } else {
            return 'Invalid endpoint';
        }
    }

    private static String handleSync(String requestBody) {
        try {
            List<Product2> receivedProducts = (List<Product2>) JSON.deserialize(requestBody, List<Product2>.class);

            Set<String> names = new Set<String>();
            Map<String, Decimal> stockUpdates = new Map<String, Decimal>();
            for (Product2 product : receivedProducts) {
                if (product.Name != null) {
                    names.add(product.Name);
                    stockUpdates.put(product.Name, product.Stock__c);
                }
            }

            List<Product2> products = [
                SELECT Id, Stock__c, Name
                FROM Product2
                WHERE Name IN :names
                WITH SECURITY_ENFORCED
            ];

            for (Product2 product : products) {
                if (stockUpdates.containsKey(product.Name)) {
                    product.Stock__c = stockUpdates.get(product.Name);
                }
            }

            if (Schema.sObjectType.Product2.isUpdateable()) {
                update products;
            }
            return 'Products received successfully in Org B';
        } catch (Exception e) {
            System.debug('Deserialization error: ' + e.getMessage());
            return 'Error during deserialization: ' + e.getMessage();
        }
    }
}