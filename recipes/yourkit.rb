yourkit_package_path = node['yourkit']['package_path']
yourkit_package_url = node['yourkit']['package_url']
yourkit_install_parent_path = node['yourkit']['install_parent_path']
yourkit_install_path = node['yourkit']['install_path']
yourkit_session_name = node['yourkit']['session_name']

remote_file yourkit_package_path do
  source yourkit_package_url
end

directory yourkit_install_parent_path do
  action :create
end

# Bzip2 is needed to uncompress yourkit
package "bzip2" do
  action :install
end

execute "uncompress-yourkit" do
  command "tar jxf #{yourkit_package_path} -C #{yourkit_install_parent_path}"
  not_if { File.exist?(yourkit_install_path) }
end

execute "copy-libyjpagent.so-to-/usr/local/lib64" do
  command "cp -f #{yourkit_install_path}/bin/linux-x86-64/libyjpagent.so /usr/local/lib64"
  not_if { File.exist?("/usr/local/lib64/libyjpagent.so") }
end

# Update JAVA_OPTS
yourkit_opts = "-agentpath:/usr/local/lib64/libyjpagent.so=dir=/var/cache/tomcat-alfresco,telemetrylimit=1,builtinprobes=none,onexit=snapshot,sessionname=#{yourkit_session_name}"

node.default['tomcat']['java_options'] = "#{node['tomcat']['java_options']} #{yourkit_opts}"

node.default['alfresco']['alfresco_tomcat_instance']['java_options'] = "#{node['alfresco']['alfresco_tomcat_instance']['java_options']} #{yourkit_opts}"

node.default['alfresco']['share_tomcat_instance']['java_options'] = "#{node['alfresco']['share_tomcat_instance']['java_options']} #{yourkit_opts}"

node.default['alfresco']['solr_tomcat_instance']['java_options'] = "#{node['alfresco']['solr_tomcat_instance']['java_options']} #{yourkit_opts}"
