/****************************************************************************************   
* File Name   : SyncProductCalloutJob.cls
* Description : Product Sync 요청에 다시 callout하기 위한 Queueable 구현체
*               Schedulable 구현체에 들어가는 future 메소드도 공통 관리
* Test Class  : SyncProductCalloutJob_Test.cls
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
public class SyncProductCalloutJob {
    @future(callout=true)
    public static void executeFuture() {
        SyncProductController.syncProducts();
    }
}