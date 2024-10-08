public with sharing class SyncProductResponseDto {
    public List<Id> deletedProductIds { get; set; }
    public List<Product2> changedProducts { get; set; }
}
