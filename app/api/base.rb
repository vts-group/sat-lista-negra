module API
  class Base < Grape::API
    prefix 'v1'
    mount API::V1::Base
  end
end
