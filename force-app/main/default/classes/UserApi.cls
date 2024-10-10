/****************************************************************************************   
* File Name   : UserApi.cls
* Description : Product 관련 API
* Test Class  : UserApi_Test.cls
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
@RestResource(urlMapping='/product2/*')
global with sharing class UserApi {
    
    /** 
    * Description : /product2/sync doPost 메소드
    * Author : Evander 
    **/ 
    @HttpPost
    global static String doPost() {
        RestRequest req = RestContext.request;

        if (req.requestURI.endsWith('/sync')) {
            return handleSync(req.requestBody.toString());
        } else {
            return 'Invalid endpoint';
        }
    }
    
    /** 
    * Description : request body를 Product 리스트로 변환 후 Custom_External_Id__c 필드를 기준으로 upsert
    * Author : Evander 
    * @Param requestBody 
    * @return String 
    **/ 
    private static String handleSync(String requestBody) {
    //     try {
    //         List<Product2> receivedProducts = (List<Product2>) JSON.deserialize(requestBody, List<Product2>.class);
            
    //         for (Product2 receivedProduct : receivedProducts) {
    //             receivedProduct.Custom_External_Id__c = receivedProduct.Id;
    //             receivedProduct.Id = null;
    //         }

    //         if (Schema.sObjectType.Product2.isUpdateable()) {
    //             upsert receivedProducts Custom_External_Id__c;
    //         }

    //         return 'Sync completed successfully.';
    //     } catch (Exception e) {
    //         return 'Error: ' + e.getMessage();
    //     }
    return '';
    }
}