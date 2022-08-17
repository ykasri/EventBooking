public class SendEmailQueueable implements Queueable {
  Contact contact;

  public SendEmailQueueable(Contact contact) {
    this.contact = contact;
  }
  public void execute(QueueableContext context) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = new List<String>{ contact.Email };
    mail.setToAddresses(toAddresses);
    // TO DO : use email template and constants
    mail.setSubject('Can you dig it?');
    mail.setPlainTextBody('Hello ' + contact.Name);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
}
