#!/usr/bin/env ruby
=begin
        This is a sample program to retrieve the HTTP header token from the IBC Authority service.

        Sources:
                https://github.com/augustl/net-http-cheat-sheet
                http://www.ruby-doc.org/stdlib-2.1.3/libdoc/net/http/rdoc/Net/HTTP.html
        
        Usage:
                send-head.rb base64_username_password

          For the full documentation visit: https://api.pactrak.com/authority/documentation.html
=end


require_relative "../globals/utility_functions"
require "net/http"
require "net/https"
require "uri"

#variables

#functions


#classes


#main
        #puts "#{ ARGV } [ #{ ARGV.length } ]"
        error_msg( "Usage: #{ $0 } base64_username_password", Exception.new, 1 ) unless ARGV.length >= 1
begin
        $debug = ARGV.include? "-d"
        use_http_proxy = ARGV.include? "-p"
        
        token = ARGV[ 0 ]

        # proxy 'http://username:password@hostname:port'

        ENV[ 'http_proxy' ] = "http://proxy.address.com:3128" if use_http_proxy
        proxy_uri = URI.parse( ENV[ 'http_proxy' ] ) if use_http_proxy

        uri = URI.parse "https://api.pactrak.com/authority/token"

        puts "Head request to Host: #{ uri.host } Port: #{ uri.port } Path: #{ uri.path }"
        if $debug         
                puts "Request URI: #{ uri.request_uri }"
                puts "Token: #{ token }"
                puts "Proxy: #{ proxy_uri.host } #{ proxy_uri.port }" if use_http_proxy
                puts "-----------------------------"
        end
               
        print "Set up Connection....." if $debug

        http = Net::HTTP.new( uri.host, uri.port )
        http.use_ssl = uri.scheme.eql? "https"

        request = Net::HTTP::Head.new( uri.request_uri )
        request[ "IBCCredentials" ] = token
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
        puts "Token: #{ response[ "Authority" ] }" unless response[ "Authority" ].nil?

rescue Exception => e
        error_msg "Exception: #{e}", e, 2
end
