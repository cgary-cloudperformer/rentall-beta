/**
 * @description:            This class is responsible for generating random text based on the 
 *                          https://baconipsum.com website.
 * @group:                  Utilities
 */
public class BaconIpsum {
    /**
     * Exception for callout to bacon ipsum
     */
    public class CalloutException extends System.Exception {
        public Integer statusCode { get; set; }
        public String responseMessage { get; set; }
    }
    private static final string RANDOMAPI = 'https://baconipsum.com/api/';
    private static final string DEFAULTYPE = 'meat-and-filler';
    /**
     * Generate a list of Random Words
     * @param   wordLength      Integer - the length of the return Array
     * @return  List<String>
     */
    public static List<String> getRandomArrayOfSentences(Integer arrayLength){
        List<String> resArray = new List<String>();
        wordLength = (wordLength == null) ? 200 : arrayLength;
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('type',DEFAULTYPE);
        paramMap.put('sentences',wordLength);
        paramMap.put('format','text');
        paramMap.put('start-with-lorem','1');
        String endpoint = RANDOMAPI + generateParamString(paramMap);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        HttpResposne res = callApi(req);
        resArray = resBody.split('.',res.getBody());
        return resArray;
    }
    
    /**
     * Single place to handle HttpCallout for the class.
     * @param   req     HttpRequest - the Request to send
     * @preturn HttpResponse
     */
    private static HttpResponse callApi(HttpRequest req) {
        HttpResponse res;
        try {
            Http svc = new Http();
            res = svc.send(req);
            if(res.getStatusCode() == null || res.getStatusCode() > 299){
                BaconIpsum.CalloutException ce = new BaconIpsum.CalloutException('There was a problem with the Callout Response.');
                ce.statusCode = res.getStatusCode();
                ce.responseMessage = res.getBody();
            }
        } catch(System.Exception ex){
            throw ex;
        }
        return res;
    }

    private static string generateParamString(Map<String,String> paramMap){
        String ret;
        List<String> paramPartArray = new List<String>();
        for(String key:paramMap.keySet()){
            paramPartArray.add(key + '=' + System.EncodingUtil.urlEncode(paramMap.get(key), 'UTF-8'));
        }
        ret = '?' + String.joing(paramPartArray,'&');
        return ret;
    }

}