/**
 * @description             This class provides Data Generation for the Creation of Vendor Accounts
 * @group                   Setup, Testing, Data Generation
 */
public with sharing class Queueable_GenerateVendors implements System.Queueable, System.Finalizer, Database.AllowsCallouts {
    /**
     * Intenral Constants
     *
     */
    public static final String RANDOMDATAAPI = 'https://random-data-api.com';
    /**
     * Internal Classes
     */
    public class AddressData {
        public String street_address { get; set; }
        public String city { get; set; }
        public String state_abbr { get; set; }
        public String zip_code { get; set; }
        public String community { get; set; }
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
    /**
     * This is a finalizer designed to either restart the job if it failed, or move on to the next job if it did not
     * @param       fc      FinalizerContext - information about the Queueable job that called it.
     */
    public void execute(System.FinalizerContext fc){
        System.ParentJobResult res = fc.getResult();
        //handle the exception
        if(res == System.ParentJobResult.UNHANDLED_EXCEPTION){

        }
    }

    public void createVendorRecords(){
        
    }

}