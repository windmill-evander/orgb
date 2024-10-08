String cronExpression = '0 54 * * * ?'; // Every minute at 0 seconds
String jobName = 'ProductSyncJob';

ScheduledProductSync job = new ScheduledProductSync();
System.schedule(jobName, cronExpression, job);
