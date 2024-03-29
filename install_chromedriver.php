<?php

# wget https://raw.githubusercontent.com/mugimugi555/ubuntu/main/install_chromedriver.php && php install_chromedriver.php ;

# if you want latest version -> https://googlechromelabs.github.io/chrome-for-testing/#stable

echo "=================================\n";
echo "start check chrome driver version\n\n";

// get latest version number information
$page_latest = file_get_contents( "https://chromedriver.storage.googleapis.com/LATEST_RELEASE" );

echo "latest chrome driver version is \n\n";
echo "    {$page_latest}\n\n";
$latest_arr = explode( "." , $page_latest );
$latest_version = $latest_arr[0];

// start command
$CMD_BASH = "";

@mkdir("chromedrivers");

// download 3 version
echo "start latest 3 version\n\n";
for( $i = $latest_version - 3 ; $i <= $latest_version ; $i ++ ){

  // file download
  $url = "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_{$i}";
  echo "downloading {$i} {$url}\n";
  $page_version = file_get_contents( $url );
  $zip = file_get_contents( "https://chromedriver.storage.googleapis.com/{$page_version}/chromedriver_linux64.zip" );
  file_put_contents("chrome_driver_{$i}.zip" , $zip );

  // unzip and reanme chromedriver_VERSION
  echo "unziping and rename to chromedriver_{$i}\n\n";
  $CMD_UNZIP = <<<BASH
unzip -o chrome_driver_{$i}.zip &&
mv -f chromedriver chromedrivers/chromedriver_{$i} &&
rm chrome_driver_{$i}.zip
BASH;
  exec( $CMD_UNZIP );

  // generate start command
  $page_version_pad = str_pad( $i, 3, '0', STR_PAD_LEFT);
  $CMD_BASH .= <<<BASH
./chromedrivers/chromedriver_{$i} --port=5{$page_version_pad} &

BASH;

}

// copy to latest version
$CMD = <<<BASH
cp -f ./chromedrivers/chromedriver_{$latest_version} chromedrivers/chromedriver 
BASH;
exec( $CMD );
$CMD_BASH .= <<<BASH
./chromedrivers/chromedriver    --port=5000 &

BASH;

// start command
echo "\n";
echo "=================================\n";
echo "here is start command\n\n";
echo $CMD_BASH;
echo "\n";
echo "=================================\n";
