app_dir = "/var/webapps/walker_realty_group"
working_directory app_dir
pid app_dir + "/unicorn.pid"

stderr_path app_dir + "/log/unicorn.log"
stdout_path app_dir + "/log/unicorn.log"

# Set user
user "unicorn"

# Unicorn socket
listen "/tmp/unicorn.wrgtn.sock"

# Number of processes
worker_processes 4
timeout 60
