import org.sonatype.nexus.scheduling.schedule.Schedule;
import org.sonatype.nexus.scheduling.TaskConfiguration;
import org.sonatype.nexus.scheduling.TaskInfo;
import org.sonatype.nexus.scheduling.TaskScheduler;

import groovy.json.JsonOutput;

TaskScheduler taskScheduler = container.lookup(TaskScheduler.class.getName());

TaskInfo existingTask = taskScheduler.listsTasks().find { TaskInfo taskInfo ->
    taskInfo.getName() == args;
}

if (existingTask) {
    Schedule schedule = existingTask.getSchedule();
    Map<String, String> schedule_properties = new HashMap<>();
    schedule_properties.put('type', schedule.getType());
    if (schedule.getType() == 'cron') {
      schedule_properties.put('cronExpression', schedule.getCronExpression());
    }
    return JsonOutput.toJson([ schedule: schedule_properties ] + existingTask.getConfiguration().asMap());
}
