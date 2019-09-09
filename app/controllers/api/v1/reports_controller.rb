class Api::V1::ReportsController < ApplicationController

 def cbs_case_listing
    cases = service.cbs_case_listing
    headers['pagination'] = cases[1]
    render json: cases[0]
 end

 def cbs_client_case
 	client_case = service.cbs_client_case(params.require(:person_id))
 	render json: client_case 	
 end

 def art_initiated
 	initiated_clients = service.cbs_art_initiated(rds_db)
 	render json: initiated_clients
 end

 def service
 	if params[:person_id] == nil
      ReportService.new(start_date: params[:start_date].to_date, 
        end_date: params[:end_date].to_date, district_id: params[:district_id], site_id: params[:site_id],
        page: params[:page], per_page: params[:per_page])
    else
      ReportService.new(start_date: params[:start_date].to_date, 
        end_date: params[:end_date].to_date, district_id: params[:district_id], site_id: params[:site_id], 
        person_id: params[:person_id],score: params[score], page: params[:page], per_page: params[:per_page])
    end

 end

end
