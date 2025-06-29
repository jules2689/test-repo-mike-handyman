require "logger"
logger = Logger.new(STDOUT)

base_dir = __dir__
Dir.chdir(base_dir) do

  total_saved = 0
  total_slideshow_size = 0
  Dir.glob("assets/img/slideshow/*.{jpg,png,jpeg}").each do |image_path|
    logger.info("Optimizing image: #{image_path}")
    original_file_size = File.size(image_path)

    # Remove all metadata from the image
    logger.info("Removing metadata from image: #{image_path}")
    system("exiftool -all= #{image_path} -overwrite_original")

    image_width = `magick identify -format "%w" "#{image_path}"`.strip.to_i
    image_height = `magick identify -format "%h" "#{image_path}"`.strip.to_i

    extra_flags = ""

    # Resize the image if it exceeds 1500 pixels in width or height
    if image_width > 1500
      logger.info("Resizing image width from #{image_width} to 1500 pixels")
      extra_flags += " -resize '1500x'"
    elsif image_height > 1500
      logger.info("Resizing image height from #{image_height} to 1500 pixels")
      extra_flags += " -resize 'x1500'"
    end

    # Optimize the image using ImageMagick
    logger.info("Optimizing image: #{image_path} with flags: #{extra_flags}")
    system("magick '#{image_path}' -strip -quality 80 #{extra_flags} '#{image_path}'")

    # Output results
    file_size = File.size(image_path)
    reduction_bytes = original_file_size - file_size
    reduction_kb = reduction_bytes / 1024.0
    total_saved += reduction_kb
    total_slideshow_size += file_size
    puts "Optimized image size: #{file_size} bytes, original size: #{original_file_size} bytes. Reduced by #{reduction_kb} KB."
  end

  logger.info("Total space saved by image optimizations: #{total_saved.round(2)} KB")
  logger.info("Total size of slideshow images: #{total_slideshow_size / 1024.0} KB")
end
