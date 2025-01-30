@echo off

mkdir C:\PodmanVolumes
mkdir C:\PodmanVolumes\timescaledb
mkdir C:\PodmanVolumes\timescaledb\data
icacls C:\PodmanVolumes\timescaledb\data /grant:r *S-1-1-0:(RX) "%USERNAME%":(F)
mkdir C:\PodmanVolumes\Observability_TimescaleDb
mkdir C:\PodmanVolumes\Observability_TimescaleDb\prometheus\prom_data
icacls C:\PodmanVolumes\Observability_TimescaleDb\prometheus\prom_data /grant:r *S-1-1-0:(RX) "%USERNAME%":(F)

echo Completed.
pause