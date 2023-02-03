/**
 * @description         This class provides Apex logic in order to expose inventory logic
 * @group               Services
 */
public with sharing class RentallInventoryService {
    /**
     * This method will determine if the inventory item is available between
     * the dates passed in
     * @param   inventoryId     String - the id of the InventoryItem__c record
     * @param   startDate       Date - the start date of the rental window to check
     * @param   endDate         Date - the end date of the rental window to check
     * @return  boolean         true if inventory available during rental window, false if not.
     */
    @AuraEnabled
    public static boolean isRentalInventoryAvailable(String inventoryId, Date startDate, Date endDate){
        //get the Items reserved for the Date provided.
        /*
        AggregateResult[] totalReserved = [SELECT SUM(Quantity__c) TotalReserved FROM ItemReservation__c WHERE
            InventoryItem__c =:inventoryId AND StartDate__c <= :endDate AND EndDate >= :startDate];
        */
        return false;
    }
}
