public class ExternalSystemService {
  public static void registerAttendees(ID accountID) {
    for (Account account : [SELECT Id FROM Account WHERE id = :accountID]) {
      for (Contact contact : [
        SELECT Id, Name, Email, AccountId
        FROM Contact
        WHERE AccountId = :accountID
      ]) {
        postRequestThenNotifyByEmail(contact);
      }
    }
  }

  private static void postRequestThenNotifyByEmail(Contact contact) {
    PostRequestQueueable postRequestJob = new PostRequestQueueable(contact);
    ID jobID = System.enqueueJob(postRequestJob);
  }
}
