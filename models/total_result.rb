# coding: utf-8
module ROGv
  class TotalResult
    include MongoMapper::Document

    key  :gv_dates,    Array,  :required => true
    key  :guild_names, Array,  :required => true
    many :guilds, :class_name => 'ROGv::GuildResult'
    timestamps!

    class << self

      def totalize(span = nil)
        span ||= ServerConfig.result_size
        dates = WeeklyResult.date_list.sort.reverse.take(span)

        total = self.new
        dates.each{|d| total.add_result(d)}

        total.gv_dates = dates.sort.reverse
        total.guilds = total.guilds.sort_by(&:called_count).reverse
        total.guilds.each{|g| g.gv_date = nil}
        total.guild_names = total.guilds.map(&:name)

        total
      end

      def totalize!(span = nil)
        total = totalize(span)
        return unless total

        self.all.each(&:destroy)
        total.save!
        total
      end

    end

    def add_result(d)
      wr = WeeklyResult.for_date(d)
      return unless wr

      wr.guilds.each do |wrg|
        trg = self.guilds.to_a.find{|g| g.name == wrg.name}
        trg ? trg.add_result(wrg) : (self.guilds << wrg.dup)
      end

      self
    end

  end
end
