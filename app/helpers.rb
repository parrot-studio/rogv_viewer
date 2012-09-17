# coding: utf-8
module ROGv
  ROGv::Viewer.helpers do
    include TimeUtil
    include FortUtil

    def each_rankers_for_view(total, max_rank = nil)
      return unless total
      count = nil
      rank = 1
      total.guilds.sort_by(&:called_count).reverse.each.with_index(1) do |g, i|
        cc = g.called_count
        count ||= cc
        if count > cc
          rank = i
          count = cc
        end
        break if max_rank && max_rank < rank
        yield((rank == i ? rank : '-'), g.name, cc)
      end
    end

  end
end
