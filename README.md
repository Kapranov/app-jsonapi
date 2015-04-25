# Демо версия для проверки работы пакета JSONAPI-Resources

Реализация простого веб приложения в виде API который следует правилам JSON API spec.
Клиентскую часть для этого API будет реализовано позже, будущий frontend будет написан
на Ember.js (MVC Framework).

Краткая инсткрукция как создавался Backend этого приложения.
Чтобы продеманстрировать возможности JSON API spec.


bash> rails new jsonapi-resources-demo --skip-javascript

### Создания базы
bash> rake db:create

### Добавление пакета JSONAPI-Resources
bash> cat >> Gemfile
gem 'jsonapi-resources'

### Затем сборка
bash> bundle install

### Меняем в application_controller.rb  на JSONAPI::ResourceController
class ApplicationController < JSONAPI::ResourceController
  protect_from_forgery with: :null_session
end

### Редактируем файл config/environments/development.rb
  config.eager_load = true
  config.consider_all_requests_local = false

### Создаем модель
bash> rails g model Contact name_first:string name_last:string email:string twitter:string

### Редактируем модель
class Contact < ActiveRecord::Base
  has_many :phone_numbers

  ### Validations
  validates :name_first, presence: true
  validates :name_last, presence: true

end

bash> rails g model PhoneNumber contact_id:integer name:string phone_number:string

class PhoneNumber < ActiveRecord::Base
  belongs_to :contact
end

### Затем миграция
bash> rake db:migrate

### Создаем контролеры
bash> rails g controller Contacts --skip-assets
bash> rails g controller PhoneNumbers --skip-assets

### Создаем директорию с названием resources

bash> mkdir app/resources

### Создаем ресурсы

contact_resource.rb
phone_number_resource.rb


class ContactResource < JSONAPI::Resource
  attributes :name_first, :name_last, :email, :twitter
  has_many :phone_numbers
end

class PhoneNumberResource < JSONAPI::Resource
  attributes :name, :phone_number
  has_one :contact

  filter :contact
end

### Настраиваем маршрутизацию

jsonapi_resources :contacts
jsonapi_resources :phone_numbers

## Запускаем приложения

bash> rails server

### Создаем новый контакт frontend пока нет будем использовать Curl

bash> curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"contacts", "name-first":"Oleg", "name-last":"Kapranov", "email":"lugatex@yahoo.com"}}' http://212.26.132.49:2274/contacts

И мы должны увидеть что то в этом роде:

HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
ETag: W/"c96e63cdd31da0722c421f46514c46a4"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 6d2a34f2-8dd9-4c6d-8a84-c2e950b0d7b5
X-Runtime: 0.234775
Transfer-Encoding: chunked

{"data":{"id":"1","name-first":"Oleg","name-last":"Kapranov","email":"lugatex@yahoo.com","twitter":null,"type":"contacts","links":{"self":"http://212.26.132.49:2274/contacts/1","phone-numbers":{"self":"http://212.26.132.49:2274/contacts/1/links/phone-numbers","related":"http://212.26.132.49:2274/contacts/1/phone-numbers"}}}}

### Теперь создадим для этого контакта номер телефона
bash> curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"phone-numbers", "links": {"contact": {"linkage": {"type": "contacts", "id":"1"}}}, "name":"cellphone", "phone-number":"(380) 99-717-06-09"}}' "http://212.26.132.49:2274/phone-numbers"

И снова увидем что то в этом роде:

HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
ETag: W/"902552b7ff263e38fe6321ef057b74da"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: e6e02771-31e0-47d8-ae1b-ed96a81aef5a
X-Runtime: 0.030659
Transfer-Encoding: chunked

{"data":{"id":"1","name":"cellphone","phone-number":"(380) 99-717-06-09","type":"phone-numbers","links":{"self":"http://212.26.132.49:2274/phone-numbers/1","contact":{"self":"http://212.26.132.49:2274/phone-numbers/1/links/contact","related":"http://212.26.132.49:2274/phone-numbers/1/contact","linkage":{"type":"contacts","id":"1"}}}}}

### Теперь мы можем запросить все данные

bash> curl -i -H "Accept: application/vnd.api+json" "http://212.26.132.49:2274/contacts"

И увидем результат:

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
ETag: W/"e7ef07d165a14b5617cc362e6f79b298"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: fc6206d0-e08e-4292-bfeb-8539bde53ce0
X-Runtime: 0.006662
Transfer-Encoding: chunked

{"data":[{"id":"1","name-first":"Oleg","name-last":"Kapranov","email":"lugatex@yahoo.com","twitter":null,"type":"contacts","links":{"self":"http://212.26.132.49:2274/contacts/1","phone-numbers":{"self":"http://212.26.132.49:2274/contacts/1/links/phone-numbers","related":"http://212.26.132.49:2274/contacts/1/phone-numbers"}}}]}

Напомню что поле phone_number id включено в links, но не в общем описании, его можно получить через запрос:

bash> curl -i -H "Accept: application/vnd.api+json" "http://212.26.132.49:2274/contacts?include=phone-numbers"

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
ETag: W/"159da2c3fa7ae98ab9bcc634f1b76523"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 65680c49-fb3b-4222-b9f7-e9178596217b
X-Runtime: 0.028035
Transfer-Encoding: chunked

{"data":[{"id":"1","name-first":"Oleg","name-last":"Kapranov","email":"lugatex@yahoo.com","twitter":null,"type":"contacts","links":{"self":"http://212.26.132.49:2274/contacts/1","phone-numbers":{"self":"http://212.26.132.49:2274/contacts/1/links/phone-numbers","related":"http://212.26.132.49:2274/contacts/1/phone-numbers","linkage":[{"type":"phone-numbers","id":"1"}]}}}],"included":[{"id":"1","name":"cellphone","phone-number":"(380) 99-717-06-09","type":"phone-numbers","links":{"self":"http://212.26.132.49:2274/phone-numbers/1","contact":{"self":"http://212.26.132.49:2274/phone-numbers/1/links/contact","related":"http://212.26.132.49:2274/phone-numbers/1/contact","linkage":{"type":"contacts","id":"1"}}}}]}

И другие поля:

bash> curl -i -H "Accept: application/vnd.api+json" "http://212.26.132.49:2274/contacts?include=phone-numbers&fields%5Bcontacts%5D=name-first,name-last&fields%5Bphone-numbers%5D=name"

HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
ETag: W/"ac33e0d36dc8ffa5cd86fdb972a0534e"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 39c8232c-1ed0-4a5f-9ac3-23bb4910ebab
X-Runtime: 0.009657
Transfer-Encoding: chunked

{"data":[{"name-first":"Oleg","name-last":"Kapranov","type":"contacts","id":"1","links":{"self":"http://212.26.132.49:2274/contacts/1"}}],"included":[{"name":"cellphone","type":"phone-numbers","id":"1","links":{"self":"http://212.26.132.49:2274/phone-numbers/1"}}]}

### Проверка validation Error

bash> curl -i -H "Accept: application/vnd.api+json" -H 'Content-Type:application/vnd.api+json' -X POST -d '{"data": {"type":"contacts", "name-first":"Oleg Kapranov", "email":"lugatex@yahoo.com"}}' http://212.26.132.49:2274/contacts

HTTP/1.1 422 Unprocessable Entity
X-Frame-Options: SAMEORIGIN
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/vnd.api+json
Cache-Control: no-cache
X-Request-Id: e9bf8d98-eb57-4b40-84c6-5692f9affe10
X-Runtime: 0.015617
Transfer-Encoding: chunked

{"errors":[{"title":"name_last - can't be blank","detail":"can't be blank","id":null,"href":null,"code":100,"path":"/name_last","links":null,"status":"unprocessable_entity"}]}

### Конец

# Создание Frontend (Ember.js) для этого сервиса.

### 24 April 2015 Oleg G.Kapranov
