#!/usr/bin/env ruby
=begin
        This is a sample program to retrieve the IBC Label.

        Sources:
                http://mislav.net/2011/07/faraday-advanced-http/
                https://github.com/augustl/net-http-cheat-sheet
                http://www.ruby-doc.org/stdlib-2.1.3/libdoc/net/http/rdoc/Net/HTTP.html
        
        Usage:
                ibclabel-request.rb action url [-d]
      
               action_url can be one of these create, delete or close
               and for the url pass something similar to: TST/E/222222

               For the full documentation visit: https://api.pactrak.com/ibclabel/documentation.html

               Sample calls: 
                 $ ruby label create TST/E/FDX  --- TST/UPSG/UPS
                 $ ruby label delete TST/E/794674245377
                 $ ruby lable close TST/S/222222
          
          Note: for create requests the file "feed.txt" will be read as input for the create request

=end


require_relative "../globals/utility_functions"
require "net/http"
require "net/https"
require "uri"
require 'json'

#variables
     #this is where you put the token received from the head request
token = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXxlzPQ=="  

#functions


#classes


#main
        #puts "#{ ARGV } [ #{ ARGV.length } ]"
        error_msg( "Usage: #{ $0 } create|delete|close url", Exception.new, 1 ) unless ARGV.length >= 2
begin
        $debug = ARGV.include? "-d"
        use_http_proxy = ARGV.include? "-p"
        
        action = ARGV[ 0 ]
        raise "Please specify correct action (create|close|delete)" unless ( action =~ /(create$|close$|delete$)/ ) == 0

        url = ARGV[ 1 ]
        puts "#{ action } on #{ url } is requested" if $debug


        # proxy 'http://username:password@hostname:port'
        

        ENV[ 'http_proxy' ] = "http://proxy.address.com:3128" if use_http_proxy    
        proxy_uri = URI.parse( ENV[ 'http_proxy' ] ) if use_http_proxy
        

        fulluri = "https://api.pactrak.com/ibclabel/service/#{ url }"
        puts "URL: #{ fulluri }"
        uri = URI.parse fulluri

        new_query_ar = URI.decode_www_form(uri.query || '') << ["token", token]
        uri.query = URI.encode_www_form( new_query_ar )

        puts "Request to Host: #{ uri.host } Port: #{ uri.port } Path: #{ uri.path }"
        if $debug         
                puts "Request URI: #{ uri.request_uri }"
                puts "Path: #{ uri.path }"
                puts "Proxy: #{ proxy_uri.host } #{ proxy_uri.port }" if use_http_proxy
                puts "-----------------------------"
        end
      
        print "Set up Connection....." if $debug

        http = Net::HTTP.new( uri.host, uri.port )
        http.use_ssl = uri.scheme.eql? "https"
        puts "Use SSL? #{ http.use_ssl? }" if $debug
        request = case action
               when "create"
                    puts "POST Method...."
                    Net::HTTP::Post.new( uri.request_uri )
               when "close"
                    puts "PUT Method...."
                    Net::HTTP::Put.new( uri.request_uri )
               when "delete"
                    puts "DELETE Method...."
                    Net::HTTP::Delete.new( uri.request_uri )
        end
        create_req = false 

        if action.eql? "create"
             create_req = true
             feed = File.open( 'feed.txt', 'rb') { |file| file.read }
             
             #or as a JSON object in the body of the request...
             request.add_field( 'Content-Type', 'application/json' )
             request.body = feed
             
             #You could also create JSON object..This option below is
             #not setup in our API.
             #request.body = {feed: JSON.parse(feed) }.to_json
             
               
             if $debug
                    puts request.to_hash
                    puts request.body
             end
               
        end


        print "Done. Connecting....."  if $debug

        response = http.request( request )
        puts "Done.\n#{ response.inspect }"  if $debug
        puts "The service responded: ( #{ response.code } - #{ response.message } )"

        if $debug
                puts
                puts "Headers Received:"
#                puts "#{ response.to_hash.inspect }"
                response.each_header do |key, value|
                        puts "#{ key }: #{ value }"
                end
                puts "-----------------------------"
        end

        puts
        puts "CL: #{ response[ "content-length" ] }" if $debug
        puts "----BODY----"
        puts response.body
        puts "------------"
        resp = JSON.parse( response.body )
        code = resp["code"].to_i
        puts code
        puts resp["message"]
        puts resp["service_answer"]["trackNumbers"][ 0 ] if code == 200 && create_req
        
rescue Exception => e
        error_msg "Exception: #{e}", e, 2
end
exit 0
