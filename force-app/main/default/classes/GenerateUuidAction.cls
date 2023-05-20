/**
 * @description:                the purpose of this class is to provide a generation of a universally unique
 *                              identifier. This functionality should be available from a Flow.
 * @group                       Actions
 */
public class GenerateUuidAction {
    @InvocableMethod( label='Generate UUID' description='Generates a Universally Unique Identifier' category='Utilities' )
    public static List<String> generateValue(List<SObject> recList) {
        List<String> retList = new List<String>();
        for(SObject rec:recList){
            Uuid uuidObj = new Uuid();
            retList.add(uuidObj.getValue());
        }
        return retList;
    }
}