public class SyncProductResultRequestDto {
    public List<Id> successfullyDeletedIds;
    public List<Id> successfullyUpdatedIds;

    public SyncProductResultRequestDto() {
        successfullyDeletedIds = new List<Id>();
        successfullyUpdatedIds = new List<Id>();
    }
}