require "logger"
logger = Logger.new(STDOUT)

base_dir = __dir__
Dir.chdir(base_dir) do
  Dir.glob("assets/img/slideshow/*.{jpg,png,jpeg}").each do |image_path|
    logger.info("Optimizing image: #{image_path}")

    # Remove all metadata from the image
    logger.info("Removing metadata from image: #{image_path}")
    system("exiftool -all= #{image_path} -overwrite_original")

    image_width = `identify -format "%w" "#{image_path}"`.strip.to_i
    image_height = `identify -format "%h" "#{image_path}"`.strip.to_i

    extra_flags = ""

    # Resize the image if it exceeds 1500 pixels in width or height
    if image_width > 1500
      logger.info("Resizing image width from #{image_width} to 1500 pixels")
      extra_flags += " -resize 1500x'"
    elsif image_height > 1500
      logger.info("Resizing image height from #{image_height} to 1500 pixels")
      extra_flags += " -resize 'x1500'"
    end

    # Optimize the image using ImageMagick
    logger.info("Optimizing image: #{image_path} with flags: #{extra_flags}")
    system("magick '#{image_path}' -strip -quality 85 #{extra_flags} '#{image_path}'")
  end
end
