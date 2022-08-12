public without sharing class CaseTriggerHelper {
  // Error messages
  public final static String ERROR_ACCOUNT_REQUIRED = 'You cannot create a request without attaching an account';
  public final static String ERROR_CONTACTS_REQUIRED = 'You cannot create a request for accounts without contacts';
  public final static String ERROR_WEB_MAX_ATTENDEES = 'Web request are only allowed to have one attendee';
  public final static String ERROR_PHONE_MAX_ATTENDEES = 'Phone request are only allowed to have three attendee';

  private List<Case> cases;
  public CaseTriggerHelper(List<Case> newCases) {
    this.cases = newCases;
  }

  private CaseTriggerHelper() {
    return; // Disable the default constructor
  }

  public void validateCases() {
    // Testing if the content of case is null or not to avoid NPE ;)
    if (cases == null || cases.isEmpty()) {
      return;
    }
    for (Case currentCase : cases) {
      validateCase(currentCase);
    }
  }

  @testVisible
  private void validateCase(Case newCase) {
    if (newCase == null) {
      return;
    }

    if (newCase.AccountId == null) {
      newCase.addError(ERROR_ACCOUNT_REQUIRED);
      return;
    }

    Integer contactsCount = getContactsCount(newCase.AccountID);
    if (contactsCount == 0) {
      newCase.addError(ERROR_CONTACTS_REQUIRED);
    } else if (newCase.Origin == 'Web' && contactsCount >= 2) {
      newCase.addError(ERROR_WEB_MAX_ATTENDEES);
    } else if (newCase.Origin == 'Phone' && contactsCount >= 4) {
      newCase.addError(ERROR_PHONE_MAX_ATTENDEES);
    }
  }

  // Singleton : Contacts Count
  private Map<ID, Integer> AccountContactsCount;
  private Integer getContactsCount(ID accountID) {
    if (
      AccountContactsCount != null &&
      AccountContactsCount.containsKey(accountID)
    ) {
      return AccountContactsCount.get(accountID);
    }

    Set<ID> casesIDs = getCasesIDs();
    AccountContactsCount = new Map<ID, Integer>();
    Account[] accounts = [SELECT ID, (SELECT ID FROM Contacts) FROM Account];
    for (Account account : accounts) {
      Integer contactsCount = account.Contacts.size();
      AccountContactsCount.put(account.ID, contactsCount);
    }
    return AccountContactsCount.containsKey(accountID)
      ? AccountContactsCount.get(accountID)
      : 0; // 0 If account has no contacts
  }

  private Set<ID> getCasesIDs() {
    Set<ID> casesIDs = new Set<ID>();
    for (Case currentCase : cases) {
      casesIDs.add(currentCase.Id);
    }
    return casesIDs;
  }

  public void registerAttendees() {
    for (Case newCase : cases) {
      if (newCase.Status == 'Closed') {
        ExternalSystemService service = new ExternalSystemService();
        service.registerAttendees(newCase);
      }
    }
  }
}
