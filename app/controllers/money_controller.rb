class MoneyController < ApplicationController
  before_action :set_money, only: [:show, :edit, :update, :destroy]

  def index
    @money = current_user.moneys
    this_month_expenses
    prevent_month_expenses
  end

  def show
  end

  def new
    @money = Money.new
  end

  def edit
  end

  def create
    @money = Money.new(money_params)
      if @money.image.present?
        $moneyimage = @money
        
        redirect_to action: 'file'
      else
      respond_to do |format|
        if @money.save
          format.html { redirect_to @money, notice: 'Money was successfully created.' }
          format.json { render :show, status: :created, location: @money }
        else
          format.html { render :new }
          format.json { render json: @money.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @money.update(money_params)
        format.html { redirect_to @money, notice: 'Money was successfully updated.' }
        format.json { render :show, status: :ok, location: @money }
      else
        format.html { render :edit }
        format.json { render json: @money.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @money.destroy
    respond_to do |format|
      format.html { redirect_to money_index_url, notice: 'Money was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  def file
    require 'base64'
    require 'json'
    require 'net/https'

    image_file = "public#{$moneyimage.image.url}"
    api_key = ENV['GOOGLE_VISION_API_KEY']
    api_url = "https://vision.googleapis.com/v1/images:annotate?key=#{api_key}"
    base64_image = Base64.strict_encode64(File.new(image_file, 'rb').read)

    body = {
    requests: [{
      image: {
        content: base64_image
      },
      features: [
        {
          type: 'DOCUMENT_TEXT_DETECTION', 
          maxResults: 1
        }
      ]
    }]
    }.to_json

    uri = URI.parse(api_url)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)

    request["Content-Type"] = "application/json"
    response = https.request(request, body)
    @response_rb = JSON.parse(response.body)
    @description = @response_rb["responses"][0]["textAnnotations"][0]["description"]
    str = @description.match(/合計\d*\D*(\d\D*\d*)/)
    num = str[1]
    num1 = num.gsub(/(\d{0,3}),(\d{3})/, '\1\2')
    @num = num1.to_i
    @money = Money.new
    @money.expenses = @num
  end

  private
    def set_money
      @money = Money.find(params[:id])
    end

    def money_params
      params.require(:money).permit(:expenses, :image, :tag_id).merge(user_id:current_user.id)
    end

    def total_expenses
      sum = 0 
      @money.each do |money|
        sum += money.expenses
      end
        return sum
    end

    def this_month_expenses
      @this_month_data = []
      @this_month_sum = 0
      this_month = Date.today.all_month # all_monthをDate.todayに適用すると、今月の年月日データを取得できる。
      @money.each do |money| 
        if (this_month.include?(Date.parse(money[:created_at].to_s)))
          # 今月の日にちの中にhoge[:created_at]の年月日が含まれていれば、trueを返す。
          @this_month_data << money
          @this_month_sum += money.expenses
        end
      end
    end

    def prevent_month_expenses
      @prevent_month_data = []
      @prevent_month_sum = 0
      @prevent_month_data = @money.where(created_at: Time.now.prev_month.beginning_of_month..Time.now.prev_month.end_of_month)
      @prevent_month_data.each do |money|
        @prevent_month_sum += money.expenses
      end
    end
end
