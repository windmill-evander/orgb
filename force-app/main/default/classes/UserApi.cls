@RestResource(urlMapping='/product2/*')
global with sharing class UserApi {

    public class ProductWrapper {
        public String Name; // 그냥 Product2로 deserial x?
        public String ProductCode;
    }

    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        System.debug('Request Body: ' + requestBody);

        if (req.requestURI.endsWith('/sync')) {
            return handleSync(requestBody);
        } else {
            return 'Invalid endpoint';
        }
    }

    private static String handleSync(String requestBody) {
        try {
            List<ProductWrapper> products = (List<ProductWrapper>) JSON.deserialize(requestBody, List<ProductWrapper>.class);

            for (ProductWrapper product : products) {
                System.debug('Product Name: ' + product.Name);
                System.debug('Product Code: ' + product.ProductCode);
            }

            return 'Products received successfully in Org B';
        } catch (Exception e) {
            System.debug('Deserialization error: ' + e.getMessage());
            return 'Error during deserialization: ' + e.getMessage();
        }
    }

}