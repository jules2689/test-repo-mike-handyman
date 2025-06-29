require "erb"
require "pathname"
require "yaml"
require "logger"

# This is a helper class to provide a binding context for rendering templates
# It allows us to access instance variables and methods in the templates
# without polluting the global namespace.
#
# The class also provides methods to load configuration and render templates.
# It uses ERB for template rendering and YAML for configuration loading.
class AbstractBinding
  attr_accessor :locals

  def initialize(templates, logger)
    @templates = templates
    @logger = logger
    @locals = {}
  end

  def root
    __dir__
  end

  def config
    @config ||= YAML.load_file(File.join(__dir__, "config.yaml"))
  end

  # Helper method to convert a path to a relative path from the root directory
  def path_relative_to_root(path)
    Pathname.new(path).relative_path_from(Pathname.new(__dir__))
  end

  # Helper method to render ERB templates with locals
  def render(template_name, locals = {})
    @logger.info("Rendering template: #{template_name} with locals: #{locals.inspect}")
    local_binding = AbstractBinding.new(@templates, @logger)
    local_binding.locals = locals

    if @templates.key?(template_name)
      @templates[template_name].result(local_binding.get_binding).to_s
    else
      raise "Template '#{template_name}' not found."
    end
  end

  # This method provides a binding context for the ERB templates
  def get_binding
    binding
  end
end

# Load all templates into a global hash for easy access.
templates = {}
logger = Logger.new(STDOUT)

# Load all ERB templates from the templates directory
logger.info("Loading templates from 'templates' directory...")
Dir.glob("templates/**/*.erb").each do |file|
  template_name = File.basename(file, ".erb")
  templates[template_name] = ERB.new(File.read(file), trim_mode: '-')
end

# Render the main template
logger.info("Rendering main template 'index.html.erb'...")
main_template = File.read("index.html.erb")

logger.info("Rendering 'index.html' with the main template...")
File.write("index.html", ERB.new(main_template, trim_mode: '-').result(AbstractBinding.new(templates, logger).get_binding))

logger.info("Rendering 'index.html' complete.")