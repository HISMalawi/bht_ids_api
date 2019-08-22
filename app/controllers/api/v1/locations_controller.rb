class Api::V1::LocationsController < ApplicationController

	def district_code
		dis_code = Location.find_by_sql("SELECT name, location_id FROM locations")
		render json: dis_code
	end

	def site_code
		sites_code = Site.find_by_sql("SELECT site_name, site_id FROM sites")
		render json: sites_code		
	end
      
end