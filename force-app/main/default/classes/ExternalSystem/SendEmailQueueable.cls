public class SendEmailQueueable implements Queueable {
  private static String TEMPLATE_API_NAME = 'Notify_attendees';

  Contact contact;

  public SendEmailQueueable(Contact contact) {
    this.contact = contact;
  }
  public void execute(QueueableContext context) {
    sendEmailUsingTemplate();
  }

  public void sendEmailUsingTemplate() {
    EmailTemplate template = [
      SELECT Id, Subject, Body
      FROM EmailTemplate
      WHERE DeveloperName = :TEMPLATE_API_NAME
    ];
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setTemplateId(template.Id);
    mail.setTargetObjectId(contact.Id);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
  }
}
