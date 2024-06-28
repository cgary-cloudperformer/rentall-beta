/**
 * @description:        Provides Apex Logic for the Rental Object and the Rental Process.
 * @group:              Services
 */
public with sharing class RentAllRentalInfoService {
    @AuraEnabled(cacheable=true)
    public static List<ItemReservation__c> getItemReservationsByRentalId(String recordId){
        List<ItemReservation__c> retList = new List<ItemReservation__c>();
        try {
            if(String.isBlank(recordId)){
                throw new IllegalArgumentException('recordId is a required parameter');
            }
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE,[
                SELECT Id, EndDate__c, InventoryItem__c, Name, Quantity__c, Rental__c, StartDate__c,
                    ProductName__c, LocationName__c, PerDayUnitRental__c, TotalRental__c
                FROM ItemReservation__c WHERE Rental__c = :recordId
            ]);
            if(!decision.getRecords().isEmpty()){
                retList = (List<ItemReservation__c>)decision.getRecords();
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return retList;
    }
    @AuraEnabled(cacheable=true)
    public static Integer getItemReservationCountByRentalId(String recordId){
        Integer retVal;
        try {
            if(String.isBlank(recordId)){
                throw new IllegalArgumentException('recordId is a required parameter');
            }
            retVal = Database.countQuery('SELECT COUNT() FROM ItemReservation__c WHERE Rental__c = :recordId');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return retVal;
    }
    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> findInventoryByName(String searchTerm, List<String> selectedIds){
        List<LookupSearchResult> retList = new List<LookupSearchResult>();
        
        try {
            if(String.isBlank(searchTerm)){
                throw new IllegalArgumentException('searchTerm is a required parameter');
            }
            searchTerm = searchTerm + '*';
            String objectTypeName = Schema.InventoryItem__c.getSObjectType().getDescribe().getName();
            List<List<sObject>> soslResults = [FIND :searchTerm IN ALL FIELDS
                RETURNING InventoryItem__c(Id,Name,ProductName__c,Location__c,LocationName__c WHERE RentalProduct__r.IsAvailable__c = true)];
            if(!soslResults.isEmpty()){
                List<InventoryItem__c> inventoryList = (List<InventoryItem__c>)soslResults[0];
                for(InventoryItem__c item:inventoryList){
                    retList.add(new LookupSearchResult(item.Id,objectTypeName,'custom:custom6',item.ProductName__c,item.LocationName__c));
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return retList;
    }
    @AuraEnabled
    public static void deleteItemReservationsById(List<String> reservationIds){
        try {
            if(reservationIds == null || reservationIds.isEmpty()){
                throw new IllegalArgumentException('Reservation Record IDs must be provided');
            }
            List<ItemReservation__c> reservationRecords = [SELECT Id FROM ItemReservation__c WHERE Id IN :reservationIds];
            delete reservationRecords;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateItemReservations(List<Map<String,String>> reservationUpdates){
        try {
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
