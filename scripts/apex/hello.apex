        // Query all Account records
        List<Account> allAccounts = [SELECT Id, Description FROM Account];

        // List to hold accounts with description 'tmp'
        List<Account> accountsToDelete = new List<Account>();

        // Loop through all accounts and filter based on description
        for (Account acc : allAccounts) {
            if (acc.Description != null && acc.Description == 'tmp') {
                accountsToDelete.add(acc);
            }
        }

        // Delete the accounts if any found
        if (!accountsToDelete.isEmpty()) {
            delete accountsToDelete;
        }