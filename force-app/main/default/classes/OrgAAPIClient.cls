/****************************************************************************************   
* File Name   : OrgAAPIClient.cls
* Description : Org A에 Product Sync를 요청하는 Callout client  
* Test Class  : OrgAAPIClient_Test.cls
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
public with sharing class OrgAAPIClient {   

    /** 
    * Description : Org A에 Product Sync 요청
    * Author : Evander 
    **/ 
    @AuraEnabled
    public static String syncProducts() {
        try {
            HttpRequest req = new HttpRequest();
            // param으로 뺀다?
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