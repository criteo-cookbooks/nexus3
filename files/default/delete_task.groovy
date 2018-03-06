import org.sonatype.nexus.scheduling.TaskConfiguration;
import org.sonatype.nexus.scheduling.TaskInfo;
import org.sonatype.nexus.scheduling.TaskScheduler;

TaskScheduler taskScheduler = container.lookup(TaskScheduler.class.getName());
TaskInfo existingTask = taskScheduler.listsTasks().find { TaskInfo taskInfo ->
    taskInfo.getName() == args;
}

if (existingTask && !existingTask.remove()) {
    throw new RuntimeException("Could not remove currently running task: " + args);
}
