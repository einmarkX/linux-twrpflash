#!/bin/bash



###############################################################
# TWRP INSTALLER FOR ANDROID DEVICES                          #
# Supported devices : Samsung,Xiaomi,Google Pixel             #
# Script by xflop                                             #
# Under GNU GPLv3 LICENSE                                     #
###############################################################
usermode=`whoami`
cleanup(){
    rm -rf /tmp/twrp/*
}
link="ftp://192.168.1.3:19261/image"
select_usrint(){
    while true ;do
        echo "/help for instruction"
        read -p "(SELECT INTERFACE)> " select
        case $select in
            /help) echo "usage : <interface> <lang>"
                echo "interface "
                echo  "/gui          Use Graphical user interface"
                echo  "/cli          Use Command Line interface"
                echo  "lang(language)"
                echo  "-ID            Indonesian Language"
                echo  "-EN            English Language "
                echo  "Ex:"
                echo  " /gui-ID"
                echo  " /cli-EN"
                echo  "Notes :
                echo  " You can use normal shell command,like ls,cd,etc;;
            /gui-ID) id_gui;;
            /cli-ID) cli_id;;
            /gui-EN) en_gui;;
            /cli-EN) cli_en;;
            $select) case $select in
                sudo | su | bash | vi ) echo "no";;
                $select) $select;;
            esac;;
        esac
    done
}
en_gui(){
    while true ;do
        whiptail --title " Select Recovery " --menu " Select custom recovery " 25 78 16 \
            "TWRP" "Team Win Recovery Project"\
            "" ""\
            "PBRP" "PitchBlack Recovery Project"\
            "" ""\
            "ORRP" "OrangeFox Recovery Project"\
            "" ""\
            "Exit" "" 2>/tmp/twrp/en_gui.$$
        nau=`cat /tmp/twrp/en_gui.$$`
        case $nau in
            TWRP) twrp_brand_en;;
            PBRP) pbrp_brand_en;;
            ORRP) orangefox_brand_en;;
            Exit) clear;cleanup;exit;;
            *) ;;
        esac
    done
}
## RECOVERY
chooseRecovery()
{
    (
    xf=0
    while [ $xf -lt 100 ];do
        xf=$(( xf + 1 ))
        sleep 0.1
        if [ $xf -eq 80 ];then curl $link > /tmp/twrp/file.list$$;fi
        echo $xf
    done) | whiptail --title " Wait " --gauge "Please wait while we getting file list" 9 60 0
    list=`cat /tmp/twrp/file.list$$ | grep "$codename"`
    whiptail --title " Available " --menu " Available twrp recovery list " 25 78 16\
        "1" "$list"\
        ""  "" 2>/tmp/twrp/rc.list_menu$$
    ap=`cat /tmp/twrp/rc.list_menu$$`
    case $ap in
        1) wget $link/$list 2>/dev/null
            whiptail --title " Attention " --yesno " Flash custom recovery now?" --yes-button "Yes,now" --no-button "Later,exit" 9 60
            case "${?}" in
                0) nausea=`find -type f -name *.img`
                    if [ -z $nausea ];then
                        (
                        x=0
                        while [ $x -lt 100 ];do
                            x=$(( x + 1 ))
                            sleep 0.1
                            if [ $x -eq 75  ];then fastboot flash recovery *.ftips 2>/dev/null;fi
                            echo $x
                        done) | whiptail --title " Wait " --gauge " Flashing recovery..... " 9 60 0
                        sleep 0.5
                        whiptail --title " Info " --yesno " Recovery succesfully flashed" --yes-button "Reboot to recovery " --no-button "Exit" 9 60
                        case "${?}" in
                            0) fastboot boot *.ftips;;
                            1) en_gui;;
                        esac
                    else
                        (
                        x=0
                        while [ $x -lt 100 ];do
                            x=$(( x + 1 ))
                            sleep 0.1
                            if [ $x -eq 75 ];then fastboot flash recovery *.img 2>/dev/null;fi
                            echo $x
                        done ) | whiptail --title " Wait " --gauge "Flashing recovery,......." 9 60 0
				 whiptail --title " Info " --yesno " Recovery succesfully flashed" --yes-button "Reboot to recovery " --no-button "Exit" 9 60
                        case "${?}" in
                            0) fastboot boot *.img;;
                            1) en_gui;;
                        esac
                        fi;;
                    1) en_gui;;
        *) en_gui;;
    esac
esac
}
## CHECK BOOTLOADER STATUS
refresh(){
    fastbootgetBootloaderStatus
}
fastbootgetBootloaderStatus(){
    (
    a=0
    while [ $a -lt 100 ];do
        a=$(( a + 1 ))
        sleep 0.1
        echo $a
        if [ $a -eq 50 ];then adb devices 2>/dev/null; adb devices > /tmp/twrp/exist.info$$;fi
    done
    ) | whiptail --title " Wait " --gauge " Please wait while we checking devices...." 9 60 0
    nsfw=`cat /tmp/twrp/exist.info$$ | sed '1d' | awk '{print $1}'`
    if [ -z $nsfw ];then
        whiptail --title " Info " --yesno " Device is not detected , please fix it with replug or enable usb debugging then refresh, or already in fastboot mode " --yes-button "Refresh" --no-button "Already fastboot" 9 60
        case "${?}" in
            0) refresh;;
            1) sleep 0.5;;
        esac
    else
        sleep 0.1
    fi
    (
    b=0
    # fastboot kah
    while [ $b -lt 100 ];do
        b=$(( b + 1 ))
        sleep 0.001
        echo $b
        if [ $b -eq 69 ];then adb devices >/tmp/twrp/fastboot.devices.info$$;fi
    done)| whiptail --title " Wait " --gauge " Detecting devices.....Please wait" 9 60 0
    potato=`cat /tmp/twrp/fastboot.devices.info$$ | sed '1d' | awk '{print $1}'`
    if [ ! -z $potato ];then
        whiptail --title " Info " --yesno " Your $potato device is not in fastboot/bootloader mode, reboot now?" --yes-button "Reboot" --no-button "Manual" 9 60
        case "${?}" in
            0) adb reboot bootloader 2>/dev/null;;
            1) sleep 2.5;;
        esac
    else
        sleep 0.5
    fi
    (
    #fastboot.getBootloaderStatus()
    c=0
    while [ $c -lt 100 ];do
        c=$(( c + 1 ))
        echo $c
        sleep 0.1
        if [ $c -eq 75 ];then fastboot oem device-info 2>/tmp/twrp/bootloader.info$$;fi
    done) | whiptail --title " Wait " --gauge " Please wait while we getting bootloader info" 9 60 0
    bootloaderInfo=`cat /tmp/twrp/bootloader.info$$ | grep 'Device unlocked' | awk '{print $4}'`
    if [ $bootloaderInfo==true ];then
        dialog --title " Info " --yes-label "Yes,next " --no-label "Later,exit" --yesno "Your bootloader is unlocked do you want to flash twrp recovery?" 9 60
        case "${?}" in
            0) chooseRecovery;;
            1) clear;cleanup;exit;;
        esac
    elif [ $bootloaderInfo==false ];then
        whiptail--title " Info " --yesno " Your device's bootloader is locked, do you want to unlock it?" --yes-button "Yes,unlock" --no-button "Later"
        case "${?}" in
            0) ubl;;
            1) clear;cleanup;exit;;
        esac
    fi
}
## DEVICEMENU
twrp_brand_en(){
    while true;do
        whiptail --title " Select brand " --menu " Select your device's brand" 25 78 16\
            "Samsung" ""\
            "Xiaomi" ""\
            "Pixel" "(Google)"\
            "Exit" ""\
            "Back" "" 2>/tmp/twrp/brand.$$
        dev=`cat /tmp/twrp/brand.$$`
        case $dev in
            Samsung) twrp_s_device_en;;
            Xiaomi) twrp_x_device_en;;
            Pixel) twrp_g_device_en;;
            Exit) clear;cleanup;exit;;
            Back) en_gui;;
        esac
    done
}
twrp_x_device_en(){
        while true ;do
            whiptail --title " Select devices " --menu "Select device properly, or your device will remain unusable ex, bootloop or hardbrick" 25 78 16\
                "Santoni" "Redmi 4X"\
                "Prada" "Redmi 4"\
                "Markw" "Redmi 4 Pro"\
                "Rolex" "Redmi 4A" 2>/tmp/twrp/device.$$
            aus=`cat /tmp/twrp/device.$$`
            case $aus in
                Santoni ) codename=santoni
                    setftpLink
                    fastbootgetBootloaderStatus;;
                Prada) codename=prada
                    setftpLink
                    fastbootgetBootloaderStatus;;
                Markw) codename=markw
                    setftpLink
                    fastbootgetBootloaderStatus;;
                Rolez) codename=rolex
                    setftpLink
                    fastbootgetBootloaderStatus;;
                *) whiptail --title " Confirm " --yesno " Back or exit " --yes-button " Back " --no-button " Exit " 9 50
                    case "${?}" in
                        0) twrp_brand_en;;
                        1) clear;cleanup;exit;;
                    esac;;
            esac
        done
    }
        if [ $OSTYPE==linux-gnu ];then
            if [ $usermode != 'root' ];then
                whiptail --title " INFO " --msgbox "please run this script with sudo or root user " 9 50
            else
                if [ -d /tmp/twrp ];then select_usrint;else mkdir /tmp/twrp;fi
            fi
        else
            exit
        fi
