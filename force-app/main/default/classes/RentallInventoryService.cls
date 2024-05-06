/**
 * @description         This class provides Apex logic in order to expose inventory logic
 * @group               Services
 */
public with sharing class RentallInventoryService {
    /**
     * This method will determine if the inventory item is available between
     * the dates passed in
     * @param   inventoryId     String - the id of the InventoryItem__c record
     * @return  boolean         if true, only include rentals that have not been completed/returned. false returns
     *                          all records regardless of rental status.
     */
    @AuraEnabled
    public static List<ItemReservation__c> obtainReservationLinesByInventoryId(String inventoryId, 
            Boolean excludeCompletedRentals) {
        List<ItemReservation__c> retList;
        Set<String> includedRentalStatusSet = new Set<String>{'Tenative','Confirmed','Delivered'};
        if(!excludeCompletedRentals){
            includedRentalStatusSet.add('Received');
            includedRentalStatusSet.add('Fulfilled/Completed');
        }
        try {
            if(String.isBlank(inventoryId)){
                throw new IllegalArgumentException('inventoryId is required for obtainReservationLinesByInventoryId.');
            }
            System.SObjectAccessDecision decision = Security.stripInaccessible(System.AccessType.READABLE, [
                SELECT Id, Name, InventoryItem__c, LocationName__c, StartDate__c, EndDate__c, Rental__c, TotalRental__c,
                    Quantity__c, Rental__r.Status__c
                FROM ItemReservation__c
                WHERE Rental__r.Status__c IN :includedRentalStatusSet
            ],true);
            if(!decision.getRecords().isEmpty()){
                retList = decision.getRecords();
            }
        } catch(System.Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return retList;
    }
}
