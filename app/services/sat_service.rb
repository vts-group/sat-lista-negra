class SatService

  SAT_URL = "https://siat.sat.gob.mx/PTSC/consultapdc/articulo69"

  def get_lista_negra
    get_lista_negra_ley_transparencia
    get_lista_negra_consulta_global
    get_lista_retornoinv
    get_lista_gral_no_localizados
    get_lista_elim_excreg13
    get_lista_elim_aclarcont
    get_lista_elim_rectordverif
    get_lista_presuntos
    get_lista_definitivos
    get_desvirtuaron
  end

  def get_lista_negra_ley_transparencia
    list_type =  "Personas Físicas y Morales- Créditos cancelados, condonados y condonados por retorno de inversiones"
    url = SAT_URL + "/ley_transparencia/fis_mor/efed/TODAS"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_negra_consulta_global
    list_type =  "Personas Físicas y Morales- Consulta Global"
    url = SAT_URL + "/inc_fm_todos/fis_mor/efed/TODAS"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_retornoinv
    list_type =  "retornoinv"
    url = SAT_URL + "/retornoinv"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_gral_no_localizados
    list_type =  "gral_no_localizados/fis_mor/efed/TODAS"
    url = SAT_URL + "/gral_no_localizados/fis_mor/efed/TODAS"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_elim_excreg13
    list_type =  "elim/excreg13"
    url = SAT_URL + "/elim/excreg13"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_elim_aclarcont
    list_type =  "elim/aclarcont"
    url = SAT_URL + "/elim/aclarcont"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_elim_rectordverif
    list_type =  "elim/rectordverif"
    url = SAT_URL + "/elim/rectordverif"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_presuntos
    list_type =  "presuntos/fis_mor/TODAS"
    url = SAT_URL + "/presuntos/fis_mor/TODAS"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_lista_definitivos
    list_type =  "definitivos/fis_mor/TODAS"
    url = SAT_URL + "/definitivos/fis_mor/TODAS"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_desvirtuaron
    list_type =  "desvirtuaron/fis_mor/TODAS"
    url = SAT_URL + "/desvirtuaron/fis_mor/TODAS"
    ('A'..'Z').each do |letter|
      clean_list(letter,list_type)
      get_pdf(url,letter,list_type)
    end
  end

  def get_pdf(url,letter,list_type)
    i = 1
    uri = URI.parse(url + "/" +  letter + i.to_s + ".pdf")
    res = Net::HTTP.get_response(uri)
    while res.code.to_i == 200 do
        uri = URI.parse(url + "/" +  letter + i.to_s + ".pdf")
        res = Net::HTTP.get_response(uri)
        if res.code.to_i == 200
          save_file(res.body)
          parse(letter,list_type)
          @file.unlink
        end
    end
  end

  def save_file(body)
    @file = Tempfile.new('tmp.pdf')
    @file.write(body.force_encoding("utf-8"))
  end

  def parse(letter,list_type)
    reader = PDF::Reader.new(@file.path)
    reader.pages.each do |page|
      date_list = page.text.scan(/actualizada\s+al\s+(\d{2}\/\d{2}\/\d{4})/).first.first
      page.text.scan(/\s+([A-Za-z0-9_&]{3}[0-9]{6}[A-Za-z0-9_]{3})/).each do |tax_reference|
        List.create(letter:letter,tax_reference: tax_reference.first, list_type: list_type, date_list:date_list)
      end
    end
  end

  def clean_list(letter,list_type)
    List.where(letter: letter, list_type: list_type).destroy_all
  end
end
