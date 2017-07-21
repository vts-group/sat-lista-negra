require 'net/http'
class SatService

  SAT_URL = "https://siat.sat.gob.mx/PTSC/consultapdc/articulo69"

  def get_lista_negra
    sat_urls.each do | array_url |
      url = SAT_URL + array_url[0]
      ('A'..'Z').each do |letter|
        clean_list(letter,array_url[1])
        get_pdf(url,letter,array_url[1])
      end
    end
  end

  def sat_urls
    [
      [
        "/ley_transparencia/fis_mor/efed/TODAS",
        "Personas Físicas y Morales- Créditos cancelados, condonados y condonados por retorno de inversiones"
      ],
      [
        "/inc_fm_todos/fis_mor/efed/TODAS",
        "Personas Físicas y Morales- Consulta Global"
      ],
      [
        "/retornoinv",
        "Consulta Global Condonados Retorno de Inversiones"
      ],
      [
        "/gral_no_localizados/fis_mor/efed/TODAS",
        "Personas Físicas y Morales- Consulta Global No localizados"
      ],
      [
        "/elim/excreg13",
        "Excluidos de conformidad con la regla I.1.3 de la Resolución Miscelánea Fiscal vigente"
      ],
      [
        "/elim/aclarcont",
        "Aclaraciones presentadas por contribuyentes"
      ],
      [
        "/elim/rectordverif",
        "Confirmación de datos en la orden de verificación"
      ],
      [
        "/presuntos/fis_mor/TODAS",
        "presuntos/fis_mor/TODAS"
      ],
      [
        "/definitivos/fis_mor/TODAS",
        "definitivos/fis_mor/TODAS"
      ],
      [
        "/desvirtuaron/fis_mor/TODAS",
        "/desvirtuaron/fis_mor/TODAS"
      ],
      [
        "/int_con",
        "Consulta Global"
      ],

    ]
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
