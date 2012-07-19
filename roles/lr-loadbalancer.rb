name 'lr-loadbalancer'
run_list 'recipe[apache2]', 'recipe[lrcc::lrcluster]'
