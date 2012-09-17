# coding: utf-8
module ROGv
  class GuildResult
    include MongoMapper::EmbeddedDocument
    include FortUtil

    key :name,    String, :required => true
    key :gv_date, String
    key :called,  Hash,   :required => true

    class << self

      def convert_result(gr)
        return if gr.nil? || gr.empty?
        name = gr['name']
        return if name.nil? || name.empty?

        g = self.new
        g.name = name
        g.gv_date = gr['gv_date']

        org = gr['called']
        fe = org.select{|k, v| FortUtil::fort_types_fe?(k)}.values.sum
        se = org.select{|k, v| FortUtil::fort_types_se?(k)}.values.sum
        g.called = {'fe' => fe, 'se' => se}

        g
      end

    end

    def called_count_fe
      self.called['fe'] || 0
    end

    def called_count_se
      self.called['se'] || 0
    end

    def called_count
      called_count_fe + called_count_se
    end

    def add_result(g)
      self.called = merge_result(self.called, g.called)
      self
    end

    private

    def merge_result(org, add)
      keys = [org.keys, add.keys].flatten.uniq.compact
      rsl = {}
      keys.each do |f|
        rsl[f] = org[f].to_i + add[f].to_i
      end
      rsl
    end

  end
end
