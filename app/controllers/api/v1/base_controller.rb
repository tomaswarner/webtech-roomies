module Api
  module V1
    # Public, read-only API: no session and no token. Every error has the same shape: { "errors": [ ... ] }.
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      def route_not_found
        render_errors("There is no route for #{request.request_method} #{request.path}", status: :not_found)
      end

      private

      def render_errors(messages, status:)
        render json: { errors: Array(messages) }, status: status
      end

      def record_not_found(error)
        render_errors("There is no #{error.model.to_s.underscore.humanize.downcase} with id #{error.id}", status: :not_found)
      end

      # Money travels as a string: the column is a decimal, and a JSON number would pass through a float.
      def money(amount)
        format("%.0f", amount)
      end
    end
  end
end
