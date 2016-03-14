require 'sdltm_importer/version'
require 'sqlite3'
require 'open-uri'
require 'pretty_strings'

module SdltmImporter
  class Tag
    attr_accessor :id, :content
    TAG_REGEX = /<TagID>(\d*)<\/TagID>/
    def initialize(tag, tag_content)
      @id = parse_tag_id tag
      @content = tag_content
    end

    def parse_tag_id(tags)
      tags[0].scan(TAG_REGEX).first
    end
  end

  class Sdltm
    TUV_TRANSLATION_REGEX = /<Elements><Text><Value>(.*)<\/Value><\/Text><\/Elements>/
    TUV_LANG_REGEX = /<CultureName>(.*)<\/CultureName>/
    TUV_TAGS_REGEX = /<Tag>(.*?)<\/Tag>/
    TUV_CONTENT_REGEX = /<\/Tag><Text><Value>(.*?)<\/Value><\/Text><Tag>/
    attr_reader :file_path
    def initialize(file_path:)
      @file_path = file_path
      @doc = {
        source_language: "",
        target_language: "",
        tu: { id: "", counter: 0, vals: [], creation_date: "" },
        seg: { lang: "", counter: 0, vals: [], role: "" },
        language_pairs: []
      }
    end

    def stats
      imported_data
      { tu_count: @doc[:tu][:vals].length, seg_count: @doc[:seg][:vals].length, language_pairs: @doc[:language_pairs] }
    end

    def import
      imported_data
      [@doc[:tu][:vals], @doc[:seg][:vals]]
    end

    private

    def imported_data
      @imported_data ||= import_data
    end

    def import_data
      db          = SQLite3::Database.new(open(file_path).path)
      data        = db.execute "Select * FROM translation_units"
      tus = []
      data.each do |segment|
        @doc[:tu][:id]             = [(1..4).map{rand(10)}.join(''), Time.now.to_i, @doc[:tu][:counter] += 1 ].join("-")
        @doc[:tu][:creation_date]  = iso_timestamp segment[7]
        @doc[:tu][:vals]           << [@doc[:tu][:id], @doc[:tu][:creation_date]]

        [4, 6].each do |i|
          language        = segment[i].scan(TUV_LANG_REGEX).flatten[0]
          tags            = create_tags(segment[i].scan(TUV_TAGS_REGEX), segment, i)
          segment_text    = PrettyStrings::Cleaner.new(parse_segment_text(segment, tags, i)).pretty.gsub("\\","&#92;").gsub("'",%q(\\\'))
          word_count      = segment_text.gsub("\s+", ' ').split(' ').length
          if i.eql?(4)
            @doc[:source_language] = language
            @doc[:seg][:role] = 'source'
          else
            @doc[:target_language] = language
            @doc[:seg][:role] = 'target'
            @doc[:language_pairs] << [@doc[:source_language], @doc[:target_language]]
            @doc[:language_pairs] = @doc[:language_pairs].uniq
          end
          @doc[:seg][:lang] = language
          @doc[:seg][:vals] << [@doc[:tu][:id], @doc[:seg][:role], word_count, @doc[:seg][:lang], segment_text, @doc[:tu][:creation_date]]
        end
      end
    end

    def iso_timestamp(timestamp)
      timestamp.delete('-').delete(':').sub(' ','T') + 'Z'
    end

    def parse_segment_text(segment, combined_tags, i)
      if combined_tags.nil? || combined_tags.empty?
        text = segment[i].scan(TUV_TRANSLATION_REGEX).flatten[0]
      else
        combined_tags.each_with_index do |tag, i|
          if i.eql?(0)
            if tag.content.nil? || tag.content.empty?
              text = ''
            else
              text = tag.content[0]
            end
          else
            unless tag.content.nil? || tag.content.empty?
              text = text + ' ' + tag.content[0]
            end
          end
        end
      end
      text
    end

    def create_tags(tags, segment, i)
      unless tags.empty?
        tags = tags.values_at(* tags.each_index.select { |i| i.even? })
        combined_tags = []
        content = segment[i].scan(TUV_CONTENT_REGEX)
        tags.zip(content) do |t, c|
          tag = Tag.new(t, c)
          combined_tags << tag
        end
      end
      combined_tags
    end
  end
end
