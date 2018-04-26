FROM microsoft/dotnet-framework:4.7.1-windowsservercore-1709

ENV sqllocaldb_download_url https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SqlLocalDB.msi

SHELL ["powershell", "-ExecutionPolicy", "Bypass", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR /

RUN Invoke-WebRequest -Uri $env:sqllocaldb_download_url -OutFile sqllocaldb.msi;

USER ContainerAdministrator

RUN Start-Process -filepath C:\sqllocaldb.msi -ArgumentList "/qn", "IACCEPTSQLLOCALDBLICENSETERMS=YES" -PassThru | Wait-Process

# RUN setx /M PATH "%PATH%;C:\Program Files\Microsoft SQL Server\140\Tools\Binn"

# Download the Build Tools bootstrapper.
RUN Invoke-WebRequest -Uri https://aka.ms/vs/15/release/vs_buildtools.exe -OutFile vs_buildtools.exe

# Install Build Tools excluding workloads and components with known issues.
RUN C:\vs_buildtools.exe --quiet --wait --norestart --nocache \
    --installPath C:\BuildTools \
    --all \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \
    --remove Microsoft.VisualStudio.Component.Windows81SDK

USER ContainerUser

RUN $Env:Path = $Env:Path + ';C:\Program Files\Microsoft SQL Server\140\Tools\Binn';

RUN C:\BuildTools\Common7\Tools\VsDevCmd.bat
