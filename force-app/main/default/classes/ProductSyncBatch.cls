public class ProductSyncBatch implements Database.Batchable<String>, Database.AllowsCallouts { 
    private String startingUrl;
    private String nextUrl;

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
        
        if (!String.isEmpty(nextUrl)) {
            req.setEndpoint('callout:Product_Sync_Named' + nextUrl); 
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');

            try {
                HttpResponse res = http.send(req); 
                this.nextUrl = res.getHeader('Next-Url'); 

                if (res.getStatusCode() != 200) {
                    throw new CalloutException('Sync API call failed. Status Code: ' + res.getStatusCode());
                }

                String resultJson = SyncProductController.handleSync(res.getBody());
                System.enqueueJob(new SyncProductCalloutJob(resultJson)); 

            } catch (Exception e) {
                System.debug('Error during callout: ' + e.getMessage());
                throw new CalloutException('Error during API call: ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!String.isEmpty(nextUrl)) {
            Database.executeBatch(new ProductSyncBatch(nextUrl), 1);
        }
    }
}
