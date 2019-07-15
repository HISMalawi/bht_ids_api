class ApplicationController < ActionController::API
  require 'yaml'

  before_action :authenticate_request
  attr_reader :current_user

  def rds_db
    YAML.load_file("#{Rails.root}/config/database.yml")['rds']['database']
  end
  
  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end
end
