require "erb"
require "pathname"
require "yaml"

class AbstractBinding
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
    puts "Rendering template: #{template_name} with locals: #{locals.inspect}"
    local_binding = AbstractBinding.new
    local_binding.locals = locals

    if $templates.key?(template_name)
      $templates[template_name].result(local_binding.get_binding).to_s
    else
      raise "Template '#{template_name}' not found."
    end
  end

  def get_binding
    binding
  end

  attr_accessor :locals
end

# Load all templates
$templates = {}

# Load all ERB templates from the templates directory
Dir.glob("templates/**/*.erb").each do |file|
  template_name = File.basename(file, ".erb")
  $templates[template_name] = ERB.new(File.read(file), trim_mode: '-')
end

# Render the main template
main_template = File.read("index.html.erb")
File.write("index.html", ERB.new(main_template, trim_mode: '-').result(AbstractBinding.new.get_binding))