require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'erb'

# Database setup
DB = SQLite3::Database.new('quran-combined.db')
DB.results_as_hash = true

# Simple models
class Mushaf
  def self.find(id)
    DB.get_first_row('SELECT * FROM mushaf WHERE id = ?', [id])
  end
end

class MushafPage
  def self.for_page(mushaf_id, page_number)
    DB.execute('SELECT * FROM mushaf_pages WHERE mushaf_id = ? AND page_number = ? ORDER BY line_number',
               [mushaf_id, page_number])
  end
end

class Word
  def self.find_range(mushaf, first_id, last_id)
    return [] if first_id.nil? || last_id.nil? || first_id == '' || last_id == ''

    # Determine which column to use based on mushaf code
    text_column = case mushaf['code']
                  when 'qpc_v1' then 'qpc_v1'
                  when 'qpc_v2' then 'qpc_v2'
                  when 'indopak_nastaleeq_15' then 'indopak_nastaleeq_15'
                  else 'qpc_v1'
                  end

    DB.execute("SELECT *, #{text_column} as text FROM words WHERE id >= ? AND id <= ? ORDER BY id",
               [first_id, last_id])
  end
end

class Chapter
  def self.find(id)
    DB.get_first_row('SELECT * FROM chapters WHERE id = ?', [id])
  end
end

# Routes
get '/' do
  redirect '/mushaf/1/page/15'
end

get '/mushaf/:mushaf_id/page/:page_number' do
  @mushaf_id = params[:mushaf_id].to_i
  @page_number = params[:page_number].to_i
  @mushaf = Mushaf.find(@mushaf_id)
  @lines = MushafPage.for_page(@mushaf_id, @page_number)

  erb :page
end
