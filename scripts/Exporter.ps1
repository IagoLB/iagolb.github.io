$servicio= (Get-service -name node_exporter) -ne $null

if (!$servicio) {
	New-service -name node_exporter -DisplayName node_exporter -BinaryPathName "\\172.19.0.10\exporter\exporter.exe --config.file=\\172.19.0.10\exporter\config.yml" -StartupType Automatic
    Start-Service -name node_exporter
}
	
