require 'json'

# Ejecuta `rails routes` para obtener las rutas en texto
routes_text = `rails routes`

# Analiza las líneas de salida y construye una estructura de datos
routes = []
routes_text.each_line.with_index do |line, index|
  next if index == 0 # Salta la primera línea (cabecera)

  # Divide la línea en partes usando expresiones regulares para manejar espacios múltiples
  match = line.match(/^(?<prefix>\S+)?\s+(?<verb>GET|POST|PUT|PATCH|DELETE|OPTIONS|HEAD)\s+(?<path>\S+)\s+(?<action>.+)$/)
  next unless match # Salta líneas mal formadas

  # Extrae los valores usando grupos nombrados
  prefix = match[:prefix]
  verb = match[:verb]
  path = match[:path]

  routes << {
    "name" => prefix || "Unnamed Route",
    "verb" => verb,
    "path" => path
  }
end

# Crea el archivo Postman
collection = {
  "info" => {
    "name" => "Rails API Endpoints",
    "schema" => "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item" => routes.map do |route|
    {
      "name" => route["name"],
      "request" => {
        "method" => route["verb"],
        "url" => {
          "raw" => "http://localhost:3000#{route['path']}",
          "host" => ["localhost"],
          "port" => "3000",
          "path" => route["path"].split("/").reject(&:empty?)
        }
      }
    }
  end
}

# Guarda el JSON generado
File.open("rails_endpoints.postman_collection.json", "w") do |f|
  f.write(JSON.pretty_generate(collection))
end

puts "Postman collection generated successfully!"
