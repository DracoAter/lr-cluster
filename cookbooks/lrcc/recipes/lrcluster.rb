include_recipe 'java::java6'

file_cache_path = ::File.join( Chef::Config[:file_cache_path], 'liverebel.zip' )

remote_file file_cache_path do
	source node[:lrcc][:download]
end

bash "Unzip #{file_cache_path}" do
	code "unzip -q -uo #{file_cache_path} -d /opt"
end

directory node[:lrcc][:home]

bash "Restart LiveRebel CC" do
	code <<-BASH
		#{node[:lrcc][:home]}/bin/lr-command-center.sh stop
		sleep 1
		#{node[:lrcc][:home]}/bin/lr-command-center.sh start
	BASH
end
