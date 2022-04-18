#!/usr/bin/bash

# wget https://raw.githubusercontent.com/mugimugi555/raspberrypi/main/install_voice.sh && bash install_voice.sh ;

#-----------------------------------------------------------------------------------------------------------------------
# install voice app
#-----------------------------------------------------------------------------------------------------------------------
sudo echo ;
sudo apt update ;
sudo apt install -y open-jtalk ;
sudo apt install -y open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 ;

cd ;

#-----------------------------------------------------------------------------------------------------------------------
# voice by echo
#-----------------------------------------------------------------------------------------------------------------------
echo "こんにちは" | open_jtalk \
  -x /var/lib/mecab/dic/open-jtalk/naist-jdic \
  -m /usr/share/hts-voice/nitech-jp-atr503-m001/nitech_jp_atr503_m001.htsvoice \
  -ow hello1.wav ;
aplay hello1.wav ;

#-----------------------------------------------------------------------------------------------------------------------
# voice by text
#-----------------------------------------------------------------------------------------------------------------------
cd ;
echo "今日は天気がいいですね" > hello.txt ;
open_jtalk \
  -x /var/lib/mecab/dic/open-jtalk/naist-jdic \
  -m /usr/share/hts-voice/nitech-jp-atr503-m001/nitech_jp_atr503_m001.htsvoice \
  -ow hello2.wav \
  hello.txt ;
aplay hello2.wav ;

#-----------------------------------------------------------------------------------------------------------------------
# girl's voice
#-----------------------------------------------------------------------------------------------------------------------
cd ;
wget https://sourceforge.net/projects/mmdagent/files/MMDAgent_Example/MMDAgent_Example-1.7/MMDAgent_Example-1.7.zip ;
unzip ./MMDAgent_Example-1.7.zip ;
sudo cp -r ./MMDAgent_Example-1.7/Voice/mei/ /usr/share/hts-voice/ ;
echo "女性用ボイスのテストです" | open_jtalk \
  -m /usr/share/hts-voice/mei/mei_normal.htsvoice \
  -x /var/lib/mecab/dic/open-jtalk/naist-jdic \
  -ow hello3.wav ;
aplay hello3.wav ;
