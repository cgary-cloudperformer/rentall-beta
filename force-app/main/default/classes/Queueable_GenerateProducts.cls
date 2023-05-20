/**
 * @description         This class implements the Queueable interface and is designed
 *                      to set up some products for testing the RentAll Application. 
 *                      Because this Apex Class performs an HttpCallout that could be
 *                      executed after DML Statements, it needs to be called within its
 *                      own context.
 * @group               Setup, Testing, Data Generation              
 */
public with sharing class Queueable_GenerateProducts implements System.Queueable, Database.AllowsCallouts {
    /**
     * Internal Constants
     */
    public static final String RANDOMPRODUCTURI = 'https://randomapi.com/api/ec37862fca6d89cb9387fac88a97292f';
    /**
     * Constructor
     */
    public Queueable_GenerateProducts() {}
    /**
     * This method is the implementation of the System.Queueable Interface. For this 
     * class the purpose is to call out the an API for the generation of Data that can
     * be used in order to create Products.
     * @param       qc          System.QueueableContext - the queueable context.
     */
    public void execute(System.QueueableContext qc){
        Map<String,String> paramString = new Map<String,String>();
        paramString.put('fmt','json');
        paramString.put('results','100');
        String endpoint = RANDOMPRODUCTURI + RentAllUtils.generateUrlSearchPartFromMap(paramString);
        HttpRequest req = new HttpRequest();

        req.setMethod('GET');
        req.setEndpoint(endpoint);
        
    }
}