require 'rack'

class Rack::Maintenance

  attr_reader :app, :options

  def initialize(app, options={})
    @app     = app
    @options = options

    raise(ArgumentError, 'Must specify a :file') unless options[:file]
  end

  def call(env)
    if maintenance? && path_in_app(env)
      data = File.read(file)
      [ status_code, { 'Content-Type' => content_type, 'Content-Length' => data.length.to_s }, [data] ]
    else
      app.call(env)
    end
  end

  private

  def content_type
    file.end_with?('json') ? 'application/json' : 'text/html'
  end

  def environment
    options[:env]
  end

  def file
    options[:file]
  end

  def maintenance?
    environment ? ENV[environment] : File.exists?(file)
  end

  def path_in_app(env)
    env["PATH_INFO"] !~ /^\/assets/
  end

  def status_code
    options[:status_code] || 503
  end
end
