package 'unzip' do
	action :nothing
end.run_action :install

file_cache_path = ::File.join( Chef::Config[:file_cache_path], 'jdk1.6.0_32.zip' )

remote_file file_cache_path do
	source node[:java][:download]
end

bash "Unzip #{file_cache_path}" do
	code "unzip -q -uo #{file_cache_path} -d /opt"
end

link node[:java][:home] do
	to "/opt/jdk1.6.0_32"
end

bash "Update Java Alternatives" do
	code <<-BASH
		update-alternatives --install /usr/bin/java java #{node[:java][:home]}/bin/java 100
	BASH
end
