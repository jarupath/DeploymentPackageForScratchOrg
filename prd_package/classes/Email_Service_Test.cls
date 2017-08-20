@isTest
private class Email_Service_Test
{
	@isTest
	static void test() {
		Email_Service.sendEmailWithAttachment('subject', 'test@email.com', 'bodyMsg', 'attachmentBody', 'attachmentName');
	}
}