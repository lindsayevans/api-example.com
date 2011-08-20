require 'rubygems'
require 'sinatra'
#require 'sinatra/reloader'
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
	render_dataset(get_dataset(params[:dataset]), 'html')
end

def get_dataset dataset_name
	# TODO: load these from disk or something instead
	if dataset_name == 'employees'
		return [
			{ :id => 1, :first_name => 'Clarence', :last_name => 'Binford'},
			{ :id => 2, :first_name => 'Janet', :last_name => 'Chapa'},
			{ :id => 3, :first_name => 'Henry', :last_name => 'Nieto'},
			{ :id => 4, :first_name => 'Myrtle', :last_name => 'Shell'},
			{ :id => 5, :first_name => 'Georgia', :last_name => 'Maggio'},
			{ :id => 6, :first_name => 'Jeremy', :last_name => 'Duque'},
			{ :id => 7, :first_name => 'Margie', :last_name => 'Wheaton'},
			{ :id => 8, :first_name => 'Dale', :last_name => 'Bloch'},
			{ :id => 9, :first_name => 'Larry', :last_name => 'Ringer'},
			{ :id => 10, :first_name => 'Jose', :last_name => 'Sanabria'},
			{ :id => 11, :first_name => 'Adam', :last_name => 'Page'},
			{ :id => 12, :first_name => 'Juan', :last_name => 'Backus'},
			{ :id => 13, :first_name => 'Natalie', :last_name => 'Shirley'},
			{ :id => 14, :first_name => 'Albert', :last_name => 'Beaver'},
			{ :id => 15, :first_name => 'George', :last_name => 'Horton'},
			{ :id => 16, :first_name => 'Katrina', :last_name => 'Leathers'},
			{ :id => 17, :first_name => 'Russell', :last_name => 'Adorno'},
			{ :id => 18, :first_name => 'Bernice', :last_name => 'Braithwaite'},
			{ :id => 19, :first_name => 'Janie', :last_name => 'Thrasher'},
			{ :id => 20, :first_name => 'Adam', :last_name => 'Troupe'},
			{ :id => 21, :first_name => 'Celia', :last_name => 'Nowlin'},
			{ :id => 22, :first_name => 'Stephanie', :last_name => 'Milne'},
			{ :id => 23, :first_name => 'Nicholas', :last_name => 'Haire'},
			{ :id => 24, :first_name => 'Clara', :last_name => 'Barham'},
			{ :id => 25, :first_name => 'Clarence', :last_name => 'O\'Malley'},
			{ :id => 26, :first_name => 'Lawrence', :last_name => 'Simone'},
			{ :id => 27, :first_name => 'Chris', :last_name => 'Ouellette'},
			{ :id => 28, :first_name => 'Pam', :last_name => 'Soukup'},
			{ :id => 29, :first_name => 'Robert', :last_name => 'MacIntyre'},
			{ :id => 30, :first_name => 'Gregory', :last_name => 'Pauley'}
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
