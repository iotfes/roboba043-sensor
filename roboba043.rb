# coding: utf-8
#----------------------------------------------------------------------
# roboba043.rb
# Roboba043赤外線アレイセンサから8x8温度情報を取得し、Cumulocityへアップするスクリプト
# usage: 同じディレクトリにcalc_temperature.rb を配置した上で、下記コマンドを実行
#  $ ruby roboba043.rb
# Last update: 2017/01/10
# author: Sho KANEMARU
#----------------------------------------------------------------------
$LOAD_PATH.push('.')
require 'socket'
require 'rubygems'
gem 'serialport','>=1.0.4'
require 'serialport'
require 'net/http'
require 'yaml'
require 'uri'
require 'base64'
require 'json'
require 'calc_temperature'

#------------ 設定ファイル読み込み ------------
confFileName = "./config.yml"
config = YAML.load_file(confFileName)

# デバイスID (Cumulocityが払い出したID)
DEVICEID = config["deviceId"]
# CumulocityへのログインID
USERID = config["userId"]
# Cumulocityへのログインパスワード
PASSWD = config["password"]
# CumulocityのURL
URL = config["url"] + "/measurement/measurements/"
# ttyへのパス
TTYPATH = config["ttypath"]

#------------ シリアル通信により8x8温度データを取得 ------------
# シリアル通信用のセッションをオープン
sp = SerialPort.new(TTYPATH, 115200, 8, 1, 0) # 115200bps, 8bit, stopbit 1, parity none
sp.read_timeout = 5000
# デリミタの設定
delimiterCRLF = "\r\n"
delimiterCR = "\r"

# set slave register address to 0x80
begin
  sp.write("w80#{delimiterCRLF}")
  line = sp.gets(delimiterCRLF)
  puts "result(w80): #{line}"
  sleep(3)
end while line != "ok#{delimiterCRLF}"

# read 0x80 bytes from 0x80 address
begin
  sp.write("r80#{delimiterCR}")
  line = sp.gets(delimiterCRLF)
  puts "result(r80): #{line}"
  sleep(3)
end while line == "error#{delimiterCRLF}"

sp.close

# split data from infrared sensor
data_array = line.split(",")
p data_array

# set calc_array[
calc_array = []
num = 0
for i in 0..63 do
  #puts "data[#{num}]:#{data_array[num]}, data[#{num+1}]:#{data_array[num+1]}"
  calc_array.push(calc_temperature(data_array[num], data_array[num+1]))
  num += 2
end
p calc_array

#--------------- Cumulocity API実行用のペイロード(JSON)を作成 ------------
# 現在時刻を取得
day = Time.now
currentTime = day.strftime("%Y-%m-%dT%H:%M:%S.000+09:00")

# 温度データ64個分のJSONを作成
hash_array = []
for i in 0..63 do
  hash_array[i] = {
    :cumonosu_Roboba043Measurement => {
      "temperature#{i+1}" => { 
        :value => calc_array[i],
        :unit=>  "C" }
    },
    :time => currentTime, 
    :source => {
      :id => DEVICEID }, 
    :type => "cumonosu_Roboba043Measurement"
  }
end

# 温度データ64個分のJSONを配列としてセット(Cumulocityが受信できるJSONに変換)
data = {
  :measurements => hash_array
}

#----------- Cumulociy API (POST /measurement/measurements)を実行 ----------
# URLからURIをパース
uri = URI.parse(URL)

https = Net::HTTP.new(uri.host, uri.port)
https.set_debug_output $stderr
#https.use_ssl = false # HTTPSは使用しない
https.use_ssl = true # HTTPSを使用する

# httpリクエストヘッダの追加
initheader = {
  'Content-Type' =>'application/json',
  'Accept'=>'application/vnd.com.nsn.cumulocity.measurementCollection+json',
  'Authorization'=>'Basic ' + Base64.encode64("#{USERID}:#{PASSWD}")
}

# httpリクエストを送信
request = Net::HTTP::Post.new(uri.request_uri, initheader)
payload = JSON.pretty_generate(data)
request.body = payload
#p request
response = https.request(request)

# httpレスポンスの中身を確認
puts "------------------------"
puts "code -> #{response.code}"
puts "msg -> #{response.message}"
#puts "body -> #{response.body}"


