module Nexus3
  # Load Groovy scripts via the Nexus3 API.
  class Scripts
    def self.groovy_script_location(script_name, node)
      cookbook = node.run_context.cookbook_collection['nexus3']
      cookbook.preferred_filename_on_disk_location(node, :files, "#{script_name}.groovy")
    end

    def self.groovy_content(script_name, node)
      ::File.read groovy_script_location(script_name, node)
    end
  end
end
