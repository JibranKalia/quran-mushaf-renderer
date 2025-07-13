# app.rb
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'erb'

# Database Configuration
DB = SQLite3::Database.new('quran-combined.db')
DB.results_as_hash = true

# Models
class Mushaf
  def self.find(id)
    DB.get_first_row('SELECT * FROM mushaf WHERE id = ?', [id])
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

# Routes
get '/' do
  redirect '/mushaf/1/page/1'
end

get '/mushaf/:mushaf_id/page/:page_number' do
  @mushaf_id = params[:mushaf_id].to_i
  @page_number = params[:page_number].to_i
  @mushaf = Mushaf.find(@mushaf_id)
  @lines = MushafPage.for_page(@mushaf_id, @page_number)

  erb :page
end
