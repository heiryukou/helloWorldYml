#
# 関数定義
#

#
# プラットフォームクリーン処理
#
# CLEAN:全プロジェクトクリーンフラグ
# platformFolder:プラットフォームフォルダ
# return 0:正常終了/1:異常終了
#
proc cleanPlatform { platformFolder } {
	global CLEAN
	
	putLog ">>>>>>>>>>$platformFolder clean start:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	# プラットフォームクリーン（※現状CLEANの判定処理は抑止）
	#if { CLEAN == 1 } {
		if { [ catch { platform clean } err ] } {
			putLog "ERROR: $err"
			return 1
		}
	#}
	putLog ">>>>>>>>>>$platformFolder clean end:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	return 0
}

#
# プラットフォームビルド処理
#
# platformFolder:プラットフォームフォルダ
# return 0:正常終了/1:異常終了
#
proc buildPlatform { platformFolder } {

	putLog ">>>>>>>>>>$platformFolder build start:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	# プラットフォームビルド
	if { [ catch { platform generate } err ] } {
		putLog "ERROR: $err"
		return 1
	}
	putLog ">>>>>>>>>>$platformFolder build end:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	return 0
}

#
# カーネルビルド処理
#
# kernelFolder:	 カーネルフォルダ
# KERNEL_CONFIG  0:カーネルのコンフィグレーションファイル生成/1:生成無し
# return 0:正常終了/1:異常終了
#
proc buildKernel { kernelFolder } {
	if { [ catch { sysproj build -name $kernelFolder } err ] } {
		putLog "ERROR: $err"
		return 1
	}
	return 0
}

#
# プロジェクトクリーン処理
#
# CLEAN:全プロジェクトクリーンフラグ
# prjFolder:プロジェクトフォルダ
# return 0:正常終了/1:異常終了
#
proc cleanProject { prjFolder } {
	global CLEAN
	
	putLog ">>>>>>>>>>$prjFolder clean start:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	# プロジェクトクリーン（※現状CLEANの判定処理は抑止）
	#if { CLEAN == 1 } {
		if { [ catch { sysproj clean -name $prjFolder } err ] } {
			putLog "ERROR: $err"
			return 1
		}
	#}
	putLog ">>>>>>>>>>$prjFolder clean end:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	return 0
}

#
# プロジェクトビルド処理
#
# prjFolder:プロジェクトフォルダ
# return 0:正常終了/1:異常終了
#
proc buildProject { prjFolder } { 

	putLog ">>>>>>>>>>$prjFolder build start:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	# プロジェクトビルド
	if { [ catch { sysproj build -name $prjFolder } err ] } {
		putLog "ERROR: $err"
		return 1
	}
	putLog ">>>>>>>>>>$prjFolder build end:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	return 0
}

#
# ｂifファイルフォルダパス置換処理
#
# bifFile:		フォルダパス置換元のbifファイル
# copyBifFile:	フォルダパス置換後のbifファイル
# return 0:正常終了/1:異常終了
#
proc pathReplace { bifFile copyBifFile } {

	if { [ catch { open ./$bifFile r } fid ] } {
		puts "ERROR: $fid"
		return 1
		
	}
	
	if { [ catch { open ./$copyBifFile a } newFid ] } {
		puts "ERROR: $newFid"
		close $fid
		return 1	
	}

	while { ![ eof $fid ] } {
		set line [ gets $fid ]
		set retFirst [ string first "C:" "$line" 0 ]
		if { [ string match "*\\test_a53.bin" $line ] == 1 } {
			set retLastLine [ string last "\\project" "$line" end ]
			puts $newFid [ string replace $line $retFirst $retLastLine "..\\" ]
			
		} else {
			set retLast [ string last "\\" "$line" end ]
			puts $newFid [ string replace $line $retFirst $retLast ".\\" ]
		}
	}
	close $newFid	
	close $fid
	return 0
}

#
# ソフトウェア実行ファイルビルド処理
#
# TARGET_INPUT_PATH:ソフトウェア実行ファイルの実装環境へのパス
# return 0:正常終了/1:異常終了
#
proc createBootImage {} {
	global TARGET_INPUT_PATH
	
	putLog ">>>>>>>>>>create BOOT start:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	# 現在の作業ディレクトリのパスを保存
	if { [ catch { set workDir [ pwd ] } err ] } {
		putLog "ERROR: $err"
		return 1
	}

	# 作業ディレクトリをbootloaderフォルダに移動する
	if { [ catch { cd $TARGET_INPUT_PATH/helloworld/bootloader } err ] } {
		putLog "ERROR: $err"
		return 1
	}
	
	# fmp_system.bifファイルのパスを置換してコピー
	set ret [ pathReplace fmp_system.bif copy_fmp_system.bif ]
	if { $ret != 0 } {
		return 1
	}
	
	# ソフトウェア実行ファイルビルド
	if { [ catch { exec bootgen -arch zynqmp -image ./copy_fmp_system.bif -o BOOT.bin -w -log } err ] } {
		file delete -force ./copy_fmp_system.bif
		putLog "ERROR: $err"
		return 1
	}
	
	# copy_fmp_system.bifの削除
	file delete -force ./copy_fmp_system.bif
	
	# fmp_system_factory.bifファイルのパスを置換してコピー
	set ret [ pathReplace fmp_system_factory.bif copy_fmp_system_factory.bif ]
	if { $ret != 0 } {
		return 1
	}
	
	# 新規プログラム書き込みモード用ソフトウェア実行ファイルのビルド
	if { [ catch { exec bootgen -arch zynqmp -image ./copy_fmp_system_factory.bif -o BOOT_factory.bin -w -log } err ] } {
		file delete -force ./copy_fmp_system_factory.bif
		putLog "ERROR: $err"
		return 1
	}
	
	# copy_fmp_system_factory.bifの削除
	file delete -force ./copy_fmp_system_factory.bif
	
	# workDirに移動
	if { [ catch { cd $workDir } err ] } {
		putLog "ERROR: $err"
		return 1
	}
	putLog ">>>>>>>>>>create BOOT end:[clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
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
	putLog ">>E0401:build image phase01 FAILED."
	return 1
}
putLog ">>N0401:build image phase01 PASS."



# 作業ディレクトリをプロジェクトフォルダへ移動
if { [ catch { cd $TARGET_INPUT_PATH/helloworld/project } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0402:build image phase02 FAILED."
	return 1
}
putLog ">>N0402:build image phase02 PASS."



# ワークスペースを設定
if { [ catch { setws $TARGET_INPUT_PATH/helloworld/project } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0403:build image phase03 FAILED."
	return 1
}
putLog ">>N0403:build image phase03 PASS."



# プラットフォームをアクティブにする
if { [ catch { platform active sample_vitis_zcu106 } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0404:build image phase04 FAILED."
	return 1
}
putLog ">>N0404:build image phase04 PASS."



# プラットフォームのクリーン
set ret [ cleanPlatform edit ]
if { $ret != 0 } {
	putLog ">>E0405:build image phase05 FAILED."
	return 1
}
putLog ">>N0405:build image phase05 PASS."



# プロジェクトのクリーン
set ret [ cleanProject test_a53_system ]
if { $ret != 0 } {
	putLog ">>E0406:build image phase06 FAILED."
	return 1
}
putLog ">>N0406:build image phase06 PASS."



# プラットフォームのビルド
set ret [ buildPlatform edit ]
if { $ret != 0 } {
	putLog ">>E0412:build image phase12 FAILED."
	return 1
}
putLog ">>N0412:build image phase12 PASS."

pause "1"

# カーネルのビルド
set ret [ buildKernel test_a53_system ]
if { $ret != 0 } {
	putLog ">>E0419:build image phase19 FAILED."
	return 1
}
putLog ">>N0419:build image phase19 PASS."

pause "4"

# ソフトウェア実行ファイルビルド
set ret [ createBootImage ]
if { $ret == 1 } {
	putLog ">>E0420:build image phase20 FAILED."
	return 1
}
putLog ">>N0420:build image phase20 PASS."



# workDirに移動
if { [ catch { cd $workDir } err ] } {
	putLog "ERROR: $err"
	putLog ">>E0421:build image phase21 FAILED."
	return 1
}
putLog ">>N0421:build image phase21 PASS."



# 正常終了
return 0