class Api::V1::ReportsController < ApplicationController

 def cbs_case_listing
    cases = service.cbs_case_listing
    render json: cases
 end

 def art_initiated
 	initiated_clients = service.cbs_art_initiated(rds_db)
 	render json: initiated_clients
 end

 def service
    ReportService.new(start_date: params[:start_date].to_date, 
        end_date: params[:end_date].to_date, district_id: 1, site_id: 1)
 end

end
