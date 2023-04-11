/**
 * Script that will perform some basic data setup  
 */
 /*
 String categoryList = 'ALUMA,ALUMINUM,COLUMN,CUSTOM BUILT LUMBER,DESLAURIERS,DOKA,ELLIS SHORE,FEES AND CHARGES,FIELD ENGINEERING,LUMBER,MAT. HANDLING,MISC.,OTHER,PAN,PERI,PLATE GIRDER,RMD,RMD SHOREFORM,SAFETY,SAFETY - FENCE,SAFETY - NET,SCAFFOLD,SCAFFOLD - PATENT,SCAFFOLD - WACO,SHOREFORM,SOCON,STEEL - SHORE,STEEL - SYSTEM,TOOLS,TOOLS - DEWALT,TOOLS - HILTI,TOOLS - MAKITA,TRUSS,WALL,AHHARRIS,ALSINA,HYBRID PARKING FORMS,EFCO,SAFEWAY,alshor/ASC,PARTS';
 List<String> categoryArray = categoryList.split(',');
 List<Category__c> categoryRecordsToCreate = new List<Category__c>();
 for(String category:categoryArray){
    categoryRecordsToCreate.add(new Category__c(Name=category));
 }
 if(!categoryRecordsToCreate.isEmpty()){
    insert categoryRecordsToCreate;
 }
 */
 Queueable_GenerateVendors vendorGeneration = new Queueable_GenerateVendors();
 String jobId = System.enqueueJob(vendorGeneration);
 System.debug(LoggingLevel.INFO,'\n\n*****\nJob ID: ' + jobId + '\n*****\n\n'); 