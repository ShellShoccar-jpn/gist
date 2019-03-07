awk '
  # (例1)フィールド2が100以上なら一時停止。その際、その値を書き出す。
  $2>=100 {shut_valve("/tmp/over100", "$2:" $2);}

  # (例2)行頭に"Error"という文字があったら一時停止。その際、行番号を書き出す。
  /^Error/ {shut_valve("/tmp/error_line", NR);}

  # この行は、平常時にデータを素通しするために必要
  {print;} 

  ####################################################################
  #
  # [機能] 特定の文字列パターンが現れた時に、パイプの流れを一時停止させる
  #
  # [引数] filename : 一時停止させる時に生成するファイル名
  #                   このファイルを削除すれば流れが再開する。
  #                   反対に、このファイルの中身を"__IGNORE"として
  #                   予め作り置いておけば、一時停止を無効化できる。
  #        message  : filenameの中に何かメッセージを送りたい場合に設定
  #        _dummy   : (AWKでグローバル変数化を避ける為の引数、呼出側は使わない)
  #
  ####################################################################
  function shut_valve(filename, message,  _dummy) {
    if (getline _dummy < filename >0) {
      if (_dummy == "__IGNORE") {return;}
    }
    print message > filename;
    while (getline _dummy < filename >0) {
      system("sleep 1");
      close(filename);
    }
  }
  '
