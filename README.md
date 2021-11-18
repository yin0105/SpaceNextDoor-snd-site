# Space Next Door

===

The SND Project

## Requirement

* Linux or macOS
* Ruby 2.6+
* PostgreSQL 9.5+
* Redis
* Node.js 12+

### Backing Services

* Google APIs (`GOOGLE_API_KEY`, `GOOGLE_FRONTEND_API_KEY` env)
  * Google Maps JavaScript API
  * Google Maps Geocoding API
* Stripe
* Twilio
* Facebook

## Setup Rails

Create database config.

```bash
$ cp config/database.yml.example config/database.yml
$ vim config/database.yml
```

Create dotenv environment config.

```bash
$ cp .env.example .env
$ vim .env
```

Update `config/settings.yml` if necessary.

Prepare database for rails.

```bash
$ bundle exec rake db:create
$ bundle exec rake db:migrate
```

Start rails server.

```bash
$ rails server
```

## yarn install

```bash
yarn install
# if need
yarn global add mjml@^4.6.3
```

## front-end server

```bash
./bin/webpack-dev-server
```

### Foreman

To enable sidekiq and other services, use Procfile to start services is better then open multiple console to start it.

Install Foreman

```bash
$ gem install foreman
```

If use `rbenv-bundle-exec` add `foreman` into `.no_bundle_exec` file.

```bash
$ echo foreman >> ~/.no_bundle_exec
```

Start All services.

```bash
$ foreman start
```

## Setup StyleGuide

To enable editable styleguide, below is required.

* Node.js 12.0+
* Rails ready environment

First, setup rails let it ready.

```bash
$ bundle install
$ bundle exec rake db:create
$ bundle exec rake db:migrate
```

Next, install required node.js packages.

```bash
$ bundle exec rake assets:install
$ bundle exec rake styleguide:setup
```

And now, start rails and styleguide api server.

```bash
$ rails server
$ bundle exec rake styleguide:start
```

Access `http://yordomain/styleguide/` and start create styleguide.

## Rubocop

### Frozen String

Due to new Ruby feature, the rubocop suggest enable `frozen string literal` feature.
But the Rails didn't add the options by default. So, the helper task can help us do this.

```bash
$ bundle exec rake syntax:frozen
```

## ESLint

Rails working with ESLint has many details, below will listed the relative rules.

### Add `core-modules`

If add JavaScript library into `vendor/assets/javascript` or install by gem, and required to use `import` to include it.
You can edit `.eslint.json` and add new element into `import/core-modules` array to ignore check dependency inside `package.json`.

```json
"settings": {
  "import/core-modules": [ "flatpickr" ]
}
```

### Configure `globals` variable

If use sprockets' `//= require` to add JavaScript library, the global will cause ESLint raise an error.
To fix this, you can edit `.eslint.json` and add new element into `globals` to register it.

```json
"globals": {
  "Stripe": true
}
```

## Capybara

The feature test is use PhantomJS as driver, please install PhantomJS before running feature test.

```
brew install phantomjs
```

## Usage

### Create Admin

The belowing command will create an admin user `admin@example.com` and generate a random password:

```bash
$ rake admin:create[admin@example.com]
```

### Run Robocop

```bash
$ bundle exec rubocop
```

### Run ESLint

```bash
$ yarn eslint
```

### Run SCSSLint

```bash
$ bundle exec scss-lint
```
