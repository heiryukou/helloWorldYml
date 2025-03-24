#
# 関数定義
#

#
# ファイル格納処理
#
# TARGET_OUTPUT_PATH:成果物格納フォルダへのパス
# imageFile:格納対象ファイルへのパス
# return 0:正常終了/1:異常終了
#
proc storeFile { imageFile } {
	global TARGET_OUTPUT_PATH

	puts "storeFile: $imageFile"
	# 成果物格納フォルダの存在確認(存在しない場合作成する)
	if { [ file exist $TARGET_OUTPUT_PATH ] != 1 } {
		if { [ catch { file mkdir $TARGET_OUTPUT_PATH } err ] } {
			putLog "ERROR: $err"
			return 1
		} 
	}
	
	puts "TARGET_OUTPUT_PATH: $TARGET_OUTPUT_PATH"
	# ソフトウェア実行ファイル格納
	if { [ catch { file copy -force $imageFile $TARGET_OUTPUT_PATH } err ] } {
		putLog "ERROR: $err"
		return 1
	} 
	return 0
}

#
# ビルドファイル格納処理
#
# TARGET_OUTPUT_PATH_B:成果物格納フォルダへのパス
# imageFile:格納対象ファイルへのパス
# return 0:正常終了/1:異常終了
#
proc storeFileBuild { imageFile } {
	global TARGET_OUTPUT_PATH_B

	puts "storeFileBuild: $imageFile"
	# 成果物格納フォルダの存在確認(存在しない場合作成する)
	if { [ file exist $TARGET_OUTPUT_PATH_B ] != 1 } {
		if { [ catch { file mkdir $TARGET_OUTPUT_PATH_B } err ] } {
			putLog "ERROR: $err"
			return 1
		} 
	}
	
	puts "TARGET_OUTPUT_PATH_B: $TARGET_OUTPUT_PATH_B"
	# ソフトウェア実行ファイル格納
	if { [ catch { file copy -force $imageFile $TARGET_OUTPUT_PATH_B } err ] } {
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

# ソフトウェア実行ファイル格納
set ret [ storeFile $TARGET_INPUT_PATH/helloworld/bootloader/BOOT.BIN ]
if { $ret != 0 } {
	putLog ">>E0501:store image phase01 FAILED."
	return 1
}
putLog ">>N0501:store image phase01 PASS."

set ret [ storeFileBuild $TARGET_INPUT_PATH/helloworld/project/test_a53/Debug/test_a53.elf ]
if { $ret != 0 } {
	putLog ">>E0502:store image phase02 FAILED."
	return 1
}
putLog ">>N0502:store image phase02 PASS."

set ret [ storeFile $TARGET_INPUT_PATH/helloworld/bootloader/BOOT_factory.BIN ]
if { $ret != 0 } {
	putLog ">>E0503:store image phase03 FAILED."
	return 1
}
putLog ">>N0503:store image phase03 PASS."

set ret [ storeFileBuild $TARGET_INPUT_PATH/helloworld/project/test_a53/Debug/test_a53.bin ]
if { $ret != 0 } {
	putLog ">>E0504:store image phase04 FAILED."
	return 1
}
putLog ">>N0504:store image phase04 PASS."

# 正常終了
return 0