/****************************************************************************************   
* File Name   : SyncProductCalloutJob.cls
* Description : Schedulable 구현체에 들어가는 future 메소드
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
public class SyncProductCalloutJob implements Queueable, Database.AllowsCallouts { // PostSyncResultQueueable
    private String resultJson;

    public SyncProductCalloutJob(String resultJson) {
        this.resultJson = resultJson;
    }

    public void execute(QueueableContext context) {
        SyncProductController.postSyncResult(this.resultJson);
    }

    @future(callout=true)
    public static void executeFuture() {
        SyncProductController.syncProduct();
    }
}