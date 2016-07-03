require 'mechanize'
require 'digest/md5'

CEDULA = '1231234'
CUENTA = '0000'
PIN = '123456'

agent = Mechanize.new do |agent|
  agent.user_agent_alias = 'Mac Safari'
  agent.follow_meta_refresh = true
  agent.redirect_ok = true
end

agent.get('https://www.secure.itau.com.py/24horasinternet/Login') do |page|

  first_step_form = page.forms.last
  first_step_form.vcedula = CEDULA
  first_step_form.TipoIngreso = 'c'
  first_step_form.vcuenta = CUENTA

  second_step = first_step_form.submit()

  second_step_form = second_step.form_with( :id => 'login2_pin_access' ) do |form|
    form.InputValuePIN = Digest::MD5.hexdigest(PIN)
  end

  final_step = second_step_form.submit()
  p final_step.uri
end
