/**
 * Script that will perform some basic data setup  
 */
List<Account> res = DataStaging.createVendorAccounts(5,true);
System.debug(LoggingLevel.INFO,'\n\n*****\nAccount List:\n' + JSON.serializePretty(res) + '\n*****\n\n');