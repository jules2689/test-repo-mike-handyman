require "erb"
require "pathname"

# Load all templates
$templates = {}
root = __dir__

def render(template_name, locals = {})
  # Check if the template exists in the loaded templates
  if $templates.key?(template_name)
    $templates[template_name]
  else
    raise "Template '#{template_name}' not found."
  end
end

def path_relative_to_root(path)
  # Convert the given path to a relative path from the root directory
  Pathname.new(path).relative_path_from(Pathname.new(__dir__))
end

Dir.glob("templates/**/*.erb").each do |file|
    template_name = File.basename(file, ".erb")
    $templates[template_name] = ERB.new(File.read(file), trim_mode: '-').result(binding)
end

# Render the main template
main_template = File.read("index.html.erb")
File.write("index.html", ERB.new(main_template, trim_mode: '-').result(binding))