class MoneyController < ApplicationController
  before_action :set_money, only: [:show, :edit, :update, :destroy]

  def index
    @money = current_user.moneys
    this_month_expenses
    prevent_month_expenses
    tag_sum
    @pie = {"#{Tag.find(1).tag}" => @tag1, "#{Tag.find(2).tag}" => @tag2, "#{Tag.find(3).tag}" => @tag3, "#{Tag.find(4).tag}" => @tag4, "#{Tag.find(5).tag}" => @tag5}
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
          format.html { redirect_to money_index_url, notice: ' 登録しました。' }
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
      format.html { redirect_to money_index_url, notice: '削除しました.' }
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
    if str.nil?
      redirect_to new_money_path, notice: ' 解析に失敗しました。他の画像で試してください。' 
    else
    num = str[1]
    num1 = num.gsub(/(\d{0,3}),(\d{3})/, '\1\2')
    @num = num1.to_i
    @money = Money.new
    @money.expenses = @num
    end
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

    def tag_sum
      tag1,tag2,tag3,tag4,tag5 = 0, 0, 0, 0, 0
      @money.each do |money|
        if money.tag_id == 1 
          tag1 += money.expenses
        elsif money.tag_id == 2
          tag2 += money.expenses
        elsif money.tag_id == 3
          tag3 += money.expenses
        elsif money.tag_id == 4
          tag4 += money.expenses
        else 
          tag5 += money.expenses
        end
      end
      tag_sum = tag1 + tag2 + tag3 + tag4 + tag5
      @tag1 = (tag1 * 1000)/tag_sum
      @tag2 = (tag2 * 1000)/tag_sum
      @tag3 = (tag3 * 1000)/tag_sum
      @tag4 = (tag4 * 1000)/tag_sum
      @tag5 = (tag5 * 1000)/tag_sum
    end

end
