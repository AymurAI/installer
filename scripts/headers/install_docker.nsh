; Docker Installation Header

!define IMAGE_URL "registry.gitlab.com/collective.ai/datagenero-public/aymurai-api-prod:latest"

!macro InstallDocker
    ; Check if Docker is installed
    ExecWait 'powershell -Command "if (!(Get-Command docker -ErrorAction SilentlyContinue)) { exit 1 } else { exit 0 }"'
    IfErrors docker_install docker_skip_install

    docker_skip_install:
        MessageBox MB_OK "Docker is already installed."
        Goto check_docker_daemon

    docker_install:
        MessageBox MB_OK "Docker is not installed. Installing Docker Desktop..."

        ; Set output path
        SetOutPath $INSTDIR

        ; Download Docker Desktop Installer
        ExecWait 'powershell -Command "Invoke-WebRequest -Uri https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe -OutFile $INSTDIR\DockerDesktopInstaller.exe"'

        ; Install Docker Desktop
        ExecWait '"$INSTDIR\DockerDesktopInstaller.exe"'
        Sleep 5000 ; Wait 5 seconds

        ; Restart the shell
        ExecWait 'powershell -Command "Start-Sleep -Seconds 5; Start-Process powershell -ArgumentList \"-NoExit\", \"-Command\", \"& {exit}\""'

        ; Verify Docker installation
        ExecWait 'powershell -Command "if (!(Get-Command docker -ErrorAction SilentlyContinue)) { exit 1 } else { exit 0 }"'
        IfErrors docker_install_failed

        ; Remove the Docker Desktop installer if Docker installation succeeded
        Delete "$INSTDIR\DockerDesktopInstaller.exe"
        Goto check_docker_daemon

    docker_install_failed:
        MessageBox MB_OK "Docker installation failed. Please try again."
        Abort

    check_docker_daemon:
        ; Check if Docker daemon is running
        ExecWait 'powershell -Command "docker info"'
        IfErrors start_docker docker_image_check

    start_docker:
        MessageBox MB_OK "Docker is not running. Starting Docker Desktop..."
        ExecWait 'powershell -Command "Start-Process -NoNewWindow -FilePath \"C:\Program Files\Docker\Docker\Docker Desktop.exe\""'

        ; Wait for Docker to start
        StrCpy $0 0 ; Initialize counter
        StrCpy $1 30 ; Set timeout (30 attempts)
        loop:
            Sleep 2000 ; Wait 2 seconds before each check
            ExecWait 'powershell -Command "docker info"' $2
            IfErrors +2 +5
            MessageBox MB_OK "Docker is running."
            Goto docker_image_check
            IntOp $0 $0 + 1
            IntCmp $0 $1 docker_failed loop
        
    docker_failed:
        MessageBox MB_OK "Failed to start Docker. Please check your Docker installation."
        Quit

    docker_image_check:
        ; Check if Docker image exists
        ExecWait 'powershell -Command "docker images --format \"{{.Repository}}:{{.Tag}}\" | findstr ${IMAGE_URL}"'
        IfErrors docker_pull_image image_exists

    image_exists:
        MessageBox MB_OK "Docker image is already pulled."
        Goto finish

    docker_pull_image:
        MessageBox MB_OK "Pulling Docker image..."
        ExecWait 'powershell -Command "docker pull ${IMAGE_URL}"'

    finish:
        ; No further actions needed here
!macroend