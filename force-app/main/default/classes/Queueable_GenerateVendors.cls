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
        //set up the finalizer to catch any issues and handle further instructions.
        System.attachFinalizer(new Queueable_GenerateVendors());
        //generate HttpRequest for random data
        Map<String,String> urlParameterMap = new Map<String,String>{'response_type'=>'json','size'=>'2'};
        String endpoint = Queueable_GenerateVendors.RANDOMDATAAPI + '/api/v2/addresses' + RentAllUtils.generateUrlSearchPartFromMap(urlParameterMap);
        System.debug(LoggingLevel.INFO,'\n\n*****\nEndpoint to Access: ' + endpoint + '\n*****\n\n');
        Http svc = new Http();
        HttpRequest req = new HttpRequest();
        List<AddressData> responseAddressList = new List<AddressData>();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        HttpResponse res;
        try {
            res = svc.send(req);
            responseAddressList = (List<AddressData>)JSON.deserialize(res.getBody(), List<AddressData>.class);
            System.debug(LoggingLevel.INFO,'\n\n*****\nNumber of Addresses: ' + responseAddressList.size() + '\n*****\n\n');
        } catch(System.Exception ex) {
            throw ex;
        }
        //now lets try to create vendor Accounts using the random data.
        List<Account> newVendorAcctList = new List<Account>();
        Schema.RecordTypeInfo vendorRT = Schema.Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('RentAllVendor');
        for(AddressData ad:responseAddressList){
            Account vendorAcct = new Account(Name=ad.community,BillingStreet=ad.street_address,BillingCity=ad.city,BillingState=ad.state_abbr,BillingPostalCode=ad.zip_code);
            newVendorAcctList.add(vendorAcct);
        }
        if(!newVendorAcctList.isEmpty()){
            insert newVendorAcctList;
        }
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

}