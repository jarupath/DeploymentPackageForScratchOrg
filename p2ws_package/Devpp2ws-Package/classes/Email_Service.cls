public with sharing class Email_Service {
	public Email_Service() {
		
	}

	public static Boolean sendEmailWithAttachment(String subject, String toEmails, String bodyMsg, String attachmentBody, String attachmentName) {
		System.debug('attachmentBody :' + attachmentBody);
		Blob b = null;
		if(String.isNotBlank(attachmentBody)) {
			b = Blob.valueOf(attachmentBody);
		}
		return sendEmailWithAttachment(subject, toEmails, bodyMsg, b, attachmentName);
	}

	public static Boolean sendEmailWithAttachment(String subject, String toEmails, String bodyMsg, Blob attachment, String attachmentName) {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(toEmails.split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(bodyMsg);

        if(attachment != null) {
        	Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setBody(attachment);		
			efa.setFileName(attachmentName);
    		mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        }
		
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        return true;
	}

	public static Boolean sendEmail(String subject, String toEmails, String bodyMsg) {
		sendEmailWithAttachment(subject, toEmails, bodyMsg, '', '');
        return true;
	}
}