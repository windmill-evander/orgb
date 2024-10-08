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
public with sharing class ScheduledProductSync implements Schedulable {
    public void execute(SchedulableContext sc) {
        // future, static
        SyncProductCalloutJob.executeFuture();
        // SyncProductController.syncProducts();
    }
}