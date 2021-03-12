import groovy.json.JsonOutput
import org.sonatype.nexus.repository.routing.RoutingRule
import org.sonatype.nexus.repository.routing.RoutingRuleStore

conf = repository.repositoryManager.get(args)?.getConfiguration()
if (conf != null) {
    String routingRuleName;
    if (conf.getRoutingRuleId() != null) {
      RoutingRuleStore routingRuleStore = container.lookup(RoutingRuleStore.class.getName());
      routingRule = routingRuleStore.getById(conf.getRoutingRuleId().getValue())
      if (routingRule != null) {
        routingRuleName = routingRule.name()
      }
    }

    JsonOutput.toJson([
            repositoryName: conf.getRepositoryName(),
            recipeName: conf.getRecipeName(),
            online: conf.isOnline(),
            attributes: conf.getAttributes(),
            routingRuleName: routingRuleName
        ])
}
