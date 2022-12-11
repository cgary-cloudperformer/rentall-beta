global class RentAllCustomerFormAccountFieldset extends VisualEditor.DynamicPickList {
    /**
     * Return the default fieldset available
     */
    global override VisualEditor.DataRow getDefaultValue(){
        Map<String, Schema.Fieldset> accountFieldsetMap = Schema.Account.getSObjectType().getDescribe().fieldsets.getMap();
        List<Schema.Fieldset> fieldsetValues = accountFieldsetMap.values();
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(fieldsetValues[0].getLabel(),fieldsetValues[0].getName());
        return defaultValue;
    }
    /**
     * Present the fieldsets available to use as fields for the customer Form from the 
     * Account object
     * @returns VisualEditor.DynamicPickListRows
     */
    global override VisualEditor.DynamicPickListRows getValues(){
        Map<String, Schema.Fieldset> accountFieldsetMap = Schema.Account.getSObjectType().getDescribe().fieldsets.getMap();
        VisualEditor.DynamicPickListRows picklistRows = new VisualEditor.DynamicPickListRows();
        for(Schema.Fieldset fieldSetInfo:accountFieldsetMap.values()){
            VisualEditor.DataRow dynamicRow = new VisualEditor.DataRow(fieldSetInfo.getLabel(),fieldSetInfo.getName());
            picklistRows.addRow(dynamicRow);
        }
        return picklistRows;
    }
}
