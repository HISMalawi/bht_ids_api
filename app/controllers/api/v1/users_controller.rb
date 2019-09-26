class Api::V1::UsersController < ApplicationController
	#skip_before_action :authenticate_request, only: %i[login register]
	before_action :set_user, only: [:show, :update, :destroy]

	# GET /users
	def index
		@users = User.all

		render json: @users		
	end

	# GET /users/1
	def show
		render json: @user		
	end

	# POST 
	def create
		authorize @user

		@user = User.new(user_params)

		if @user.save
			render json: {status: 'User created successfully'}, status: :created
		else
			render json: {errors: @user.errors.full_messages}, status: :bad_request
		end
	end

	# PUT /user/1
	def update
		authorize @user
		
		if @user.update(user_params)
			render json: @user
		else
			render json: {errors: @user.errors}, status: :unprocessable_entity
		end
		
	end

    # DELETE /user/1
	def destroy
		authorize @user

		if @user.destroy
		   render json: {status: "Successfully deleted user"}, status: :success
	    else
	    	render json: {errors: @user.errors.full_messages}, status: :internal_server_error
	    end		
	end

	private

	def set_user
		@user = User.find(params[:id])		
	end

	def user_params
		params.permit(:name, :username, :password, :password_confirmation)
	end


end