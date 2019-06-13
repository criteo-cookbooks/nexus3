module Nexus3
  # Load Groovy scripts via the Nexus3 API.
  class Scripts
    def self.groovy_script_location(script_name, node, cookbook_name)
      cookbook = node.run_context.cookbook_collection[cookbook_name]
      cookbook.preferred_filename_on_disk_location(node, :files, "#{script_name}.groovy")
    end

    def self.groovy_content(script_name, node, cookbook_name = 'nexus3')
      ::File.read groovy_script_location(script_name, node, cookbook_name)
    end
  end
end
