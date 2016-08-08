if defined?(ChefSpec)
  def install_nexus3(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3, :install, resource_name)
  end

  def uninstall_nexus3(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3, :uninstall, resource_name)
  end

  def run_nexus3_api(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3_api, :run, resource_name)
  end

  def create_nexus3_api(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3_api, :create, resource_name)
  end

  def delete_nexus3_api(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3_api, :delete, resource_name)
  end

  def list_nexus3_api(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3_api, :list, resource_name)
  end
end
