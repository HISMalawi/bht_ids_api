class AuthenticationController < ApplicationController
    skip_before_action :authenticate_request
   
    def authenticate
      command = AuthenticateUser.call(params[:username], params[:password])
   
      if command.success?
        render json: { auth_token: command.result, username: command.username }
      else
        render json: { error: command.errors }, status: :unauthorized
      end
    end
   end
