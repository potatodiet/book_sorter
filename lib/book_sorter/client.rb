require 'httparty'
require 'nokogiri'

module BookSorter
  class Client
    ORGANIZED_DIR = 'Books/'

    def initialize(book_path)
      book_file = File.basename(book_path)
      title = File.basename(book_path, '.*')

      if Dir["#{ORGANIZED_DIR}**/*"].any? { |file| file.include?(book_file) }
        puts 'Book is already sorted'
        #return
      end

      details = Client.book_details(title: title)
      wordings = Client.dewey_to_text(details[:dewey_code])
      dewey_codes = Client.split_dewey('513.54')

      dst_path = Client.gen_path(dewey_codes, wordings, details[:authors])
      FileUtils.mkpath(dst_path)

      puts "Copying to: #{dst_path}"
      FileUtils.cp(book_path, dst_path)
    end

    def self.book_details(params)
      params[:maxRecs] = 1
      response = HTTParty.get(
        'http://classify.oclc.org/classify2/Classify', query: params
      ).body
      xml = Nokogiri::XML(response)

      status = xml.at_css('response').attr('code').to_i
      case status
      when 0, 2
        dewey_code = xml.at_css('mostPopular').attr('sfa')

        authors = xml.css('author').map(&:text).map do |author|
          unless author.include?('Illustrator')
            author.split('[', 2).first.strip
          end
        end.compact

        { dewey_code: dewey_code, authors: authors }
      when 4
        stdnbr = xml.at_css('work').attr('wi')
        book_details(stdnbr: stdnbr)
      else
        raise "oclc responded with the following unexpected code: #{status}"
      end
    end

    def self.dewey_to_text(dewey_code)
      response = HTTParty.get(
        "https://www.librarything.com/mds/#{dewey_code}"
      ).body
      xml = Nokogiri::XML(response)

      xml.at_css('h2').css('a').map(&:text).map do |wording|
        break if wording == 'Not set'
        wording
      end
    end

    def self.split_dewey(dewey_code)
      (0..dewey_code.length - 1).map do |i|
        dewey_code[0..i].ljust(3, '0')
      end.reject { |el| el.chars.last == '.' }
    end

    def self.gen_path(dewey_codes, wordings, authors)
      path = ORGANIZED_DIR

      dewey_codes.zip(wordings).each do |code, wording|
        already_exists = false

        # Enables users to rename directories, without being overwritten.
        already_exists, existing_name = already_exists?(code, path)

        if already_exists
          path += existing_name
        else
          path += "#{code} - #{wording}/"
        end
      end

      path + authors.sort.join(' & ')
    end

    def self.already_exists?(dewey_code, path)
      Dir["#{path}*/"].each do |sub_path|
        existing_name = sub_path.chomp('/').rpartition('/').last + '/'
        if existing_name.split(' -', 2).first == dewey_code
          return [true, existing_name]
        end
      end

      [false, '']
    end
  end
end
