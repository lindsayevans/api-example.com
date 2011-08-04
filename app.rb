require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'json'
require 'roxml'

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

get '/:dataset.:format' do
	#'wassup!' + params[:dataset] + '.' + params[:format]
	@data = get_data(params[:dataset])
	case params[:format].downcase
		when 'html'
			response.headers['Content-Type'] = 'text/html'
			@data.to_html
		when 'xml'
			response.headers['Content-Type'] = 'text/xml'
			@data.to_xml
		when 'js'
			response.headers['Content-Type'] = 'text/js'
			if !params[:callback].nil? then
				params[:callback] + '(' + @data.to_json + ');'
			else
				@data.to_json
			end
		when 'json'
			response.headers['Content-Type'] = 'text/json'
			@data.to_json
		when 'csv'
			response.headers['Content-Type'] = 'text/csv'
			@data.to_csv
		when 'tsv'
			response.headers['Content-Type'] = 'text/tsv'
			@data.to_tsv
	end
end

def get_data dataset_name

	if dataset_name == 'employees'
		return [
			{ :first_name => 'Lindsay', :last_name => 'Evans'},
			{ :first_name => 'Fred', :last_name => 'Randell'},
			{ :first_name => 'Grant', :last_name => 'Klein'},
			{ :first_name => 'Danny', :last_name => 'Webster'},
			{ :first_name => 'Sharyn', :last_name => 'Persijn'}
		]
	end

end

class Array

	def to_html

		h = '<table>'

		# Headers
		h += '<thead><tr>'
		self[0].keys.each do |k|
			h += "<th>#{k}</th>"
		end
		h += '<tr></thead>'

		# Data
		self.each do |r|
			h += '<tr>'
			r.each_value do |v|
				h += "<td>#{v}</td>"
			end
			h += '</tr>'
		end

		h += '</table>'
		return h
	end

	def to_csv

		# TODO: escaping etc.

		h = ''

		# Headers
		self[0].keys.each do |k|
			h += "#{k}"
			h += ',' if k != self[0].keys.last
		end
		h += "\r\n"

		# Data
		self.each do |r|
			r.each_value do |v|
				h += "#{v}"
				h += ',' if v != r.values.last
			end
			h += "\r\n"
		end

		return h
	end

	def to_tsv

		# TODO: escaping etc.

		h = ''

		# Headers
		self[0].keys.each do |k|
			h += "#{k}"
			h += "\t" if k != self[0].keys.last
		end
		h += "\r\n"

		# Data
		self.each do |r|
			r.each_value do |v|
				h += "#{v}"
				h += "\t" if v != r.values.last
			end
			h += "\r\n"
		end

		return h
	end

end
