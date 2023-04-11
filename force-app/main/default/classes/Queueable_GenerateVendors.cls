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
        Queueable_GenerateVendors f = new Queueable_GenerateVendors();
        Map<String,Schema.RecordTypeInfo> accountRtMap = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
        Schema.RecordTypeInfo vendorRtInfo = accountRtMap.get('RentAllVendor'); 
        List<Account> vendorsToInsert = new List<Account>();
        List<String> vendorNameArray = new List<String>();
        List<String> vendorStreetArray = new List<String>();
        List<String> vendorCityArray = new List<String>();
        List<String> vendorStateArray = new List<String>();
        List<String> vendorPostalCodeArray = new List<String>();
        Integer vendorCount = 1;
        System.attachFinalizer(f);
        Map<String,String> urlParams = new Map<String,String>();
        urlParams.put('size','5');
        urlParams.put('response_type','json');
        String endpoint = Queueable_GenerateVendors.RANDOMDATAAPI + 'api/v2/addresses' + RentAllUtils.generateUrlSearchPartFromMap(urlParams);
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res;
        Http svc = new Http();
        try {
            res = svc.send(req);
            Integer responseCode = res.getStatusCode();
            if(responseCode > 299){
                throw new RentAllUtils.RentAllApiException('There was a problem accessing the API: issue - ' + res.getBody());
            }
            System.JSONParser parser = JSON.createParser(res.getBody());
            while(parser.nextToken() != null) {
                if(parser.getCurrentToken() == JSONToken.START_ARRAY){
                    Account vendor = new Account(Name=vendorName,RecordTypeId=vendorRtInfo.getRecordTypeId());
                    vendorNameArray.add(vendorName);
                    do {
                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                            parser.nextToken();
                            String fieldName = parser.getCurrentName();
                            switch on fieldName {
                                when 'street_address' {
                                    vendorStreetArray.add(parser.getText());
                                }
                                when 'city' {
                                    vendorCityArray.add(parser.getText());
                                }
                                when 'state_abbr' {
                                    vendorStateArray.add(parser.getText());
                                }
                                when 'zip_code' {
                                    vendorPostalCodeArray.add(parser.getText());
                                }
                                when else {
                                    System.debug(LoggingLevel.INFO,' Field name: ' + parser.getCurrentName() + ', Field Value: ' + parser.getText());
                                }
                            }
                        }
                    } while (parser.nextToken() != JSONToken.END_ARRAY);
                    String vendorName = 'Vendor ' + vendorCount;
                    vendorNameArray.add(vendorName);
                    vendorCount++;
                }
            }
            Integer count = 0;
            for(String vendorName:vendorNameArray){
                Account a = new Account(Name=vendorName,BillingStreet=vendorStreetArray.get(count),BillingCity=vendorCityArray.get(count),
                    BillingState=vendorStateArray.get(count),BillingPostalCode=vendorPostalCodeArray.get(count));
                vendorsToInsert.add(a);
            }
            if(!vendorsToInsert.isEmpty()){
                insert vendorsToInsert;
            }
        }catch(System.Exception e) {
            throw e;
        }
    }

    public void execute(System.FinalizerContext fc){
        if(fc.getResult() == ParentJobResult.UNHANDLED_EXCEPTION){
            Queueable_GenerateVendors jobUpdate = new Queueable_GenerateVendors();
            System.enqueueJob(jobUpdate);
        }
    }

}