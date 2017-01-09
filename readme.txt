Last update: 2017/01/10
Author: Sho KANEMARU

○roboba043.rb
- Roboba043赤外線アレイセンサから8x8温度情報を取得し、Cumulocityへアップするスクリプト
- usage: 同じディレクトリにcalc_temperature.rb を配置した上で、下記コマンドを実行
  $ ruby roboba043.rb

○ calc_temperature.rb
- Roboba043赤外線アレイセンサから取得した温度情報(バイナリ)を8x8二次元配列に変換するためのライブラリ
- 下記ドキュメントのP9を実装しています。
http://moosoft.jp/images/moosoft/grideye/grideye_manual.pdf

○セットアップ方法
(記入中。。)

○赤外線アレイセンサについて
- 一度の測定情報で64個(8x8)の温度データを取得できるセンサ。領域の温度を測定することが可能です。
http://moosoft.jp/index.php?option=com_content&view=article&id=105&Itemid=140
https://industrial.panasonic.com/jp/products/sensors/built-in-sensors/grid-eye

- シリアル通信により温度情報を取得する。
- シリアル通信用コマンドの詳細は下記を参照。(calc_temperature.rbは下記ドキュメントのP9を実装しています。)
http://moosoft.jp/images/moosoft/grideye/grideye_manual.pdf



