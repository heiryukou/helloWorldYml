#
# 環境変数定義
#
# TARGET_INPUT_PATH		ソフトウェア実行ファイルの実装環境へのパスを設定する
# TARGET_OUTPUT_PATH	ソフトウェア実行ファイルの格納先のパスを設定する
# TARGET_OUTPUT_PATH_B	ソフトウェア実行ビルドファイルの格納先のパスを設定する
# CLEAN					全プロジェクトクリーン処理実施フラグ（0:クリーン無/1:クリーン有）を設定する
# PAUSE					異常発生時の一時停止実施フラグ（0:一時停止しない/1:一時停止する）を設定する
# LOG_FILE_PATH			LOGファイル出力先のパスを設定する（通常は設定しない）
#
set TARGET_INPUT_PATH ""
set TARGET_OUTPUT_PATH ""
set TARGET_OUTPUT_PATH_B ""
set CLEAN 0
set PAUSE 0
set LOG_FILE_PATH ""

cd script

#
# 関数定義
#

#
# スクリプト実行処理
#
# scriptPath:実行するスクリプトへのパス
# return 0:正常終了/1:異常終了
#
proc runScript { scriptPath } {
	if { [ file isfile $scriptPath ] != 1 } {
		return 1
	}
	set ret [ source $scriptPath ]
	if { $ret != 0 } {
		return 1
	}
	return 0
}

#
# 一時停止処理
#
# message:エラーメッセージ
#
proc pause { message } {
	global PAUSE
	puts "$message"
	if { $PAUSE == 1 } {
		puts -nonewline " Hit Enter to continue ==> "
		flush stdout
		gets stdin
	}
}

#
# 主処理
# 
# argv 1:		環境構築用インプットフォルダのパス
# argv 2:		ソフトウェア実行ファイルの格納先フォルダのパス
# argv 3以降:	オプションパラメータ（クリーンフラグ/一時停止フラグ）※順不同
# exit 0:正常終了/1:異常終了
#

# 起動メッセージ出力
puts ">>N0101:Image build started..... $LOG_FILE_PATH"
if { $LOG_FILE_PATH ne "" } {
	if { [ catch { open $LOG_FILE_PATH a } fid ] == 0 } {
		puts $fid ">>N0101:Image build started."
		close $fid
	}
}

puts ">>>>>>>>>>processStart:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
if { $LOG_FILE_PATH ne "" } {
	if { [ catch { open $LOG_FILE_PATH a } fid ] == 0 } {
		puts $fid ">>>>>>>>>>process start:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
		close $fid
	}
}

# 共有関数定義の読み込み
set ret [ runScript ci_misc.tcl ]
if { $ret != 0 } {
	pause ">>E0102:Common function loading failed."
	puts ">>E0101:Image build failed."
	exit 1
}

putLog ">>N0103:Common function loading completed. $argv [ lindex $argv 0 ]"

# 環境変数設定
if { [ lindex $argv 0 ] eq "" } {
	pause ">>E0103:Failed to configuration."
	putLog ">>E0101:Image build failed."
	exit 1
}
set ret [ setEnv TARGET_INPUT_PATH [ lindex $argv 0 ] ]
if { $ret != 0 } {
	pause ">>E0103:Failed to configuration."
	putLog ">>E0101:Image build failed."
	exit 1
}

if { [ lindex $argv 1 ] eq "" } {
	pause ">>E0103:Failed to configuration."
	putLog ">>E0101:Image build failed."
	exit 1
}
set ret [ setEnv TARGET_OUTPUT_PATH [ lindex $argv 1 ] ]
if { $ret != 0 } {
	pause ">>E0103:Failed to configuration."
	putLog ">>E0101:Image build failed."
	exit 1
}

if { [ lindex $argv 2 ] eq "" } {
	pause ">>E0103_1:Failed to configuration."
	putLog ">>E0101_1:Image build failed."
	exit 1
}
set ret [ setEnv TARGET_OUTPUT_PATH_B [ lindex $argv 2 ] ]
if { $ret != 0 } {
	pause ">>E0103_1:Failed to configuration."
	putLog ">>E0101_1:Image build failed."
	exit 1
}

set loopMax $argc
putLog ">>loopMax: $loopMax"
for { set index 3 } { $index < $loopMax } { incr index } {
	putLog ">>index: $index"
	set ret [ setOpt [ lindex $argv $index ] ]
	if { $ret != 0 } {
		pause ">>E0103:Failed to configuration."
		putLog ">>E0101:Image build failed."
		exit 1
	}
}

putLog ">>N0104:Complete configuration.[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"

# LockFileの確認(LockFileが存在しない場合は作成する)
set ret [ checkLockFile ]
if { $ret != 0 } {
	pause ">>E0107:Build process is in progress."
	putLog ">>E0101:Image build failed."
	exit 1
}

set ret [ createLockFile ]
if { $ret != 0 } {
	pause ">>E0108:Failed to create lock file."
	putLog ">>E0101:Image build failed."
	exit 1
}

# スクリプト実行処理

# プロジェクトのインポート
set ret [ runScript ci_importProject.tcl ]
if { $ret != 0 } {
	deleteLockFile
	pause ">>E0104:Failed to import project."
	putLog ">>E0101:Image build failed."
	exit 1
}
putLog ">>N0105:Complete project import.[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"

# ソフトウェア実行ファイルビルド
set ret [ runScript ci_systemBuild.tcl ]
if { $ret != 0 } {
	deleteLockFile
	pause ">>E0106:Executable image build failed."
	putLog ">>E0101:Image build failed."
	exit 1
}
putLog ">>N0107:Executable image build completed.[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"

# ソフトウェア実行ファイル格納
set ret [ runScript ci_storeImage.tcl ]
if { $ret != 0 } {
	deleteLockFile
	pause ">>E0107:Failed to image storage."
	putLog ">>E0101:Image build failed."
	exit 1
}
pause ">>N0108:Complete image storage."
putLog ">>N0102:Image build complete."
putLog ">>>>>>>>>>process end:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"

#LockFileの削除
deleteLockFile
exit 0
