global class EbayAuthProviderPlugin extends Auth.AuthProviderPluginClass {

    global EbayAuthProviderPlugin(){
        super();
    }

    private String customMetadataTypeApiName = 'EBayAppCredential__mdt';
    private final String AUTH_ENDPOINT = 'https://auth.ebay.com';
    private final String AUTH_ENDPOINT_SANDBOX = 'https://auth.sandbox.ebay.com';
    /**
     * Method that is inherited from AuthProviderPluginClass - returns the name of the Custom Metadata Type 
     * that holds the confiugration of EBay Client Application to authenticate.
     * @return String - the CustomMetadataType API Name 
     */
    global String getCustomMetadataType(){
        return customMetadataTypeApiName;
    }
    /**
     * Method that is inherited from AuthProviderPluginClass - returns the URL that the user is redirected to 
     * for authentication.
     * @param   authProviderConfiguration               Map<String,String> - Map of auth Provider config values.
     * @param   stateToPropagate                        String - The state passed in to initiate the authentication 
     *                                                  request for the user.
     * @return  PageReference                           The Page to forward user to for authentication
     */
    global PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate) {
        String authUrlString;
        //determine the authorization hostname and the path
        String isSandbox = authProviderConfiguration.get('IsSandbox__c');
        if(isSandbox == 'true'){
            authUrlString  = AUTH_ENDPOINT_SANDBOX;
        } else {
            authUrlString = AUTH_ENDPOINT;
        }
        authUrlString += '/oauth2/authorize';
        //determine the authorization parameters
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('client_id',authProviderConfiguration.get('ClientId__c'));
        paramMap.put('redirect_uri',authProviderConfiguration.get('EbayRedirectUrlName__c'));
        paramMap.put('response_type','code');
        paramMap.put('scope',authProviderConfiguration.get('ClientScopes__c'));
        paramMap.put('state',stateToPropagate);
        authUrlString += createParamStringFromMap(paramMap);
        return new PageReference(authUrlString);
    }
    global Auth.UserData getUserInfo(Map<String,String> authProviderConfiguration, Auth.AuthProviderTokenResponse resp) {
        String identifier;
        String firstName;
        String lastName;
        String fullName;
        String email;
        String link;
        String userName;
        String locale;
        String provider;
        String siteLoginUrl;
        String authUrlString;
        String isSandbox = authProviderConfiguration.get('IsSandbox__c');
        if(isSandbox == 'true'){
            authUrlString  = AUTH_ENDPOINT_SANDBOX;
        } else {
            authUrlString = AUTH_ENDPOINT;
        }
        authUrlString += '/commerce/identity/v1/user/';
        Map<String,String> attributeMap = new Map<String,String>();
        Auth.UserData userInfo = new Auth.UserData(identifier, firstName,lastName,fullName,email,link,userName,
            locale, provider, siteLoginUrl, attributeMap);
        return userInfo;
    }
    /**
     * This method is design to handle callbacks after the user is authorized to exchange the authorization code for an
     * access token.
     * @param       authProviderConfiguration           Map<String,String> the original config values for Auth. Provider
     * @param       callbackState                       Object containing authorization info in callback.
     * @return      Auth.AuthProviderTokenResponse
     */
    global Auth.AuthProviderTokenResponse handleCallback(Map<String,String> authProviderConfiguration,
            Auth.AuthProviderCallbackState callbackState) {
        String provider;
        String oauthToken;
        String oauthSecretOrRefreshToken;
        String state;
        String authUrlString;
        state = callbackState.queryParameters.get('state');
        //provider = authProviderConfiguration.get('DeveloperName');
        //determine the authorization hostname and the path
        String isSandbox = authProviderConfiguration.get('IsSandbox__c');
        if(isSandbox == 'true'){
            authUrlString  = AUTH_ENDPOINT_SANDBOX;
        } else {
            authUrlString = AUTH_ENDPOINT;
        }
        authUrlString += '/identity/v1/oauth/token';
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(authUrlString);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization',base64EncodeAuth(authProviderConfiguration.get('ClientId__c'), 
            authProviderConfiguration.get('ClientSecret__c')));
        Map<String,String> paramMap = new Map<String,String>();
        paramMap.put('grant_type','authorization_code');
        paramMap.put('code',callbackState.queryParameters.get('code'));
        paramMap.put('redirect_uri',authProviderConfiguration.get('EbayRedirectUrlName__c'));
        String paramString = createParamStringFromMap(paramMap);
        paramString = paramString.replace('?', '');
        req.setBody(paramString);
        Http svc = new Http();
        try {
            HttpResponse res = svc.send(req);
            if(res.getStatusCode() <= 399) {
                System.debug(LoggingLevel.INFO,'\n\n*****\nResponse: ' + res.getBody() + '\n*****\n\n');
                JSONParser p = JSON.createParser(res.getBody());
                while(p.nextToken() != null){
                    if(p.getCurrentToken() == JSONToken.FIELD_NAME){
                        String currentName = p.getCurrentName();
                        switch on currentName {
                            when 'access_token'{
                                p.nextValue();
                                oauthToken = p.getText();
                            }
                            when 'refresh_token' {
                                p.nextValue();
                                oauthSecretOrRefreshToken = p.getText();
                            }
                        }
                    }
                }
            }
        } catch(System.Exception ex) {
            throw ex;
        }
        Auth.AuthProviderTokenResponse resp = new Auth.AuthProviderTokenResponse(provider, oauthToken, 
            oauthSecretOrRefreshToken, state);
        return resp;
    }
    /**
     * Method that will create a URL encoded parameter string from a Map if String values.
     * @param   paramValues             Map<String,String> - map of values to convert to String
     * @return  String
     */
    private String createParamStringFromMap(Map<String,String> paramValues){
        String retVal = '?';
        List<String> valArray = new List<String>();
        for(String key:paramValues.keySet()){
            valArray.add(key + '=' + System.EncodingUtil.urlEncode(paramValues.get(key), 'UTF-8'));
        }
        retVal += String.join(valArray,'&');
        return retVal;
    }
    private String base64EncodeAuth(String clientId, String clientSecret) {
        if(String.isBlank(clientId) || String.isBlank(clientSecret)){
            throw new IllegalArgumentException('clientId or clientSecret cannot be empty');
        }
        String fullAuthHeader = EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret));
        return 'Basic ' + fullAuthHeader;
    }
}