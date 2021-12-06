public with sharing class OppTriggerHandler {
    public static void validateFieldAcc(
        List<Opportunity> newRecords,
        List<Opportunity> oldRecords,
        System.TriggerOperation triggerEvent
    ) {
        List<Account> accList = [
            SELECT Id, Name, Direct_sales_manager__c, Service_manager__c
            FROM Account
            WHERE Direct_sales_manager__c != NULL OR Service_manager__c != NULL
            WITH SECURITY_ENFORCED
        ];
        Set<Id> Ids = (new Map<Id, Account>(accList)).keySet();
        System.debug('AccList ' + accList);
        List<RecordType> rtList = [
            SELECT Id, Name, SobjectType
            FROM RecordType
            WHERE SobjectType = :'Opportunity'
            WITH SECURITY_ENFORCED
        ];

        switch on triggerEvent {
            when BEFORE_INSERT, BEFORE_UPDATE {
                for (Opportunity opp : newRecords) {
                    if (Ids.contains(opp.AccountId)) {
                        String recordTypeName;

                        for (RecordType recordType : rtList) {
                            if (recordType.id == opp.RecordTypeId) {
                                recordTypeName = recordType.Name;
                            }
                        }

                        if (opp.AccountId == null) {
                            opp.addError('The Account field is required');
                        } else {
                            for (Account acc : accList) {
                                if (acc.id == opp.AccountId)
                                    if (recordTypeName == 'Direct selling Record Type') {
                                        if (acc.id == opp.AccountId) {
                                            if (acc.Direct_sales_manager__c != null) {
                                                opp.Sales_manager__c = acc.Direct_sales_manager__c;
                                                System.debug('in if ' + acc.Direct_sales_manager__c);
                                            } else {
                                                opp.addError('Select the sales manager of this account');
                                            }
                                        }
                                    }

                                if (recordTypeName == 'Сonsultations Record Type') {
                                    if (acc.id == opp.AccountId) {
                                        if (acc.Service_manager__c != null) {
                                            opp.Service_manager__c = acc.Service_manager__c;
                                        } else {
                                            opp.addError('Select the service manager of this account');
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        opp.addError('Account does not have manager selection fields filled in');
                    }
                }
            }
        }
    }
}
