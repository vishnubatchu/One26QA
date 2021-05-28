public class ScheduleQuoteReminder implements Schedulable {

    public void execute(SchedulableContext sc) {
		QuoteReminderBatch quoteBatchObj = New QuoteReminderBatch();
        Database.executeBatch(quoteBatchObj);
    }
}