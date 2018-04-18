default['nexus3']['api']['username'] = 'admin'
default['nexus3']['api']['password'] = 'admin123'
default['nexus3']['api']['endpoint'] = 'http://localhost:8081/service/rest/v1/script/'

# Patch java_se attributes until vrivellino/chef-java_se#4 is merged & released
default['java_se']['update'] = '171'
default['java_se']['build'] = '11'
default['java_se']['hash'] = '512cd62ec5174c3487ac17c61aaa89e8'
default['java_se']['sha256']['tar']['i586'] = '37896425b90ea323d841cb57784cec21822c38754e94e415b7f102b205c80536'
default['java_se']['sha256']['tar']['x64'] = 'b6dd2837efaaec4109b36cfbb94a774db100029f98b0d78be68c27bec0275982'
default['java_se']['sha256']['dmg']['x64'] = '00ccc048009e64e7e341d55d35c8519ab63ef5f86f0d73d4e823281d0b358d40'
default['java_se']['sha256']['exe']['i586'] = 'fa5de8068571d40f01d6ce8040761b63b5e805aca584e8904cfd026c3fd09138'
default['java_se']['sha256']['exe']['x64'] = '841b20e904b7f46fe7c8ce88bd35148e9663c750c8336286d0eb05a0a5b203f4'
