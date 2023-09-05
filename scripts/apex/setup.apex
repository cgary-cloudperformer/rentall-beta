/**
 * Script that will perform some basic data setup  
 */
/**************************************************************
 * Step 1 - Create Vendor Accounts
 **************************************************************/
//List<Account> res = DataStaging.createVendorAccounts(5,true);
//System.debug(LoggingLevel.INFO,'\n\n*****\nAccount List:\n' + JSON.serializePretty(res) + '\n*****\n\n');

/**************************************************************
 * Step 2 - Create Customer Accounts and Contacts
 **************************************************************/
List<Account> res = DataStaging.createCustomerAccountsAndContacts(5, true);
System.debug(LoggingLevel.INFO,'\n\n*****\nAccount List:\n' + JSON.serializePretty(res) + '\n*****\n\n');
