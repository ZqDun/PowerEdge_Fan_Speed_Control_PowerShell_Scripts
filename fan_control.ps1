# Dell iDRAC Fan Control Script - PowerShell
# 保存为 fan_control.ps1，运行时请确保以管理员身份启动 PowerShell

# 进入ipmitool所在目录
Set-Location "C:\Program Files\Dell\SysMgt\iDRACTools\IPMI"

Write-Host "=== Dell 服务器风扇控制脚本 ===" -ForegroundColor Cyan
Write-Host "输入 exit 随时退出脚本`n"

# 上一次输入的服务器信息
$last_server_ip = ""
$last_server_user = ""

while ($true) {
    # 输入服务器 IP
    if ($last_server_ip -ne "") {
        $server_ip = Read-Host "请输入服务器 IP 地址 [上次: $last_server_ip]"
        if ([string]::IsNullOrWhiteSpace($server_ip)) { $server_ip = $last_server_ip }
    } else {
        $server_ip = Read-Host "请输入服务器 IP 地址"
    }
    if ($server_ip -eq "exit") { break }

    # 输入服务器用户名
    if ($last_server_user -ne "") {
        $server_user = Read-Host "请输入服务器用户名 [上次: $last_server_user]"
        if ([string]::IsNullOrWhiteSpace($server_user)) { $server_user = $last_server_user }
    } else {
        $server_user = Read-Host "请输入服务器用户名"
    }
    if ($server_user -eq "exit") { break }

    # 输入服务器密码
    $server_user_password = Read-Host "请输入服务器密码" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($server_user_password)
    $server_user_password_plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    # 保存当前输入为“上一次”
    $last_server_ip = $server_ip
    $last_server_user = $server_user

    while ($true) {
        Write-Host "`n请选择风扇模式：" -ForegroundColor Yellow
        Write-Host "1. 手动模式"
        Write-Host "2. 自动模式"
        Write-Host "输入 exit 返回服务器选择"

        $mode = Read-Host "请输入选项"
        if ($mode -eq "exit") { break }

        if ($mode -eq "1") {
            # 手动模式
            Write-Host "`n设置手动风扇模式..."
            .\ipmitool.exe -I lanplus -H $server_ip -U $server_user -P $server_user_password_plain raw 0x30 0x30 0x01 0x00

            # 输入转速
            $fan_speed = Read-Host "请输入风扇转速 (1-100, 单位 %，exit 返回)"
            if ($fan_speed -eq "exit") { break }

            if ([int]$fan_speed -ge 1 -and [int]$fan_speed -le 100) {
                # 转换为16进制
                $fan_speed_hex = "{0:x2}" -f [int]$fan_speed
                Write-Host "设置风扇转速为 $fan_speed% (hex=$fan_speed_hex)..."
                .\ipmitool.exe -I lanplus -H $server_ip -U $server_user -P $server_user_password_plain raw 0x30 0x30 0x02 0xff 0x$fan_speed_hex
            }
            else {
                Write-Host "无效的输入，请输入 1-100 范围内的数字！" -ForegroundColor Red
            }
        }
        elseif ($mode -eq "2") {
            # 自动模式
            Write-Host "`n设置自动风扇模式..."
            .\ipmitool.exe -I lanplus -H $server_ip -U $server_user -P $server_user_password_plain raw 0x30 0x30 0x01 0x01
        }
        else {
            Write-Host "无效选项，请重新输入！" -ForegroundColor Red
        }
    }
}
Write-Host "`n脚本已退出。" -ForegroundColor Cyan
