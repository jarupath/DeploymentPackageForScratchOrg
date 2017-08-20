public with sharing class Monitoring {
    private class Email {
        String subject;
        String bodyMsg;
        String toEmail;

        public Email(String subject, String bodyMsg, String toEmail) {
            this.subject = subject;
            this.bodyMsg = bodyMsg;
            this.toEmail = toEmail;
        }
    }

    private static Monitoring instance = null;
    private static List<Email> emailList = new List<Email>();
    public String monitoringEmail = 'somwut.j@beryl8.com';
    public Monitoring() {
    }

    public static Boolean notifyError(Exception e, String toEmail) {
        String subject = 'Exception :' + e.getMessage();

        String bodyMsg = '';
        bodyMsg = e.getMessage();
        bodyMsg += '\n';
        bodyMsg += e.getStackTraceString();
        return notifyError(subject, bodyMsg, toEmail);
    }

    public static Boolean notifyError(String subject, String bodyMsg, String toEmail) {
        return notifyErrorByEmail(subject, bodyMsg, toEmail);
    }

    public static Boolean notifyErrorByEmail(String subject, String bodyMsg, String toEmail) {
        String toEmailAddress = '';

        try {
            if (!String.isBlank(toEmail)) {
                // Custom_Mail_List__mdt emergencyEmail = (Custom_Mail_List__mdt)BE8_MasterDataRepository.getInstance().getObjectByName('Custom_Mail_List__mdt', toEmail);
                toEmailAddress = MailList_Repository.getEmailAddress('Monitoring', toEmail);
                if (toEmailAddress == null) {
                    if (BE8_GlobalUtility.isEmailValid(toEmail)) {
                        toEmailAddress = toEmail;
                    } else {
                        toEmailAddress = getInstance().monitoringEmail;
                    }
                }
            } else {
                toEmailAddress = getInstance().monitoringEmail;
            }

            emailList.add(new Email(subject, bodyMsg, toEmailAddress));
            BE8_GlobalUtility.sendEmail(subject, toEmailAddress, bodyMsg);
            return true;
        } catch(Exception e) {
            AppLogger.error('Monitoring', 'notifyErrorByEmail', subject, bodyMsg, e);
        }
        return false;
    }

    public static void sendEmail() {
        System.debug('####emailList: ' + emailList);
        for (Email eachEmail : emailList) {
            BE8_GlobalUtility.sendEmail(eachEmail.subject, eachEmail.toEmail, eachEmail.bodyMsg);
        }
    }


    public static Monitoring getInstance() {
        if (instance == null) instance = new Monitoring();
        return instance;
    }
}