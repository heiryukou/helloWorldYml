#
# 関数定義
#

#
# プロジェクトインポート処理
#
# TARGET_INPUT_PATH:ソフトウェア実行ファイルの実装環境へのパス
# prjPath:インポートするプロジェクトへのパス
# return 0:正常終了/1:異常終了
#
proc importPrj { prjPath } {
	global TARGET_INPUT_PATH
	if { [ catch { importprojects $TARGET_INPUT_PATH/helloworldproject/$prjPath } err ] } {
		putLog "ERROR: $err"
		return 1
	}
	return 0
}

#
# プロジェクト削除処理
# TARGET_INPUT_PATH:ソフトウェア実行ファイルの実装環境へのパス
# return 0:正常終了/1:異常終了
#
proc removePrj {} {
	global TARGET_INPUT_PATH
	if { [catch { file delete -force $TARGET_INPUT_PATH/helloworld/project } err] } {
		putLog "ERROR: $err"
		return 1
	}
	return 0
}

#
# 主処理
#
# TARGET_INPUT_PATH:ソフトウェア実行ファイルの実装環境へのパス
# return 0:正常終了/1:異常終了
#
global TARGET_INPUT_PATH

# 現在の作業ディレクトリのパスを保存
if { [ catch { set workDir [ pwd ] } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0201:import prj phase01 FAILED."
	return 1
}
putLog ">>N0201:import prj phase01 PASS."

# 作業ディレクトリを実装環境フォルダへ移動
if { [ catch { cd $TARGET_INPUT_PATH/helloworld } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0202:import prj phase02 FAILED."
	return 1
}
putLog ">>N0202:import prj phase02 PASS."

# プロジェクト削除
set ret [ removePrj ]
if { $ret != 0 } {
	putLog ">>E0203:import prj phase03 FAILED."
	return 1
}
putLog ">>N0203:import prj phase03 PASS."

# ワークスペースを設定
if { [ catch { setws $TARGET_INPUT_PATH/helloworld/project } err ] } {
	putLog ">>E0204:import prj phase04 FAILED."
	return 1
}
putLog ">>N0204:import prj phase04 PASS."

# プロジェクトをインポート
set ret [ importPrj test_a53 ]
if { $ret != 0 } {
	putLog ">>E0215:import prj phase15 FAILED."
	return 1
}
putLog ">>N0215:import prj phase15 PASS."

set ret [ importPrj test_a53_system ]
if { $ret != 0 } {
	putLog ">>E0216:import prj phase16 FAILED."
	return 1
}
putLog ">>N0216:import prj phase16 PASS."

set ret [ importPrj sample_vitis_zcu106 ]
if { $ret != 0 } {
	putLog ">>E0217:import prj phase17 FAILED."
	return 1
}
putLog ">>N0217:import prj phase17 PASS."

# workDirに移動
if { [ catch { cd $workDir } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0218:import prj phase18 FAILED."
	return 1
}
putLog ">>N0218:import prj phase18 PASS."

# 正常終了
return 0