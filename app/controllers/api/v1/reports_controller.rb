class Api::V1::ReportsController < ApplicationController

 def cbs_case_listing
  start_date, end_date = params.require %i[start_date end_date]
  cases = service.cbs_case_listing(start_date, end_date)

  render json: cases
 end

 private

 def service
 	
 end

end