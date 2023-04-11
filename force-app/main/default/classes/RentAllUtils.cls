/**
 * @description:            This class provides general utility methods for use 
 *                          with the Rentall Application
 * @group:                  Utilities
 */
public class RentAllUtils {
    public class RentAllApiException extends System.Exception {}
    public static String generateUrlSearchPartFromMap(Map<String,String> searchParams){
        String ret = '';
        List<String> searchParts = new List<String>();
        for(String searchKey:searchParams.keySet()){
            searchParts.add(searchKey + '=' + searchParams.get(searchKey));
        }
        String search = String.join(searchParts,'&');
        search = '?' + search;
        ret = search;
        return ret;
    }
}