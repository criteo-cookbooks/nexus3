# nexus3_resources_test

This is a test cookbook for use by chefspec and test-kitchen.
It aims to validate that nexus3 resources are properly coded and idempotent.

When adding a new resource to this project, please:
* duplicate the attributes file TEMPLATE_FOR_NEW_RESOURCE.rb and rename it with the name of your resource
* uncomment attributes lines and replace the placeholders with valid values
