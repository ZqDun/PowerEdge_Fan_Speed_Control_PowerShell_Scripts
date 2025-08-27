# Dell iDRAC Fan Control Script - PowerShell
# ����Ϊ fan_control.ps1������ʱ��ȷ���Թ���Ա������� PowerShell

# ����ipmitool����Ŀ¼
Set-Location "C:\Program Files\Dell\SysMgt\iDRACTools\IPMI"

Write-Host "=== Dell ���������ȿ��ƽű� ===" -ForegroundColor Cyan
Write-Host "���� exit ��ʱ�˳��ű�`n"

# ��һ������ķ�������Ϣ
$last_server_ip = ""
$last_server_user = ""

while ($true) {
    # ��������� IP
    if ($last_server_ip -ne "") {
        $server_ip = Read-Host "����������� IP ��ַ [�ϴ�: $last_server_ip]"
        if ([string]::IsNullOrWhiteSpace($server_ip)) { $server_ip = $last_server_ip }
    } else {
        $server_ip = Read-Host "����������� IP ��ַ"
    }
    if ($server_ip -eq "exit") { break }

    # ����������û���
    if ($last_server_user -ne "") {
        $server_user = Read-Host "������������û��� [�ϴ�: $last_server_user]"
        if ([string]::IsNullOrWhiteSpace($server_user)) { $server_user = $last_server_user }
    } else {
        $server_user = Read-Host "������������û���"
    }
    if ($server_user -eq "exit") { break }

    # �������������
    $server_user_password = Read-Host "���������������" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($server_user_password)
    $server_user_password_plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    # ���浱ǰ����Ϊ����һ�Ρ�
    $last_server_ip = $server_ip
    $last_server_user = $server_user

    while ($true) {
        Write-Host "`n��ѡ�����ģʽ��" -ForegroundColor Yellow
        Write-Host "1. �ֶ�ģʽ"
        Write-Host "2. �Զ�ģʽ"
        Write-Host "���� exit ���ط�����ѡ��"

        $mode = Read-Host "������ѡ��"
        if ($mode -eq "exit") { break }

        if ($mode -eq "1") {
            # �ֶ�ģʽ
            Write-Host "`n�����ֶ�����ģʽ..."
            .\ipmitool.exe -I lanplus -H $server_ip -U $server_user -P $server_user_password_plain raw 0x30 0x30 0x01 0x00

            # ����ת��
            $fan_speed = Read-Host "���������ת�� (1-100, ��λ %��exit ����)"
            if ($fan_speed -eq "exit") { break }

            if ([int]$fan_speed -ge 1 -and [int]$fan_speed -le 100) {
                # ת��Ϊ16����
                $fan_speed_hex = "{0:x2}" -f [int]$fan_speed
                Write-Host "���÷���ת��Ϊ $fan_speed% (hex=$fan_speed_hex)..."
                .\ipmitool.exe -I lanplus -H $server_ip -U $server_user -P $server_user_password_plain raw 0x30 0x30 0x02 0xff 0x$fan_speed_hex
            }
            else {
                Write-Host "��Ч�����룬������ 1-100 ��Χ�ڵ����֣�" -ForegroundColor Red
            }
        }
        elseif ($mode -eq "2") {
            # �Զ�ģʽ
            Write-Host "`n�����Զ�����ģʽ..."
            .\ipmitool.exe -I lanplus -H $server_ip -U $server_user -P $server_user_password_plain raw 0x30 0x30 0x01 0x01
        }
        else {
            Write-Host "��Чѡ����������룡" -ForegroundColor Red
        }
    }
}
Write-Host "`n�ű����˳���" -ForegroundColor Cyan
