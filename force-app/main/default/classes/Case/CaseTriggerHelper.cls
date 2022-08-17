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
  private Map<ID, Integer> accountsContactsCount;
  private Integer getContactsCount(ID accountID) {
    if (
      accountsContactsCount != null &&
      accountsContactsCount.containsKey(accountID)
    ) {
      return accountsContactsCount.get(accountID);
    }

    Set<ID> accountsIDs = getAccountsIDs();
    accountsContactsCount = new Map<ID, Integer>();
    Account[] accounts = [
      SELECT ID, (SELECT ID FROM Contacts)
      FROM Account
      WHERE ID IN :accountsIDs
    ];
    for (Account account : accounts) {
      Integer contactsCount = account.Contacts.size();
      accountsContactsCount.put(account.ID, contactsCount);
    }
    return accountsContactsCount.get(accountID);
  }

  private Set<ID> getAccountsIDs() {
    Set<ID> accountsIDs = new Set<ID>();
    for (Case currentCase : cases) {
      accountsIDs.add(currentCase.AccountId);
    }
    return accountsIDs;
  }

  public void registerAttendees() {
    for (Case newCase : cases) {
      if (newCase.Status == 'Closed') {
        ExternalSystemService.registerAttendees(newCase.AccountId);
      }
    }
  }
}
