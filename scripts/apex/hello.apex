List<Product2> products = [SELECT Id, Stock__c FROM Product2];
for(Product2 prod : products) {
    prod.Stock__c = 1;
}
update products;
