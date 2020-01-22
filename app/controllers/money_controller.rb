class MoneyController < ApplicationController
  before_action :set_money, only: [:show, :edit, :update, :destroy]

  # GET /money
  # GET /money.json
  def index
    @money = current_user.moneys
    @sum = total_expenses
  end

  # GET /money/1
  # GET /money/1.json
  def show
  end

  # GET /money/new
  def new
    @money = Money.new
  end

  # GET /money/1/edit
  def edit
  end

  # POST /money
  # POST /money.json
  def create
    @money = Money.new(money_params)
    
      if @money.image
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

  # PATCH/PUT /money/1
  # PATCH/PUT /money/1.json
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

  # DELETE /money/1
  # DELETE /money/1.json
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
# image_file = "app/assets/images/98994102fd19907905fbf84d8fc3fa88.png"
# IMAGE_FILE = ARGV[0]

api_key = ENV['GOOGLE_VISION_API_KEY']
api_url = "https://vision.googleapis.com/v1/images:annotate?key=#{api_key}"
# API_KEY = ENV['GOOGLE_VISION_API_KEY']
# API_URL = "https://vision.googleapis.com/v1/images:annotate?key=#{API_KEY}"


base64_image = Base64.strict_encode64(File.new(image_file, 'rb').read)
# base64_image = Base64.strict_encode64(File.new(IMAGE_FILE, 'rb').read)

body = {
  requests: [{
    image: {
      content: base64_image
    },
    features: [
      {
        type: 'TEXT_DETECTION', #画像認識の分析方法を選択
        maxResults: 1   # 出力したい結果の数
      }
    ]
  }]
}.to_json

# 文字列のAPI_URLをURIオブジェクトに変換します。
uri = URI.parse(api_url)   
# uri = URI.parse(API_URL) 

# httpではなく暗号化通信の施されたhttpsを用いる設定です。
https = Net::HTTP.new(uri.host, uri.port)
https.use_ssl = true

# POSTリクエストを作成します
request = Net::HTTP::Post.new(uri.request_uri)


request["Content-Type"] = "application/json"
response = https.request(request, body)


# 返り値がJSON形式のため、JSONをrubyで扱えるように変換。
response_rb = JSON.parse(response.body)




@description = response_rb["responses"][0]["textAnnotations"][0]["description"]


  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_money
      @money = Money.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def money_params
      params.require(:money).permit(:expenses, :image).merge(user_id:current_user.id)
    end

    def total_expenses
      sum = 0 
      @money.each do |money|
        sum += money.expenses
      end
        return sum
    end
end
