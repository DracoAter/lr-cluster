node.set[:node_name] = Chef::Config[:node_name]
include_recipe "java::java6"

#Install tomcat

file_cache_path = ::File.join( Chef::Config[:file_cache_path], 'apache-tomcat-6.0.18.zip' )

remote_file file_cache_path do
	source node[:tomcat][:download]
end

bash "Unzip #{file_cache_path}" do
	code "unzip -q -uo #{file_cache_path} -d /opt"
end

link node[:tomcat][:home] do
	to "/opt/apache-tomcat-6.0.18"
end

file ::File.join( node[:tomcat][:home], 'bin', 'setclasspath.sh' ) do
	mode 0755
end

file ::File.join( node[:tomcat][:home], 'bin', 'catalina.sh' ) do
	mode 0755
end

template ::File.join( node[:tomcat][:home], 'conf', 'server.xml' ) do
	mode 0644
	source "server.xml.erb"
	notifies :run, "bash[Stop tomcat6]", :immediately
end

#Install lr-agent

lrcc = search(:node, "roles:lr-loadbalancer").first
lr_agent_installer_path = ::File.join( node[:tomcat][:home], 'lr-agent-installer.jar' )
lr_agent_installer_url = "https://#{lrcc[:ipaddress]}:9001/public/lr-agent-installer.jar"
pid_file = ::File.join( node[:tomcat][:home], 'pid' )

template ::File.join( node[:tomcat][:home], 'lr-agent-service.sh' ) do
	mode 0755
	variables( :lrcc_ip => lrcc[:ipaddress] 	)
end

remote_file lr_agent_installer_path do
	action :create
	source lr_agent_installer_url
	backup false
	notifies :run, "bash[Stop tomcat6]", :immediately
	notifies :run, "bash[Install lr-client for tomcat6]", :immediately
end

bash "Stop tomcat6" do
	action :nothing
	cwd node[:tomcat][:home]
	code "./lr-agent-service.sh stop"
	ignore_failure true
end

bash "Install lr-client for tomcat6" do
	action :nothing
	cwd node[:tomcat][:home]
	code "java -jar lr-agent-installer.jar"
end

bash "Start tomcat6 with Liverebel agent" do
	action :run
	not_if { begin ::File.exists?( pid_file ) && Process.kill( 0, IO.read( pid_file ).to_i ) rescue false end }
	cwd node[:tomcat][:home]
	code "./lr-agent-service.sh start"
end
