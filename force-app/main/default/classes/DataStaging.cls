/**
 * @description         This class is responsible for staging data inside of a Salesforce Org for the RentAll Application.
 * @group               Utilities, Staging
 * @author              me@cgary.com
 */
global class DataStaging {
    public static final string RANDOMDATA_API = 'https://randomapi.com';
    
    public static List<Account> createVendorAccounts(Integer numberOfAccounts, Boolean saveData){
        List<Account> acctList;
        String urlPath = '/api/df8dc24f1dac2b43ec6f08a221dd666f';
        String endpoint = DataStaging.RANDOMDATA_API + urlPath;
        //get the RecordId for a Vendor Account
        Schema.RecordTypeInfo rtInfo = Schema.Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('RentAllVendor');
        if(numberOfAccounts == null || numberOfAccounts < 2){
            numberOfAccounts = 2;
        }
        endpoint += '?results=' + numberOfAccounts;
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        try {
            HttpResponse res = DataStaging.makeCall(req);
            DataStaging.VendorAccountResponse resObj = (DataStaging.VendorAccountResponse)JSON.deserialize(res.getBody(), DataStaging.VendorAccountResponse.class);
            acctList = resObj.results;
            for(Account a:acctList){
                a.RecordTypeId = rtInfo.getRecordTypeId();
            }
            if(saveData){
                insert acctList;
            }
        } catch(System.Exception ex){
            throw ex;
        }
        return acctList;
    }
    public static List<Account> createCustomerAccountsAndContacts(Integer numberOfAccounts, Boolean saveData){
        
    }

    private static HttpResponse makeCall(HttpRequest req){
        Http svc = new Http();
        HttpResponse res;
        try {
            String errMess;
            res = svc.send(req);
            Integer responseCode = res.getStatusCode();
            switch on responseCode {
                when 400 {
                    errMess = 'Bad Request';
                }
                when 404 {
                    errMess = 'Location Not Found';
                }
                when 409,415 {
                    errMess = 'Bad parameters';
                }
                when 500 {
                    errMess = 'Internal Server Error';
                }
            }
            if(String.isNotBlank(errMess)){
                throw new DataStaging.StagingException(errMess);
            }
        } catch(System.Exception ex){
            throw ex;
        }
        return res;
    }

    public class StagingException extends System.Exception {}
    public class VendorAccountResponse {
        public List<Account> results{ get; set; }
    }
}