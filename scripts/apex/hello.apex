String cronExp = '0 22 * * * ?'; // Run daily at midnight
System.schedule('Scheduled Product Sync Job', cronExp, new ScheduledProductSync());
