property :component_name, ::String, name_property: true # maven2.artifactId / raw.asset1.filename
property :type, ::String, equal_to: %w[maven2 raw rubygems], default: 'raw'.freeze
property :repo, ::String
property :asset, ::String # Path to asset to be uploaded
# maven2 specific params
property :maven2_asset_extension, [NilClass, ::String], default: nil
property :maven2_asset_classifier, [NilClass, ::String], default: nil
property :maven2_version, [NilClass, ::String], default: nil
property :maven2_group_id, [NilClass, ::String], default: nil
# raw specific params
property :raw_directory, [NilClass, ::String], default: nil

property :api_client, ::Nexus3::Api, identity: true, desired_state: false, default: lazy { ::Nexus3::Api.default(node) }

action :create do
  validate!

  unless new_resource.api_client.exists?(new_resource.repo, path)
    converge_by("Creating component #{new_resource.component_name}") do
      ::File.open(new_resource.asset) do |file|
        params = case new_resource.type
                 when 'maven2'
                   {
                     'maven2.artifactId' => new_resource.component_name,
                     'maven2.groupId' => new_resource.maven2_group_id,
                     'maven2.version' => new_resource.maven2_version,
                     'maven2.asset1' => file,
                     'maven2.asset1.extension' => new_resource.maven2_asset_extension
                   }.tap do |p|
                     p['maven2.asset1.classifier'] = new_resource.maven2_asset_classifier if new_resource.maven2_asset_classifier
                   end
                 when 'raw'
                   {
                     'raw.directory' => new_resource.raw_directory,
                     'raw.asset1' => file,
                     'raw.asset1.filename' => new_resource.component_name
                   }
                 else
                   { "#{new_resource.type}.asset" => file }
                 end
        new_resource.api_client.add_component(new_resource.repo, params)
      end
    end
  end
end

action_class do
  def validate!
    case new_resource.type
    when 'maven2'
      if new_resource.maven2_asset_extension.nil? || new_resource.maven2_version.nil? || new_resource.maven2_group_id.nil?
        raise 'Missing mandatory maven2 properties'
      end
    when 'raw'
      raise 'Missing mandatory raw directory property' if new_resource.raw_directory.nil?
    end
  end

  def path
    case new_resource.type
    when 'maven2'
      classifier = new_resource.maven2_asset_classifier ? "-#{new_resource.maven2_asset_classifier}" : ''
      asset_name = "#{new_resource.component_name}-#{new_resource.maven2_version}#{classifier}.#{new_resource.maven2_asset_extension}"
      ::File.join(new_resource.maven2_group_id.split('.') << new_resource.component_name << new_resource.maven2_version << asset_name)
    when 'raw'
      ::File.join(new_resource.raw_directory, new_resource.component_name)
    when 'rubygems'
      ::File.join('gems', new_resource.component_name + '.gem')
    end
  end

  def whyrun_supported?
    true
  end
end
