# coding: utf-8
module ROGv
  class WeeklyResult
    include MongoMapper::Document
    include TimeUtil
    include FortUtil

    key  :gv_date,     String, :required => true
    many :guilds, :class_name => 'ROGv::GuildResult'
    many :forts,  :class_name => 'ROGv::Fort'
    timestamps!
    ensure_index :gv_date

    class << self

      def date_list
        self.sort(:gv_date.desc).fields(:gv_date).map(&:gv_date)
      end

      def for_date(d)
        self.where(:gv_date => d).first
      end

      def latest
        self.sort(:gv_date.desc).first
      end

      def convert(rsl)
        return if rsl.nil? || rsl.empty?
        gdate = rsl['gv_date']
        return if gdate.nil? || gdate.empty?

        wr = self.new
        wr.gv_date = gdate
        wr.forts = rsl['forts'].map{|fr| Fort.convert_result(fr)}
        wr.guilds = rsl['guilds'].map{|gr| GuildResult.convert_result(gr)}
        return if wr.forts.empty? || wr.guilds.empty?

        wr
      end

      def convert!(rsl)
        wr = convert(rsl)
        return unless wr

        # remove old data
        self.where(:gv_date => wr.gv_date).each(&:destroy)

        wr.save!
        wr
      end

      def compact!(size = nil)
        size ||= ServerConfig.result_size
        return false if size < 1

        dlist = self.date_list.dup.sort.reverse
        size.times{ dlist.shift }
        return true if dlist.empty?
        dlist.each{|d| self.where(:gv_date => d).each(&:destroy) }

        true
      end

    end

    def forts_map
      @forts_map ||= lambda do
        next {} unless (forts && !forts.empty?)
        forts.inject({}){|h, f| h[f.fort_id] = f;h}
      end.call
      @forts_map
    end

    def guild_map
      @guild_map ||= lambda do
        next {} unless (guilds && !guilds.empty?)
        guilds.inject({}){|h, g| h[g.name] = g;h}
      end.call
      @guild_map
    end

    def before
      date = self.class.date_list.select{|d| d < self.gv_date}.sort.last
      return unless date
      self.class.for_date(date)
    end

    def after
      date = self.class.date_list.select{|d| d > self.gv_date}.sort.first
      return unless date
      self.class.for_date(date)
    end

  end
end
