# coding: utf-8
module ROGv
  class Fort
    include MongoMapper::EmbeddedDocument

    key :fort_id,     String, :required => true
    key :fort_name,   String, :required => true
    key :formal_name, String, :required => true
    key :guild_name,  String, :required => true

    class << self

      def convert_result(fr)
        return if fr.nil? || fr.empty?

        f = Fort.new
        f.fort_id = fr['fort_id']
        f.fort_name = fr['fort_name']
        f.formal_name = fr['formal_name']
        f.guild_name = fr['guild_name']
        f
      end

    end

  end
end
