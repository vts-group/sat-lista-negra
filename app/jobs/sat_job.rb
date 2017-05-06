class SatJob  < ApplicationJob
  queue_as :sat
  def perform
    SatService.new.get_lista_negra
  end
end
