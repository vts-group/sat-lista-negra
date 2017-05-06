module API
  module V1
    class Base < Grape::API
      version 'v1', using: :path
      format :json
      default_format :json
      resource :list do
        get ":tax_reference" do
         List.find_by(tax_reference: params[:tax_reference])
        end
      end
    end
  end
end
