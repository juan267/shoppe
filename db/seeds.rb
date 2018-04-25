# encoding: UTF-8

tax_rate = Shoppe::TaxRate.where(name: 'IVA', rate: 16.0).first_or_create

# delivery services
ds = Shoppe::DeliveryService.new(name: 'Deprisa', code: 'DEP', courier: 'Deprisa', tracking_url: 'http://trackingurl.com/track/{{consignment_number}}')
if ds.save
  ds.delivery_service_prices.create(code: 'Parcel', min_weight: 0, max_weight: 100, price: 5.0, cost_price: 4.50, tax_rate: tax_rate)
end

# categories
cat1 = Shoppe::ProductCategory.where(name: 'Naranjas').first_or_create
cat2 = Shoppe::ProductCategory.where(name: 'Limones').first_or_create

def get_file(name, content_type = 'image/jpeg')
  file = ActionDispatch::Http::UploadedFile.new(tempfile: File.open(File.join(Shoppe.root, 'db', 'seeds_data', name), 'rb'))
  file.original_filename = name
  file.content_type = content_type
  file
end

salustiana = 'La naranja Salustiana es una variedad de la naranja Navel y se produjo por una mutación espontánea en la provincia de Valencia debido a su clima y condiciones de cultivo. Es una naranja típicamente española. De la misma forma que la Valencia, no tiene el color tan naranja tirando a rojizo que tienen las navelinas. Su forma también es algo diferente, ya que suelen tener una forma más achatada. Su piel también es más fina que otras variedades, y su tamaño suele ser mediano. Su punto fuerte es su gran cantidad de jugo. Esto, unido a su intenso sabor dulce, las hace perfectas para consumir en forma de zumo'

sweety = 'Es el resultado de la investigación realizada por la agroindustria colombiana, con el objetivo de obtener una naranja apta para el procesamiento de jugos y concentrados. El resultado indicado para las condiciones de suelo del Eje Cafetero fue la variedad Sweety Orange. Por lo cual, se convirtió en una de las alternativas económicamente viables para la sustitución de cultivos en esta región, tras la Crisis Cafetera. La variedad sweety, tiene un fruto mediano, casi sin semillas, de color anaranjado y de un sabor dulce inclusive cuando el fruto no se encuentra totalmente maduro.'

valencia = 'Esta variedad se identificó y nombró en Portugal, pero es probablemente de origen chino como la mayoría de los cítricos. Es la variedad más comercial a nivel nacional e internacional y se identifica por ser un fruto de tamaño medio a grande de forma esférica a oblonga, con pocas semillas. Su pulpa es muy jugosa y de extraordinario sabor, adicionalmente el jugo de esta naranja es ligeramente ácido y posee un profundo color anaranjado.'

short_description = 'Naranjas de excelente calidad'

#Salustiana
pro = Shoppe::Product.new(name: 'Salustiana', sku: 'Sl-20k', description: salustiana, short_description: short_description, weight: 20, price: 0, cost_price: 0, tax_rate: tax_rate)
pro.product_category_ids = cat1.id
pro.default_image_file = get_file('salustiana.jpg')
if pro.save
  pro.stock_level_adjustments.create(description: 'Initial Stock', adjustment: 0)
  pro.product_attributes.create(key: 'Tamaño', value: 'Media a Grande', position: 1)
  pro.product_attributes.create(key: 'Semillas', value: 'Pocas', position: 1)
  pro.product_attributes.create(key: 'Sabor', value: 'Dulce', position: 1)
  pro.product_attributes.create(key: 'Contenido de Jugo ', value: 'Alto', position: 1)
  pro.product_attributes.create(key: 'Durabilidad', value: 'Hasta 20 dias en buenas condiciones', position: 1)
end


#Valencia
pro = Shoppe::Product.new(name: 'Valencia', sku: 'V-20k', description: valencia, short_description: short_description, weight: 20, price: 0, cost_price: 0, tax_rate: tax_rate)
pro.product_category_ids = cat1.id
pro.default_image_file = get_file('valencia.jpg')
if pro.save
  pro.stock_level_adjustments.create(description: 'Initial Stock', adjustment: 0)
  pro.product_attributes.create(key: 'Tamaño', value: 'Media a Grande', position: 1)
  pro.product_attributes.create(key: 'Semillas', value: 'Pocas', position: 1)
  pro.product_attributes.create(key: 'Sabor', value: 'Agridulce', position: 1)
  pro.product_attributes.create(key: 'Contenido de Jugo ', value: 'Alto', position: 1)
  pro.product_attributes.create(key: 'Durabilidad', value: 'Hasta 20 dias en buenas condiciones', position: 1)
end

#Sweety
pro = Shoppe::Product.new(name: 'Sweety', sku: 'SW-20k', description: sweety, short_description: short_description, weight: 20, price: 0, cost_price: 0, tax_rate: tax_rate)
pro.product_category_ids = cat1.id
pro.default_image_file = get_file('sweety.jpg')
if pro.save
  pro.stock_level_adjustments.create(description: 'Initial Stock', adjustment: 0)
  pro.product_attributes.create(key: 'Tamaño', value: 'Medio', position: 1)
  pro.product_attributes.create(key: 'Semillas', value: 'Medio', position: 1)
  pro.product_attributes.create(key: 'Sabor', value: 'Dulce', position: 1)
  pro.product_attributes.create(key: 'Contenido de Jugo ', value: 'Alto', position: 1)
  pro.product_attributes.create(key: 'Durabilidad', value: 'Hasta 20 dias en buenas condiciones', position: 1)
end
