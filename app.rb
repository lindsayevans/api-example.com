require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'haml'
require 'json'
require 'roxml'
require 'yaml'
require 'active_support'

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

get '/:dataset/:id.:format' do
	render_dataset(get_data_by_id(params[:dataset], params[:id]), params[:format])
end

get '/:dataset.:format' do
	render_dataset(get_dataset(params[:dataset]), params[:format])
end

get '/:dataset' do
	render_dataset(params[:dataset], 'html')
end

def get_dataset dataset_name

	if dataset_name == 'employees'
		return [
			{ :id => 1, :first_name => 'Lindsay', :last_name => 'Evans'},
			{ :id => 2, :first_name => 'Fred', :last_name => 'Randell'},
			{ :id => 3, :first_name => 'Grant', :last_name => 'Klein'},
			{ :id => 4, :first_name => 'Danny', :last_name => 'Webster'},
			{ :id => 5, :first_name => 'Sharyn', :last_name => 'Persijn'}
		]
	end

end

def get_data_by_id dataset_name, id
	data = get_dataset dataset_name
	data.delete_if {|r| r[:id] != id.to_i}
end

helpers do
	def render_dataset(data, format)
		case format.downcase
			when 'html'
				response.headers['Content-Type'] = 'text/html'
				data.to_html
			when 'xml'
				response.headers['Content-Type'] = 'text/xml'
				data.to_xml
			when 'js'
				response.headers['Content-Type'] = 'text/js'
				if !params[:callback].nil? then
					params[:callback] + '(' + data.to_json + ');'
				else
					data.to_json
				end
			when 'json'
				response.headers['Content-Type'] = 'text/json'
				data.to_json
			when 'csv'
				response.headers['Content-Type'] = 'text/csv'
				data.to_csv
			when 'tsv'
				response.headers['Content-Type'] = 'text/tsv'
				data.to_tsv
		end
	end
end


class Array

	def to_html

		data_array = [self]
		data_array = self if !self[0].nil?

		h = '<table>'

		# Headers
		h += '<thead><tr>'
		data_array[0].keys.each do |k|
			h += "<th>#{k.to_s.humanize}</th>"
		end
		h += '<tr></thead>'

		# Data
		data_array.each do |r|
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
