#
# 関数定義
#

#
# ログ出力処理
#
# message:メッセージ（正常系・異常系）
#
proc putLog { message } {
	puts "$message"
	flush stdout
	
	global LOG_FILE_PATH
	if { $LOG_FILE_PATH ne "" } {
		if { [ catch { open $LOG_FILE_PATH a } fid ] == 0 } {
			puts $fid "$message"
			close $fid
		}
	}
}

#
# LOCKファイル判定処理
#
# return 0:LOCKファイル無/1:LOCKファイル有
#
proc checkLockFile {} {
	global TARGET_INPUT_PATH
	set ret [ file isfile $TARGET_INPUT_PATH/lockfile ]
	if { $ret != 0 } {
		return 1
	}
	return 0
}

#
# LOCKファイル作成処理
#
# return 0:正常終了/1:異常終了
#
proc createLockFile {} {
	global TARGET_INPUT_PATH
	if { [ catch { open $TARGET_INPUT_PATH/lockfile w } fid ] } {
		puts "ERROR: $fid"
		return 1
	}
	close $fid
	return 0
}

#
# LOCKファイル削除処理
#
proc deleteLockFile {} {
	global TARGET_INPUT_PATH
	file delete -force $TARGET_INPUT_PATH/lockfile
}

#
# 環境変数設定処理
#
# le:	環境変数
# val:	メイン処理起動時に通知されたパラメータ
# return 0:正常終了/1:異常終了
#
proc setEnv { le val } {
	if { [ catch { upvar $le e } err ] } {
		puts "ERROR: $err"
		return 1
	}
	puts "$le = $val"
	set e $val
	return 0
}

#
# オプション設定処理
#
# val:メイン処理起動時に通知されたパラメータ
# return 0:正常終了/1:異常終了
#
proc setOpt { val } {
	puts ">>setOpt: $val"
	if { $val eq "clean" } {
		if { [ catch { upvar CLEAN e } err ] } {
			puts "ERROR: $err"
			return 1
		}
		puts "CLEAN = 1"
		set e 1
		return 0
		
	} elseif { $val eq "pause" } {
		if { [ catch { upvar PAUSE e } err ] } {
			puts "ERROR: $err"
			return 1
		}
		puts "PAUSE = 1"
		set e 1
		return 0
	}
	return 1
}



# 正常終了
return 0