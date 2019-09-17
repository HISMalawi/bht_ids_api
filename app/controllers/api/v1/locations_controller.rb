class Api::V1::LocationsController < ApplicationController

	def district_code
		dis_code = Location.find_by_sql("SELECT name, location_id,code FROM locations")
		render json: dis_code
	end

	def site_code(code)
		sites_code = Site.find_by_sql("SELECT site_name, site_id FROM sites where short_name = #{code}")
		render json: sites_code		
	end
      
end