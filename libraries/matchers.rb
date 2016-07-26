if defined?(ChefSpec)
  def install_nexus3(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:nexus3, :install, resource_name)
  end
end
