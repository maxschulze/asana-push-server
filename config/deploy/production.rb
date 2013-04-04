set :deploy_to, "/u/apps/asana-push-server"
set :daemon_env, 'production'

set :domain, 'server.maxschulze.com'
server 'server.maxschulze.com', :daemon
