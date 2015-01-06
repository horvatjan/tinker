module Api::V1::Concerns::Response
  extend ActiveSupport::Concern

  def success_response(content)
    render json: content, status: 200
  end

  def error_response(message, error_code)
    render json: {
      errorCode: error_code,
      errorMessage: message
    }, status: 200
  end
end
