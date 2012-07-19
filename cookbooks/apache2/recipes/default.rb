package "apache2"
package "libapache2-mod-proxy-html"

cookbook_file ::File.join( node[:apache2][:home], 'httpd.conf' ) do
	mode 0644
	notifies :restart, 'service[apache2]'
end

lr_nodes = search(:node, "role:lr-node")

template ::File.join( node[:apache2][:home], 'conf.d', 'httpd-proxy-balancer.conf' ) do
	mode 0644
	variables(:lr_nodes => lr_nodes)
	notifies :restart, 'service[apache2]'
end

service "apache2" do
	action [:enable, :start]
end
