public class ProductSyncBatch implements Database.Batchable<String>, Database.AllowsCallouts {
    private String startingUrl;

    public ProductSyncBatch(String startingUrl) {
        this.startingUrl = startingUrl;
    }

    public Iterable<String> start(Database.BatchableContext bc) {
        return new List<String>{startingUrl};
    }

    public void execute(Database.BatchableContext bc, List<String> scope) {
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        String nextUrl = this.startingUrl;

        Integer calloutLimit = 90;
        
        while (!String.isEmpty(nextUrl) && calloutLimit > 0) {
            req.setEndpoint('callout:Product_Sync_Named' + nextUrl);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');

            HttpResponse res = http.send(req);

            if (res.getStatusCode() != 200) {
                throw new CalloutException('Sync API call failed. Status Code: ' + res.getStatusCode());
            }

            String resultJson = SyncProductController.handleSync(res.getBody());
            System.enqueueJob(new SyncProductCalloutJob(resultJson));

            nextUrl = res.getHeader('Next-Url');
            System.debug('Next URL: ' + nextUrl);
            calloutLimit = calloutLimit - 1;
        }
        
        // The maximum number of asynchronous Apex method executions
        //  (batch Apex, future methods, Queueable Apex, and scheduled Apex) per a 24-hour period1,6,7	250,000 
        //  or the number of user licenses in your org multiplied by 200, whichever is greater
        if (!String.isEmpty(nextUrl)) {
            Database.executeBatch(new ProductSyncBatch(nextUrl), 1);
        }
    }

    public void finish(Database.BatchableContext bc) {
        // Optionally perform any final operations after the batch completes
    }
}
