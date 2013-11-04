module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :verify_authenticity_token, if: :json_request?
      before_action :authenticate_api_user

      # GET /api/v1/user.json
      # Optional parameters: username or id or email
      # Required parameters: token
      def show
        user = if params[:username]
          User.where(username: params[:username]).first
        elsif params[:email]
          User.where(email: params[:email]).first
        elsif params[:id]
          User.where(id: params[:id])
        else
          raise "No field provided"         
        end
        render json: user.to_json
      end

      private

      def json_request?
        request.format.json?
      end

      def authenticate_api_user
        raise "AccessDenied: Bad token" unless Group.where(token: params[:token]).any?
      end
    end
  end
end