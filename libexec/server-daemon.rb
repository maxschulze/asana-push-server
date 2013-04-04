# Change this file to be a wrapper around your daemon code.

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

class ApiRequest
  
  def initialize(command, socket)
    @command  = command
    @http     = EventMachine::HttpRequest.new(@command['url'])
    @socket   = socket
  end
  
  def request_options
    options = {
      :keepalive => true,
      :head => {
        'authorization' => [@command['username'], @command['password']],
        'content-type' => @command['contentType'] || 'application/json',
      }
    }
    
    options[:query] = @command['data'] if @command['type'].downcase == 'get'
    options[:body] = @command['data'] if @command['type'].downcase == 'post'
    
    options
  end
  
  def fire
    request = @http.public_send(@command['type'].downcase, self.request_options)
    
    request.callback {
      pp request.response
      response = JSON.parse(request.response)
      response['status'] = 'success'
      response['request_id'] = @command['request_id']
      @socket.send(JSON.generate(response))
    }
    
    request.errback {
      response = JSON.parse(request.response)
      response['status'] = 'error'
      response['request_id'] = @command['request_id']
      @socket.send(JSON.generate(response))
    }
  end
  
end

EM.run do
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    ws.onopen { |handshake|
      # puts "WebSocket connection open"

      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers

      # Publish message to the client
      # ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { 
      puts "Connection closed" 
    }

    ws.onmessage { |msg|
      pp "-------------------"
      
      command = JSON.parse(msg)
      pp command
      
      if command['poll'] == true
        timer = EventMachine::PeriodicTimer.new(30) do
          pp "Timer!"
          
          if ws.state.to_s == 'closed'
            timer.cancel
          end
          
          request = ApiRequest.new(command, ws)
          request.fire
        end
      end
      
      request = ApiRequest.new(command, ws)
      request.fire
    }
  end
  
  puts "Server started."
end