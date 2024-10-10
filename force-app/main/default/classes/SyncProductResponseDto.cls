public with sharing class SyncProductResponseDto { // ProductSyncResponseDto
    public List<Id> deletedProductIds { get; set; }
    public List<Product2> updatedProducts { get; set; }

    public SyncProductResponseDto() {
        deletedProductIds = new List<Id>();
        updatedProducts = new List<Product2>();
    }
}