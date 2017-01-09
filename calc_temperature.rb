# coding: utf-8
#----------------------------------------------------------------------
# calc_temperature.rb
# Roboba043赤外線アレイセンサから取得した温度情報(バイナリ)を8x8二次元配列に変換するためのライブラリ
# 下記仕様書のP9を実装
#  http://moosoft.jp/images/moosoft/grideye/grideye_manual.pdf
# Last update: 2017/01/10
# author: Sho KANEMARU
#----------------------------------------------------------------------
def create_float(num)
  case num & 3
  when 3 then
    return 0.75
  when 2 then
    return 0.5
  when 1 then
    return 0.25
  when 0 then
    return 0
  end
end

# get temperature from data
def calc_temperature(lower, upper)
  #puts "upper: #{upper}, lower: #{lower}"
  upperPart = upper.hex << 8
  lowerPart = lower.hex & 255
  total = upperPart | lowerPart
  return (total >> 2) + create_float(total)
end
