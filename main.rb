require 'mechanize'
require 'digest/md5'

CEDULA = '123123'
CUENTA = '1000000'
PIN = '123456'

START_URL = 'https://www.secure.itau.com.py/24horasinternet/Login'
SUCCESS_URL = 'https://www.secure.itau.com.py/24horasinternet/'
LOGOUT_URL = 'https://www.secure.itau.com.py/24horasinternet/LogOff'

PRIMARY_ACCOUNT_URL = 'https://www.secure.itau.com.py/24horasinternet/Cuentas/Lista/_VerCuenta?nroCuenta=1&tipo=cc'

agent = Mechanize.new do |agent|
  agent.user_agent_alias = 'Mac Safari'
  agent.follow_meta_refresh = true
  agent.redirect_ok = true
end

agent.get( START_URL ) do |page|

  first_step_form = page.forms.last
  first_step_form.vcedula = CEDULA
  first_step_form.TipoIngreso = 'c'
  first_step_form.vcuenta = CUENTA

  second_step = first_step_form.submit()

  second_step_form = second_step.form_with( :id => 'login2_pin_access' ) do |form|
    form.InputValuePIN = Digest::MD5.hexdigest(PIN)
  end

  final_step = second_step_form.submit()

  if final_step.uri.to_s == SUCCESS_URL
    puts "Login OK"
  else
    raise "Authentication error?"
  end

  primary_account = agent.get(PRIMARY_ACCOUNT_URL)

  balance = primary_account.parser.xpath("//span[@class='valor valor_principal']").inner_text

  puts "Balance: #{balance}"

  puts "Logout"
  logout_page = agent.get(LOGOUT_URL)
  puts "URL: #{logout_page.uri}"

end
