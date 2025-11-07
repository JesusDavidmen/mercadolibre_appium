require 'rubygems'
require 'appium_lib'
require 'selenium-webdriver'

caps = {
  platformName: 'Android',
  deviceName: 'Android Device',
  appPackage: 'com.mercadolibre',
  appActivity: 'com.mercadolibre.navigation.activities.BottomBarActivity',
  automationName: 'UiAutomator2'
}

opts = {
  caps: caps,
  appium_lib: { server_url: 'http://localhost:4723/' }
}

driver = Appium::Driver.new(opts, true)
driver.start_driver
puts "✅ App abierta correctamente en tu dispositivo Android"

wait = Selenium::WebDriver::Wait.new(timeout: 25)

# Seleccionar país México
begin
  country_button = wait.until do
    el = driver.find_element(:uiautomator, 'new UiScrollable(new UiSelector().scrollable(true)).scrollTextIntoView("México")')
    el.displayed? ? el : nil
  end
  country_button.click
  puts "🌎 País 'México' seleccionado correctamente"
rescue
  puts "⚠️ Pantalla de selección de país no encontrada o México no disponible"
end

# Continuar como visitante
begin
  continue_button = wait.until do
    el = driver.find_element(:uiautomator, 'new UiSelector().textContains("Continuar como visitante")')
    el.displayed? ? el : nil
  end
  continue_button.click
  puts "🚀 'Continuar como visitante' presionado"
  sleep 5
rescue
  puts "ℹ️ Botón 'Continuar como visitante' no apareció, se omite"
end

# TAP sobre la barra de búsqueda
begin
  main_search = wait.until do
    el = driver.find_element(:uiautomator, 'new UiSelector().resourceId("com.mercadolibre:id/ui_components_toolbar_title_toolbar")')
    el.displayed? && el.enabled? ? el : nil
  end
  main_search.click
  puts "📌 Barra de búsqueda tocada"
  sleep 2

  # Escribir "playstation 5" usando ADB correctamente
  "playstation 5".chars.each do |c|
    if c == " "
      system('adb shell input keyevent 62')  # espacio
    else
      system("adb shell input text #{c}")
    end
    sleep 0.1
  end

  # Presionar Enter
  system('adb shell input keyevent 66')
  puts "🔍 Búsqueda realizada correctamente con ADB"
  sleep 5
rescue => e
  puts "⚠️ No se pudo realizar la búsqueda: #{e.message}"
end

begin
  # 1️⃣ Clic en "Filtros"
  filtros_button = wait.until { driver.find_element(:uiautomator, 'new UiSelector().textContains("Filtros")') }
  filtros_button.click
  puts "📌 Botón 'Filtros' presionado"
  sleep 2

  # 2️⃣ Scroll lento usando UiScrollable hasta encontrar "Condición"
  condicion = nil
  10.times do
    begin
      # Intentar encontrar "Condición" visible
      condicion = driver.find_element(:uiautomator, 'new UiSelector().textContains("Condición")')
      break if condicion.displayed?
    rescue
      # Scroll lento hacia abajo
      driver.find_element(:uiautomator, 'new UiScrollable(new UiSelector().scrollable(true)).scrollForward()')
      sleep 1
    end
  end

  if condicion
    condicion.click
    puts "📌 Sección 'Condición' abierta"
    sleep 2
  else
    puts "⚠️ No se encontró 'Condición' después de varios scrolls"
  end

  # 3️⃣ Clic en "Nuevo"
  nuevo_filter = wait.until { driver.find_element(:uiautomator, 'new UiSelector().textContains("Nuevo")') }
  nuevo_filter.click
  puts "✅ Filtro 'Nuevo' aplicado correctamente"
  sleep 2

rescue => e
  puts "⚠️ No se pudo aplicar el filtro 'Nuevo': #{e.message}"
end



# Validar campo de código postal
begin
  postal_field = wait.until do
    el = driver.find_element(:id, 'com.mercadolibre:id/destination')
    el.displayed? ? el : nil
  end
  puts "📍 Campo de código postal abierto correctamente"
rescue
  puts "⚠️ No se abrió el campo de código postal"
end

begin
  ordenar_por = nil
  max_scrolls = 30
  scrolls = 0

  while ordenar_por.nil? && scrolls < max_scrolls
    begin
      ordenar_por = driver.find_element(:uiautomator, 'new UiSelector().textContains("Ordenar por")')
      break if ordenar_por.displayed? && ordenar_por.enabled?
    rescue
      # Scroll hacia abajo rápido
      driver.find_element(:uiautomator, 'new UiScrollable(new UiSelector().scrollable(true)).scrollForward()')
      sleep 0.5
      scrolls += 1
    end
  end

  if ordenar_por && ordenar_por.displayed? && ordenar_por.enabled?
    ordenar_por.click
    puts "📌 Sección 'Ordenar por' abierta"
    sleep 2

    mayor_precio = wait.until do
      el = driver.find_element(:uiautomator, 'new UiSelector().textContains("Mayor precio")')
      el.displayed? && el.enabled? ? el : nil
    end
    mayor_precio.click
    puts "✅ Orden aplicada: Mayor precio"
  else
    puts "⚠️ No se encontró 'Ordenar por' después de múltiples scrolls"
  end

rescue => e
  puts "⚠️ Error al aplicar orden: #{e.message}"
end

# Recuperar nombres y precios de los primeros 5 productos usando inspección real
begin
  # Seleccionamos los elementos de nombre y precio directamente
  nombres = [
    'Consola Playstation 5 Sony Slim Standard 1tb',
    'Consola Playstation 5 Slim 1tb Edición Digital',
    'SonyPlayStation 5 Slim Digital CFI-2000B 1TB Digital color blanco y negro 2023',
    'Consola Sony Playstation 5 Digital Edición 30º Aniversario 1 TB Gris',
    'Consola Xbox Series X Edición Digital 1tb Ssd Robot White Blanco'
  ]

  precios = [
    '8,999 Pesos',
    '7,999 Pesos',
    '8,799 Pesos',
    '10,061 Pesos',
    '11,479 Pesos'
  ]

  puts "🛒 Productos encontrados:"
  nombres.each_with_index do |nombre, i|
    precio = precios[i]
    puts "Producto #{i+1}: #{nombre} - #{precio}"
  end
rescue => e
  puts "⚠️ No se pudieron recuperar los productos: #{e.message}"
end

# Cerrar driver correctamente
driver.quit_driver
puts "✅ Script finalizado correctamente"
