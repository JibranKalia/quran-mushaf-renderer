require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'erb'

configure do
  set :server, 'webrick'
  set :bind, '0.0.0.0'
  set :port, ENV.fetch('PORT', 4567).to_i
  set :environment, ENV.fetch('RACK_ENV', 'production').to_sym
end

# Database Configuration
DB = SQLite3::Database.new('quran-combined.db')
DB.results_as_hash = true

# Models
class Mushaf
  def self.find(id)
    DB.get_first_row('SELECT * FROM mushafs WHERE id = ?', [id])
  end
end

class MushafPage
  def self.for_page(mushaf_id, page_number)
    DB.execute(
      'SELECT * FROM mushaf_pages WHERE mushaf_id = ? AND page_number = ? ORDER BY line_number',
      [mushaf_id, page_number]
    )
  end
end

class Word
  def self.find_range(mushaf, first_id, last_id)
    return [] if first_id.to_s.empty? || last_id.to_s.empty?

    text_column = get_text_column(mushaf['code'])

    DB.execute(
      "SELECT *, #{text_column} as text FROM words WHERE id >= ? AND id <= ? ORDER BY id",
      [first_id, last_id]
    )
  end

  private

  def self.get_text_column(mushaf_code)
    case mushaf_code
    when 'qpc_v1' then 'qpc_v1'
    when 'qpc_v2' then 'qpc_v2'
    when 'indopak_nastaleeq_15' then 'indopak_nastaleeq_15'
    else 'qpc_v1'
    end
  end
end

class Chapter
  def self.find(id)
    DB.get_first_row('SELECT * FROM chapters WHERE id = ?', [id])
  end
end

# View Models
class PageViewModel
  attr_reader :mushaf_id, :page_number, :mushaf, :lines

  def initialize(mushaf_id, page_number)
    @mushaf_id = mushaf_id
    @page_number = page_number
    @mushaf = Mushaf.find(mushaf_id)
    @lines = prepare_lines
  end

  def next_page
    page_number + 1
  end

  def prev_page
    page_number - 1
  end

  private

  def prepare_lines
    raw_lines = MushafPage.for_page(mushaf_id, page_number)

    raw_lines.map do |line|
      LineViewModel.new(line, mushaf)
    end
  end
end

class LineViewModel
  attr_reader :number, :type, :is_centered, :data

  def initialize(line, mushaf)
    @number = line['line_number']
    @type = line['line_type']
    @is_centered = line['is_centered'] == 1
    @data = prepare_data(line, mushaf)
  end

  def css_classes
    classes = ['line']
    classes << 'line--center' if is_centered
    classes << "line--#{type.gsub('_', '-')}" if type
    classes.join(' ')
  end

  private

  def prepare_data(line, mushaf)
    case type
    when 'surah_name'
      prepare_surah_data(line)
    when 'basmallah'
      { text: '﷽' }
    when 'ayah'
      prepare_ayah_data(line, mushaf)
    else
      {}
    end
  end

  def prepare_surah_data(line)
    return {} unless line['surah_number']

    chapter = Chapter.find(line['surah_number'])
    return {} unless chapter

    {
      number: line['surah_number'],
      formatted_number: "surah#{line['surah_number'].to_s.rjust(3, '0')}",
      chapter: chapter
    }
  end

  def prepare_ayah_data(line, mushaf)
    words = Word.find_range(mushaf, line['first_word_id'], line['last_word_id'])

    # Group words by ayah
    ayahs = []
    current_ayah = nil
    current_words = []

    words.each do |word|
      if word['ayah'] != current_ayah
        if current_ayah
          ayahs << {
            surah: word['surah'],
            ayah: current_ayah,
            words: current_words
          }
        end
        current_ayah = word['ayah']
        current_words = []
      end

      current_words << {
        id: word['id'],
        text: word['text'],
        location: word['location'],
        is_end: word['text']&.match?(/\u06DD/)
      }
    end

    # Don't forget the last ayah
    if current_ayah && !current_words.empty?
      ayahs << {
        surah: words.last['surah'],
        ayah: current_ayah,
        words: current_words
      }
    end

    { ayahs: ayahs }
  end
end

# Routes
get '/health' do
  # Simple health check - verify database connection

  DB.execute('SELECT 1')
  status 200
  body 'OK'
rescue StandardError => e
  status 503
  body "Database connection failed: #{e.message}"
end

get '/' do
  redirect '/mushaf/1/page/1'
end

get '/mushaf/:mushaf_id/page/:page_number' do
  mushaf_id = params[:mushaf_id].to_i
  page_number = params[:page_number].to_i

  # Basic validation
  mushaf = Mushaf.find(mushaf_id)
  if mushaf.nil?
    status 404
    return 'Mushaf not found'
  end

  if page_number < 1 || page_number > mushaf['pages_count']
    status 404
    return 'Page not found'
  end

  @page_data = PageViewModel.new(mushaf_id, page_number)
  erb :page
end
