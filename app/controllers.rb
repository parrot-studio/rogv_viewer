# coding: utf-8
module ROGv
  ROGv::Viewer.controllers  do

    before :except => :update do
      @dates = result_dates
    end

    get :index do
      get_with_cache("index_view") do
        @result = TotalResult.first || TotalResult.new
        @weeks = {}
        @result.gv_dates.each do |d|
          @weeks[d] = (WeeklyResult.for_date(d) || WeeklyResult.new)
        end
        render :index
      end
    end

    get :result, :with => :date do
      date_action do |date|
        get_with_cache("result_view_for_#{date}") do
          @result = WeeklyResult.for_date(date)
          render :result
        end
      end
    end

    get :call, :with => :date do
      date_action do |date|
        get_with_cache("call_view_for_#{date}") do
          @result = WeeklyResult.for_date(date)
          render :call
        end
      end
    end

    get :about do
      render :about
    end

    post :update do
      post_action do
        rsl = params[:result]
        halt 400 if rsl.nil? || rsl.empty?

        wr = WeeklyResult.convert!(JSON.parse(rsl))
        halt 400 unless wr
        WeeklyResult.compact!
        TotalResult.totalize!
        expire_all_cache

        204
      end
    end

  end
end
