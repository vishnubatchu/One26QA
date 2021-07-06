/*
* Created by : Pooja U
* Date : 5th July 2021
* Description: This class has email util method  
*/
public class EmailUtil {
	//This method sends email with attachment if batch fails to process any records 
    public static void sendEmailWithAttachment(String csvContent,String csvname,String toEmailIdStr,String subject,
                                              String emailTextBody){
        Messaging.EmailFileAttachment csvAttcmnt = new Messaging.EmailFileAttachment ();
        blob csvBlob = Blob.valueOf (csvContent);
        csvAttcmnt.setFileName (csvname);
        csvAttcmnt.setBody (csvBlob);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toEmailIdList=new List<String>();
        if(toEmailIdStr!=null && toEmailIdStr.trim()!=''){
            if(toEmailIdStr.contains(',')){
                toEmailIdList=toEmailIdStr.split(',');
            }else{
                toEmailIdList.add(toEmailIdStr);
            }
        }
        mail.setToAddresses(toEmailIdList);
        mail.setSubject(subject);
        mail.setPlainTextBody(emailTextBody);
        mail.setFileAttachments (new Messaging.EmailFileAttachment []{csvAttcmnt});
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}