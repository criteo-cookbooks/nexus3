import org.sonatype.nexus.scheduling.TaskConfiguration;
import org.sonatype.nexus.scheduling.TaskInfo;
import org.sonatype.nexus.scheduling.TaskScheduler;

import groovy.json.JsonOutput;

TaskScheduler taskScheduler = container.lookup(TaskScheduler.class.getName());

TaskInfo existingTask = taskScheduler.listsTasks().find { TaskInfo taskInfo ->
    taskInfo.getName() == args;
}

if (existingTask) {
    return JsonOutput.toJson(existingTask.getConfiguration().asMap());
}
