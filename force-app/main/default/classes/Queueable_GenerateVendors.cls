/**
 * @description             This class provides Data Generation for the Creation of Vendor Accounts
 * @group                   Setup, Testing, Data Generation
 */
public with sharing class Queueable_GenerateVendors implements System.Queueable, System.Finalizer, Database.AllowsCallouts {
    /**
     * Intenral Constants
     *
     */
    public static final String RANDOMDATAAPI = 'https://random-data-api.com/';
    /**
     * Internal Classes
     */
    public class AddressData {
        public String street_address { get; set; }
        public String city { get; set; }
        public String state { get; set; }
        public String postcode { get; set; }
        public String state_abbr { get; set; }
        public Integer id { get; set; }
    }
    
    /**
     * Constructors
     */
    public Queueable_GenerateVendors() {}
    /**
     * This method is the implementation of the System.Queueable Interface For this class the
     * purpose is to call the API for the generation of data that can be used to create Vendor Accounts
     */
    public void execute(System.QueueableContext qc){
        
    }

    public void execute(System.FinalizerContext fc){
        if(fc.getResult() == ParentJobResult.UNHANDLED_EXCEPTION){
            Queueable_GenerateVendors jobUpdate = new Queueable_GenerateVendors();
            System.enqueueJob(jobUpdate);
        }
    }

    public void createVendorRecords(){
        
    }

}