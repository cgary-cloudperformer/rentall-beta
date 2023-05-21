/**
 * @description:                the purpose of this class is to provide a generation of a universally unique
 *                              identifier. This functionality should be available from a Flow.
 * @group                       Actions
 */
public class GenerateUuidAction {
    @InvocableMethod(label='UuidGenerator' description='Generates a Universally Unigue Identifier' category='Utilities')
    public static List<String> getUuidForRecord(List<Boolean> returnUuid){
        List<String> retValList = new List<String>();
        for(Boolean boolVal:returnUuid){
            if(boolVal){
                Uuid uidSvc = new Uuid();
                retValList.add(uidSvc.getValue());
            }
        }
        return retValList;
    }
}