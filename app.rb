require 'rubygems'
require 'sinatra'
require 'haml'

# HAML config
set :haml, {:format => :html5, :attr_wrapper => '"' }

# main stylesheet
get '/css/screen.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  css :screen
end

# homepage
get '/' do

  # Make heroku cache this page
  response.headers['Cache-Control'] = 'public, max-age=300'
    
  haml :index

end


